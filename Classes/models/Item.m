// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ItemShelf for iPhone/iPod touch

  Copyright (c) 2008, ItemShelf Development Team. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Item.h"
#import "AppDelegate.h"
#import "DataModel.h"

@implementation Item

@synthesize pkey, date, shelfId;
@synthesize idType, idString, asin;
@synthesize name, author, manufacturer, productGroup, detailURL, price, tags;
@synthesize memo, imageURL, sorder;
@synthesize imageCache, infoStrings, registeredWithShelf;

- (id)init
{
    self = [super init];
    if (self) {
        self.pkey = -1; // initial
        self.date = [NSDate date];  // 現在時刻で生成
        self.shelfId = 0; // unclassified shelf
        self.idType = -1;
        self.idString = @"";
        self.asin = @"";
        self.name = @"";
        self.author = @"";
        self.manufacturer = @"";
        self.productGroup = @"";
        self.detailURL = @"";
        self.price = @"";
        self.tags = @"";
        self.memo = @"";
        self.imageURL = @"";
        self.sorder = -1;
        self.registeredWithShelf = NO;
    }
    return self;
}

- (void)dealloc
{
    [asin release];
    [idString release];
    [name release];
    [author release];
    [manufacturer release];
    [productGroup release];
    [detailURL release];
    [price release];
    [tags release];
    [memo release];
    [imageURL release];
    [imageCache release];
    [infoStrings release];
	
    [super dealloc];
}

- (BOOL)isEqualToItem:(Item*)item
{
    return [self.asin isEqualToString:item.asin];
}

////////////////////////////////////////////////////////////////////
// Database operation

+ (void)checkTable
{
    Database *db = [Database instance];
    dbstmt *stmt;

    // テーブルの scheme をチェック
    // sqlite_master テーブルから table 一覧と schema をチェックする
    stmt = [db prepare:"SELECT sql FROM sqlite_master WHERE type='table' AND name='Item';"];
    if ([stmt step] != SQLITE_ROW) {
        // テーブル新規作成
        [db exec:"CREATE TABLE Item ("
            "pkey INTEGER PRIMARY KEY,"
            "date TEXT,"
            "itemState INTEGER,"
            "idType INTEGER,"
            "idString TEXT,"
            "asin TEXT,"
            "name TEXT,"
            "author TEXT,"
            "manufacturer TEXT,"
            "productGroup TEXT,"
            "detailURL TEXT,"
            "price TEXT,"
            "tags TEXT,"
            "memo TEXT,"
            "imageURL TEXT,"
            "sorder INTEGER"
            ");"
         ];
    } else {
        // スキーマをチェック
        // TBD

        // Sqlite では列名は変更できないので注意
    }
    [stmt release];
}

- (void)loadRow:(dbstmt *)stmt
{
    self.pkey         = [stmt colInt:0];
    self.date         = [stmt colDate:1];
    self.shelfId      = [stmt colInt:2];
    self.idType       = [stmt colInt:3];
    self.idString     = [stmt colString:4];
    self.asin         = [stmt colString:5];
    self.name         = [stmt colString:6];
    self.author       = [stmt colString:7];
    self.manufacturer = [stmt colString:8];
    self.productGroup = [stmt colString:9];
    self.detailURL    = [stmt colString:10];
    self.price        = [stmt colString:11];
    self.tags         = [stmt colString:12];
    self.memo         = [stmt colString:13];
    self.imageURL     = [stmt colString:14];
    self.sorder       = [stmt colInt:15];

    self.registeredWithShelf = YES;

    NSLog(@"%d %d %@", self.pkey, self.sorder, self.name);
}

- (void)insert
{
    Database *db = [Database instance];
	
    [db beginTransaction];
	
    const char *sql = "INSERT INTO Item VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    dbstmt *stmt = [db prepare:sql];

    [stmt bindDate:0 val:date];
    [stmt bindInt:1 val:shelfId];
    [stmt bindInt:2 val:idType];
    [stmt bindString:3 val:idString];
    [stmt bindString:4 val:asin];
    [stmt bindString:5 val:name];
    [stmt bindString:6 val:author];
    [stmt bindString:7 val:manufacturer];
    [stmt bindString:8 val:productGroup];
    [stmt bindString:9 val:detailURL];
    [stmt bindString:10 val:price];
    [stmt bindString:11 val:tags];
    [stmt bindString:12 val:memo];
    [stmt bindString:13 val:imageURL];
    [stmt bindInt:14 val:sorder];
    [stmt step];
    [stmt release];

    self.pkey = [db	lastInsertRowId];
    self.sorder = pkey;  // 初期並び順は Primary Key と同じにしておく(最大値)
    [self updateSorder];
	
    [db commitTransaction];
}

- (void)delete
{
    [self deleteImageFile];

    Database *db = [Database instance];

    const char *sql = "DELETE FROM Item WHERE pkey = ?;";
    dbstmt *stmt = [db prepare:sql];

    [stmt bindInt:0 val:pkey];
    [stmt step];
    [stmt release];
}

- (void)changeShelf:(int)shelf
{
    if (self.shelfId == shelf) {
        return; // do nothing
    }
    self.shelfId = shelf;

    if (self.pkey < 0) {
        return;	 // fail safe
    }

    const char *sql = "UPDATE Item SET itemState = ? WHERE pkey = ?;";
    dbstmt *stmt = [[Database instance] prepare:sql];

    [stmt bindInt:0 val:shelfId];
    [stmt bindInt:1 val:pkey];
    [stmt step];
    [stmt release];
}

- (void)updateSorder
{
    const char *sql = "UPDATE Item SET sorder = ? WHERE pkey = ?;";
    dbstmt *stmt = [[Database instance] prepare:sql];
	
    [stmt bindInt:0 val:sorder];
    [stmt bindInt:1 val:pkey];
    [stmt step];
    [stmt release];
}

////////////////////////////////////////////////////////////////////
// Database operation


- (UIImage *)getNoImage
{
    static UIImage *noImage = nil;
	
    if (noImage == nil) {
        noImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NoImage" ofType:@"png"]];
        [noImage retain];
    }
    return noImage;	
}

static NSMutableArray *agingArray = nil;

+ (void)clearAllImageCache
{
    NSLog(@"clearAllImageCache - maybe low memory");
	
    for (Item *item in agingArray) {
        item.imageCache = nil;
    }
    [agingArray removeAllObjects];
}

- (void)refreshImageCache
{
    if (agingArray == nil) {
        agingArray = [[NSMutableArray alloc] initWithCapacity:MAX_IMAGE_CACHE_AGE];
    }
	
    [agingArray removeObject:self];
    [agingArray addObject:self];
}

- (void)putImageCache
{
    if (agingArray == nil) {
        agingArray = [[NSMutableArray alloc] initWithCapacity:MAX_IMAGE_CACHE_AGE];
    }
	
    [agingArray addObject:self];

    // aging 処理
    if (agingArray.count > MAX_IMAGE_CACHE_AGE) {
        Item *expire = [agingArray objectAtIndex:0];
        expire.imageCache = nil;
        [agingArray removeObjectAtIndex:0];
        //LOG(@"image expire");
    }
}	

// イメージをダウンロードする
- (UIImage *)getImage:(id<ItemDelegate>)delegate
{
    // No image の場合
    if (imageURL == nil || imageURL.length == 0) {
        return [self getNoImage];
    }

    // メモリキャッシュあり
    if (imageCache != nil) {
        [self refreshImageCache];
        return imageCache;
    }

    // ダウンロード中は返せない
    if (buffer != nil) {
        return nil;
    }

    // ファイルキャッシュあり？
    NSString *imagePath = [self imagePath];
    if (imagePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
#if 1
        // キャッシュファイルあり
        self.imageCache = [UIImage imageWithContentsOfFile:imagePath];
        [self putImageCache];
        return self.imageCache;
#else
        if (delegate == nil) return nil;
        // キャッシュファイルをバックグランドでロードする
        itemDelegate = delegate;
        NSInvocationOperation *op = [[[NSInvocationOperation alloc] 
                                         initWithTarget:self
                                         selector:@selector(taskLoadImage:) 
                                         object:nil] autorelease];
        [[AppDelegate sharedOperationQueue] addOperation:op];
        return nil;
#endif
    }

    if (delegate == nil) return nil;
	
    // キャッシュなし : イメージをネットワークからダウンロード開始する
    itemDelegate = delegate;
	
    NSURLRequest *req =
        [NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]
                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                      timeoutInterval:30.0];

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        buffer = [[NSMutableData data] retain];
        LOG(@"Loading image: %@", imageURL);
        [conn release];
    }
	
    return nil;
}

#if 0
- (void)taskLoadImage:(id)dummy
{
    // TBD 排他制御
    self.imageCache = [UIImage imageWithContentsOfFile:[self imagePath]];
    [self putImageCache];

    if (itemDelegate) {
        [NSThread performSelectorOnMainThread:@selector(itemDidFinishDownloadImage:) 
                  withObject:itemDelegate];
    }
}
#endif

// NSURLConnection delegates
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    LOG(@"Loading image done");
	
    self.imageCache = [UIImage imageWithData:buffer];
	
    // キャッシュファイルを書き出す
    NSString *imagePath = [self imagePath];
    if (imagePath) {
        [buffer writeToFile:imagePath atomically:NO];
    }
	
    [buffer release];
    buffer = nil;
	
    if (itemDelegate) {
        [itemDelegate itemDidFinishDownloadImage:self];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    [buffer release];
    buffer = nil;
	
    LOG(@"Connection failed. Error - %@ %@",
        [error localizedDescription],
        [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)cancelDownload
{
    itemDelegate = nil;
}

// 画像ファイル名を決定
- (NSString*)imageFileName
{
    if (pkey < 0) return nil;

    NSString *filename = [NSString stringWithFormat:@"img-%d", self.pkey];
    return filename;
}

// 画像ダウンロードパスを決定
- (NSString *)imagePath
{
    if (pkey < 0) return nil;
	
    return [AppDelegate pathOfDataFile:[self imageFileName]];
}

// 画像ファイルを消去
- (void)deleteImageFile
{
    NSString *path = [self imagePath];
    if (path == nil) return;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:NULL];
}

@end

// Generated by O/R mapper generator ver 1.0

#import "Database.h"
#import "ItemBase.h"

@implementation ItemBase

@synthesize date = mDate;
@synthesize shelfId = mShelfId;
@synthesize serviceId = mServiceId;
@synthesize idString = mIdString;
@synthesize asin = mAsin;
@synthesize name = mName;
@synthesize author = mAuthor;
@synthesize manufacturer = mManufacturer;
@synthesize category = mCategory;
@synthesize detailURL = mDetailURL;
@synthesize price = mPrice;
@synthesize tags = mTags;
@synthesize memo = mMemo;
@synthesize imageURL = mImageURL;
@synthesize sorder = mSorder;
@synthesize star = mStar;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [mDate release];
    [mIdString release];
    [mAsin release];
    [mName release];
    [mAuthor release];
    [mManufacturer release];
    [mCategory release];
    [mDetailURL release];
    [mPrice release];
    [mTags release];
    [mMemo release];
    [mImageURL release];
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
        @"date", @"TEXT",
        @"itemState", @"INTEGER",
        @"idType", @"INTEGER",
        @"idString", @"TEXT",
        @"asin", @"TEXT",
        @"name", @"TEXT",
        @"author", @"TEXT",
        @"manufacturer", @"TEXT",
        @"productGroup", @"TEXT",
        @"detailURL", @"TEXT",
        @"price", @"TEXT",
        @"tags", @"TEXT",
        @"memo", @"TEXT",
        @"imageURL", @"TEXT",
        @"sorder", @"INTEGER",
        @"star", @"INTEGER",
        nil];

    return [super migrate:columnTypes primaryKey:@"pkey"];
}

/**
  @brief allocate entry
*/
+ (id)allocator
{
    id e = [[[ItemBase alloc] init] autorelease];
    return e;
}

#pragma mark Read operations

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (ItemBase *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM Item WHERE pkey = ?;"];
    [stmt bindInt:0 val:pid];
    if ([stmt step] != SQLITE_ROW) {
        return nil;
    }

    ItemBase *e = [self allocator];
    [e _loadRow:stmt];
 
    return e;
}

/**
  @brief get all records matche the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (NSMutableArray *)find_cond:(NSString *)cond
{
    dbstmt *stmt = [self gen_stmt:cond];
    NSMutableArray *array = [self find_stmt:stmt];
    return array;
}

/**
  @brief create dbstmt

  @param s condition
  @return dbstmt
*/
+ (dbstmt *)gen_stmt:(NSString *)cond
{
    NSString *sql;
    if (cond == nil) {
        sql = @"SELECT * FROM Item;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM Item %@;", cond];
    }  
    dbstmt *stmt = [[Database instance] prepare:sql];
    return stmt;
}

/**
  @brief get all records matche the conditions

  @param stmt Statement
  @return array of records
*/
+ (NSMutableArray *)find_stmt:(dbstmt *)stmt
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

    while ([stmt step] == SQLITE_ROW) {
        ItemBase *e = [self allocator];
        [e _loadRow:stmt];
        [array addObject:e];
    }
    return array;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.date = [stmt colString:1];
    self.shelfId = [stmt colInt:2];
    self.serviceId = [stmt colInt:3];
    self.idString = [stmt colString:4];
    self.asin = [stmt colString:5];
    self.name = [stmt colString:6];
    self.author = [stmt colString:7];
    self.manufacturer = [stmt colString:8];
    self.category = [stmt colString:9];
    self.detailURL = [stmt colString:10];
    self.price = [stmt colString:11];
    self.tags = [stmt colString:12];
    self.memo = [stmt colString:13];
    self.imageURL = [stmt colString:14];
    self.sorder = [stmt colInt:15];
    self.star = [stmt colInt:16];

    mIsNew = NO;
}

#pragma mark Create operations

- (void)_insert
{
    [super _insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    //[db beginTransaction];
    stmt = [db prepare:@"INSERT INTO Item VALUES(NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"];

    [stmt bindString:0 val:mDate];
    [stmt bindInt:1 val:mShelfId];
    [stmt bindInt:2 val:mServiceId];
    [stmt bindString:3 val:mIdString];
    [stmt bindString:4 val:mAsin];
    [stmt bindString:5 val:mName];
    [stmt bindString:6 val:mAuthor];
    [stmt bindString:7 val:mManufacturer];
    [stmt bindString:8 val:mCategory];
    [stmt bindString:9 val:mDetailURL];
    [stmt bindString:10 val:mPrice];
    [stmt bindString:11 val:mTags];
    [stmt bindString:12 val:mMemo];
    [stmt bindString:13 val:mImageURL];
    [stmt bindInt:14 val:mSorder];
    [stmt bindInt:15 val:mStar];
    [stmt step];

    self.pid = [db lastInsertRowId];

    //[db commitTransaction];
    mIsNew = NO;
}

#pragma mark Update operations

- (void)_update
{
    [super _update];

    Database *db = [Database instance];
    //[db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE Item SET "
        "date = ?"
        ",itemState = ?"
        ",idType = ?"
        ",idString = ?"
        ",asin = ?"
        ",name = ?"
        ",author = ?"
        ",manufacturer = ?"
        ",productGroup = ?"
        ",detailURL = ?"
        ",price = ?"
        ",tags = ?"
        ",memo = ?"
        ",imageURL = ?"
        ",sorder = ?"
        ",star = ?"
        " WHERE pkey = ?;"];
    [stmt bindString:0 val:mDate];
    [stmt bindInt:1 val:mShelfId];
    [stmt bindInt:2 val:mServiceId];
    [stmt bindString:3 val:mIdString];
    [stmt bindString:4 val:mAsin];
    [stmt bindString:5 val:mName];
    [stmt bindString:6 val:mAuthor];
    [stmt bindString:7 val:mManufacturer];
    [stmt bindString:8 val:mCategory];
    [stmt bindString:9 val:mDetailURL];
    [stmt bindString:10 val:mPrice];
    [stmt bindString:11 val:mTags];
    [stmt bindString:12 val:mMemo];
    [stmt bindString:13 val:mImageURL];
    [stmt bindInt:14 val:mSorder];
    [stmt bindInt:15 val:mStar];
    [stmt bindInt:16 val:mPid];

    [stmt step];
    //[db commitTransaction];
}

#pragma mark Delete operations

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM Item WHERE pkey = ?;"];
    [stmt bindInt:0 val:mPid];
    [stmt step];
}

/**
  @brief Delete all records
*/
+ (void)delete_cond:(NSString *)cond
{
    Database *db = [Database instance];

    if (cond == nil) {
        cond = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Item %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [ItemBase delete_cond:nil];
}

#pragma mark Internal functions

+ (NSString *)tableName
{
    return @"Item";
}

@end

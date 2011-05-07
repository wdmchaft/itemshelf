// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestUtility.h"

@interface ShelfTest : SenTestCase {
    Database *db;
}
@end

@implementation ShelfTest

- (void)setUp
{
    db = [Database instance];
}

- (void)testAlloc
{
}

// テーブルがないときにテーブルが作成されること
- (void)testInitDb
{
    // テーブルを削除する
    [db exec:@"DROP TABLE Shelf;"];
    [Database shutdown];

    // 再度オープンする (ここでテーブルができるはず）
    db = [Database instance];
	
    // テーブル定義確認
    dbstmt *stmt = [db prepare:@"SELECT sql FROM sqlite_master WHERE type='table' AND name='Shelf';"];
    int result = [stmt step];
    AssertEqualInt(SQLITE_ROW, result);
    NSString *sql = [stmt colString:0];

    // TBD: ここでテーブル定義をチェック
    NSLog(@"%@", sql);
}

// テーブルのアップグレードテスト
- (void)testUpgradeDbFrom1_0
{
    // ver 1.0 テーブルを作成
    [db exec:@"DROP TABLE Shelf;"];
    [db exec:@"CREATE TABLE Shelf (pkey INTEGER PRIMARY KEY, name TEXT, sorder INTEGER);"];
    [Database shutdown];

    // 再ロード
    db = [Database instance];

    // テーブル定義確認
    dbstmt *stmt = [db prepare:@"SELECT sql FROM sqlite_master WHERE type='table' AND name='Shelf';"];
    ASSERT(SQLITE_ROW == [stmt step]);
    NSString *sql = [stmt colString:0];

    // ここでテーブル定義をチェック
    NSLog(@"%@", sql);
    NSRange range = [sql rangeOfString:@"manufacturerFilter"];
    ASSERT(range.location != NSNotFound);
}	

- (void)assertShelfEquals:(Shelf*)i with:(Shelf*)j
{
    AssertEqualInt(j.pid, i.pid);
    AssertEqualInt(j.shelfType, i.shelfType);
    AssertEqualInt(j.sorder, i.sorder);
    AssertEquals(j.name, i.name);
    AssertEquals(j.titleFilter, i.titleFilter);
    AssertEquals(j.authorFilter, i.authorFilter);
    AssertEquals(j.manufacturerFilter, i.manufacturerFilter);
}

// loadRow テスト
#if 0
- (void)testLoadRow
{
    [TestUtility initializeTestDatabase];

    dbstmt *stmt = [db prepare:@"SELECT * FROM Shelf WHERE pkey = ?;"];
    for (int i = 1; i <= NUM_TEST_SHELF; i++) {
        [stmt bindInt:0 val:i];
        ASSERT(SQLITE_ROW == [stmt step]);

        Shelf *shelf = [[Shelf alloc] init];
        [shelf loadRow:stmt];

        // 比較対象データ
        Shelf *testShelf = [TestUtility createTestShelf:i];

        [self assertShelfEquals:shelf with:testShelf];

        [shelf release];
        [testShelf release];

        [stmt reset];	
    }
}
#endif

// insert テスト
// delete テスト
// updateName テスト
// updateSorder テスト
// updateSmartFilters テスト

// addItem
// removeItem
// containsItem
// enumeration テスト
// sortBySorder テスト
	
@end
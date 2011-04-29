// Generated by O/R mapper generator ver 1.0

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@class ShelfBase;

@interface ShelfBase : ORRecord {
    NSString* mName;
    int mSorder;
    int mShelfType;
    NSString* mTitleFilter;
    NSString* mAuthorFilter;
    NSString* mManufacturerFilter;
    NSString* mTagsFilter;
    int mStarFilter;
}

@property(nonatomic,retain) NSString* name;
@property(nonatomic,assign) int sorder;
@property(nonatomic,assign) int shelfType;
@property(nonatomic,retain) NSString* titleFilter;
@property(nonatomic,retain) NSString* authorFilter;
@property(nonatomic,retain) NSString* manufacturerFilter;
@property(nonatomic,retain) NSString* tagsFilter;
@property(nonatomic,assign) int starFilter;

+ (BOOL)migrate;

// CRUD (Create/Read/Update/Delete) operations

// Create/update operations
// Note: You should use 'save' method
- (void)_insert;
- (void)_update;

// Read operations (Finder)
+ (ShelfBase *)find:(int)pid;
+ (ShelfBase *)find_by_name:(NSString*)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_name:(NSString*)key;
+ (ShelfBase *)find_by_sorder:(int)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_sorder:(int)key;
+ (ShelfBase *)find_by_type:(int)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_type:(int)key;
+ (ShelfBase *)find_by_titleFilter:(NSString*)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_titleFilter:(NSString*)key;
+ (ShelfBase *)find_by_authorFilter:(NSString*)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_authorFilter:(NSString*)key;
+ (ShelfBase *)find_by_manufacturerFilter:(NSString*)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_manufacturerFilter:(NSString*)key;
+ (ShelfBase *)find_by_tagsFilter:(NSString*)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_tagsFilter:(NSString*)key;
+ (ShelfBase *)find_by_starFilter:(int)key cond:(NSString*)cond;
+ (ShelfBase *)find_by_starFilter:(int)key;

+ (NSMutableArray *)find_all:(NSString *)cond;

+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (ShelfBase *)find_first_stmt:(dbstmt *)stmt;
+ (NSMutableArray *)find_all_stmt:(dbstmt *)stmt;

// Delete operations
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// internal functions
+ (NSString *)tableName;
- (void)_loadRow:(dbstmt *)stmt;

@end

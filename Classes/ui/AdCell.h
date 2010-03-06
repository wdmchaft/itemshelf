// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  AdCell.h
//

#import <UIKit/UIKit.h>

#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"

#define AFMA_CLIENT_ID  @"ca-mb-app-pub-4621925249922081"
#define AFMA_CHANNEL_IDS @"6284604915"
#define AFMA_KEYWORDS  @"本,書籍,通販,ショッピング,book,shopping"
#define AFMA_IS_TEST 1

@interface AdCell : UITableViewCell <GADAdViewControllerDelegate> {
    GADAdViewController *adViewController;
    UIViewController *parentViewController;
}

@property(nonatomic,assign) UIViewController *parentViewController;

+ (AdCell *)adCell:(UITableView *)tableView parentViewController:(UIViewController *)parentViewController;
+ (CGFloat)adCellHeight;

+ (NSDictionary *)adAttributes;

@end

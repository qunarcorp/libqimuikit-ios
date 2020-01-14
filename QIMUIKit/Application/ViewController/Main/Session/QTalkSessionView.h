//
//  QTalkSessionView.h
//  STChatIphone
//
//  Created by Qunar-Lu on 16/7/20.
//
//

#import "STIMCommonUIFramework.h"

@class STIMMainVC;

@interface QTalkSessionView : UIView

@property(nonatomic, strong, readonly) UITableView *tableView;

@property(nonatomic, assign) BOOL needUpdateNotReadList;

@property(nonatomic, assign) BOOL notShowHeader;

@property(nonatomic, assign) BOOL showNotReadList;

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame withRootViewController:(STIMMainVC *)rootVc;

- (void)prepareNotReaderIndexPathList;

- (void)reloadSessionViewFrame;

- (void)scrollToNotReadMsg;

- (void)sessionViewWillAppear;

- (void)updateOtherPlatFrom:(BOOL)flag;

- (void)setSessionViewHeader:(UIView *)headerView;

- (void)updateSessionHeaderViewWithShowNetWorkBar:(BOOL)showNetWorkBar;

- (UIViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)sessionViewTitleDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

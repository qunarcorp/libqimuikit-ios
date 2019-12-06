//
//  QIMMainVC.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/15.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMMainVC.h"
#import "QIMUUIDTools.h"
#import "UIApplication+QIMApplication.h"
#import "QIMCustomTabBar.h"
#import "QTalkSessionView.h"
#import "QIMUserListView.h"
#import "QIMMessageHelperVC.h"
#import "QIMGroupChatVC.h"
#import "QIMIconInfo.h"
#import "UIImage+ImageEffects.h"
#import "QIMNavPushTransition.h"
#import "QIMNavPopTransition.h"
#import "QIMRemoteNotificationManager.h"
#import "QIMAddIndexViewController.h"
#import "QIMZBarViewController.h"
#import "QIMJumpURLHandle.h"
#import "QIMMineTableView.h"
#import "QIMWorkFeedView.h"
#import "QIMNavBackBtn.h"
#import "QIMArrowTableView.h"
#import "QIMRNDebugConfigVc.h"
#import "NSBundle+QIMLibrary.h"
#if __has_include("RNSchemaParse.h")

#import "QTalkSuggestRNJumpManager.h"

#endif
#if __has_include("QIMAutoTracker.h")

#import "QIMAutoTracker.h"

#endif

#import "UIView+QIMToast.h"
#import "QIMUpdateAlertView.h"

#define kTabBarHeight   49

@interface QIMMainVC () <QIMCustomTabBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIViewControllerPreviewingDelegate, UINavigationControllerDelegate, UISearchResultsUpdating, QIMUpdateAlertViewDelegate, SelectIndexPathDelegate> {

    QIMCustomTabBar *_tabBar;
    UIView *_contentView;
    UIImageView *_blurImageView;

    UIView *_loadingView;
    UIActivityIndicatorView *_loadingActivityView;
    BOOL _needLoading;

}

@property(nonatomic, strong) QTalkSessionView *sessionView;
@property(nonatomic, strong) UIView *travelView;
@property(nonatomic, strong) UIView *userListView;
@property(nonatomic, strong) UIView *rnSuggestView;
@property(nonatomic, strong) QIMWorkFeedView *momentView;
@property(nonatomic, strong) UIView *mineView;
@property(nonatomic, strong) UIViewController *mineVC;

@property(nonatomic, strong) UIButton *searchDemissionBtn;

@property(nonatomic, strong) NSMutableArray *totalTabBarIndexs;

@property(nonatomic, strong) NSMutableArray *totalTabBarArray;

@property(nonatomic, strong) QTalkViewController *currentPreViewVc;

#pragma mark - Navigation

@property(nonatomic, strong) NSArray *moreActionArray;  //右上角更多列表

@property(nonatomic, strong) UIButton *moreBtn;     //更多按钮

@property(nonatomic, strong) QIMArrowTableView *arrowPopView;

@property(nonatomic, strong) UIButton *addFriendBtn;
@property (nonatomic, strong) UIButton *rnDebugConfigBtn;

@property(nonatomic, strong) UIButton *scanBtn;

@property(nonatomic, strong) UIButton *searchMomentBtn;
@property(nonatomic, strong) UIButton *momentBtn;

@property(nonatomic, strong) UIButton *settingBtn;

@property(nonatomic, copy) NSString *navTitle;

@property(nonatomic, copy) NSString *appNetWorkTitle;

@property(nonatomic, assign) BOOL showNetWorkBar;

@property(nonatomic, strong) dispatch_queue_t reloadCountQueue;

@property (nonatomic, assign) BOOL notVisibleReload;

@end

static BOOL _mainVCReShow = YES;

@implementation QIMMainVC

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_searchBar sizeToFit];
        _searchBar.placeholder = [NSBundle qim_localizedStringForKey:@"search_bar_placeholder"];
        [_searchBar setTintColor:[UIColor spectralColorBlueColor]];
        if ([_searchBar respondsToSelector:@selector(setBarTintColor:)]) {
            [_searchBar setBarTintColor:[UIColor qim_colorWithHex:0xEEEEEE alpha:1.0]];
        }
        [_searchBar setBackgroundColor:[UIColor qim_colorWithHex:0xEEEEEE]];
    }
    return _searchBar;
}

+ (void)setMainVCReShow:(BOOL)mainVCReShow {
    _mainVCReShow = mainVCReShow;
    if (mainVCReShow) {
        [[NSNotificationCenter defaultCenter] removeObserver:__mainVc];
        __mainVc = nil;
        __onceMainToken = 0;
    }
}

+ (BOOL)getMainVCReShow {
    return _mainVCReShow;
}

+ (BOOL)checkMainVC {
    return __mainVc != nil;
}

static QIMMainVC *__mainVc = nil;
static dispatch_once_t __onceMainToken;
+ (instancetype)sharedInstanceWithSkipLogin:(BOOL)skipLogin {
    dispatch_once(&__onceMainToken, ^{
        __mainVc = [[QIMMainVC alloc] init];
    });
    __mainVc.skipLogin = skipLogin;
    return __mainVc;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainVCReShow = NO;
    /*
    if (@available(iOS 10.3, *)) {
        [self changeIcon];
    }
    */
    self.reloadCountQueue = dispatch_queue_create("Reload Main Read Count", DISPATCH_QUEUE_SERIAL);
    [self registerNSNotifications];
//    self.view.width = [[QIMWindowManager shareInstance] getPrimaryWidth];
    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setAutoresizesSubviews:YES];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self initRootView];
    [self initTabbar];
    if (_needLoading) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        [_loadingView setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.45]];
        [self.view addSubview:_loadingView];

        _loadingActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_loadingActivityView setHidesWhenStopped:YES];
        [_loadingActivityView startAnimating];
        [_loadingActivityView setCenter:_loadingView.center];
        [_loadingView addSubview:_loadingActivityView];
    }
    if (self.skipLogin) {
        [self autoLogin];
    }
#if __has_include("RNSchemaParse.h")
    [[QTalkSuggestRNJumpManager sharedInstance] setOwnerVC:self];
#endif
}

- (void)registerNSNotifications {
    //登录成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotify:) name:kNotificationLoginState object:nil];
    //更新App未读数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotReadCount) name:kMsgNotReadCountChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotReadCount) name:kNotificationSessionListUpdate object:nil];
    //更新骆驼帮未读数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExploreNotReadCount:) name:kExploreNotReadCountChange object:nil];
    //更新驼圈未读数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWorkFeedNotReadCount:) name:kNotifyNotReadWorkCountChange object:nil];
    //更新App网络状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWorkStateChange:) name:kAppWorkStateChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifySelectTab:) name:kNotifySelectTab object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSwitchAccount:) name:kNotifySwichUserSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherPlatformLogin:) name:kPBPresenceCategoryNotifyOnline object:nil];

    //上传日志进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUpdateProgress:) name:KNotifyUploadProgress object:nil];
 
    //上传日志
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitLog:) name:kNotifySubmitLog object:nil];
    //销毁群通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChatRoomDestroy:) name:kChatRoomDestroy object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWorkFeedNotifyConfig:) name:kNotifyUpdateNotifyConfig object:nil];
    
    //更新提醒
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppVersion:) name:kNotifyUpdateAppVersion object:nil];
}

- (NSString *)navTitle {
    if (!_navTitle) {
        NSString *title = [NSBundle qim_localizedStringForKey:@"Chat"];
        _navTitle = title;
    }
    return _navTitle;
}

- (void)changeIcon {
    if ([UIApplication sharedApplication].supportsAlternateIcons) {
        QIMVerboseLog(@"this app can change app icon");
    } else {
        QIMVerboseLog(@"sorry,this app can not change app icon");
        return;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval nowTime = [date timeIntervalSince1970];

    //截止二月二，龙抬头
    NSString *iconName = [[UIApplication sharedApplication] alternateIconName];
    if (nowTime >= 1521302400) {
        [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:^(NSError *_Nullable error) {
            if (error) {
                QIMVerboseLog(@"set icon error: %@", error);
            }
            QIMVerboseLog(@"current icon's name -> %@", [[UIApplication sharedApplication] alternateIconName]);
        }];
    } else {
        if ([iconName isEqualToString:@"HappyNewYear"]) {

        } else {
            [[UIApplication sharedApplication] setAlternateIconName:@"HappyNewYear" completionHandler:^(NSError *_Nullable error) {
                if (error) {
                    QIMVerboseLog(@"set icon error: %@", error);
                }
                QIMVerboseLog(@"current icon's name -> %@", [[UIApplication sharedApplication] alternateIconName]);
            }];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLoadingViewWithHidden:(BOOL)hidden {
    _needLoading = !hidden;
    [_loadingView setHidden:hidden];
    if (hidden == NO) {
        [_loadingActivityView startAnimating];
    } else {
        [_loadingActivityView stopAnimating];
    }
}

- (void)updateNotReadCount {
    UIViewController *vc = [UIApplication sharedApplication].visibleViewController;
    if (![vc isKindOfClass:[self class]]) {
     //不展示在当前屏幕时不刷新View
        self.notVisibleReload = YES;
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.reloadCountQueue, ^{
        NSUInteger appNotReaderCount = [[QIMKit sharedInstance] getAppNotReaderCount];
        NSInteger appNotRemindCount = [[QIMKit sharedInstance] getNotRemindNotReaderCount];
        NSInteger appCount = appNotReaderCount - appNotRemindCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tabBar setBadgeNumber:appCount ByItemIndex:0];
            if (appCount <= 0) {
                weakSelf.navTitle = [NSBundle qim_localizedStringForKey:@"Chat"];
                [weakSelf.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName: [UIColor qim_colorWithHex:0x333333]}];
                [[QIMNavBackBtn sharedInstance] updateNotReadCount:0];
            } else {
//                NSString *appName = [QIMKit getQIMProjectTitleName];
//                weakSelf.navTitle = [NSString stringWithFormat:@"%@(%ld)", appName, (long)appCount];
                weakSelf.navTitle = [NSBundle qim_localizedStringForKey:@"Chat"];
                [weakSelf.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName: [UIColor qim_colorWithHex:0x333333]}];
                [[QIMNavBackBtn sharedInstance] updateNotReadCount:appCount];
            }
            [weakSelf updateNavBarAppCount];
            [weakSelf.sessionView setNeedUpdateNotReadList:YES];
        });
    });
    self.notVisibleReload = NO;
}

- (void)otherPlatformLogin:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL online = [notify.object boolValue];
        [self.sessionView updateOtherPlatFrom:online];
    });
}

- (void)appWorkStateChange:(NSNotification *)notify {
    QIMVerboseLog(@"收到通知中心appWorkStateChange通知 : %@", notify);

    NSInteger appworkState = [notify.object integerValue];
    switch (appworkState) {
        case AppWorkState_Logout: {
            self.appNetWorkTitle = [NSBundle qim_localizedStringForKey:@"Not_Logged_In"];
            self.showNetWorkBar = NO;
        }
            break;
        case AppWorkState_Logining: {
            self.appNetWorkTitle = [NSBundle qim_localizedStringForKey:@"Connecting…"];//@"连接中...";
            self.showNetWorkBar = NO;
            [self.sessionView updateSessionHeaderViewWithShowNetWorkBar:NO];
        }
            break;
        case AppWorkState_Updating: {
            self.appNetWorkTitle = [NSBundle qim_localizedStringForKey:@"Loading…"];//@"接收中...";
            self.showNetWorkBar = NO;
            [self.sessionView updateSessionHeaderViewWithShowNetWorkBar:NO];
        }
            break;
        case AppWorkState_NotNetwork: {
            self.appNetWorkTitle = [NSBundle qim_localizedStringForKey:@"Disconnected"];
            self.showNetWorkBar = YES;
            [self.sessionView updateSessionHeaderViewWithShowNetWorkBar:YES];
        }
            break;
        case AppWorkState_NetworkNotWork: {
            self.appNetWorkTitle = [NSBundle qim_localizedStringForKey:@"No_network_available"];
            self.showNetWorkBar = YES;
            [self.sessionView updateSessionHeaderViewWithShowNetWorkBar:YES];
        }
            break;
        case AppWorkState_Upgrading: {
            self.appNetWorkTitle = [NSBundle qim_localizedStringForKey:@"Updating_data"];
            self.showNetWorkBar = YES;
        }
        default: {
            self.appNetWorkTitle = nil;
            self.showNetWorkBar = NO;
            [self.sessionView updateSessionHeaderViewWithShowNetWorkBar:NO];
        }
            break;
    }
    [self updateNavBarAppCount];
}

- (void)updateNavBarAppCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        //只有列表页更新
        if (_tabBar.selectedIndex == 0) {
            if (self.appNetWorkTitle) {
                [self.navigationItem setTitle:self.appNetWorkTitle];
                [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName: [UIColor qim_colorWithHex:0x333333]}];
            } else {
                [self.navigationItem setTitle:self.navTitle];
                [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName: [UIColor qim_colorWithHex:0x333333]}];
            }
        }
    });
}

- (void)updateExploreNotReadCount:(NSNotification *)notify {
    QIMVerboseLog(@"收到通知中心updateExploreNotReadCount通知 : ", notify);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL count = NO;
        if ([QIMKit getQIMProjectType] != QIMProjectTypeQChat) {
            if (notify) {
                count = [notify.object boolValue];
            }
        } else if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat && [QIMKit sharedInstance].isMerchant) {
            [[QIMKit sharedInstance] getLeaveMsgNotReaderCountWithCallBack:^(NSInteger num) {
                count = num;
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([QIMKit getQIMProjectType] != QIMProjectTypeQChat) {
                // 发现页移动小红点 到 第二页
                [_tabBar setBadgeNumber:count ByItemIndex:2 showNumber:NO];
            } else if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat && [QIMKit sharedInstance].isMerchant) {
                [_tabBar setBadgeNumber:count ByItemIndex:2 showNumber:NO];
            }
        });
    });
}

- (void)updateWorkFeedNotReadCount:(NSNotification *)notify {
    BOOL oldAuthSign = [[[QIMKit sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"] boolValue];
    BOOL checkAuthSignKey = [[QIMKit sharedInstance] containsObjectForKey:@"kUserWorkFeedEntrance"];
    if (checkAuthSignKey == NO) {
        oldAuthSign = YES;
    }
    BOOL containMomentView = [self.totalTabBarIndexs containsObject:@"tab_title_moment"];
    if (!oldAuthSign || !containMomentView) {
        return;
    }
    QIMVerboseLog(@"收到驼圈updateWorkFeedNotReadCount通知 : %@", notify);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL workMoment = [[QIMKit sharedInstance] getLocalWorkMomentNotifyConfig];
        if (workMoment == YES) {
            NSDictionary *newWorkMomentNotify = notify.object;
            //新帖子通知
            BOOL newWorkMoment = [[newWorkMomentNotify objectForKey:@"newWorkMoment"] boolValue];
            NSInteger newWorkNoticeCount = [[newWorkMomentNotify objectForKey:@"newWorkNoticeCount"] integerValue];
            if (newWorkNoticeCount > 0) {
                //有未读消息时候展示数字
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tabBar setBadgeNumber:newWorkNoticeCount ByItemIndex:3 showNumber:YES];
                });
            } else {
                NSInteger notReadCount = [[QIMKit sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(QIMWorkFeedNotifyTypeComment), @(QIMWorkFeedNotifyTypePOSTAt), @(QIMWorkFeedNotifyTypeCommentAt)]];
                if (notReadCount > 0) {
                    //过来的通知不是新评论时，优先展示未读数
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tabBar setBadgeNumber:notReadCount ByItemIndex:3 showNumber:YES];
                    });
                } else {
                    //过来的通知不是新评论时且本地没有未读消息时，展示新帖子小红点
                    if (newWorkMoment == YES) {
                        //没有未读消息时展示新帖子小红点
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_tabBar setBadgeNumber:1 ByItemIndex:3 showNumber:NO];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_tabBar setBadgeNumber:0 ByItemIndex:3 showNumber:NO];
                        });
                    }
                }
            }
        }
    });
}

- (void)updateUpdateProgress:(NSNotification *)notify {
    float uploadProgress = [notify.object floatValue];
    if (uploadProgress < 1.0 && uploadProgress > 0) {
        NSString *str = [NSString stringWithFormat:@"日志反馈中...%ld%%，请勿关闭应用程序！", (int) (uploadProgress * 100)];
        if (str.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_hideAllToasts];
                });
            });
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_makeToast:str];
                });
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_hideAllToasts];
            });
        });
    }
}

- (void)submitLog:(NSNotification *)notify {
    NSDictionary *dic = notify.object;
    NSString *promotMessage = [dic objectForKey:@"promotMessage"];
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_hideAllToasts];
        });
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_makeToast:promotMessage];
        });
    });
}

- (void)submitLogSuccessed:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_hideAllToasts];
        });
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_makeToast:[NSBundle qim_localizedStringForKey:@"Thanks_feedback"]];
        });
    });
}

- (void)submitLogFaild:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_hideAllToasts];
        });
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject qim_makeToast:[NSBundle qim_localizedStringForKey:@"Failed_upload_log"]];
        });
    });
}

- (void)updateAppVersion:(NSNotification *)notify {
    QIMUpdateAlertView *updateAlertView = [QIMUpdateAlertView qim_showUpdateAlertViewWithUpdateDic:notify.object];
    updateAlertView.upgradeDelegate = self;
}

- (void)onChatRoomDestroy:(NSNotification *)notify {
    NSString *groupId = nil;
    id obj = notify.object;
    if ([obj isKindOfClass:[NSString class]]) {
        groupId = obj;
    }
    NSString *reason = [notify.userInfo objectForKey:@"Reason"];
    NSString *groupName = [[notify userInfo] objectForKey:@"GroupName"];
    NSString *fromNickName = [[notify userInfo] objectForKey:@"FromNickName"];
    NSString *message = nil;
    if (fromNickName.length > 0) {
        if (groupName.length > 0) {
            message = [NSString stringWithFormat:@"%@%@:%@。", fromNickName, [NSBundle qim_localizedStringForKey:@"dissolved_group"], groupName];
        } else {
            message = [NSString stringWithFormat:@"%@%@:%@。", fromNickName, [NSBundle qim_localizedStringForKey:@"dissolved_group"], groupId];
        }
    } else {
        if (groupName.length > 0) {
            message = [NSString stringWithFormat:@"[%@]%@。", groupName, [NSBundle qim_localizedStringForKey:@"group_dissolved"]];
        } else {
            message = [NSString stringWithFormat:@"[%@]%@。", groupId, [NSBundle qim_localizedStringForKey:@"group_dissolved"]];
        }
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Reminder"] message:message delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
    [alertView show];

    [self.sessionView sessionViewWillAppear];

}

- (void)updateWorkFeedNotifyConfig:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL flag = [notify.object boolValue];
        if (flag == NO) {
            [_tabBar setBadgeNumber:0 ByItemIndex:3 showNumber:NO];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self updateNavigationWithSelectIndex:_tabBar.selectedIndex];
    switch (_tabBar.selectedIndex) {
        case 0:

            [_sessionView sessionViewWillAppear];
            break;
        case 1:
            break;
        case 2:
#if __has_include("RNSchemaParse.h")
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QTalkSuggestRNViewWillAppear" object:nil];
#endif
            break;
        case 3:
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkMoment": @(0)}];
            break;
        default:
            break;
    }
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk || [QIMKit getQIMProjectType] == QIMProjectTypeStartalk || ([QIMKit getQIMProjectType] == QIMProjectTypeQChat && [QIMKit sharedInstance].isMerchant)) {
        [self updateExploreNotReadCount:nil];
    }
    if (YES == self.notVisibleReload) {
        [self updateNotReadCount];
        [self.sessionView sessionViewWillAppear];
    }
}

#pragma mark - init ui

- (void)initRootView {

    _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [_rootView setAutoresizesSubviews:YES];
    [_rootView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [_rootView setBackgroundColor:qim_mainRootViewBgColor];
    [_rootView setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:_rootView];
}

- (void)initTotalTabBarArray {
    //这里用Id做tabBar的唯一标示，可以防止PM突然让改个顺序，加个tab
    self.totalTabBarArray = [NSMutableArray arrayWithCapacity:4];
    self.totalTabBarIndexs = [NSMutableArray arrayWithCapacity:4];
    [self.totalTabBarIndexs addObject:@"tab_title_chat"];
    [self.totalTabBarArray addObject:@{@"title": [NSBundle qim_localizedStringForKey:@"tab_title_chat"], @"normalImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_chat_font size:28 color:qim_tabImageNormalColor]], @"selectImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_chat_font size:28 color:qim_tabImageSelectedColor]]}];
    /*
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk && ![[[QIMKit getLastUserName] lowercaseString]  isEqualToString:@"appstore"]) {
        [self.totalTabBarArray addObject:@{@"title":[NSBundle qim_localizedStringForKey:@"tab_title_travel"], @"normalImage":[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_travel_font size:28 color:qim_tabImageNormalColor]], @"selectImage":[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_travel_font size:28 color:qim_tabImageSelectedColor]]}];
    }
    */
    [self.totalTabBarIndexs addObject:@"tab_title_contact"];
    [self.totalTabBarArray addObject:@{@"title": [NSBundle qim_localizedStringForKey:@"tab_title_contact"], @"normalImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_contact_font size:28 color:qim_tabImageNormalColor]], @"selectImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_contact_font size:28 color:qim_tabImageSelectedColor]]}];
    
    [self.totalTabBarIndexs addObject:@"tab_title_discover"];
    [self.totalTabBarArray addObject:@{@"title": [NSBundle qim_localizedStringForKey:@"tab_title_discover"], @"normalImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_discover_font size:28 color:qim_tabImageNormalColor]], @"selectImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_discover_font size:28 color:qim_tabImageSelectedColor]]}];
    BOOL oldAuthSign = [[[QIMKit sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"] boolValue];
    BOOL checkAuthSignKey = [[QIMKit sharedInstance] containsObjectForKey:@"kUserWorkFeedEntrance"];
    if (checkAuthSignKey == NO) {
        oldAuthSign = YES;
    }
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk && ![[[QIMKit getLastUserName] lowercaseString] isEqualToString:@"appstore"] && oldAuthSign == YES && [[[QIMKit sharedInstance] getDomain] isEqualToString:@"ejabhost1"]) {

        [self.totalTabBarIndexs addObject:@"tab_title_moment"];
        [self.totalTabBarArray addObject:@{@"title": [NSBundle qim_localizedStringForKey:@"tab_title_moment"], @"normalImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_camel_font size:28 color:qim_tabImageNormalColor]], @"selectImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_camel_font size:28 color:qim_tabImageSelectedColor]]}];
    }
    
    [self.totalTabBarIndexs addObject:@"tab_title_myself"];
    [self.totalTabBarArray addObject:@{@"title": [NSBundle qim_localizedStringForKey:@"tab_title_myself"], @"normalImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_myself_font size:28 color:qim_tabImageNormalColor]], @"selectImage": [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_tab_title_myself_font size:28 color:qim_tabImageSelectedColor]]}];
    _tabBar = [[QIMCustomTabBar alloc] initWithItemCount:self.totalTabBarArray.count WithFrame:CGRectMake(0, _rootView.height - [[QIMDeviceManager sharedInstance] getTAB_BAR_HEIGHT] - 3.5, _rootView.width, kTabBarHeight)];
    [_tabBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_tabBar setDelegate:self];
    [_tabBar setSelectedIndex:0];
    [_rootView addSubview:_tabBar];

    for (NSInteger i = 0; i < self.totalTabBarArray.count; i++) {

        NSDictionary *tabbarDic = [self.totalTabBarArray objectAtIndex:i];
        NSString *title = [tabbarDic objectForKey:@"title"];
        UIImage *normalImage = [tabbarDic objectForKey:@"normalImage"];
        UIImage *selectImage = [tabbarDic objectForKey:@"selectImage"];

        [_tabBar setTitle:title ByItemIndex:i];
        [_tabBar setNormalImage:normalImage ByItemIndex:i];
        [_tabBar setSelectedImage:selectImage ByItemIndex:i];
        [_tabBar setNormalTitleColor:qim_tabTitleNormalColor ByItemIndex:i];
        [_tabBar setSelectedTitleColor:qim_tabTitleSelectedColor ByItemIndex:i];
        [_tabBar setAccessibilityIdentifier:title ByItemIndex:i];
    }
}

- (void)initTabbar {

    CGRect frame = CGRectMake(0, 0, self.view.width, _rootView.height - 2.5 - [[QIMDeviceManager sharedInstance] getTAB_BAR_HEIGHT]);
    _contentView = [[UIView alloc] initWithFrame:frame];
    [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
    [_contentView setContentMode:UIViewContentModeScaleToFill];
    [_contentView setBackgroundColor:qim_mainRootViewBgColor];
    [_rootView addSubview:_contentView];
    [self initTotalTabBarArray];
}

- (QTalkSessionView *)sessionView {

    if (!_sessionView) {

        _sessionView = [[QTalkSessionView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, _contentView.height - 5) withRootViewController:self];
        _sessionView.backgroundColor = [UIColor spectralColorWhiteColor];
        [_sessionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return _sessionView;
}

- (UIView *)travelView {
    if (!_travelView) {
#if __has_include("QimRNBModule.h")
        QIMVerboseLog(@"打开QIM RN 行程页面");
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"createQIMRNVCWithParam:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"module": @"TravelCalendar"};
            vc = [RunC performSelector:sel withObject:param];
        }
        _travelView = [vc view];
        [_travelView setFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
#endif
    }
    return _travelView;
}

- (UIView *)userListView {
    if (!_userListView) {
#if __has_include("QimRNBModule.h")
        //导航中返回RNContactView == NO，展示Native界面
        QIMVerboseLog(@"RNContactView : %d", [[QIMKit sharedInstance] qimNav_RNContactView]);
        if ([[QIMKit sharedInstance] qimNav_RNContactView] == NO) {
            QIMVerboseLog(@"打开Native 通讯录页");
            QIMUserListView *userlistView = [[QIMUserListView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
            [userlistView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [userlistView setRootViewController:self];
            [userlistView setBackgroundColor:[UIColor spectralColorWhiteColor]];
            _userListView = userlistView;
        } else {
            QIMVerboseLog(@"打开QIM RN 通讯录页");
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"createQIMRNVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"module": @"Contacts"};
                vc = [RunC performSelector:sel withObject:param];
            }
            _userListView = [vc view];
            [_userListView setFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
        }
#else
        QIMVerboseLog(@"打开Native 通讯录页");
        QIMUserListView *userlistView = [[QIMUserListView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
        [userlistView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [userlistView setRootViewController:self];
        [userlistView setBackgroundColor:[UIColor spectralColorWhiteColor]];
        _userListView = userlistView;
#endif
    }
    return _userListView;
}

- (UIView *)rnSuggestView {
    if (!_rnSuggestView) {
        /*
#if __has_include("QimRNBModule.h")
        
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"createQIMRNVCWithParam:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"module":@"FoundPage", @"properties":@{@"domain":[[QIMKit sharedInstance] getDomain]}};
            vc = [RunC performSelector:sel withObject:param];
        }
        _rnSuggestView = [vc view];
        [_rnSuggestView setFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
#endif
        */
        //导航中返回showOA == YES / QChat，展示OPS OA界面
        QIMVerboseLog(@"showOA : %d", [[QIMKit sharedInstance] qimNav_ShowOA]);
        QIMVerboseLog(@"Domain : %@", [[QIMKit sharedInstance] qimNav_Domain]);
        if ([[QIMKit sharedInstance] qimNav_ShowOA] == YES || [[[QIMKit sharedInstance] qimNav_Domain] isEqualToString:@"ejabhost2"] || [[[QIMKit sharedInstance] qimNav_Domain] isEqualToString:@"ejabhost1"]) {
            QIMVerboseLog(@"打开OPS 发现页");
#if __has_include("RNSchemaParse.h")

            Class RunC = NSClassFromString(@"QTalkSuggestRNView");
            SEL sel = NSSelectorFromString(@"initWithFrame:WithOwnnerVC:");
            UIView *suggestRNView = nil;
            if ([RunC respondsToSelector:sel]) {
                NSString *frame = NSStringFromCGRect(CGRectMake(0, 0, _contentView.width, _contentView.height));
                suggestRNView = [RunC performSelector:sel withObject:frame withObject:self];
            }
            _rnSuggestView = suggestRNView;
#endif
        } else {
            QIMVerboseLog(@"打开QIM RN 发现页");
#if __has_include("QimRNBModule.h")

            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"createQIMRNVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"module": @"FoundPage", @"properties": @{@"domain": [[QIMKit sharedInstance] getDomain]}};
                vc = [RunC performSelector:sel withObject:param];
            }
            _rnSuggestView = [vc view];
            [_rnSuggestView setFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
#endif
        }
    }
    return _rnSuggestView;
}

- (QIMWorkFeedView *)momentView {
    if (!_momentView) {
        QIMWorkFeedView *workfeedView = [[QIMWorkFeedView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
        workfeedView.rootVC = self;
        _momentView = workfeedView;
    }
    return _momentView;
}

- (UIView *)mineView {
    if (!_mineView) {

#if __has_include("QimRNBModule.h")

        //导航中返回RNMineView == NO，展示Native界面
        QIMVerboseLog(@"RNMineView : %d", [[QIMKit sharedInstance] qimNav_RNMineView]);
        if ([[QIMKit sharedInstance] qimNav_RNMineView] == NO) {
            QIMVerboseLog(@"打开Native 我的页面");
            QIMMineTableView *mineNativeView = [[QIMMineTableView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
            [mineNativeView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [mineNativeView setRootViewController:self];
            _mineView = mineNativeView;
        } else {
            QIMVerboseLog(@"打开QIM RN 我的页面");

            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"createQIMRNVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"module": @"MySetting"};
                vc = [RunC performSelector:sel withObject:param];
            }
            _mineVC = vc;
            _mineView = [vc view];
            [_mineView setFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
            [_mineView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        }

#else
        QIMVerboseLog(@"打开Native 我的页面");
        QIMMineTableView *mineNativeView = [[QIMMineTableView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
        [mineNativeView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [mineNativeView setRootViewController:self];
        _mineView = mineNativeView;
#endif
    }
    return _mineView;
}

#pragma mark - Custom Tabbar Delegate

- (void)customTabBar:(QIMCustomTabBar *)tabBar longPressAtIndex:(NSUInteger)index {
    if ([QIMKit getQIMProjectType] != QIMProjectTypeQChat) {
        switch (index) {
            case 0:
                if (tabBar.selectedIndex != 0) {
                    [_tabBar setSelectedIndex:0 animated:YES];
                }
                break;
            default:
                break;
        }
    }
}

- (void)customTabBar:(QIMCustomTabBar *)tabBar doubleClickIndex:(NSUInteger)index {
    NSDictionary *tabBarDict = [self.totalTabBarArray objectAtIndex:index];
    NSString *tabBarId = [tabBarDict objectForKey:@"title"];
    if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_chat"]]) {
        if (tabBar.selectedIndex != 0) {
            [_tabBar setSelectedIndex:0 animated:YES];
        }
        if (_sessionView.needUpdateNotReadList) {
            [_sessionView prepareNotReaderIndexPathList];
        } else {
            [_sessionView scrollToNotReadMsg];
        }
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_moment"]]) {
        [_momentView updateMomentView];
    } else {

    }
}

- (void)customTabBar:(QIMCustomTabBar *)tabBar didSelectIndex:(NSUInteger)index {

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

    [_sessionView setHidden:YES];
    [_travelView setHidden:YES];
    [_userListView setHidden:YES];
    [_rnSuggestView setHidden:YES];
    [_momentView setHidden:YES];
    [_mineView setHidden:YES];
    [self updateNavigationWithSelectIndex:index];

    NSDictionary *tabBarDict = [self.totalTabBarArray objectAtIndex:index];
    NSString *tabBarId = [tabBarDict objectForKey:@"title"];

    if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_chat"]]) {
        if (nil == _sessionView) {
            [_contentView addSubview:self.sessionView];
        }
        [_sessionView setHidden:NO];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"conversation" withDescription:@"会话"];
#endif
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_travel"]]) {
        [_contentView addSubview:self.travelView];
        [_travelView setHidden:NO];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"route" withDescription:@"行程"];
#endif
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_contact"]]) {

        [_contentView addSubview:self.userListView];
        [self.userListView setHidden:NO];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"address list" withDescription:@"通讯录"];
#endif
#if __has_include("QimRNBModule.h")
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel2 = NSSelectorFromString(@"sendQIMRNWillShow");
        if ([RunC respondsToSelector:sel2]) {
            [RunC performSelector:sel2];
        }
#endif
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_discover"]]) {

        [_contentView addSubview:self.rnSuggestView];
        [self.rnSuggestView setHidden:NO];
#if __has_include("QIMAutoTracker.h")

        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"discovery" withDescription:@"发现"];
#endif

#if __has_include("RNSchemaParse.h")
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QTalkSuggestRNViewWillAppear" object:nil];
#endif
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_moment"]]) {
        //驼圈页面

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkMoment": @(0)}];
        [_contentView addSubview:self.momentView];
        [self.momentView setHidden:NO];
        long long currentTime = [NSDate timeIntervalSinceReferenceDate];
        long long lastUpdateMomentTime = [[[QIMKit sharedInstance] userObjectForKey:@"lastUpdateMomentTime"] longLongValue];
        if (currentTime - lastUpdateMomentTime > 5 * 60 * 60) {
            [self.momentView updateMomentView];
            [[QIMKit sharedInstance] setUserObject:@(currentTime) forKey:@"lastUpdateMomentTime"];
        }
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_myself"]]) {

        [_contentView addSubview:self.mineView];
        [_mineView setHidden:NO];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"mine" withDescription:@"我的"];
#endif
    } else {

    }
}

- (void)notifySelectTab:(NSNotification *)notify {
    QIMVerboseLog(@"收到通知中心notifySelectTab通知 : %@", notify);
    [self selectTabAtIndex:[notify.object integerValue]];
}

- (void)selectTabAtIndex:(NSInteger)index {
    if (index > _tabBar.itemCount) {
        return;
    }
    [_tabBar setSelectedIndex:index animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {

#if __has_include("QTalkSearchViewManager.h")
#if __has_include("QIMAutoTracker.h")

    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"search" withDescription:@"搜索"];
#endif
    [QIMFastEntrance openRNSearchVC];
    return NO;
#endif
    return YES;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        //返回我们自定义的效果
        return (id <UIViewControllerAnimatedTransitioning>) [[QIMNavPushTransition alloc] init];
    } else if (operation == UINavigationControllerOperationPop) {
        return (id <UIViewControllerAnimatedTransitioning>) [[QIMNavPopTransition alloc] init];
    }
    //返回nil则使用默认的动画效果
    return nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

#pragma mark -  previewing Delegate

- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    // 转换坐标
    CGPoint p = [self.sessionView.tableView convertPoint:location fromView:self.sessionView];
    //通过坐标获得当前cell indexPath
    NSIndexPath *indexPath = [self.sessionView.tableView indexPathForRowAtPoint:p];
    //防止重复加入
    if ([self.presentedViewController isKindOfClass:[QTalkViewController class]]) {
        return nil;
    } else {
        QTalkViewController *preViewVc = (QTalkViewController *) [self.sessionView sessionViewDidSelectRowAtIndexPath:indexPath];
        self.currentPreViewVc = [self.sessionView sessionViewDidSelectRowAtIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(preViewVc.view.frame), 44)];
        label.backgroundColor = [UIColor blackColor];
        label.text = [self.sessionView sessionViewTitleDidSelectRowAtIndexPath:indexPath];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [preViewVc.view addSubview:label];
        return preViewVc;
    }
}

//Pop 操作:(用力继续某一个Cell之后弹出视图，再次Touch的效果)
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {

    viewControllerToCommit.hidesBottomBarWhenPushed = YES;
    [self showViewController:self.currentPreViewVc sender:self];
}

#endif

- (void)autoLogin {
    NSString *lastUserName = [QIMKit getLastUserName];
    NSString *userToken = [[QIMKit sharedInstance] getLastUserToken];
//    [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
    NSString *userFullJid = [[QIMKit sharedInstance] userObjectForKey:@"kFullUserJid"];
    QIMVerboseLog(@"autoLogin lastUserName : %@, userFullJid : %@, userToken : %@", lastUserName, userFullJid, userToken);
    QIMVerboseLog(@"autoLogin UserDict : %@", [[QIMKit sharedInstance] userObjectForKey:@"Users"]);
    if ([lastUserName length] > 0 && [userToken length] > 0) {
        if ([lastUserName isEqualToString:@"appstore"]) {
            [[QIMKit sharedInstance] updateLastTempUserToken:@"appstore"];
//            [[QIMKit sharedInstance] setUserObject:@"appstore" forKey:@"kTempUserToken"];
            [[QIMKit sharedInstance] loginWithUserName:@"appstore" WithPassWord:@"appstore"];
        } else if ([[lastUserName lowercaseString] isEqualToString:@"qtalktest"]) {
            [[QIMKit sharedInstance] updateLastTempUserToken:@"qtalktest123"];
//            [[QIMKit sharedInstance] setUserObject:@"qtalktest123" forKey:@"kTempUserToken"];
            [[QIMKit sharedInstance] loginWithUserName:@"qtalktest" WithPassWord:@"qtalktest123"];
        } else {
            if ([[QIMKit sharedInstance] qimNav_LoginType] == QTLoginTypeSms) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *pwd = [NSString stringWithFormat:@"%@@%@", [QIMUUIDTools deviceUUID], userToken];
                    [[QIMKit sharedInstance] updateLastTempUserToken:userToken];
//                    [[QIMKit sharedInstance] setUserObject:userToken forKey:@"kTempUserToken"];
                    [[QIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:pwd];
                });
            } else {
                [[QIMKit sharedInstance] updateLastTempUserToken:userToken];
//                [[QIMKit sharedInstance] setUserObject:userToken forKey:@"kTempUserToken"];
                [[QIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:userToken];
            }
        }
    } else {
        QIMVerboseLog(@"lastUserName或userToken为空,回到登录页面");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationOutOfDate" object:nil];
    }
}

#pragma mark - NSNotification

- (void)loginNotify:(NSNotification *)notify {
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([notify.object boolValue]) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [[QIMKit sharedInstance] setUserObject:[infoDictionary objectForKey:@"CFBundleVersion"] forKey:@"QTalkApplicationLastVersion"];
            [QIMRemoteNotificationManager checkUpNotifacationHandle];
        }
    });
    */
}

#pragma mark - Navigation

- (void)updateNavigationWithSelectIndex:(NSUInteger)index {
    NSDictionary *tabBarDict = [self.totalTabBarArray objectAtIndex:index];
    NSString *tabBarId = [tabBarDict objectForKey:@"title"];

    if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_chat"]]) {
        [self.navigationItem setRightBarButtonItems:nil];
        if (self.appNetWorkTitle) {
            [self.navigationItem setTitle:self.appNetWorkTitle];
        } else {
            [self.navigationItem setTitle:self.navTitle];
        }
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreBtn];
        [self.navigationItem setRightBarButtonItem:rightBarItem];
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_travel"]]) {
        [self.navigationItem setRightBarButtonItems:nil];
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_travel"]];
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_contact"]]) {
        [self.navigationItem setRightBarButtonItems:nil];
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_contact"]];
        /*
        if ([QIMKit getQIMProjectType] != QIMProjectTypeStartalk) {
            UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.addFriendBtn];
            [self.navigationItem setRightBarButtonItem:rightBarItem];
        }
        */
    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_discover"]]) {
        [self.navigationItem setRightBarButtonItems:nil];
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_discover"]];
        if ([QIMKit getQIMProjectType] != QIMProjectTypeStartalk) {
            UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.scanBtn];
            [self.navigationItem setRightBarButtonItem:rightBarItem];
        } else {

        }

    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_moment"]]) {

        [self.navigationItem setRightBarButtonItems:nil];
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_moment"]];
        UIBarButtonItem *searchMomentItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchMomentBtn];
        UIBarButtonItem *myMomentItem = [[UIBarButtonItem alloc] initWithCustomView:self.momentBtn];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = 16;
        [self.navigationItem setRightBarButtonItems:@[myMomentItem, space, searchMomentItem]];

    } else if ([tabBarId isEqualToString:[NSBundle qim_localizedStringForKey:@"tab_title_myself"]]) {
        [self.navigationItem setRightBarButtonItems:nil];
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_myself"]];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingBtn];
        [self.navigationItem setRightBarButtonItem:rightBarItem];
    } else {

    }
    if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
        UIBarButtonItem *rndebugBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.rnDebugConfigBtn];
        [self.navigationItem setLeftBarButtonItem:rndebugBarItem];
    }
}

- (UIButton *)rnDebugConfigBtn {
    if (!_rnDebugConfigBtn) {
        _rnDebugConfigBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rnDebugConfigBtn.frame = CGRectMake(0, 0, 28, 28);
        [_rnDebugConfigBtn setTitle:@"RD" forState:UIControlStateNormal];
        [_rnDebugConfigBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rnDebugConfigBtn addTarget:self action:@selector(openRNDebugConfigVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rnDebugConfigBtn;
}

- (QIMArrowTableView *)arrowPopView {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.view.width - 20 - 28, -30, 28, 28);
    button.backgroundColor = [UIColor clearColor];
    [self.view addSubview:button];
    CGRect rect1 = [button convertRect:button.frame fromView:self.view];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect rect2 = [button convertRect:rect1 toView:window];         //获取button在window的位置
    
    CGRect rect3 = CGRectInset(rect2, -0.5 * 8, -0.5 * 8);
    
    CGPoint point;
    //获取控件相对于window的   中心点坐标
    
    NSString *qCloudHost = [[QIMKit sharedInstance] qimNav_QCloudHost];
    NSString *wikiHost = [[QIMKit sharedInstance] qimNav_WikiUrl];
    self.moreActionArray = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *moreActionImages = nil;
    self.moreActionArray = @[[NSBundle qim_localizedStringForKey:@"Scan"], [NSBundle qim_localizedStringForKey:@"Unread Messages"], [NSBundle qim_localizedStringForKey:@"Create Group"], [NSBundle qim_localizedStringForKey:@"Mark All as Read"]];
    moreActionImages = @[[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_arrow_scan_font size:28 color:qim_rightArrowImageColor]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_arrow_notread_font size:28 color:qim_rightArrowImageColor]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_arrow_gototalk_font size:28 color:qim_rightArrowImageColor]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_arrow_clearnotread_font size:28 color:qim_rightArrowImageColor]]];
    NSInteger arrowWidth = 135;
    NSString *Language = [[QIMKit sharedInstance] currentLanguage];
    if ([Language containsString:@"en"]) {
        arrowWidth = 220;
    }
    point = CGPointMake(rect3.origin.x + rect3.size.width / 2, rect3.origin.y + rect3.size.height / 2);
    _arrowPopView = [[QIMArrowTableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) Origin:point Width:arrowWidth Height:50 * self.moreActionArray.count + 10 Type:Type_UpRight Color:[UIColor whiteColor]];
    _arrowPopView.dataArray = self.moreActionArray;
    _arrowPopView.backView.layer.cornerRadius = 5.0f;
    _arrowPopView.images = moreActionImages;
    _arrowPopView.row_height = 50;
    _arrowPopView.delegate = self;
    _arrowPopView.titleTextColor = qim_rightArrowTitleColor;
    return _arrowPopView;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        UIButton *moreActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreActionBtn.frame = CGRectMake(0, 0, 28, 28);
        [moreActionBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_rightMoreBtn_font size:28 color:qim_rightMoreBtnColor]] forState:UIControlStateNormal];
        [moreActionBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_rightMoreBtn_font size:28 color:qim_rightMoreBtnColor]] forState:UIControlStateSelected];
        [moreActionBtn addTarget:self action:@selector(doMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn = moreActionBtn;
    }
    return _moreBtn;
}

- (UIButton *)addFriendBtn {
    if (!_addFriendBtn) {
        UIButton *addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addFriendBtn.frame = CGRectMake(0, 0, 28, 28);
        [addFriendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_addfriend_font size:28 color:qim_nav_addfriend_btnColor]] forState:UIControlStateNormal];
        [addFriendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_addfriend_font size:28 color:qim_nav_addfriend_btnColor]] forState:UIControlStateSelected];
        [addFriendBtn addTarget:self action:@selector(addNewFriend:) forControlEvents:UIControlEventTouchUpInside];
        _addFriendBtn = addFriendBtn;
    }
    return _addFriendBtn;
}

- (UIButton *)scanBtn {
    if (!_scanBtn) {
        UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        scanBtn.frame = CGRectMake(0, 0, 28, 28);
        [scanBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_scan_font size:28 color:qim_nav_scan_btnColor]] forState:UIControlStateNormal];
        [scanBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_scan_font size:28 color:qim_nav_scan_btnColor]] forState:UIControlStateSelected];
        [scanBtn addTarget:self action:@selector(scanQrcode:) forControlEvents:UIControlEventTouchUpInside];
        _scanBtn = scanBtn;
    }
    return _scanBtn;
}

- (UIButton *)searchMomentBtn {
    if (!_searchMomentBtn) {
        _searchMomentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchMomentBtn.frame = CGRectMake(0, 0, 21, 21);
        [_searchMomentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e752" size:21 color:[UIColor qim_colorWithHex:0x666666]]] forState:UIControlStateNormal];
        [_searchMomentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e752" size:21 color:[UIColor qim_colorWithHex:0x666666]]] forState:UIControlStateSelected];
        [_searchMomentBtn addTarget:self action:@selector(searchMoment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchMomentBtn;
}

- (UIButton *)momentBtn {
    if (!_momentBtn) {
        _momentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _momentBtn.frame = CGRectMake(0, 0, 28, 28);
        [_momentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_mymoment_font size:28 color:qim_nav_moment_color]] forState:UIControlStateNormal];
        [_momentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_mymoment_font size:28 color:qim_nav_moment_color]] forState:UIControlStateSelected];
        [_momentBtn addTarget:self action:@selector(myOwnerMoment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _momentBtn;
}

- (UIButton *)settingBtn {
    if (!_settingBtn) {
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBtn.frame = CGRectMake(0, 0, 28, 28);
        [_settingBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_myself_font size:28 color:qim_nav_myself_color]] forState:UIControlStateNormal];
        [_settingBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_myself_font size:28 color:qim_nav_myself_color]] forState:UIControlStateSelected];
        [_settingBtn addTarget:self action:@selector(openMySetting:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

- (void)openRNDebugConfigVC:(id)sender {
    QIMRNDebugConfigVc *rndebugVC = [[QIMRNDebugConfigVc alloc] init];
    [self.navigationController pushViewController:rndebugVC animated:YES];
}

- (void)doMoreAction:(id)sender {
    UIButton *button = (UIButton *) sender;
    button.selected = ~button.selected;
    if (button.selected) {
        [self.arrowPopView popView];
    } else {
        [self.arrowPopView dismiss];
    }
}

- (void)scanQrcode:(id)sender {
    [QIMFastEntrance openQRCodeVC];
#if __has_include("QIMAutoTracker.h")
    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"RichScan" withDescription:[NSBundle qim_localizedStringForKey:@"Scan"]];
#endif
}

- (void)addNewFriend:(id)sender {
    QIMAddIndexViewController *indexVC = [[QIMAddIndexViewController alloc] init];
    [self.navigationController pushViewController:indexVC animated:YES];
#if __has_include("QIMAutoTracker.h")
    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"add a contact" withDescription:@"添加联系人"];
#endif
}

- (void)searchMoment:(id)sender {
    [QIMFastEntrance openWorkMomentSearchVc];
}

//我的驼圈儿navbar入口
- (void)myOwnerMoment:(id)sender {
    [[QIMFastEntrance sharedInstance] openUserWorkWorldWithParam:@{@"UserId": [[QIMKit sharedInstance] getLastJid]}];
#if __has_include("QIMAutoTracker.h")
    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"push my moment" withDescription:@"进去我的驼圈"];
#endif
}

- (void)openMySetting:(id)sender {
/*
    {
        Bundle = "clock_in.ios";
        Module = MySetting;
        Properties =     {
            Screen = Setting;
        };
        Version = "1.0.0";
    }
    */
    [QIMFastEntrance openQIMRNVCWithModuleName:@"MySetting" WithProperties:@{@"Screen": @"Setting"}];
#if __has_include("QIMAutoTracker.h")
    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"Setting" withDescription:@"设置页面"];
#endif
}

- (void)refreshSwitchAccount:(NSNotification *)notify {
    QIMVerboseLog(@"收到通知中心refreshSwitchAccount通知 : %@", notify);
    BOOL switchAccountSuccess = [notify.object boolValue];
    if (switchAccountSuccess) {
        _rnSuggestView = nil;
        _userListView = nil;
        _travelView = nil;
        _userListView = nil;
        [_travelView removeFromSuperview];
        [_rnSuggestView removeFromSuperview];
        [_userListView removeFromSuperview];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {

    return UIInterfaceOrientationPortrait;
}

#pragma mark - QIMUpdateAlertViewDelegate

- (void)qim_UpdateAlertViewDidClickWithType:(QIMUpgradeType)type withUpdateDic:(QIMUpdateDataModel *)updateModel {
    if (QIMUpgradeNow == type) {
        //
        NSString *updateUrl = updateModel.linkUrl;
        [QIMFastEntrance openWebViewForUrl:updateUrl showNavBar:YES];
    } else {
        //下次再说
        NSInteger version = updateModel.version;
//        [[updateDic objectForKey:@"version"] integerValue];
        [[QIMKit sharedInstance] setUserObject:@(version) forKey:@"updateAppVersion"];
    }
}

#pragma mark -

- (void)selectIndexPathRow:(NSInteger)index {
    QIMVerboseLog(@"右上角快捷入口%s , %ld", __func__, index);
    NSString *moreActionId = [self.moreActionArray objectAtIndex:index];
    if ([moreActionId isEqualToString:[NSBundle qim_localizedStringForKey:@"Scan"]]) {
        [QIMFastEntrance openQRCodeVC];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"RichScan" withDescription:[NSBundle qim_localizedStringForKey:@"Scan"]];
#endif
    } else if ([moreActionId isEqualToString:[NSBundle qim_localizedStringForKey:@"Create Group"]]) {
        [QIMFastEntrance openQIMGroupListVC];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"StarToTalk" withDescription:[NSBundle qim_localizedStringForKey:@"Create Group"]];
#endif
    } else if ([moreActionId isEqualToString:[NSBundle qim_localizedStringForKey:@"Mark All as Read"]]) {
        [self oneKeyRead];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"A key has been read" withDescription:[NSBundle qim_localizedStringForKey:@"Mark All as Read"]];
#endif
    } else if ([moreActionId isEqualToString:[NSBundle qim_localizedStringForKey:@"notes"]]) {
        [QIMFastEntrance openQTalkNotesVC];
#if __has_include("QIMAutoTracker.h")
        [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"note" withDescription:[NSBundle qim_localizedStringForKey:@"notes"]];
#endif
    } else if ([moreActionId isEqualToString:@"Wiki"]) {
        if ([[QIMKit sharedInstance] qimNav_WikiUrl].length > 0) {
            [QIMFastEntrance openWebViewForUrl:[[QIMKit sharedInstance] qimNav_WikiUrl] showNavBar:YES];
#if __has_include("QIMAutoTracker.h")
            [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"note" withDescription:@"wiki"];
#endif
        }
    } else if ([moreActionId isEqualToString:[NSBundle qim_localizedStringForKey:@"Unread Messages"]]) {
        [QIMFastEntrance openNotReadMessageVC];
    } else {
        
    }
}

- (void)oneKeyRead {
    NSUInteger count = [[QIMKit sharedInstance] getAppNotReaderCount];
    if (count) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"clear_unread_messages"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"continue"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[QIMKit sharedInstance] clearAllNoRead];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:okAction];
        [alertVc addAction:cancelAction];
        [self presentViewController:alertVc animated:YES completion:nil];
    } else {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"no_unread_messages"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[QIMKit sharedInstance] clearAllNoRead];
        }];
        [alertVc addAction:okAction];
        [self presentViewController:alertVc animated:YES completion:nil];
    }
}

@end

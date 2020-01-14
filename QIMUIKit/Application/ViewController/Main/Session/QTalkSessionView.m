//
//  QTalkSessionView.m
//  STChatIphone
//
//  Created by Qunar-Lu on 16/7/20.
//
//

#import "QTalkSessionView.h"
#import "STIMChatVC.h"
#import "STIMMainVC.h"
#import "UIApplication+STIMApplication.h"
#import "STIMJSONSerializer.h"
#import "STIMGroupChatVC.h"
#import "STIMIconInfo.h"
#import "STIMPublicNumberVC.h"
#import "STIMFriendNotifyViewController.h"
#import "STIMWebView.h"
#import <CoreText/CoreText.h>
#import "STIMCollectionChatViewController.h"
#import "STIMContactSelectionViewController.h"
#import "STIMArrowTableView.h"
#import "STIMContactSelectVC.h"
#import "STIMZBarViewController.h"
#import "STIMJumpURLHandle.h"
#import "MBProgressHUD.h"
#import "STIMCustomPopViewController.h"
#import "STIMCustomPresentationController.h"
#import "STIMCustomPopManager.h"
#import "STIMSearchBar.h"
#import "YYModel.h"
#import "STIMUpdateAlertView.h"
#import "QTalkNewSessionTableViewCell.h"
#import "QTalkSessionDataManager.h"
#import "QtalkSessionModel.h"


#define cellReuseID @"QtalkNewSessionCellIdentifier"

#if __has_include("STIMIPadWindowManager.h")

#import "STIMIPadWindowManager.h"

#endif

#if __has_include("STIMNotifyManager.h")

#import "STIMNotifyManager.h"

#endif
#if __has_include("STIMAutoTracker.h")

#import "STIMAutoTracker.h"

#endif

#define kClearAllNotReadMsg 1002

#if __has_include("STIMNotifyManager.h")

@interface QTalkSessionView () <STIMNotifyManagerDelegate>

@end

#endif

@interface QTalkSessionView () <UITableViewDelegate, UITableViewDataSource, STIMNewSessionScrollDelegate, UIViewControllerPreviewingDelegate, STIMSearchBarDelegate>

@property(nonatomic, strong) QTalkSessionDataManager *dataManager;

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, assign) BOOL notVisibleReload;

@property(atomic, strong) NSMutableArray *notReaderIndexPathList;

@property(nonatomic, strong) dispatch_queue_t update_reader_list_queue;

@property(nonatomic, strong) dispatch_queue_t reloadListViewQueue;

@property(nonatomic, assign) BOOL isSelected;       //是否已选择，防止点A进B

@property(nonatomic, assign) BOOL scrollTop;        //是否滚动置顶

@property(nonatomic, strong) STIMSearchBar *searchBar;   //搜索条

@property(nonatomic, strong) UIView *connectionAlertView;   //网络连接提示条

@property(nonatomic, strong) UIView *otherPlatformView;     //其他平台已登录条

@property(nonatomic, strong) NSMutableArray *appendHeaderViews;

@property(nonatomic, strong) STIMMainVC *rootViewController;

@end

@implementation QTalkSessionView

#pragma mark - setter and getter

- (NSMutableArray *)appendHeaderViews {
    if (!_appendHeaderViews) {
        _appendHeaderViews = [NSMutableArray arrayWithCapacity:2];
    }
    return _appendHeaderViews;
}

- (UIView *)connectionAlertView {
    if (!_connectionAlertView) {
        _connectionAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 45)];
        _connectionAlertView.backgroundColor = stimDB_sessionViewConnectionErrorViewBgColor;

        UIImageView *alertView = [[UIImageView alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"connect_alert_error"]];
        alertView.frame = CGRectMake(20, (CGRectGetHeight(_connectionAlertView.frame) - 28) / 2, 28, 28);
        [_connectionAlertView addSubview:alertView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(alertView.frame) + 12, 0, 300, 45)];
        label.textColor = stimDB_sessionViewConnectionErrorTextColor;
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"当前网络不可用，请检查你的网络设置";
        [_connectionAlertView addSubview:label];
        [_connectionAlertView setAccessibilityIdentifier:@"connectionAlertView"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotConnectWebView:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_connectionAlertView addGestureRecognizer:tap];
    }
    return _connectionAlertView;
}

- (UIView *)otherPlatformView {
    if (!_otherPlatformView) {
        _otherPlatformView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 49)];
        _otherPlatformView.backgroundColor = stimDB_otherPlatformViewBgColor;
        UIImageView *pcIconView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 12, 24, 24)];
        pcIconView.image = [UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:stimDB_otherPlatformViewIcon_font size:20 color:stimDB_otherPlatformViewIconColor]];
        [_otherPlatformView addSubview:pcIconView];
        UILabel *pcTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(pcIconView.right + 15, 12, 300, 20)];
        NSString *platTitle = @"QTalk";
        if ([STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
            platTitle = @"QTalk";
        } else if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
            platTitle = @"QChat";
        } else {
            platTitle = [STIMKit getSTIMProjectTitleName];
        }
        pcTipLabel.text = [NSString stringWithFormat:[NSBundle stimDB_localizedStringForKey:@"Logged in to %@ on computer"], platTitle];
        pcTipLabel.textColor = stimDB_otherPlatformViewTextColor;
        pcTipLabel.font = [UIFont systemFontOfSize:14];
        [_otherPlatformView addSubview:pcTipLabel];
        pcTipLabel.centerY = pcIconView.centerY;

        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(self.right - 5 - 34, 7.5, 34, 34)];
        arrowView.image = [UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:stimDB_otherPlatformViewArrow_font size:34 color:stimDB_otherPlatformViewRightArrowColor]];
        [_otherPlatformView addSubview:arrowView];
        arrowView.centerY = pcTipLabel.centerY;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFileTrans)];
        [_otherPlatformView addGestureRecognizer:tap];

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _otherPlatformView.height - 0.5f, _otherPlatformView.width, 0.5f)];
        lineView.backgroundColor = [UIColor stimDB_colorWithHex:0xEAEAEA];
        [_otherPlatformView addSubview:lineView];
    }
    return _otherPlatformView;
}

- (UIView *)tableViewHeaderView {

    if (self.notShowHeader == YES) {
        return nil;
    } else {
        CGFloat appendHeight = 0.0f;
        for (UIView *appendView in self.appendHeaderViews) {
            appendHeight += appendView.height;
        }

        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, self.searchBar.height + appendHeight)];
//        UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.tableView.height, self.tableView.width, self.tableView.height)];
//        [logoView setBackgroundColor:[UIColor stimDB_colorWithHex:0xEEEEEE alpha:1]];
//        [headerView addSubview:logoView];
//        if ([self.rootViewController isKindOfClass:[STIMMainVC class]] && [[STIMKit sharedInstance] getIsIpad] == NO) {
//            [headerView addSubview:self.searchBar];
//        } else {
//            [headerView addSubview:self.searchBar];
//        }
        [headerView addSubview:self.searchBar];
        for (UIView *appendView in self.appendHeaderViews) {
            UIView *lastView = headerView.subviews.lastObject;
            CGRect appendViewFrame = CGRectMake(appendView.origin.x, lastView.bottom, appendView.width, appendView.height);
            [appendView setFrame:appendViewFrame];
            [headerView addSubview:appendView];
        }
        return headerView;
    }
}

- (UITableView *)tableView {

    if (!_tableView) {

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = stimDB_sessionViewBgColor;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setAccessibilityIdentifier:@"SessionView"];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0.5);           //top left bottom right 左右边距相同
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor stimDB_colorWithHex:0xEAEAEA];
        _tableView.tableFooterView = [UIView new];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [_tableView setTableHeaderView:[self tableViewHeaderView]];
    }
    return _tableView;
}

- (STIMSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[STIMSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 56)];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (void)initUI {

    [self addSubview:self.tableView];
    [self reloadTableView];
}

- (void)updateOtherPlatFrom:(BOOL)flag {
    if (flag) {
        if (![self.appendHeaderViews containsObject:self.otherPlatformView]) {
            [self.appendHeaderViews addObject:self.otherPlatformView];
        } else {
            //不做改变
        }
    } else {
        [self.appendHeaderViews removeObject:self.otherPlatformView];
    }
    [self.tableView setTableHeaderView:[self tableViewHeaderView]];
}

- (void)updateSessionHeaderViewWithShowNetWorkBar:(BOOL)showNetWorkBar {
    if (showNetWorkBar) {
        if (![self.appendHeaderViews containsObject:self.connectionAlertView]) {
            [self.appendHeaderViews addObject:self.connectionAlertView];
        } else {
            //不做改变
        }
    } else {
        [self.appendHeaderViews removeObject:self.connectionAlertView];
    }
    [self.tableView setTableHeaderView:[self tableViewHeaderView]];
}

- (void)showFileTrans {
    [[STIMFastEntrance sharedInstance] openFileTransMiddleVC];
}

- (void)setSessionViewHeader:(UIView *)headerView {
    [self.tableView setTableHeaderView:headerView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _dataManager = [[QTalkSessionDataManager alloc] init];
        __weak typeof(self) weakSelf = self;
        [_dataManager setQtBlock:^{
            [weakSelf refreshTableView];
        }];
        _update_reader_list_queue = dispatch_queue_create("update reader list queue", 0);
        _reloadListViewQueue = dispatch_queue_create("reloadListViewQueue", 0);
        [self resigisterNSNotifications];
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withRootViewController:(id)rootVc {

    self = [self initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        if ([rootVc isKindOfClass:[STIMMainVC class]]) {
            STIMMainVC *mainVc = (STIMMainVC *) rootVc;
            _rootViewController = mainVc;
        } else {

        }
    }
    return self;
}

- (void)resigisterNSNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChatSession:) name:kChatSessionDelete object:nil];

    //置顶一个数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeNotifyView:) name:@"kNotifyViewCloseNotification" object:nil];
}

- (void)autoScrollTableView {

    if (!self.scrollTop) {
        [UIView animateWithDuration:3 animations:^{
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

        }                completion:^(BOOL finished) {
            self.scrollTop = YES;
        }];
    } else {
        [self scrollTableToFoot:YES];
        self.scrollTop = NO;
    }
}

- (void)scrollTableToFoot:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger s = [self.tableView numberOfSections];  //有多少组
        if (s < 1) return;  //无数据时不执行 要不会crash
        NSInteger r = [self.tableView numberOfRowsInSection:s - 1]; //最后一组有多少行
        if (r < 1) return;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:r - 1 inSection:s - 1];  //取最后一行数据
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated]; //滚动到最后一行
    });
}

- (void)sessionViewWillAppear {
    [self refreshTableView];
    [self.dataManager registCellNotification];
#if __has_include("STIMNotifyManager.h")

    [[STIMNotifyManager shareNotifyManager] setNotifyManagerGlobalDelegate:self];
#endif
}

- (void)reloadSessionViewFrame {
    _searchBar = nil;
    [_tableView setValue:nil forKey:@"reusableTableCells"];
    [self refreshTableView];
}

- (void)refreshTableView {

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *currentVc = [UIApplication sharedApplication].visibleViewController;
        Class mainVC = NSClassFromString(@"STIMMainVC");
        Class helperVC = NSClassFromString(@"STIMMessageHelperVC");
//        if ([currentVc isKindOfClass:[mainVC class]] || [currentVc isKindOfClass:[helperVC class]] || [[STIMKit sharedInstance] getIsIpad] == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadTableView) object:nil];
                [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.1];
            });
            self.notVisibleReload = NO;
//        } else {
//            self.notVisibleReload = YES;
//        }
    });
}

#pragma mark - notify

- (void)reloadTableView {


    dispatch_async(self.reloadListViewQueue, ^{
        @autoreleasepool {
            STIMVerboseLog(@"啊啊啊你倒是刷新呀");
            NSDictionary *friendDic = [[STIMKit sharedInstance] getLastFriendNotify];
            NSInteger friendNotifyCount = [[STIMKit sharedInstance] getFriendNotifyCount];
            NSArray *temp = nil;
            if (self.showNotReadList == YES) {
                temp = [[STIMKit sharedInstance] getNotReadSessionList];
            } else {
                temp = [[STIMKit sharedInstance] getSessionList];
            }
//            STIMVerboseLog(@"从数据库中获取的列表页数据 : %@", temp);
            NSMutableArray *normalList = [NSMutableArray array];
            BOOL isAddFN = NO;
            long long fnTime = 0;
            NSString *fnDescInfo = nil;
            if (friendDic && friendNotifyCount) {

                fnTime = [[friendDic objectForKey:@"LastUpdateTime"] longLongValue] * 1000;
                NSString *name = [friendDic objectForKey:@"Name"];
                if (name == nil) {

                    name = @"";
                }
                int state = [[friendDic objectForKey:@"State"] intValue];
                NSString *newName = [NSString stringWithFormat:@"%@为好友", name];
                switch (state) {
                    case 0: {
                        //xxx请求添加为好友
                        fnDescInfo = [name stringByAppendingString:@"请求添加为好友"];
                    }
                        break;
                    case 1: {
                        fnDescInfo = [@"已同意添加" stringByAppendingString:newName];
                    }
                        break;
                    case 2: {
                        fnDescInfo = [@"已拒绝添加" stringByAppendingString:newName];
                    }
                        break;
                    default:
                        break;
                }
            }

            for (NSDictionary *infoDic in temp) {

                long long sTime = [[infoDic objectForKey:@"MsgDateTime"] longLongValue];
                long long msgState = [[infoDic objectForKey:@"MsgState"] longLongValue];

                if (friendDic && isAddFN == NO && fnTime > sTime) {
                    NSDictionary *dic = @{@"XmppId": @"FriendNotify", @"ChatType": @(ChatType_System), @"MsgType": @(1), @"MsgState": @(msgState), @"Content": fnDescInfo, @"MsgDateTime": @(fnTime)};

                    QtalkSessionModel *model = [QtalkSessionModel yy_modelWithDictionary:dic];
                    [normalList addObject:model];
                    isAddFN = YES;
                } else {
                    QtalkSessionModel *model = [QtalkSessionModel yy_modelWithDictionary:infoDic];
                    [normalList addObject:model];
                }
            }
            if (friendDic && friendNotifyCount && isAddFN == NO) {

                NSDictionary *dict = @{@"XmppId": @"FriendNotify", @"ChatType": @(ChatType_System), @"MsgType": @(1), @"Content": fnDescInfo, @"MsgDateTime": @(fnTime)};

                QtalkSessionModel *model = [QtalkSessionModel yy_modelWithDictionary:dict];
                [normalList addObject:model];
            }
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataManager removeAllData];
                [normalList enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                    if ((NSDictionary *) obj) {
                        [weakSelf.dataManager addDataModel:obj];
                    } else {
                        STIMVerboseLog(@"列表空数据了！");
                    }
                }];
//                STIMVerboseLog(@"拼接完成的列表页数据 : %@", weakSelf.dataManager.dataSource);
                [weakSelf lazyReloadTableview];
            });
        }
    });
}

- (void)showNotConnectWebView:(UITapGestureRecognizer *)tapgesture {

    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"NetWorkSetting" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [STIMFastEntrance openWebViewWithHtmlStr:htmlString showNavBar:YES];
}

#pragma mark - life ctyle

- (void)layoutSubviews {

    [super layoutSubviews];
}

- (void)dealloc {

    _tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification Method

- (void)lazyReloadTableview {

    [NSObject cancelPreviousPerformRequestsWithTarget:self.tableView
                                             selector:@selector(reloadData)
                                               object:nil];

    [self.tableView performSelector:@selector(reloadData)
                         withObject:nil
                         afterDelay:0.1];
    STIMVerboseLog(@"列表页终于刷新了！！！");
}

#pragma mark - UITableViewDelegate Method

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {//设置是否显示一个可编辑视图的视图控制器。

    [_tableView setEditing:editing animated:animated];//切换接收者的进入和退出编辑模式。
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [QTalkNewSessionTableViewCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isSelected == NO) {
        self.isSelected = YES;
        
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        QtalkSessionModel *model = [self.dataManager.dataSource objectAtIndex:indexPath.row];
        NSDictionary *infoDic = [model yy_modelToJSONObject];
        QTalkNewSessionTableViewCell *cell = (QTalkNewSessionTableViewCell *) [_tableView cellForRowAtIndexPath:indexPath];
        QTalkViewController *pushVc = [self sessionViewDidSelectRowAtIndexPath:indexPath infoDic:infoDic];
        if ([self.rootViewController isKindOfClass:[STIMMainVC class]]) {
            [self.rootViewController.navigationController pushViewController:pushVc animated:YES];
        } else {
            UINavigationController *rootNav = [[UIApplication sharedApplication] visibleNavigationController];
            NSLog(@"跳转的RootVc1 ：%@ ", rootNav);
            if (!rootNav) {
                rootNav = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                NSLog(@"跳转的RootVc2 ：%@ ", rootNav);
            }
            NSLog(@"跳转的RootVc3 ：%@ ", rootNav);
            NSLog(@"跳转的PushVc : %@", pushVc);
            if ([[STIMKit sharedInstance] getIsIpad] == YES) {
#if __has_include("STIMIPadWindowManager.h")
                [[STIMIPadWindowManager sharedInstance] showDetailViewController:pushVc];
#endif
            } else {
                pushVc.hidesBottomBarWhenPushed = YES;
                [rootNav pushViewController:pushVc animated:YES];
            }
        }
    }
}

- (void)repeatDelay {
    self.isSelected = NO;
}

//返回表格视图是否可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataManager.dataSource];
    if (indexPath.row < tempArray.count && indexPath.row >= 0) {
        QTalkNewSessionTableViewCell *cell = (QTalkNewSessionTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell refreshUI];
//        NSDictionary *infoDic = [tempArray objectAtIndex:indexPath.row];
        QtalkSessionModel *model = [tempArray objectAtIndex:indexPath.row];
        NSDictionary *infoDic = [model yy_modelToJSONObject];
        ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
        NSString *jid = [infoDic objectForKey:@"XmppId"];
        if (chatType != ChatType_PublicNumber) {

            return @[cell.deleteBtn, cell.stickyBtn];
        }
        if ([jid hasPrefix:@"FriendNotify"]) {

            return @[cell.deleteBtn];
        }
    }
    return nil;
}

- (QTalkViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *infoDic = [self.dataManager.dataSource objectAtIndex:indexPath.row];
    return [self sessionViewDidSelectRowAtIndexPath:indexPath infoDic:infoDic];
}

- (QTalkViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath infoDic:(NSDictionary *)infoDic {

    NSString *jid = [infoDic objectForKey:@"XmppId"];
    NSString *name = [infoDic objectForKey:@"Name"];
    ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
    NSInteger notReadCount = [[infoDic objectForKey:@"UnreadCount"] integerValue];
    if (jid) {

        switch (chatType) {

            case ChatType_GroupChat: {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                    [[STIMKit sharedInstance] clearNotReadMsgByGroupId:jid];
//                });
                STIMGroupChatVC *chatGroupVC = (STIMGroupChatVC *) [[STIMFastEntrance sharedInstance] getGroupChatVCByGroupId:jid];
                [chatGroupVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatGroupVC setNotReadCount:notReadCount];
                [chatGroupVC setReadedMsgTimeStamp:-1];
//                if (chatGroupVC.needShowNewMsgTagCell) {
//
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                       chatGroupVC.readedMsgTimeStamp = [[STIMKit sharedInstance] getReadedTimeStampForUserId:chatGroupVC.chatId WithRealJid:chatGroupVC.chatId WithMsgDirection:STIMMessageDirection_Received withUnReadCount:notReadCount];
//                    });
//                }
                return chatGroupVC;
            }
                break;
            case ChatType_System: {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                    [[STIMKit sharedInstance] clearNotReadMsgByJid:jid];
//                });
                if ([jid hasPrefix:@"FriendNotify"]) {

                    STIMFriendNotifyViewController *friendVC = [[STIMFriendNotifyViewController alloc] init];
                    return friendVC;
                } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                    STIMWebView *webView = [[STIMWebView alloc] init];
                    webView.needAuth = YES;
                    webView.fromOrderManager = YES;
                    webView.navBarHidden = YES;
                    webView.url = [[STIMKit sharedInstance] qimNav_QcGrabOrder];
                    return webView;
                } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                    STIMWebView *webView = [[STIMWebView alloc] init];
                    webView.needAuth = YES;
                    webView.navBarHidden = YES;
                    [[STIMKit sharedInstance] clearNotReadMsgByJid:jid];
                    webView.url = [[STIMKit sharedInstance] qimNav_QcOrderManager];
                    return webView;
                } else {

                    STIMChatVC *chatSystemVC = [[STIMChatVC alloc] init];
                    [chatSystemVC setChatType:ChatType_System];
                    [chatSystemVC setChatId:jid];
                    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {

                        if ([jid hasPrefix:@"rbt-notice"]) {
                            [chatSystemVC setTitle:@"公告通知"];
                        } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                            [chatSystemVC setTitle:@"抢单通知"];
                        } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                            [chatSystemVC setTitle:@"抢单"];
                        } else {
                            [chatSystemVC setTitle:[NSBundle stimDB_localizedStringForKey:@"System Messages"]];//@"系统消息"];
                        }
                    } else {

                        [chatSystemVC setTitle:[NSBundle stimDB_localizedStringForKey:@"System Messages"]];//@"系统消息"];
                    }
                    return chatSystemVC;
                }
            }
                break;
            case ChatType_SingleChat: {
                STIMChatVC *chatSingleVC = (STIMChatVC *) [[STIMFastEntrance sharedInstance] getSingleChatVCByUserId:jid];
                NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
                [chatSingleVC setTitle:remarkName ? remarkName : name];
                [chatSingleVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatSingleVC setReadedMsgTimeStamp:-1];
                [chatSingleVC setNotReadCount:notReadCount];
//                if (chatSingleVC.needShowNewMsgTagCell) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//
//                        chatSingleVC.readedMsgTimeStamp = [[STIMKit sharedInstance] getReadedTimeStampForUserId:jid WithRealJid:jid WithMsgDirection:STIMMessageDirection_Received withUnReadCount:notReadCount];
//                    });
//                }
                return chatSingleVC;
            }
                break;
            case ChatType_Consult: {
                NSString *xmppId = [infoDic objectForKey:@"XmppId"];
                STIMChatVC *chatSingleVC = (STIMChatVC *) [[STIMFastEntrance sharedInstance] getSingleChatVCByUserId:jid];
                //备注
                NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
                [chatSingleVC setTitle:remarkName ? remarkName : name];
                [chatSingleVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatSingleVC setReadedMsgTimeStamp:-1];
                [chatSingleVC setNotReadCount:notReadCount];
//                if (chatSingleVC.needShowNewMsgTagCell) {
//
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//
//                        chatSingleVC.readedMsgTimeStamp = [[STIMKit sharedInstance] getReadedTimeStampForUserId:jid WithRealJid:jid WithMsgDirection:STIMMessageDirection_Received withUnReadCount:notReadCount];
//                    });
//                }
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                    [[STIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:xmppId];
//                });
                return chatSingleVC;
            }
                break;
            case ChatType_ConsultServer: {
                NSString *realJid = [infoDic objectForKey:@"RealJid"];
                NSString *xmppId = [infoDic objectForKey:@"XmppId"];
                STIMChatVC *chatSingleVC = [[STIMChatVC alloc] init];
                [chatSingleVC setChatId:realJid];
                [chatSingleVC setVirtualJid:xmppId];
                [chatSingleVC setChatInfoDict:infoDic];
                [chatSingleVC setChatType:chatType];
                //备注
                NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
                [chatSingleVC setTitle:remarkName ? remarkName : name];
                [chatSingleVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatSingleVC setReadedMsgTimeStamp:-1];
                [chatSingleVC setNotReadCount:notReadCount];
//                if (chatSingleVC.needShowNewMsgTagCell) {
//
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                        chatSingleVC.readedMsgTimeStamp = [[STIMKit sharedInstance] getReadedTimeStampForUserId:jid WithRealJid:realJid WithMsgDirection:STIMMessageDirection_Received withUnReadCount:notReadCount];
//                    });
//                }
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                    [[STIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:realJid];
//                });
                return chatSingleVC;
            }
                break;
            case ChatType_PublicNumber: {
                STIMPublicNumberVC *chatPublicNumVC = [[STIMPublicNumberVC alloc] init];
                return chatPublicNumVC;
            }
                break;
            case ChatType_CollectionChat: {
#warning 代收消息
                STIMCollectionChatViewController *chatPublicNumVC = [[STIMCollectionChatViewController alloc] init];
                return chatPublicNumVC;
            }
                break;
            default:
                break;
        }
    }
    return nil;
}

- (NSString *)sessionViewTitleDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *infoDic = [self.dataManager.dataSource objectAtIndex:indexPath.row];
    NSString *name = [infoDic objectForKey:@"Name"];
    if (name) {
        return name;
    } else {
        return [NSBundle stimDB_localizedStringForKey:@"System Messages"];//@"系统消息";
    }
}

- (void)refreshCell {
    [self refreshTableView];
}

#pragma mark - UITableViewDataSource Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    STIMVerboseLog(@"确实刷新了");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.dataManager.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *dict = [[self.dataManager.dataSource objectAtIndex:indexPath.row] yy_modelToJSONObject];
    NSString *chatId = [dict objectForKey:@"XmppId"];
    NSString *realJid = [dict objectForKey:@"RealJid"];
//    NSString *cellIdentifier = cellReuseID;
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell ChatId(%@) RealJid(%@) %d", chatId, realJid, indexPath.row];
    QTalkNewSessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[QTalkNewSessionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setIndexPath:indexPath];
    [cell setAccessibilityIdentifier:chatId];
    cell.infoDic = dict;
    cell.sessionScrollDelegate = self.dataManager;
    [cell refreshUI];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    //请求数据源提交的插入或删除指定行接收者。
    if (editingStyle == UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式

        if (indexPath.row < [self.dataManager.dataSource count]) {

            NSDictionary *infoDic = [self.dataManager.dataSource objectAtIndex:indexPath.row];
            NSString *jid = [infoDic objectForKey:@"XmppId"];
            ChatType chatType = [[infoDic objectForKey:@"ChatType"] longValue];
            if (jid && (chatType != ChatType_Consult || chatType != ChatType_ConsultServer)) {

                [[STIMKit sharedInstance] removeSessionById:jid];
                [self.dataManager deleteModelFromSessionListWithIndex:index];

                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
            } else {
                NSString *realJid = [infoDic objectForKey:@"RealJid"];
                [[STIMKit sharedInstance] removeConsultSessionById:jid RealId:realJid];
                [self.dataManager deleteModelFromSessionListWithIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
            }
        }
    }
}

- (void)prepareNotReaderIndexPathList {
    dispatch_async(self.update_reader_list_queue, ^{
        if (!self.notReaderIndexPathList) {
            self.notReaderIndexPathList = [NSMutableArray arrayWithCapacity:3];
        }
        [self.notReaderIndexPathList removeAllObjects];
        int i = 0;
        NSArray *arr = [NSArray arrayWithArray:self.dataManager.dataSource];
        NSMutableArray *tempNotReadList = [[NSMutableArray alloc] initWithCapacity:3];
        for (QtalkSessionModel *infoModel in arr) {
            NSInteger unreadCount = infoModel.UnreadCount.integerValue;
            if (unreadCount > 0) {
                [tempNotReadList addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            i++;
        }
        self.notReaderIndexPathList = [NSMutableArray arrayWithArray:tempNotReadList];
        self.needUpdateNotReadList = NO;
        [self scrollToNotReadMsg];
    });
}

- (void)scrollToNotReadMsg {

    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *tempNotReaderIndexPathList = [[NSArray alloc] initWithArray:self.notReaderIndexPathList];
        if ([tempNotReaderIndexPathList count] <= 0) {
            //
            // 如果就木有，那么随便了，你可以在这里增加各种逻辑
        } else {

            NSIndexPath *totalBeginPath = nil;
            NSIndexPath *totalEndPath = nil;

            NSInteger nSections = [_tableView numberOfSections];
            if (nSections > 0) {

                totalBeginPath = [NSIndexPath indexPathForRow:0 inSection:0];

                for (int section = 0; section < nSections; section++) {
                    NSInteger rows = [_tableView numberOfRowsInSection:section];
                    totalEndPath = [NSIndexPath indexPathForRow:rows - 1 inSection:section];
                }
            }

            NSIndexPath *firstPath = [[_tableView indexPathsForVisibleRows] firstObject];
            NSIndexPath *lastPath = [[_tableView indexPathsForVisibleRows] lastObject];

            NSIndexPath *firstUnreadPath = [tempNotReaderIndexPathList firstObject];
            NSIndexPath *lastUnreadPath = [tempNotReaderIndexPathList lastObject];
            if (lastPath == totalEndPath) {
                [_tableView scrollToRowAtIndexPath:firstUnreadPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            } else {
                if (lastUnreadPath.row <= firstPath.row) {
                    //
                    // 如果最后一条未读 在当前可视的上面，那么就轮到最前面一条
                    [_tableView scrollToRowAtIndexPath:firstUnreadPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                } else {

                    NSIndexPath *currentPath = [NSIndexPath indexPathForRow:firstPath.row + 1 inSection:0];

                    while (YES) {
                        if ([tempNotReaderIndexPathList containsObject:currentPath]) {
                            [_tableView scrollToRowAtIndexPath:currentPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            break;
                        }
                        currentPath = [NSIndexPath indexPathForRow:currentPath.row + 1 inSection:0];
                    }
                }
            }
        }
    });
}

#if __has_include("STIMNotifyManager.h")

- (void)showGloablNotifyWithView:(STIMNotifyView *)view {
    STIMVerboseLog(@"showGloablNotifyWithViewDelegate :%@", view);
    if ([self.appendHeaderViews containsObject:view]) {
        [self.appendHeaderViews removeObject:view];
    }
    [self.appendHeaderViews addObject:view];
    [self updateTableViewHeaderView];
}

- (void)closeNotifyView:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMNotifyView *notifyView = notify.object;
        [self.appendHeaderViews removeObject:notifyView];
        [self updateTableViewHeaderView];
    });
}

#endif

- (void)updateTableViewHeaderView {
    [self.tableView setTableHeaderView:[self tableViewHeaderView]];
}

#pragma mark - STIMSearchBarDelegate

- (void)stimDB_searchBarBecomeFirstResponder {

#if __has_include("QTalkSearchViewManager.h")
#if __has_include("STIMAutoTracker.h")

    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"search" withDescription:@"搜索"];
#endif
    [STIMFastEntrance openRNSearchVC];
#endif
}

@end

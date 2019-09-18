//
//  QIMWorkFeedMYCirrleViewController.m
//  QIMUIKit
//
//  Created by Kamil on 2019/5/14.
//

#import "QIMWorkFeedMYCirrleViewController.h"
#import "QIMWorkMomentPushViewController.h"
#import "QIMworkFeedView.h"
#if __has_include("QIMAutoTracker.h")
#import "QIMAutoTracker.h"
#endif
#import "QIMWorkFeedMessageView.h"
#import "UIScreen+QIMIpad.h"
#import "QIMKit+QIMWorkFeed.h"
#import "QIMWorkOwnerCamelTabBar.h"
#import "QIMWorkNoticeMessageModel.h"

@interface QIMWorkFeedMYCirrleViewController ()<QIMWorkFeedMessageViewDataSource,QIMWorkOwnerCamelTabBarDelegate,UIScrollViewDelegate,QIMWorkOwnerCamelTabBarDelegate>
@property (nonatomic, strong) UIButton *addNewMomentBtn;
@property (nonatomic, strong) QIMWorkOwnerCamelTabBar * tabBarView;
@property (nonatomic, strong) UIScrollView * scrollview;
@property (nonatomic, strong) QIMWorkFeedView * myMomentView;
@property (nonatomic, strong) QIMWorkFeedMessageView * atMeView;
@property (nonatomic, strong) QIMWorkFeedMessageView * myReplyView;


@end

@implementation QIMWorkFeedMYCirrleViewController

- (UIButton *)addNewMomentBtn {
    if (!_addNewMomentBtn) {
        _addNewMomentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addNewMomentBtn.frame = CGRectMake(0, 0, 23, 23);
        [_addNewMomentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_addnewmoment_font size:28 color:qim_nav_addnewmoment_btnColor]] forState:UIControlStateNormal];
        [_addNewMomentBtn addTarget:self action:@selector(jumpToAddNewMomentVc) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewMomentBtn;
}

- (UIScrollView *)scrollview{
    if (!_scrollview) {
        
        _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 51, [[UIScreen mainScreen]qim_rightWidth], self.view.height - 51)];
        _scrollview.contentSize = CGSizeMake(3*[[UIScreen mainScreen]qim_rightWidth],self.view.height - 51);
        _scrollview.pagingEnabled = YES;
        _scrollview.backgroundColor = [UIColor clearColor];
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.delegate = self;
        _scrollview.scrollEnabled = YES;
        _scrollview.bounces = NO;
    }
    return _scrollview;
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor qim_colorWithHex:0xF7F7F7];
    [self setupNav];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor qim_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupNav {
    self.navigationController.navigationBar.translucent = NO;
    self.title = (self.userId.length <= 0) ? @"驼圈" : [NSString stringWithFormat:@"%@的驼圈", [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.userId]];
    if ([self.userId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
        self.title = [NSBundle qim_localizedStringForKey:@"moment_my_moments"];
        UIBarButtonItem *newMomentBtn = [[UIBarButtonItem alloc] initWithCustomView:self.addNewMomentBtn];
        self.navigationItem.rightBarButtonItem = newMomentBtn;
    }
    if (self.userId.length <= 0) {
        UIBarButtonItem *newMomentBtn = [[UIBarButtonItem alloc] initWithCustomView:self.addNewMomentBtn];
        self.navigationItem.rightBarButtonItem = newMomentBtn;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarView = [[QIMWorkOwnerCamelTabBar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]qim_rightWidth], 51)];
    self.tabBarView.delegate = self;
    [self.view addSubview:self.tabBarView];
    
    self.view.backgroundColor = [UIColor qim_colorWithHex:0xF8F8F8];
    
    [self.view addSubview:self.scrollview];

    self.myMomentView = [[QIMWorkFeedView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]qim_rightWidth], self.scrollview.height) userId:self.userId showNewMomentBtn:NO showNoticView:NO];
    self.myMomentView.userId = self.userId;
    self.myMomentView.rootVC = self;
    [self.scrollview addSubview:self.myMomentView];
    
    self.myReplyView = [[QIMWorkFeedMessageView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]qim_rightWidth], 0, [[UIScreen mainScreen]qim_rightWidth], self.scrollview.height) dataSource:self AndViewTag:0];
    self.myReplyView.delegate = self;
    self.myReplyView.messageCellType = QIMWorkMomentCellTypeMyREPLY;
    [self.myReplyView updateNewData];
    [self.scrollview addSubview:self.myReplyView];
    
    self.atMeView = [[QIMWorkFeedMessageView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]qim_rightWidth]*2, 0, [[UIScreen mainScreen]qim_rightWidth], self.scrollview.height) dataSource:self AndViewTag:1];
    self.atMeView.messageCellType = QIMWorkMomentCellTypeMyAT;
    self.atMeView.delegate = self;
    [self.atMeView updateNewData];
    [self.scrollview addSubview:self.atMeView];
    //R
//    [self.view addSubview:self.myMomentView];
    
#if __has_include("QIMAutoTracker.h")
    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"tuocircle" withDescription:@"驼圈"];
#endif
}

- (void)test{
    NSLog(@"testtesttest");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@(0)];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//我的驼圈儿添加入口
- (void)jumpToAddNewMomentVc {
    
    QIMWorkMomentPushViewController *newMomentVc = [[QIMWorkMomentPushViewController alloc] init];
    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
        QIMNavController *newMomentNav = [[QIMNavController alloc] initWithRootViewController:newMomentVc];
        newMomentNav.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:newMomentNav animated:YES completion:nil];
    } else {
        QIMNavController *newMomentNav = [[QIMNavController alloc] initWithRootViewController:newMomentVc];
        [self presentViewController:newMomentNav animated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[QIMImageManager sharedInstance] clearMemory];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotify_RN_QTALK_SUGGEST_WorkFeed_UPDATE object:nil];
}

#pragma UIScrollViewDeleagete

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x = scrollView.contentOffset.x;
    [self.tabBarView viewXOffset:x];
}


#pragma QIMWorkOwnerCamelTabBarDelegate
- (void)tabBarBtnClickedIndex:(NSInteger)index{
    [self.scrollview setContentOffset:CGPointMake(index * [[UIScreen mainScreen] qim_rightWidth], 0) animated:YES];
}


#pragma QIMWorkFeedMessageViewDataSource
- (NSArray *)qImWorkFeedMessageViewOriginDataSourceWithViewTag:(NSInteger)viewTag {
    if (viewTag == 0) {
        return [[QIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(QIMWorkFeedNotifyTypeMyComment)]];
    } else {
        
        return [[QIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(QIMWorkFeedNotifyTypePOSTAt), @(QIMWorkFeedNotifyTypeCommentAt)]];
    }
}

- (NSDictionary *)qImWorkFeedMessageViewModelWithMomentPostUUID:(NSString *)momentId viewTag:(NSInteger)viewTag{
    return [[QIMKit sharedInstance] getWorkMomentWithMomentId:momentId];
}

#pragma QIMWorkFeedMessageViewDelegate
- (void)qImWorkFeedMessageViewMoreDataSourceWithviewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block{
    if (viewTag == 0) {
        if (self.myReplyView.noticeMsgs.count > 0) {
            NSArray *tempArr = [[QIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:self.myReplyView.noticeMsgs.count eventTypes:@[@(QIMWorkFeedNotifyTypeMyComment)]];
            if (tempArr.count > 0) {
                block(tempArr);
            }
            else{
                QIMWorkNoticeMessageModel * model = self.myReplyView.noticeMsgs.lastObject;
                [[QIMKit sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:model.createTime pageSize:20 complete:block];
            }
        }
        else{
            [[QIMKit sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:0 pageSize:20 complete:block];
        }
    }
    else{
        if (self.atMeView.noticeMsgs.count > 0) {
            NSArray *tempArr = [[QIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:self.atMeView.noticeMsgs.count eventTypes:@[@(QIMWorkFeedNotifyTypePOSTAt), @(QIMWorkFeedNotifyTypeCommentAt)]];
            if (tempArr.count > 0) {
                block(tempArr);
            }
            else{
                QIMWorkNoticeMessageModel * model = self.atMeView.noticeMsgs.lastObject;
                [[QIMKit sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:model.createTime pageSize:20 complete:block];
            }
        }
        else{
            [[QIMKit sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:0 pageSize:20 complete:block];
        }
    }
}

-(void)qImWorkFeedMessageViewLoadNewDataWithNewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block{
    if (viewTag == 0) {
        [[QIMKit sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:0 pageSize:20 complete:block];
    }
    else{
        [[QIMKit sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:0 pageSize:20  complete:block];
    }
}


@end

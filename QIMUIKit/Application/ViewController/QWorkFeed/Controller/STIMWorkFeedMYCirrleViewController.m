//
//  STIMWorkFeedMYCirrleViewController.m
//  STIMUIKit
//
//  Created by Kamil on 2019/5/14.
//

#import "STIMWorkFeedMYCirrleViewController.h"
#import "STIMWorkMomentPushViewController.h"
#import "STIMworkFeedView.h"
#if __has_include("STIMAutoTracker.h")
#import "STIMAutoTracker.h"
#endif
#import "STIMWorkFeedMessageView.h"
#import "UIScreen+STIMIpad.h"
#import "STIMKit+STIMWorkFeed.h"
#import "STIMWorkOwnerCamelTabBar.h"
#import "STIMWorkNoticeMessageModel.h"

@interface STIMWorkFeedMYCirrleViewController ()<STIMWorkFeedMessageViewDataSource,STIMWorkOwnerCamelTabBarDelegate,UIScrollViewDelegate,STIMWorkOwnerCamelTabBarDelegate>
@property (nonatomic, strong) UIButton *addNewMomentBtn;
@property (nonatomic, strong) STIMWorkOwnerCamelTabBar * tabBarView;
@property (nonatomic, strong) UIScrollView * scrollview;
@property (nonatomic, strong) STIMWorkFeedView * myMomentView;
@property (nonatomic, strong) STIMWorkFeedMessageView * atMeView;
@property (nonatomic, strong) STIMWorkFeedMessageView * myReplyView;


@end

@implementation STIMWorkFeedMYCirrleViewController

- (UIButton *)addNewMomentBtn {
    if (!_addNewMomentBtn) {
        _addNewMomentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addNewMomentBtn.frame = CGRectMake(0, 0, 23, 23);
        [_addNewMomentBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:stimDB_nav_addnewmoment_font size:28 color:stimDB_nav_addnewmoment_btnColor]] forState:UIControlStateNormal];
        [_addNewMomentBtn addTarget:self action:@selector(jumpToAddNewMomentVc) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewMomentBtn;
}

- (UIScrollView *)scrollview{
    if (!_scrollview) {
        
        _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 51, [[UIScreen mainScreen]stimDB_rightWidth], self.view.height - 51)];
        _scrollview.contentSize = CGSizeMake(3*[[UIScreen mainScreen]stimDB_rightWidth],self.view.height - 51);
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
    self.navigationController.navigationBar.barTintColor = [UIColor stimDB_colorWithHex:0xF7F7F7];
    [self setupNav];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor stimDB_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupNav {
    self.navigationController.navigationBar.translucent = NO;
    self.title = (self.userId.length <= 0) ? @"驼圈" : [NSString stringWithFormat:@"%@的驼圈", [[STIMKit sharedInstance] getUserMarkupNameWithUserId:self.userId]];
    if ([self.userId isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
        self.title = [NSBundle stimDB_localizedStringForKey:@"moment_my_moments"];
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
    self.tabBarView = [[STIMWorkOwnerCamelTabBar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]stimDB_rightWidth], 51)];
    self.tabBarView.delegate = self;
    [self.view addSubview:self.tabBarView];
    
    self.view.backgroundColor = [UIColor stimDB_colorWithHex:0xF8F8F8];
    
    [self.view addSubview:self.scrollview];

    self.myMomentView = [[STIMWorkFeedView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]stimDB_rightWidth], self.scrollview.height) userId:self.userId showNewMomentBtn:NO showNoticView:NO];
    self.myMomentView.userId = self.userId;
    self.myMomentView.rootVC = self;
    [self.scrollview addSubview:self.myMomentView];
    
    self.myReplyView = [[STIMWorkFeedMessageView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]stimDB_rightWidth], 0, [[UIScreen mainScreen]stimDB_rightWidth], self.scrollview.height) dataSource:self AndViewTag:0];
    self.myReplyView.delegate = self;
    self.myReplyView.messageCellType = STIMWorkMomentCellTypeMyREPLY;
    [self.myReplyView updateNewData];
    [self.scrollview addSubview:self.myReplyView];
    
    self.atMeView = [[STIMWorkFeedMessageView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]stimDB_rightWidth]*2, 0, [[UIScreen mainScreen]stimDB_rightWidth], self.scrollview.height) dataSource:self AndViewTag:1];
    self.atMeView.messageCellType = STIMWorkMomentCellTypeMyAT;
    self.atMeView.delegate = self;
    [self.atMeView updateNewData];
    [self.scrollview addSubview:self.atMeView];
    //R
//    [self.view addSubview:self.myMomentView];
    
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"tuocircle" withDescription:@"驼圈"];
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
    
    STIMWorkMomentPushViewController *newMomentVc = [[STIMWorkMomentPushViewController alloc] init];
    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
        STIMNavController *newMomentNav = [[STIMNavController alloc] initWithRootViewController:newMomentVc];
        newMomentNav.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:newMomentNav animated:YES completion:nil];
    } else {
        STIMNavController *newMomentNav = [[STIMNavController alloc] initWithRootViewController:newMomentVc];
        [self presentViewController:newMomentNav animated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[STIMImageManager sharedInstance] clearMemory];
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


#pragma STIMWorkOwnerCamelTabBarDelegate
- (void)tabBarBtnClickedIndex:(NSInteger)index{
    [self.scrollview setContentOffset:CGPointMake(index * [[UIScreen mainScreen] stimDB_rightWidth], 0) animated:YES];
}


#pragma STIMWorkFeedMessageViewDataSource
- (NSArray *)qImWorkFeedMessageViewOriginDataSourceWithViewTag:(NSInteger)viewTag {
    if (viewTag == 0) {
        return [[STIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(STIMWorkFeedNotifyTypeMyComment)]];
    } else {
        
        return [[STIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)]];
    }
}

- (NSDictionary *)qImWorkFeedMessageViewModelWithMomentPostUUID:(NSString *)momentId viewTag:(NSInteger)viewTag{
    return [[STIMKit sharedInstance] getWorkMomentWithMomentId:momentId];
}

#pragma STIMWorkFeedMessageViewDelegate
- (void)qImWorkFeedMessageViewMoreDataSourceWithviewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block{
    if (viewTag == 0) {
        if (self.myReplyView.noticeMsgs.count > 0) {
            NSArray *tempArr = [[STIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:self.myReplyView.noticeMsgs.count eventTypes:@[@(STIMWorkFeedNotifyTypeMyComment)]];
            if (tempArr.count > 0) {
                block(tempArr);
            }
            else{
                STIMWorkNoticeMessageModel * model = self.myReplyView.noticeMsgs.lastObject;
                [[STIMKit sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:model.createTime pageSize:20 complete:block];
            }
        }
        else{
            [[STIMKit sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:0 pageSize:20 complete:block];
        }
    }
    else{
        if (self.atMeView.noticeMsgs.count > 0) {
            NSArray *tempArr = [[STIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:self.atMeView.noticeMsgs.count eventTypes:@[@(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)]];
            if (tempArr.count > 0) {
                block(tempArr);
            }
            else{
                STIMWorkNoticeMessageModel * model = self.atMeView.noticeMsgs.lastObject;
                [[STIMKit sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:model.createTime pageSize:20 complete:block];
            }
        }
        else{
            [[STIMKit sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:0 pageSize:20 complete:block];
        }
    }
}

-(void)qImWorkFeedMessageViewLoadNewDataWithNewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block{
    if (viewTag == 0) {
        [[STIMKit sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:0 pageSize:20 complete:block];
    }
    else{
        [[STIMKit sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:0 pageSize:20  complete:block];
    }
}


@end

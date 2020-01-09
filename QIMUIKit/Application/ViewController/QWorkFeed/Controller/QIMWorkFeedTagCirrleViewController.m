//
//  QIMWorkFeedTagCirrleViewController.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/24.
//

#import "QIMWorkFeedTagCirrleViewController.h"

#import "QIMWorkMomentPushViewController.h"
#import "QIMworkFeedView.h"
#if __has_include("QIMAutoTracker.h")
#import "QIMAutoTracker.h"
#endif

@interface QIMWorkFeedTagCirrleViewController ()
@property (nonatomic, strong) QIMWorkFeedView * myMomentView;
@property (nonatomic, strong) UIButton *addNewMomentBtn;
@end

@implementation QIMWorkFeedTagCirrleViewController

- (UIButton *)addNewMomentBtn {
    if (!_addNewMomentBtn) {
        _addNewMomentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addNewMomentBtn.frame = CGRectMake(0, 0, 23, 23);
        [_addNewMomentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_nav_addnewmoment_font size:28 color:qim_nav_addnewmoment_btnColor]] forState:UIControlStateNormal];
        [_addNewMomentBtn addTarget:self action:@selector(jumpToAddNewMomentVc) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewMomentBtn;
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
    self.title = @"话题";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor qim_colorWithHex:0xF8F8F8];
    self.myMomentView = [[QIMWorkFeedView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]qim_rightWidth], self.view.height) tagID:self.tagId showNewMomentBtn:YES showNoticView:NO showHeaderTagView:YES];
    self.myMomentView.rootVC = self;
    self.myMomentView.tagID = self.tagId;
    [self.view addSubview:self.myMomentView];
#if __has_include("QIMAutoTracker.h")
    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"tuocircle" withDescription:@"驼圈"];
#endif
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

#pragma QIMWorkFeedMessageViewDataSource
//- (NSArray *)qImWorkFeedMessageViewOriginDataSourceWithViewTag:(NSInteger)viewTag {
//    if (viewTag == 0) {
//        return [[QIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(QIMWorkFeedNotifyTypeMyComment)]];
//    } else {
//
//        return [[QIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(QIMWorkFeedNotifyTypePOSTAt), @(QIMWorkFeedNotifyTypeCommentAt)]];
//    }
//}
//
//- (NSDictionary *)qImWorkFeedMessageViewModelWithMomentPostUUID:(NSString *)momentId viewTag:(NSInteger)viewTag{
//    return [[QIMKit sharedInstance] getWorkMomentWithMomentId:momentId];
//}

#pragma QIMWorkFeedMessageViewDelegate

//-(void)qImWorkFeedMessageViewLoadNewDataWithNewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block{
//    if (viewTag == 0) {
//        [[QIMKit sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:0 pageSize:20 complete:block];
//    }
//    else{
//        [[QIMKit sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:0 pageSize:20  complete:block];
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

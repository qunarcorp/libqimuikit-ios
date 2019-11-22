//
//  STIMWorkFeedViewController.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/2.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkFeedViewController.h"
#import "STIMWorkMomentPushViewController.h"
#import "STIMWorkFeedDetailViewController.h"
#import "STIMWorkMomentCell.h"
#import "STIMWorkMomentModel.h"
#import "STIMWorkMomentContentModel.h"
#import "STIMMessageRefreshHeader.h"
#import "STIMWorkMomentNotifyView.h"
#import "STIMWorkFeedMessageViewController.h"
#import "LCActionSheet.h"
#import "STIMMessageCellCache.h"
#import <YYModel/YYModel.h>
#import <MJRefresh/MJRefresh.h>
#if __has_include("STIMAutoTracker.h")
#import "STIMAutoTracker.h"
#endif

@interface STIMWorkFeedViewController () <UITableViewDelegate, UITableViewDataSource, STIMWorkMomentNotifyViewDelegtae>

@property (nonatomic, strong) UIButton *addNewMomentBtn;

@property (nonatomic, strong) NSMutableArray *workMomentList;

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UIView *loadFaildView;

@property (nonatomic, strong) STIMWorkMomentNotifyView *notifyView;

@property (nonatomic, assign) NSInteger notReadNoticeMsgCount;

@property (nonatomic, strong) STIMWorkMomentModel *currentModel;

@property (nonatomic, assign) BOOL notNeedReloadMomentView;

@end

@implementation STIMWorkFeedViewController

- (UIButton *)addNewMomentBtn {
    if (!_addNewMomentBtn) {
        _addNewMomentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addNewMomentBtn.frame = CGRectMake(0, 0, 23, 23);
        [_addNewMomentBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:stimDB_nav_addnewmoment_font size:28 color:stimDB_nav_addnewmoment_btnColor]] forState:UIControlStateNormal];
        [_addNewMomentBtn addTarget:self action:@selector(jumpToAddNewMomentVc) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewMomentBtn;
}

- (NSMutableArray *)workMomentList {
    if (!_workMomentList) {
        _workMomentList = [NSMutableArray arrayWithCapacity:3];
    }
    return _workMomentList;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _mainTableView.backgroundColor = [UIColor stimDB_colorWithHex:0xf8f8f8];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.estimatedRowHeight = 0;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _mainTableView.separatorColor = [UIColor stimDB_colorWithHex:0xdddddd];
        
        _mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadRemoteRecenteMoments)];
        _mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMoment)];
        _mainTableView.mj_footer.automaticallyHidden = YES;
    }
    return _mainTableView;
}

- (UIView *)loadFaildView {
    if (!_loadFaildView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 54)];
        view.backgroundColor = [UIColor stimDB_colorWithHex:0xF8F8F9];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 21)];
        label.text = @"全部看完啦";
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor stimDB_colorWithHex:0xBFBFBF]];
        label.font = [UIFont systemFontOfSize:15];
        [view addSubview:label];
        label.center = view.center;
        
        UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(label.left - 50, 1, 40, 0.5f)];
        leftLineView.backgroundColor = [UIColor stimDB_colorWithHex:0xBFBFBF];
        [view addSubview:leftLineView];
        leftLineView.centerY = label.centerY;
        
        UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(label.right + 10, 1, 40, 0.5f)];
        rightLineView.backgroundColor = [UIColor stimDB_colorWithHex:0xBFBFBF];
        [view addSubview:rightLineView];
        rightLineView.centerY = label.centerY;
        
        _loadFaildView = view;
    }
    return _loadFaildView;
}

- (STIMWorkMomentNotifyView *)notifyView {
    if (!_notifyView) {
        _notifyView = [[STIMWorkMomentNotifyView alloc] initWithNewMsgCount:1];
        _notifyView.delegate = self;
    }
    _notifyView.msgCount = self.notReadNoticeMsgCount;
    return _notifyView;
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor stimDB_colorWithHex:0xF7F7F7];

    
    [self setupNav];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor stimDB_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
    
    [self.view addSubview:self.mainTableView];
    self.notReadNoticeMsgCount = [[STIMKit sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(STIMWorkFeedNotifyTypeComment), @(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)]];
    if (self.notReadNoticeMsgCount > 0 && self.userId.length <= 0) {
        [self.mainTableView reloadData];
    } else {
        
    }
    [self reloadLocalRecenteMoments:self.notNeedReloadMomentView];
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupNav {
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

- (void)registerNotifications {
    if (self.userId.length <= 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNoticeMsg:) name:kPBPresenceCategoryNotifyWorkNoticeMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLocalWorkFeed:) name:kNotifyReloadWorkFeed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMomentAttachCommentList:) name:kNotifyReloadWorkFeedAttachCommentList object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenSTIMWorkFeedDetail:) name:@"openWorkMomentDetailNotify" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stimDB_colorWithHex:0xF8F8F8];
    [self registerNotifications];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self reloadRemoteRecenteMoments];
    });
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"tuocircle" withDescription:@"驼圈"];
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkNoticeCount":@(0)}];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)getIndexOfMoments:(STIMWorkMomentModel *)model {
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.workMomentList.count; i++) {
        STIMWorkMomentModel *tempMomentModel = [self.workMomentList objectAtIndex:i];
        if ([tempMomentModel.momentId isEqualToString:model.momentId]) {
            index = i;
        }
    }
    return index;
}

- (NSInteger)getIndexOfMomentId:(NSString *)momentId {
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.workMomentList.count; i++) {
        STIMWorkMomentModel *tempMomentModel = [self.workMomentList objectAtIndex:i];
        if ([tempMomentModel.momentId isEqualToString:momentId]) {
            index = i;
        }
    }
    return index;
}

- (void)reloadMomentAttachCommentList:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainTableView reloadData];
//        NSDictionary *data = notify.object;
//        NSString *postId = [data objectForKey:@"postId"];
//        NSInteger momentIndex = [self getIndexOfMomentId:postId];
//        if (momentIndex >= 0 && momentIndex < self.workMomentList.count) {
//            [self.mainTableView reloadData];
//        }
    });
}

- (void)OpenSTIMWorkFeedDetail:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *momentId = notify.object;
        if (momentId.length > 0) {
            STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
            detailVc.momentId = momentId;
            self.notNeedReloadMomentView = YES;
            [self.navigationController pushViewController:detailVc animated:YES];
        }
    });
}

//加载本地最近的帖子
- (void)reloadLocalRecenteMoments:(BOOL)notNeedReloadMomentView {
    if (notNeedReloadMomentView == NO && self.workMomentList.count <= 0) {
        __weak typeof(self) weakSelf = self;
        [[STIMKit sharedInstance] getWorkMomentWithLastMomentTime:0 withUserXmppId:self.userId WithLimit:10 WithOffset:0 withFirstLocalMoment:YES WithComplete:^(NSArray * _Nonnull array) {
            if (array.count) {
                [weakSelf.workMomentList removeAllObjects];
                for (NSDictionary *momentDic in array) {
                    if ([momentDic isKindOfClass:[NSDictionary class]]) {
                        STIMWorkMomentModel *model = [weakSelf getMomentModelWithDic:momentDic];
                        [weakSelf.workMomentList addObject:model];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.mainTableView reloadData];
                    [weakSelf.mainTableView setContentOffset:CGPointZero animated:YES];
                });
            }
        }];
    }
}

//加载远程最近的帖子
- (void)reloadRemoteRecenteMoments {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[STIMKit sharedInstance] getWorkMomentWithLastMomentTime:0 withUserXmppId:self.userId WithLimit:20 WithOffset:0 withFirstLocalMoment:NO WithComplete:^(NSArray * _Nonnull moments) {
            if (moments) {
                [weakSelf.workMomentList removeAllObjects];
                for (NSDictionary *momentDic in moments) {
                    STIMWorkMomentModel *model = [weakSelf getMomentModelWithDic:momentDic];
                    [weakSelf.workMomentList addObject:model];
                }
                [[STIMMessageCellCache sharedInstance] clearUp];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.mainTableView reloadData];
                    [weakSelf.mainTableView.mj_header endRefreshing];
                });
            } else {
                
            }
        }];
    });
}

//上滑加载更多的帖子
- (void)loadMoreMoment {
    __weak typeof(self) weakSelf = self;
    STIMWorkMomentModel *lastModel = [self.workMomentList lastObject];
    STIMVerboseLog(@"lastModel : %@", lastModel);
    
    [[STIMKit sharedInstance] getWorkMoreMomentWithLastMomentTime:[lastModel.createTime longLongValue] withUserXmppId:self.userId WithLimit:20 WithOffset:self.workMomentList.count withFirstLocalMoment:NO WithComplete:^(NSArray * _Nonnull array) {
        if (array.count) {
            for (NSDictionary *momentDic in array) {
                STIMWorkMomentModel *model = [weakSelf getMomentModelWithDic:momentDic];
                [weakSelf.workMomentList addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mainTableView reloadData];
                [weakSelf.mainTableView.mj_footer endRefreshing];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mainTableView.mj_footer endRefreshing];
                weakSelf.mainTableView.mj_footer = nil;
                weakSelf.mainTableView.tableFooterView = [self loadFaildView];
            });
        }
    }];
}

- (STIMWorkMomentModel *)getMomentModelWithDic:(NSDictionary *)momentDic {
    
    STIMWorkMomentModel *model = [STIMWorkMomentModel yy_modelWithDictionary:momentDic];
    NSDictionary *contentModelDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    STIMWorkMomentContentModel *conModel = [STIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    model.content = conModel;
    return model;
}

#pragma mark - NSNotifications

- (void)reloadNoticeMsg:(NSNotification *)notify {
    self.notReadNoticeMsgCount = [[STIMKit sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(STIMWorkFeedNotifyTypeComment), @(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)]];
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.mainTableView reloadData];
    });
}

- (void)reloadLocalWorkFeed:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *newPosts = notify.object;
        if (newPosts.count > 0) {
            [self.workMomentList removeAllObjects];
            for (NSDictionary *momentDic in newPosts) {
                STIMWorkMomentModel *model = [self getMomentModelWithDic:momentDic];
                [self.workMomentList addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTableView reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [UIView animateWithDuration:0.2 animations:^{
                    [self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                } completion:nil];
            });
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotify_RN_QTALK_SUGGEST_WorkFeed_UPDATE object:nil];
}

- (void)jumpToAddNewMomentVc {
    
    STIMWorkMomentPushViewController *newMomentVc = [[STIMWorkMomentPushViewController alloc] init];
    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
        STIMNavController *newMomentNav = [[STIMNavController alloc] initWithRootViewController:newMomentVc];
        newMomentNav.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.notNeedReloadMomentView = YES;
        [self presentViewController:newMomentNav animated:YES completion:nil];
    } else {
        STIMNavController *newMomentNav = [[STIMNavController alloc] initWithRootViewController:newMomentVc];
        self.notNeedReloadMomentView = YES;
        [self presentViewController:newMomentNav animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.workMomentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkMomentModel *model = [self.workMomentList objectAtIndex:indexPath.row];
    NSString *identifier = model.momentId;
    STIMWorkMomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[STIMWorkMomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.delegate = self;
    cell.moment = model;
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkMomentCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self didAddComment:cell];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使用缓存行高，避免计算多次
    STIMWorkMomentModel *model = [self.workMomentList objectAtIndex:indexPath.row];
    if (model.rowHeight <= 0) {
        return 100;
    } else {
        return model.rowHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.notReadNoticeMsgCount > 0 && self.userId.length <= 0) {
        return 54.0f;
    }
    return 0.000001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.notReadNoticeMsgCount > 0 && self.userId.length <= 0) {
        return self.notifyView;
    }
    return nil;
}

#pragma mark - xxx

//操作这条Moment
- (void)didControlPanelMoment:(STIMWorkMomentCell *)cell {
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [indexSet addIndex:1];
    __weak __typeof(self) weakSelf = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                             cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"]
                                                       clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                                                           __typeof(self) strongSelf = weakSelf;
                                                           if (!strongSelf) {
                                                               return;
                                                           }
                                                           if (buttonIndex == 1) {
                                                               [[STIMKit sharedInstance] deleteRemoteMomentWithMomentId:cell.moment.momentId];
                                                               NSInteger index = [strongSelf getIndexOfMoments:cell.moment];
                                                               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                                               [strongSelf.workMomentList removeObjectAtIndex:index];
                                                               [strongSelf.mainTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                           } else if (buttonIndex == 2) {
                                                               [strongSelf didAddComment:cell];
                                                           }
                                                       }
                                         otherButtonTitleArray:@[[NSBundle stimDB_localizedStringForKey:@"Delete"], [NSBundle stimDB_localizedStringForKey:@"Reply"]]];
    actionSheet.destructiveButtonIndexSet = indexSet;
    actionSheet.destructiveButtonColor = [UIColor stimDB_colorWithHex:0xF4333C];
    [actionSheet show];
}

- (void)didControlDebugPanelMoment:(STIMWorkMomentCell *)cell {
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [indexSet addIndex:1];
    __weak __typeof(self) weakSelf = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                             cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"]
                                                       clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                                                           __typeof(self) strongSelf = weakSelf;
                                                           if (!strongSelf) {
                                                               return;
                                                           }
                                                           if (buttonIndex == 1) {
                                                               [strongSelf didLookOriginMoment:cell];
                                                           }
                                                       }
                                         otherButtonTitleArray:@[@"查看原帖"]];
    actionSheet.destructiveButtonIndexSet = indexSet;
    actionSheet.destructiveButtonColor = [UIColor stimDB_colorWithHex:0xF4333C];
    [actionSheet show];
}

- (void)didClickSmallImage:(STIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag {
        
    //初始化图片浏览控件
    if (model) {
        self.currentModel = model;
    }
    NSMutableArray *mutablImageList = [NSMutableArray arrayWithCapacity:3];
    NSArray *imageList = model.content.imgList;
    for (STIMWorkMomentPicture *picture in imageList) {
        NSString *imageUrl = picture.imageUrl;
        if (imageUrl.length > 0) {
            [mutablImageList addObject:imageUrl];
        }
    }
    
    [[STIMFastEntrance sharedInstance] browseBigHeader:@{@"imageUrlList": mutablImageList, @"CurrentIndex":@(tag)}];
}

- (void)didOpenWorkMomentDetailVc:(NSNotification *)notify {
    NSString *momentId = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
        detailVc.momentId = momentId;;
        self.notNeedReloadMomentView = YES;
        [self.navigationController pushViewController:detailVc animated:YES];
    });
}

// 评论
- (void)didAddComment:(STIMWorkMomentCell *)cell {
    STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
    detailVc.momentId = cell.moment.momentId;
    self.notNeedReloadMomentView = YES;
    [self.navigationController pushViewController:detailVc animated:YES];
}

//查看原始帖子
- (void)didLookOriginMoment:(STIMWorkMomentCell *)cell {
    NSString *originMoment = cell.moment.description;
    [[UIPasteboard generalPasteboard] setString:originMoment];
}

// 查看全文/收起
- (void)didSelectFullText:(STIMWorkMomentCell *)cell withFullText:(BOOL)isFullText {
    if (isFullText == YES) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
        [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        //收起
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
            [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    }
}

#pragma mark - STIMWorkMomentNotifyViewDelegtae

- (void)didClickNotifyView {
    NSLog(@"跳进消息列表页面");
    STIMWorkFeedMessageViewController *msgVc = [[STIMWorkFeedMessageViewController alloc] init];
    self.notNeedReloadMomentView = YES;
    [self.navigationController pushViewController:msgVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[STIMImageManager sharedInstance] clearMemory];
}

@end

//
//  STIMWorkFeedDetailViewController.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkFeedDetailViewController.h"
#import "STIMWorkMomentCell.h"
#import "STIMWorkMomentModel.h"
#import "STIMWorkMomentContentModel.h"
#import "STIMWorkCommentTableView.h"
#import "STIMWorkCommentInputBar.h"
#import "STIMWorkCommentModel.h"
#import "STIMWorkMomentUserIdentityVC.h"
#import "STIMWorkMomentUserIdentityModel.h"
#import "STIMUUIDTools.h"
#import <YYModel/YYModel.h>
#import "LCActionSheet.h"
#import "YYKeyboardManager.h"
#import "UIView+STIMToast.h"
#import "STIMWorkMomentView.h"
#import "UIApplication+STIMApplication.h"
#if __has_include("STIMIPadWindowManager.h")
    #import "STIMIPadWindowManager.h"
#endif


@interface STIMWorkFeedDetailViewController () <UITableViewDelegate, UITableViewDataSource, STIMWorkCommentTableViewDelegate, STIMWorkCommentInputBarDelegate, UIGestureRecognizerDelegate, MomentCellDelegate, YYKeyboardObserver, MomentViewDelegate>

@property (nonatomic, strong) STIMWorkMomentModel *momentModel;

@property (nonatomic, strong) STIMWorkCommentModel *staticCommentModel;

@property (nonatomic, strong) STIMWorkMomentCell *momentCell;

@property (nonatomic, strong) STIMWorkMomentView *momentView;

@property (nonatomic, strong) STIMWorkCommentTableView *commentListView;

@property (nonatomic, strong) STIMWorkCommentInputBar *commentInputBar;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, assign) CGFloat keyboardEndY;

@end

@implementation STIMWorkFeedDetailViewController

#pragma mark - setter and getter

- (STIMWorkMomentModel *)momentModel {
    if (!_momentModel) {
        NSDictionary *momentDic = [[STIMKit sharedInstance] getWorkMomentWithMomentId:self.momentId];
        if (!momentDic.count) {
            __weak __typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [[STIMKit sharedInstance] getRemoteMomentDetailWithMomentUUId:self.momentId withCallback:^(NSDictionary *momentDic) {
                    dispatch_async(dispatch_get_main_queue(), ^{                        
                        _momentModel = [STIMWorkMomentModel yy_modelWithDictionary:momentDic];
                        NSDictionary *contentModelDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
                        STIMWorkMomentContentModel *conModel = [STIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
                        _momentModel.content = conModel;
                        _momentModel.isFullText = YES;
                        _momentView.momentModel = _momentModel;
                        strongSelf.commentListView.commentHeaderView = _momentView;
                    });
                }];
            });
        } else {
            
        }
        _momentModel = [STIMWorkMomentModel yy_modelWithDictionary:momentDic];
        NSDictionary *contentModelDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
        STIMWorkMomentContentModel *conModel = [STIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
        _momentModel.content = conModel;
        _momentModel.isFullText = YES;
    }
    return _momentModel;
}

- (STIMWorkMomentView *)momentView {
    if (!_momentView) {
        _momentView = [[STIMWorkMomentView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20) withMomentModel:self.momentModel];
        _momentView.delegate = self;
    }
    return _momentView;
}

- (STIMWorkCommentTableView *)commentListView {
    if (!_commentListView) {
//        if ([[STIMKit sharedInstance] getIsIpad]) {
//            _commentListView = [[STIMWorkCommentTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 55 - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - [[STIMDeviceManager sharedInstance] getNAVIGATION_BAR_HEIGHT])];
//        } else {
            _commentListView = [[STIMWorkCommentTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 55 - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
//        }
        _commentListView.backgroundColor = [UIColor whiteColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 300)];
        view.backgroundColor = [UIColor whiteColor];
        _commentListView.commentHeaderView = self.momentView;
        _commentListView.commentDelegate = self;
    }
    _commentListView.commentNum = self.momentModel.commentsNum;
    return _commentListView;
}

- (STIMWorkCommentInputBar *)commentInputBar {
    if (!_commentInputBar) {
        _commentInputBar = [[STIMWorkCommentInputBar alloc] initWithFrame:CGRectMake(0, self.commentListView.bottom, self.view.width, 55 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        /*
        if ([[STIMKit sharedInstance] getIsIpad]) {
            _commentInputBar = [[STIMWorkCommentInputBar alloc] initWithFrame:CGRectMake(0, self.commentListView.bottom, self.view.width, 55 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        } else {
            _commentInputBar = [[STIMWorkCommentInputBar alloc] initWithFrame:CGRectMake(0, self.commentListView.bottom, self.view.width, 55 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        }
         */
        _commentInputBar.delegate = self;
    }
    [_commentInputBar setLikeNum:self.momentModel.likeNum withISLike:self.momentModel.isLike];
    [_commentInputBar setMomentId:self.momentModel.momentId];
    return _commentInputBar;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.alpha = 0.8;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSBundle stimDB_localizedStringForKey:@"moment_detail"];
    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
        [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] stimDB_rightWidth], [[UIScreen mainScreen] height])];
    }
    [[YYKeyboardManager defaultManager] addObserver:self];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor stimDB_colorWithHex:0x333333]}];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLocalComments) name:kNotifyReloadWorkComment object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCommentsAfterUpload:) name:kNotifyReloadWorkComment object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMomentCommentNum:) name:kNotifyReloadWorkFeedCommentNum object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginControlChildCommentWithComment:) name:@"beginControlChildCommentWithComment" object:nil];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor stimDB_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];

    [self.view addSubview:self.commentListView];
    [self.view addSubview:self.commentInputBar];
    [self loadComments];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateMomentCommentNum:(NSNotification *)notify {
    NSDictionary *data = notify.object;
    NSString *postId = [data objectForKey:@"postId"];
    if ([postId isEqualToString:self.momentId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.momentModel.commentsNum = [[data objectForKey:@"postCommentNum"] integerValue];
            [self.commentListView reloadCommentsData];
        });
    }
}

- (void)reloadCommentsAfterUpload:(NSNotification *)notify {
    NSDictionary *uploadCommentModelDic = notify.object;
    STIMWorkCommentModel *uploadCommentModel = [self getCommentModelWithDic:uploadCommentModelDic];
    [self.commentListView reloadUploadCommentWithModel:uploadCommentModel];
}

- (void)loadLocalComments {
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        [[STIMKit sharedInstance] getWorkCommentWithLastCommentRId:0 withMomentId:self.momentId WithLimit:20 WithOffset:0 withFirstLocalComment:YES WithComplete:^(NSArray * comments) {
            if (comments) {
                [weakSelf.commentListView.commentModels removeAllObjects];
                for (NSDictionary *commentDic in comments) {
                    STIMWorkCommentModel *model = [weakSelf getCommentModelWithDic:commentDic];
                    [weakSelf.commentListView.commentModels addObject:model];
                }
                [weakSelf.commentListView reloadCommentsData];
                [weakSelf.commentListView scrollCommentModelToTopIndex];
                if (comments.count < 20) {
                    [weakSelf.commentListView endRefreshingHeader];
                    [weakSelf.commentListView endRefreshingFooterWithNoMoreData];
                }
            }
        }];
    });
}

- (void)loadComments {

    __weak typeof(self) weakSelf = self;
    [[STIMKit sharedInstance] getRemoteRecentHotCommentsWithMomentId:self.momentId withHotCommentCallBack:^(NSArray *hotComments) {
        if ([hotComments isKindOfClass:[NSArray class]]) {
            [weakSelf.commentListView.hotCommentModels removeAllObjects];
            NSMutableArray *hotCommentIds = [NSMutableArray arrayWithCapacity:3];
            for (NSDictionary *commentDic in hotComments) {
                STIMWorkCommentModel *model = [weakSelf getCommentModelWithDic:commentDic];
                [hotCommentIds addObject:model.commentUUID];
                [weakSelf.commentListView.hotCommentModels addObject:model];
            }
            [[STIMKit sharedInstance] setHotCommentUUIds:hotCommentIds ForMomentId:self.momentId];
            [weakSelf.commentListView reloadCommentsData];
        } else {
            [[STIMKit sharedInstance] setHotCommentUUIds:@[] ForMomentId:self.momentId];
        }

        //拉完热评之后再拉新评
        [[STIMKit sharedInstance] getRemoteRecentNewCommentsWithMomentId:self.momentId withNewCommentCallBack:^(NSArray *comments) {
            if (comments) {
                [weakSelf.commentListView.commentModels removeAllObjects];
                for (NSDictionary *commentDic in comments) {
                    STIMWorkCommentModel *model = [weakSelf getCommentModelWithDic:commentDic];
                    [weakSelf.commentListView.commentModels addObject:model];
                }
                [weakSelf.commentListView reloadCommentsData];
                if (comments.count < 20) {
                    [weakSelf.commentListView endRefreshingHeader];
                    [weakSelf.commentListView endRefreshingFooterWithNoMoreData];
                }
            } else {
                [weakSelf.commentListView.commentModels removeAllObjects];
                [weakSelf.commentListView reloadCommentsData];
                [weakSelf.commentListView endRefreshingHeader];
                [weakSelf.commentListView endRefreshingFooterWithNoMoreData];

                if (weakSelf.commentListView.commentModels.count <= 0) {
                    //没有拉回来热评和普通评论，加载本地
                    [self loadLocalComments];
                }
            }
        }];
    }];
}

- (STIMWorkCommentModel *)getCommentModelWithDic:(NSDictionary *)momentDic {
    
    STIMWorkCommentModel *model = [STIMWorkCommentModel yy_modelWithDictionary:momentDic];
    return model;
}

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGRect kbFrame1 = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    CGFloat kbFrameOriginY = CGRectGetMinY(kbFrame1);
    CGFloat kbFrameHeight = CGRectGetHeight(kbFrame1);
    CGRect kbFrame = [[YYKeyboardManager defaultManager] keyboardFrame];
    if (kbFrameOriginY + kbFrameHeight > SCREEN_HEIGHT) {
        //键盘落下
        [UIView animateWithDuration:0.25 animations:^{
            //键盘落下
            self.commentInputBar.frame = CGRectMake(0, self.commentListView.bottom, self.view.width, 55 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]);
            [self.commentInputBar resignFirstInputBar:NO];
            [self.view sendSubviewToBack:self.maskView];
        } completion:nil];
    } else {
        //键盘弹起
        [UIView animateWithDuration:0.25 animations:^{
            self.commentInputBar.frame = CGRectMake(0, kbFrameOriginY - 55, CGRectGetWidth(self.view.frame), 55 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]);
            [self.commentInputBar resignFirstInputBar:YES];
            self.maskView.hidden = NO;
            self.maskView.frame = CGRectMake(0, 0, self.view.width, CGRectGetMinY(self.commentInputBar.frame));
            [self.view addSubview:self.maskView];
            [self.view bringSubviewToFront:self.maskView];
        }];
        [self.commentListView scrollTheTableViewForCommentWithKeyboardHeight:CGRectGetHeight(kbFrame)];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch  {

    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {

        return NO;
    }
    return  YES;
}

- (void)closeKeyboard:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[STIMKit sharedInstance] removeHotCommentUUIdsForMomentId:self.momentId];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - STIMWorkCommentTableViewDelegate

- (void)beginControlChildCommentWithComment:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary *postDic = @{@"ChildModel": commentModel, @"ParentIndexPath" : self.parentCommentIndexPath};
        NSDictionary *postDic = notify.object;
        
        STIMWorkCommentModel *commentModel = [postDic objectForKey:@"ChildModel"];
        NSIndexPath *indexPath = [postDic objectForKey:@"ParentIndexPath"];
        self.staticCommentModel = commentModel;
        if ([self.commentInputBar isInputBarFirstResponder] == NO) {
            
            NSString *fromUserId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
            if ([fromUserId isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
                //自己实名发的评论
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
                                                                       NSLog(@"buttonIndex : %d", buttonIndex);
                                                                       if (buttonIndex == 1) {
                                                                           //删评论
                                                                           [[STIMKit sharedInstance] deleteRemoteCommentWithComment:commentModel.commentUUID withPostUUId:commentModel.postUUID withSuperParentUUId:commentModel.superParentUUID withCallback:^(BOOL success, NSInteger superStatus) {
                                                                               if (success) {
                                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                                       if (superStatus == 2) {
                                                                                           [strongSelf.commentListView removeCommentWithIndexPath:indexPath withIsHotComment:NO withSuperStatus:superStatus];
                                                                                       }
                                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteChildCommentModel" object:commentModel];
                                                                                       [strongSelf.commentListView reloadCommentsData];
                                                                                   });
                                                                               } else {
                                                                                   [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject stimDB_makeToast:[NSBundle stimDB_localizedStringForKey:@"moment_faild_delete_comment"]];
                                                                               }
                                                                           }];
                                                                       } else if (buttonIndex == 2) {
                                                                           //回复
                                                                           [strongSelf beginAddCommentWithComment:commentModel];
                                                                       }
                                                                   }
                                                     otherButtonTitleArray:@[[NSBundle stimDB_localizedStringForKey:@"Delete"], [NSBundle stimDB_localizedStringForKey:@"Reply"]]];
                actionSheet.destructiveButtonIndexSet = indexSet;
                actionSheet.destructiveButtonColor = [UIColor stimDB_colorWithHex:0xF4333C];
                [actionSheet show];
            } else {
                BOOL isAnonymous = [commentModel isAnonymous];
                if (isAnonymous) {
                    NSString *anonymousName = [commentModel anonymousName];
                    NSString *placeholderText = [NSString stringWithFormat:@"  回复 %@", anonymousName];
                    [self.commentInputBar beginCommentToUserId:placeholderText];
                } else {
                    
                    NSString *userId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
                    NSString *name = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
                    NSString *placeholderText = [NSString stringWithFormat:@"  回复 %@", name];
                    [self.commentInputBar beginCommentToUserId:placeholderText];
                }
            }
        } else {
            [self.view endEditing:YES];
        }
    });
}

- (void)beginControlCommentWithComment:(STIMWorkCommentModel *)commentModel withIsHotComment:(BOOL)isHotComment withIndexPath:(NSIndexPath *)indexPath {
    self.staticCommentModel = commentModel;
    if (self.staticCommentModel.isDelete == YES) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"该评论已被删除" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        if ([self.commentInputBar isInputBarFirstResponder] == NO) {
            
            NSString *fromUserId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
            if ([fromUserId isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
                //自己实名发的评论
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
                                                                       NSLog(@"buttonIndex : %d", buttonIndex);
                                                                       if (buttonIndex == 1) {
                                                                           //删评论
                                                                           [[STIMKit sharedInstance] deleteRemoteCommentWithComment:commentModel.commentUUID withPostUUId:commentModel.postUUID withSuperParentUUId:commentModel.superParentUUID withCallback:^(BOOL success, NSInteger superStatus) {
                                                                               if (success) {
                                                                                   [strongSelf.commentListView removeCommentWithIndexPath:indexPath withIsHotComment:isHotComment withSuperStatus:superStatus];
                                                                               } else {
                                                                                   [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject stimDB_makeToast:[NSBundle stimDB_localizedStringForKey:@"moment_faild_delete_comment"]];
                                                                               }
                                                                           }];
                                                                       } else if (buttonIndex == 2) {
                                                                           //回复
                                                                           [strongSelf beginAddCommentWithComment:commentModel];
                                                                       }
                                                                   }
                                                     otherButtonTitleArray:@[[NSBundle stimDB_localizedStringForKey:@"Delete"], [NSBundle stimDB_localizedStringForKey:@"Reply"]]];
                actionSheet.destructiveButtonIndexSet = indexSet;
                actionSheet.destructiveButtonColor = [UIColor stimDB_colorWithHex:0xF4333C];
                [actionSheet show];
            } else {
                BOOL isAnonymous = [commentModel isAnonymous];
                if (isAnonymous) {
                    NSString *anonymousName = [commentModel anonymousName];
                    NSString *placeholderText = [NSString stringWithFormat:@"  回复 %@", anonymousName];
                    [self.commentInputBar beginCommentToUserId:placeholderText];
                } else {
                    
                    NSString *userId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
                    NSString *name = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
                    NSString *placeholderText = [NSString stringWithFormat:@"  回复 %@", name];
                    [self.commentInputBar beginCommentToUserId:placeholderText];
                }
            }
        } else {
            [self.view endEditing:YES];
        }
    }
}

- (void)beginAddCommentWithComment:(STIMWorkCommentModel *)commentModel {
    BOOL isAnonymous = [commentModel isAnonymous];
    if (isAnonymous) {
        NSString *anonymousName = [commentModel anonymousName];
        NSString *placeholderText = [NSString stringWithFormat:@"  回复 %@", anonymousName];
        [self.commentInputBar beginCommentToUserId:placeholderText];
    } else {
        
        NSString *userId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
        NSString *name = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
        NSString *placeholderText = [NSString stringWithFormat:@"  回复 %@", name];
        [self.commentInputBar beginCommentToUserId:placeholderText];
    }
}

- (void)endAddComment {
    [self.view endEditing:YES];
}

- (void)loadNewComments {
    //下拉刷新
    [[STIMKit sharedInstance] setHotCommentUUIds:@[] ForMomentId:self.momentId];
    __weak typeof(self) weakSelf = self;
    [[STIMKit sharedInstance] getRemoteMomentDetailWithMomentUUId:self.momentId withCallback:^(NSDictionary *momentDic) {
        if (momentDic.count > 0) {
            
            weakSelf.momentModel = [STIMWorkMomentModel yy_modelWithDictionary:momentDic];
            NSDictionary *contentModelDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
            STIMWorkMomentContentModel *conModel = [STIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
            weakSelf.momentModel.content = conModel;
            weakSelf.momentView.momentModel = self.momentModel;
            weakSelf.commentListView.commentNum = self.momentModel.commentsNum;
            [weakSelf.commentListView reloadCommentsData];
            [weakSelf.commentListView endRefreshingHeader];
        }
    }];
    [self loadComments];
}

- (void)loadMoreComments {
    __weak typeof(self) weakSelf = self;
    STIMWorkCommentModel *lastModel = [self.commentListView.commentModels lastObject];
    [[STIMKit sharedInstance] getWorkCommentWithLastCommentRId:lastModel.rId withMomentId:self.momentId WithLimit:20 WithOffset:self.commentListView.commentModels.count withFirstLocalComment:NO WithComplete:^(NSArray * _Nonnull array) {
        NSLog(@"loadMoreComments : %@", array);
        if (array.count > 0) {
            for (NSDictionary *commentDic in array) {
                STIMWorkCommentModel *model = [weakSelf getCommentModelWithDic:commentDic];
                [weakSelf.commentListView.commentModels addObject:model];
            }
            [weakSelf.commentListView reloadCommentsData];
            [weakSelf.commentListView endRefreshingFooter];
        } else {
            [weakSelf.commentListView endRefreshingFooterWithNoMoreData];
        }
    }];
}

#pragma mark - STIMWorkCommentInputBarDelegate

- (void)didaddCommentWithStr:(NSString *)str withAtList:(NSArray *)atList {
    if (self.staticCommentModel) {
        
        //评论上一条的评论
        STIMWorkMomentUserIdentityModel *lastUserModel = [[STIMWorkMomentUserIdentityManager sharedInstanceWithPOSTUUID:self.momentId] userIdentityModel];


        NSString *anonymousName = lastUserModel.anonymousName;
//        [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousName];
        NSString *anonymousPhoto = lastUserModel.anonymousPhoto;
//        [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
        BOOL isAnonymous = lastUserModel.isAnonymous;
//        [[STIMWorkMomentUserIdentityManager sharedInstance] isAnonymous];

        //Mark by 匿名
//        NSString *anonymousName = [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousName];
//        NSString *anonymousPhoto = [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
//        BOOL isAnonymous = [[STIMWorkMomentUserIdentityManager sharedInstance] isAnonymous];
        
        BOOL isToAnonymous = self.staticCommentModel.isAnonymous;
        NSString *toAnonymousName = self.staticCommentModel.anonymousName;
        NSString *toAnonymousPhoto = self.staticCommentModel.anonymousPhoto;
        
        NSMutableDictionary *commentDic = [[NSMutableDictionary alloc] init];
        [commentDic setSTIMSafeObject:[NSString stringWithFormat:@"1-%@", [STIMUUIDTools UUID]] forKey:@"commentUUID"];
        [commentDic setSTIMSafeObject:self.momentId forKey:@"postUUID"];
        [commentDic setSTIMSafeObject:self.staticCommentModel.commentUUID forKey:@"parentCommentUUID"];
        [commentDic setSTIMSafeObject:(self.staticCommentModel.superParentUUID.length > 0) ? self.staticCommentModel.superParentUUID : self.staticCommentModel.commentUUID forKey:@"superParentUUID"];
        [commentDic setSTIMSafeObject:str forKey:@"content"];
        [commentDic setSTIMSafeObject:[STIMKit getLastUserName] forKey:@"fromUser"];
        [commentDic setSTIMSafeObject:[[STIMKit sharedInstance] getDomain] forKey:@"fromHost"];
        [commentDic setSTIMSafeObject:self.staticCommentModel.fromUser forKey:@"toUser"];
        [commentDic setSTIMSafeObject:self.staticCommentModel.fromHost forKey:@"toHost"];
        [commentDic setSTIMSafeObject:(isAnonymous == YES) ? @(1) : @(0) forKey:@"isAnonymous"];
        [commentDic setSTIMSafeObject:(anonymousPhoto.length > 0) ? anonymousPhoto : @"" forKey:@"anonymousPhoto"];
        [commentDic setSTIMSafeObject:(anonymousName.length > 0) ? anonymousName : @"" forKey:@"anonymousName"];
        [commentDic setSTIMSafeObject:(isToAnonymous == YES) ? @(1) : @(0) forKey:@"toisAnonymous"];
        [commentDic setSTIMSafeObject:(toAnonymousName.length > 0) ? toAnonymousName : toAnonymousName forKey:@"toAnonymousName"];
        [commentDic setSTIMSafeObject:(toAnonymousPhoto.length > 0) ? toAnonymousPhoto : toAnonymousPhoto forKey:@"toAnonymousPhoto"];
        [commentDic setSTIMSafeObject:self.momentModel.ownerId forKey:@"postOwner"];
        [commentDic setSTIMSafeObject:self.momentModel.ownerHost forKey:@"postOwnerHost"];
        [commentDic setSTIMSafeObject:[[STIMKit sharedInstance] getHotCommentUUIdsForMomentId:self.momentId] forKey:@"hotCommentUUID"];
        [commentDic setSTIMSafeObject:atList forKey:@"atList"];

        [[STIMKit sharedInstance] uploadCommentWithCommentDic:commentDic];
    } else {
        //评论帖子
        STIMWorkMomentUserIdentityModel *lastUserModel = [[STIMWorkMomentUserIdentityManager sharedInstanceWithPOSTUUID:self.momentId] userIdentityModel];

        NSString *anonymousName = lastUserModel.anonymousName;
//        [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousName];
        NSString *anonymousPhoto = lastUserModel.anonymousPhoto;
//        [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
        BOOL isAnonymous = lastUserModel.isAnonymous;
//        [[STIMWorkMomentUserIdentityManager sharedInstance] isAnonymous];
//Mark by 匿名
//        NSString *anonymousName = [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousName];
//        NSString *anonymousPhoto = [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
//        BOOL isAnonymous = [[STIMWorkMomentUserIdentityManager sharedInstance] isAnonymous];
        
        NSMutableDictionary *commentDic = [[NSMutableDictionary alloc] init];
        [commentDic setSTIMSafeObject:[NSString stringWithFormat:@"1-%@", [STIMUUIDTools UUID]] forKey:@"commentUUID"];
        [commentDic setSTIMSafeObject:self.momentId forKey:@"postUUID"];
        [commentDic setSTIMSafeObject:str forKey:@"content"];
        [commentDic setSTIMSafeObject:[STIMKit getLastUserName] forKey:@"fromUser"];
        [commentDic setSTIMSafeObject:[[STIMKit sharedInstance] getDomain] forKey:@"fromHost"];
        [commentDic setSTIMSafeObject:@"" forKey:@"toUser"];
        [commentDic setSTIMSafeObject:@"" forKey:@"toHost"];
        [commentDic setSTIMSafeObject:(isAnonymous == YES) ? @(1) : @(0) forKey:@"isAnonymous"];
        [commentDic setSTIMSafeObject:(anonymousPhoto.length > 0) ? anonymousPhoto : @"" forKey:@"anonymousPhoto"];
        [commentDic setSTIMSafeObject:(anonymousName.length > 0) ? anonymousName : @"" forKey:@"anonymousName"];
        [commentDic setSTIMSafeObject:@(0) forKey:@"toisAnonymous"];
        [commentDic setSTIMSafeObject:@"" forKey:@"toAnonymousName"];
        [commentDic setSTIMSafeObject:@"" forKey:@"toAnonymousPhoto"];
        [commentDic setSTIMSafeObject:self.momentModel.ownerId forKey:@"postOwner"];
        [commentDic setSTIMSafeObject:self.momentModel.ownerHost forKey:@"postOwnerHost"];
        [commentDic setSTIMSafeObject:[[STIMKit sharedInstance] getHotCommentUUIdsForMomentId:self.momentId] forKey:@"hotCommentUUID"];
        [commentDic setSTIMSafeObject:atList forKey:@"atList"];

        [[STIMKit sharedInstance] uploadCommentWithCommentDic:commentDic];
    }
    //回复完之后清空staticCommentModel
    self.staticCommentModel = nil;
}

- (void)dealloc {
//    [[STIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
//    [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
//    [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
    [[YYKeyboardManager defaultManager] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didOpenUserIdentifierVC {
    STIMWorkMomentUserIdentityVC *identityVc = [[STIMWorkMomentUserIdentityVC alloc] init];
    identityVc.momentId = self.momentId;
    [self.navigationController pushViewController:identityVc animated:YES];
}

- (void)didiOpenUserSelectVCWithVC:(UIViewController *)qNoticeVC {
    if ([[STIMKit sharedInstance] getIsIpad]) {
        qNoticeVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        STIMNavController *qtalNav = [[STIMNavController alloc] initWithRootViewController:qNoticeVC];
        qtalNav.modalPresentationStyle = UIModalPresentationCurrentContext;
#if __has_include("STIMIPadWindowManager.h")
        [[[STIMIPadWindowManager sharedInstance] detailVC] presentViewController:qtalNav animated:YES completion:nil];
#endif
    } else {
        [self.navigationController pushViewController:qNoticeVC animated:YES];
    }
}

// 查看全文/收起
- (void)didSelectFullText:(STIMWorkMomentCell *)cell withFullText:(BOOL)isFullText {
    
}

- (void)didClickSmallImage:(STIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag {
    
    //初始化图片浏览控件
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

@end

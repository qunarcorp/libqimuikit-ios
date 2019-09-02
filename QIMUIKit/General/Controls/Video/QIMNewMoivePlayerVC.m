//
//  QIMNewMoivePlayerVC.m
//  QIMUIKit
//
//  Created by lilu on 2019/8/7.
//

#import "QIMNewMoivePlayerVC.h"
#import "SuperPlayer.h"
#import "UIView+MMLayout.h"
#import "Masonry.h"
#import "LCActionSheet.h"
#import "QIMNewVideoCacheManager.h"
#import "YYModel.h"
#import "QIMContactSelectionViewController.h"

@interface QIMNewMoivePlayerVC () <SuperPlayerDelegate>
@property UIView *playerContainer;
@property SuperPlayerView *playerView;
@property BOOL isAutoPaused;

@end

@implementation QIMNewMoivePlayerVC

- (NSString *)playUrl {
    if (self.videoModel.LocalVideoOutPath > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoModel.LocalVideoOutPath]) {
            return self.videoModel.LocalVideoOutPath;
        } else {
            if (![self.videoModel.FileUrl qim_hasPrefixHttpHeader]) {
                self.videoModel.FileUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", self.videoModel.FileUrl];
            }
            return self.videoModel.FileUrl;
        }
    } else {
        if (![self.videoModel.FileUrl qim_hasPrefixHttpHeader]) {
            self.videoModel.FileUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", self.videoModel.FileUrl];
        }
        return self.videoModel.FileUrl;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerContainer = [[UIView alloc] init];
    self.playerContainer.backgroundColor = [UIColor blackColor];
    self.playerContainer.mm_top([[QIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT]);
    self.playerContainer.mm_width(self.view.mm_w).mm_height(self.view.mm_h - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - [[QIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT]);
    
    _playerView = [[SuperPlayerView alloc] init];
    [_playerView.controlView setValue:nil forKey:@"danmakuBtn"];
    [_playerView.controlView setValue:nil forKey:@"captureBtn"];
    [_playerView.controlView setValue:nil forKey:@"moreBtn"];
    if (self.videoModel.LocalThubmImage) {
        
        [_playerView.coverImageView setImage:self.videoModel.LocalThubmImage];
        
    } else {
        [_playerView.coverImageView qim_setImageWithURL:[NSURL URLWithString:self.videoModel.ThumbUrl]];
    }
    // 设置父View
    _playerView.disableGesture = YES;
    
    SuperPlayerModel *playerModel = [[SuperPlayerModel alloc] init];
    playerModel.videoURL = self.playUrl;
    self.playerView.delegate = self;
    self.playerView.fatherView = self.playerContainer;
    
    // 开始播放
    [_playerView playWithModel:playerModel];
    [self.view addSubview:self.playerContainer];
    
    UILongPressGestureRecognizer * longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesHandle:)];
    [self.view addGestureRecognizer:longGes];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)superPlayerBackAction:(SuperPlayerView *)player {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
    if (parent == nil) {
        [self.playerView resetPlayer];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isAutoPaused) {
        [self.playerView resume];
        self.isAutoPaused = NO;
    }
}

- (void)longGesHandle:(UILongPressGestureRecognizer *)longGes{
    switch (longGes.state) {
        case UIGestureRecognizerStateBegan: {
            [self actionButtonPressed];
            
        }
            break;
        default:
            break;
    }
}

- (void)actionButtonPressed {
    if (![self.videoModel.FileUrl qim_hasPrefixHttpHeader]) {
        self.videoModel.FileUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", self.videoModel.FileUrl];
    }
    NSString *cachePath = [[QIMNewVideoCacheManager sharedInstance] getVideoCachePathWithUrl:self.videoModel.FileUrl];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoModel.LocalVideoOutPath]) {
        cachePath = self.videoModel.LocalVideoOutPath;
    } else {
        
    }
    
    BOOL canSave = NO;
    NSArray *buttonTitles = @[];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        canSave = YES;
    }
    NSLog(@"cachePath : %@", cachePath);
    if (self.videoModel.FileUrl.length > 0) {
        if (canSave == YES) {
            buttonTitles = @[@"发送给朋友", @"分享到驼圈", @"保存视频"];
        } else {
            buttonTitles = @[@"发送给朋友", @"分享到驼圈"];
        }
    } else {
        buttonTitles = @[@"分享到驼圈", @"保存视频"];
    }
    
    __weak __typeof(self) weakSelf = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                             cancelButtonTitle:@"取消"
                                                       clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                                                           __typeof(self) strongSelf = weakSelf;
                                                           if (!strongSelf) {
                                                               return;
                                                           }
                                                           if (buttonIndex == 1) {
                                                               QIMVerboseLog(@"发送给朋友");
                                                               [strongSelf shareVideoToFriends];
                                                           }
                                                           if (buttonIndex == 2) {
                                                               QIMVerboseLog(@"分享视频到驼圈");
                                                               [strongSelf shareVideoToWorkMoment];
                                                           }
                                                           if (buttonIndex == 3) {
                                                               QIMVerboseLog(@"保存视频");
                                                               [strongSelf saveVideoToAlbum:cachePath];
                                                           }
                                                       }
                                         otherButtonTitleArray:buttonTitles];
    [actionSheet show];
}

#pragma mark - 分享给朋友
- (void)shareVideoToFriends {
    NSDictionary *videoModelDic = [self.videoModel yy_modelToJSONObject];
    NSString *message = [[QIMJSONSerializer sharedInstance] serializeObject:videoModelDic];
    
    QIMMessageModel *msg = [[QIMMessageModel alloc] init];
    msg.message = message;
    msg.extendInformation = message;
    msg.messageType = QIMMessageType_SmallVideo;
    
    NSLog(@"videoModelDic : %@", videoModelDic);

    QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
    controller.ExternalForward = YES;
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
    [controller setMessage:msg];
    [[self navigationController] presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - 分享驼圈
- (void)shareVideoToWorkMoment {

    NSDictionary *videoModelDic = [self.videoModel yy_modelToJSONObject];
    
    NSDictionary *videoDic = @{@"MediaType":@(1), @"VideoDic": videoModelDic, @"videoReady": self.videoModel.FileUrl.length ? @(YES) : @(NO)};
    
    QIMVerboseLog(@"保存视频 : %@", videoModelDic);
    [QIMFastEntrance presentWorkMomentPushVCWithVideoDic:videoDic withNavVc:self.navigationController];
}

#pragma mark - 保存视频->相册
- (void)saveVideoToAlbum:(NSString *)videoPath {
    // 保存视频
    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    if (!error) {
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:@"保存成功！" message:@"小视频已经保存到相册..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:@"保存失败！" message:@"请到“设置->隐私->照片”中允许访问相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end

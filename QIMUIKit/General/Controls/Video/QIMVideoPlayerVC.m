//
//  QIMVideoPlayerVC.m
//  qunarChatIphone
//
//  Created by admin on 15/7/14.
//
//

#import "QIMVideoPlayerVC.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "QIMVideoPlayProgressView.h"
#import "QIMVideoPlayerManager.h"
#import "QIMVideoCachePathTool.h"
#import "QIMIconInfo.h"
#import "LCActionSheet.h"
#import "YYModel.h"
#import "QIMVideoModel.h"
#import "QIMContactSelectionViewController.h"

#define RGBCOLOR_HEX(hexColor) [UIColor colorWithRed: (((hexColor >> 16) & 0xFF))/255.0f         \
green: (((hexColor >> 8) & 0xFF))/255.0f          \
blue: ((hexColor & 0xFF))/255.0f                 \
alpha: 1]

static NSString *totalDurationStr = nil;

@interface QIMVideoPlayerVC () < QIMVideoPlayProgressViewDelegate, PlayVideoDelegate>
@property (nonatomic, strong) QIMVideoPlayProgressView *progressSlider;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *playOrPause;
@property (nonatomic, strong) UIView *playButtonView;
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) UIImageView *thubmImageView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) MBProgressHUD *loadingView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *repeatBtn;
@property (nonatomic, assign) BOOL showActivityWhenLoading;
@property (nonatomic, copy) NSString *suggestVideoPath;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *saveVideoBtn;

@end

@implementation QIMVideoPlayerVC

#pragma mark - setter and getter

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, 15 + [[QIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT] - 20, 40, 40);
        [_backBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3cd" size:24 color:[UIColor whiteColor]]] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)saveVideoBtn {
    if (!_saveVideoBtn) {
        _saveVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveVideoBtn.frame = CGRectMake(SCREEN_WIDTH - 55, 15 + [[QIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT] - 20, 40, 40);
        [_saveVideoBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0aa" size:24 color:[UIColor whiteColor]]] forState:UIControlStateNormal];
        [_saveVideoBtn addTarget:self action:@selector(saveBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveVideoBtn;
}

- (UIButton *)repeatBtn {
    if (!_repeatBtn) {
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _repeatBtn.frame = CGRectMake(0, 0, 64, 64);
        [_repeatBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"player_repeat_video"] forState:UIControlStateNormal];
        [_repeatBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
        _repeatBtn.hidden = YES;
    }
    return _repeatBtn;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        [_contentView setBackgroundColor:[UIColor blackColor]];
    }
    return _contentView;
}

- (UIView *)playView {
    if (!_playView) {
        
        _playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        _playView.center = self.contentView.center;
        [_playView setBackgroundColor:[UIColor blackColor]];
    }
    return _playView;
}

- (UIImageView *)thubmImageView {
    if (!_thubmImageView) {
        _thubmImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
    }
    return _thubmImageView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _playBtn;
}

- (UIView *)playButtonView {
    if (!_playButtonView) {
        _playButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 40 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], SCREEN_WIDTH, 40)];
        [_playButtonView setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.5]];
    }
    return _playButtonView;
}

- (UIButton *)playOrPause {
    if (!_playOrPause) {
        _playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPause.frame = CGRectMake(10, 6, 28, 28);
        [_playOrPause setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [_playOrPause setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"video_button_play_normal"] forState:UIControlStateNormal];
        [_playOrPause setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"video_button_stop_normal"] forState:UIControlStateSelected];
        [_playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPause;
}

- (QIMVideoPlayProgressView *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[QIMVideoPlayProgressView alloc] initWithFrame:CGRectMake(_playOrPause.right + 10, 19, SCREEN_WIDTH - (_playOrPause.right + 10) - 10, 2)];
        _progressSlider.delegate = self;
    }
    CGPoint sliderCenter = _progressSlider.center;
    sliderCenter.y = self.playOrPause.center.y;
    _progressSlider.center = sliderCenter;
    _progressSlider.playProgressBackgoundColor = RGBCOLOR_HEX(0xff7b06);
    _progressSlider.trackBackgoundColor = RGBCOLOR_HEX(0xe0d4a3);
    return _progressSlider;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel =  [[UILabel alloc] initWithFrame:CGRectMake(10, self.progressSlider.bottom + 6, SCREEN_WIDTH - 23, 12)];
        [_progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setFont:[UIFont systemFontOfSize:9]];
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_progressLabel setText:@"00:00/00:00"];
        [_progressLabel setTextAlignment:NSTextAlignmentRight];
    }
    return _progressLabel;
}

- (MBProgressHUD *)loadingView {
    if (!_loadingView) {
        _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
        _loadingView.userInteractionEnabled = YES;
    }
    _loadingView.labelText = @"加载中...";
    [_loadingView show: NO];
    return _loadingView;
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initNav {
    [self.view addSubview:self.backBtn];
//    [self.view addSubview:self.saveVideoBtn];
}

- (void)initUI {
    [self.navigationItem setTitle:@"小视频"];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.playView];
    [self.view addSubview:self.loadingView];
    [self.view addSubview:self.playButtonView];
    [self.view addSubview:self.repeatBtn];
    self.repeatBtn.center = self.contentView.center;
    [self.playButtonView addSubview:self.playOrPause];
    [self.playButtonView addSubview:self.progressSlider];
    [self.playButtonView addSubview:self.progressLabel];
    [self initNav];
    UILongPressGestureRecognizer * longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesHandle:)];
    [self.view addGestureRecognizer:longGes];
}

- (void)parseVideoMessage {
    
    if (self.videoMessageModel.extendInformation.length > 0) {
        self.videoMessageModel.message = self.videoMessageModel.extendInformation;
    }
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.videoMessageModel.message error:nil];
    
    NSString *fileName = [infoDic objectForKey:@"FileName"];
    NSString *fileUrl = [infoDic objectForKey:@"FileUrl"];
    NSInteger videoWidth = [[infoDic objectForKey:@"Width"] integerValue];;
    NSInteger videoHeight = [[infoDic objectForKey:@"Height"] integerValue];
    
    if (![fileUrl qim_hasPrefixHttpHeader]) {
        fileUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", fileUrl];
    }
    
    NSString *filePath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:fileName?fileName:@""];
    
    self.videoPath = filePath;
    self.videoUrl = fileUrl;
    self.videoWidth = videoWidth;
    self.videoHeight = videoHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self parseVideoMessage];
    [self initUI];
    _showActivityWhenLoading = YES;
    if (self.videoUrl.length > 0) {
        self.videoPath = [self getVideoRealSavePathWithFileUrl:self.videoUrl];
    }
    NSURL *videoPlayUrl = [NSURL URLWithString:self.videoUrl];
    [QIMVideoPlayerManager sharedInstance].delegate = self;
    [[QIMVideoPlayerManager sharedInstance] playVideoFromUrl:videoPlayUrl
                                                 videoFromPath:self.videoPath
                                                        onView:self.playView];
}

- (NSString *)getVideoRealSavePathWithFileUrl:(NSString *)url {
    
    NSURL *fileUrl = [NSURL URLWithString:url];
    NSString *savePath = [QIMVideoCachePathTool fileSavePath];
    NSString *suggestFileName = [QIMVideoCachePathTool suggestFileNameWithURL:fileUrl];
    savePath = [savePath stringByAppendingPathComponent:suggestFileName];
    return savePath;
}

-(void)dealloc{
    [[QIMVideoPlayerManager sharedInstance] clear];
    //退出VideoPlayerVc后，恢复后台音乐
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)setVideoUrl:(NSString *)videoUrl {
    QIMVerboseLog(@"video Url %@", videoUrl);
    _videoUrl = videoUrl;
}

- (void)setVideoPath:(NSString *)videoPath {
    QIMVerboseLog(@"video Path %@", videoPath);
    _videoPath = videoPath;
}

- (void)setVideoWidth:(NSInteger)videoWidth {
    QIMVerboseLog(@"video Width %f", videoWidth);
    _videoWidth = videoWidth;
}

- (void)setVideoHeight:(NSInteger)videoHeight {
    QIMVerboseLog(@"video Height %ld", (long)videoHeight);
    _videoHeight = videoHeight;
}

/* 点击播放按钮 */
- (void)playClick:(UIButton *)btn{
    
    if ([QIMVideoPlayerManager sharedInstance].isPlaying) {
        [[QIMVideoPlayerManager sharedInstance] pause];
    }else{
        [[QIMVideoPlayerManager sharedInstance] play];
    }
}
- (void)pauseClick {
    [[QIMVideoPlayerManager sharedInstance] pause];
}

- (void)resumClick {
    [[QIMVideoPlayerManager sharedInstance] resum];
}

- (void)stopClick{
    [[QIMVideoPlayerManager sharedInstance] stop];
}

// 开始拖动
- (void)beiginSliderScrubbing{
    [[QIMVideoPlayerManager sharedInstance] beiginSliderScrubbing];
}
// 结束拖动
- (void)endSliderScrubbing{
    [[QIMVideoPlayerManager sharedInstance] endSliderScrubbing];
    
}
// 拖动值发生改变
- (void)sliderScrubbing{
    
    CMTime playerDuration = [[QIMVideoPlayerManager sharedInstance] playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)){
        
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        float value = [self.progressSlider value];
        
        double time = duration * (value - minValue) / (maxValue - minValue);
        [[QIMVideoPlayerManager sharedInstance] sliderScrubbing:time];
    }
}

#pragma mark - delegate 视频拖放进度发生改变

// 视频缓存进度
- (void)videoBufferDataProgress:(double)bufferProgress{
    QIMVerboseLog(@"已经缓存%lf", bufferProgress);
    self.progressSlider.trackValue = bufferProgress;
}

- (void)playProgressChange{
    
    CMTime playerDuration = [[QIMVideoPlayerManager sharedInstance] playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.progressSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        double time = CMTimeGetSeconds([[QIMVideoPlayerManager sharedInstance] playerCurrentDuration]);
        
        double hoursElapsed = floor(time / (60.0*60));
        double minutesElapsed = fmod(time / 60, 60);
        double secondsElapsed = fmod(time, 60.0);
        if (!hoursElapsed) {
            self.progressLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f/%@", minutesElapsed, secondsElapsed, totalDurationStr];
        } else {
            self.progressLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f/%@", hoursElapsed, minutesElapsed, secondsElapsed, totalDurationStr];
        }
        [self.progressSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

- (void)initPlayerPlayback{
    
    CMTime playerDuration = [[QIMVideoPlayerManager sharedInstance] playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
//        CGFloat width = CGRectGetWidth([_slider bounds]);
//        interval = 0.5f * duration / width;

        double hoursElapsed = floor(duration / (60.0*60));
        double minutesElapsed = fmod(duration / 60, 60);
        double secondsElapsed = fmod(duration, 60.0);
        if (!hoursElapsed) {
            totalDurationStr = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
        } else {
            totalDurationStr = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hoursElapsed, minutesElapsed, secondsElapsed];
        }
        [[QIMVideoPlayerManager sharedInstance] updateMovieScrubberControl];
    }
}

- (void)playStatusChange:(AVPlayerPlayState)state{
    switch (state) {
        case AVPlayerPlayStatePreparing:
        {
            [_loadingView show:YES];
            [self.repeatBtn setHidden:YES];
            self.playOrPause.selected = NO;
        }
            break;
        case AVPlayerPlayStateBeigin:
        {
            [_loadingView hide:YES];
            [self.repeatBtn setHidden:YES];
            self.playOrPause.selected = YES;
        }
            break;
        case AVPlayerPlayStatePlaying:
        {
            
        }
            break;
        case AVPlayerPlayStatePause:
        {
            self.playOrPause.selected = NO;
            [_loadingView hide:YES];
            [self.repeatBtn setHidden:YES];
        }
            break;
        case AVPlayerPlayStateEnd:
        {
            self.playOrPause.selected = NO;
            self.repeatBtn.hidden = NO;
            [_loadingView hide:YES];
        }
            break;
        case AVPlayerPlayStateBufferEmpty:
        {
            [_loadingView show:YES];
            [self.repeatBtn setHidden:YES];
            self.playOrPause.selected = NO;
        }
            break;
        case AVPlayerPlayStateBufferToKeepUp:
        {
            self.playOrPause.selected = YES;
            [_loadingView hide:YES];
            [self.repeatBtn setHidden:YES];
        }
            break;
            
        case AVPlayerPlayStateNotPlay:
        {
            [_loadingView hide:YES];
            [self.repeatBtn setHidden:YES];
        }
            break;
        case AVPlayerPlayStateNotKnow:
        {
            [_loadingView hide:YES];
            [self.repeatBtn setHidden:YES];
        }
            break;
        default:
            break;
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
    NSArray *buttonTitles = @[@"发送给朋友", @"分享到驼圈", @"保存视频"];
    __weak __typeof(self) weakSelf = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                             cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Cancel"]
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
                                                               [strongSelf saveBtnHandle:nil];
                                                           }
                                                       }
                                         otherButtonTitleArray:buttonTitles];
    [actionSheet show];
}

#pragma mark - 分享给朋友

- (void)shareVideoToFriends {
    
    QIMMessageModel *msg = self.videoMessageModel;
    QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
    controller.ExternalForward = YES;
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
    [controller setMessage:msg];
    [[self navigationController] presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - 分享驼圈
- (void)shareVideoToWorkMoment {
    
    if (self.videoMessageModel.extendInformation.length > 0) {
        self.videoMessageModel.message = self.videoMessageModel.extendInformation;
    }
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.videoMessageModel.message error:nil];
    NSString *Duration = [infoDic objectForKey:@"Duration"];
    NSString *FileName = [infoDic objectForKey:@"FileName"];
    NSString *FileSize = [infoDic objectForKey:@"FileSize"];
    NSString *fileUrl = [infoDic objectForKey:@"FileUrl"];
    
    NSInteger videoWidth = [[infoDic objectForKey:@"Width"] integerValue];;
    NSInteger videoHeight = [[infoDic objectForKey:@"Height"] integerValue];
    NSString *ThumbUrl = [infoDic objectForKey:@"ThumbUrl"];
    
    QIMVideoModel *videoModel = [[QIMVideoModel alloc] init];
    videoModel.Duration = Duration;
    videoModel.FileName = FileName;
    videoModel.FileSize = FileSize;
    videoModel.FileUrl = fileUrl;
    videoModel.Height = [NSString stringWithFormat:@"%ld", videoHeight];
    videoModel.ThumbUrl = ThumbUrl;
    videoModel.Width = [NSString stringWithFormat:@"%ld", videoWidth];
    videoModel.newVideo = NO;
    videoModel.LocalVideoOutPath = self.videoPath;
    /*
    @property (nonatomic, copy) NSString *Duration;
    @property (nonatomic, copy) NSString *FileName;
    @property (nonatomic, copy) NSString *FileSize;
    @property (nonatomic, copy) NSString *FileUrl;
    @property (nonatomic, copy) NSString *Height;
    @property (nonatomic, copy) NSString *ThumbName;
    @property (nonatomic, copy) NSString *ThumbUrl;
    @property (nonatomic, copy) NSString *Width;
    @property (nonatomic, assign) BOOL newVideo;
    @property (nonatomic, copy) NSString *LocalVideoOutPath;
    @property (nonatomic, strong) UIImage *LocalThubmImage;
    */
    
    NSDictionary *videoModelDic = [videoModel yy_modelToJSONObject];
    NSDictionary *videoDic = @{@"MediaType":@(QIMWorkMomentMediaTypeVideo), @"VideoDic": videoModelDic, @"videoReady": @(NO)};
    
    QIMVerboseLog(@"分享视频到驼圈 : %@", videoModelDic);
    [QIMFastEntrance presentWorkMomentPushVCWithVideoDic:videoDic withNavVc:self.navigationController];
}

#pragma mark - UI事件

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveBtnHandle:(UIButton *)sender {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        [self saveVideoForPath:self.videoPath];
    } else {
        QIMVerboseLog(@"视频未下载成功");
    }
}

- (void)saveVideoForPath:(NSString *) path {
    // 保存视频
    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

// 视频保存回调

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    if (!error) {
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Saved_Success"] message:[NSBundle qim_localizedStringForKey:@"Video_saved"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"save_faild"] message:[NSBundle qim_localizedStringForKey:@"Privacy_Photo"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    QIMVerboseLog(@"%@",videoPath);
    
    QIMVerboseLog(@"%@",error);
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    UIInterfaceOrientation orientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
            break;
        default:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
    }
    return orientation;
}

@end

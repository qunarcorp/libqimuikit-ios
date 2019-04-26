//
//  QIMPhotoPreviewCell.m
//  QIMImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "QIMPhotoPreviewCell.h"
#import "QIMAssetModel.h"
#import "UIView+QIMLayout.h"
#import "QIMImagePickerManager.h"
#import "QIMProgressView.h"
#import "QIMImageCropManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "QIMImagePickerController.h"
#import "UIImage+QIMImagePicker.h"

@implementation QIMAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self configSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    }
    return self;
}

- (void)configSubviews {
    
}

#pragma mark - Notification

- (void)photoPreviewCollectionViewDidScroll {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation QIMPhotoPreviewCell

- (void)configSubviews {
    self.previewView = [[QIMPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [self.previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.singleTapGestureBlock) {
            strongSelf.singleTapGestureBlock();
        }
    }];
    [self.previewView setImageProgressUpdateBlock:^(double progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.imageProgressUpdateBlock) {
            strongSelf.imageProgressUpdateBlock(progress);
        }
    }];
    [self addSubview:self.previewView];
}

- (void)setModel:(QIMAssetModel *)model {
    [super setModel:model];
    _previewView.asset = model.asset;
}

- (void)recoverSubviews {
    [_previewView recoverSubviews];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _previewView.allowCrop = allowCrop;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _previewView.cropRect = cropRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

@end


@interface QIMPhotoPreviewView ()<UIScrollViewDelegate>
@property (assign, nonatomic) BOOL isRequestingGIF;
@end

@implementation QIMPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        if (@available(iOS 11, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
        [self configProgressView];
    }
    return self;
}

- (void)configProgressView {
    _progressView = [[QIMProgressView alloc] init];
    _progressView.hidden = YES;
    [self addSubview:_progressView];
}

- (void)setModel:(QIMAssetModel *)model {
    _model = model;
    self.isRequestingGIF = NO;
    [_scrollView setZoomScale:1.0 animated:NO];
    if (model.type == QIMAssetModelMediaTypePhotoGif) {
        // 先显示缩略图
        [[QIMImagePickerManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            self.imageView.image = photo;
            [self resizeSubviews];
            if (self.isRequestingGIF) {
                return;
            }
            // 再显示gif动图
            self.isRequestingGIF = YES;
            [[QIMImagePickerManager manager] getOriginalPhotoDataWithAsset:model.asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                progress = progress > 0.02 ? progress : 0.02;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progressView.progress = progress;
                    if (progress >= 1) {
                        self.progressView.hidden = YES;
                    } else {
                        self.progressView.hidden = NO;
                    }
                });
#ifdef DEBUG
                NSLog(@"[QIMImagePickerController] getOriginalPhotoDataWithAsset:%f error:%@", progress, error);
#endif
            } completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    self.isRequestingGIF = NO;
                    self.progressView.hidden = YES;
                    if ([QIMImagePickerConfig sharedInstance].gifImagePlayBlock) {
                        [QIMImagePickerConfig sharedInstance].gifImagePlayBlock(self, self.imageView, data, info);
                    } else {
                        self.imageView.image = [UIImage sd_qim_animatedGIFWithData:data];
                    }
                    [self resizeSubviews];
                }
            }];
        } progressHandler:nil networkAccessAllowed:NO];
    } else {
        self.asset = model.asset;
    }
}

- (void)setAsset:(PHAsset *)asset {
    if (_asset && self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    
    _asset = asset;
    self.imageRequestID = [[QIMImagePickerManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (![asset isEqual:self->_asset]) return;
        self.imageView.image = photo;
        [self resizeSubviews];
        self->_progressView.hidden = YES;
        if (self.imageProgressUpdateBlock) {
            self.imageProgressUpdateBlock(1);
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (![asset isEqual:self->_asset]) return;
        self->_progressView.hidden = NO;
        [self bringSubviewToFront:self->_progressView];
        progress = progress > 0.02 ? progress : 0.02;
        self->_progressView.progress = progress;
        if (self.imageProgressUpdateBlock && progress < 1) {
            self.imageProgressUpdateBlock(progress);
        }
        
        if (progress >= 1) {
            self->_progressView.hidden = YES;
            self.imageRequestID = 0;
        }
    } networkAccessAllowed:YES];
    
    [self configMaximumZoomScale];
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _imageContainerView.qim_origin = CGPointZero;
    _imageContainerView.qim_width = self.scrollView.qim_width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.qim_height / self.scrollView.qim_width) {
        _imageContainerView.qim_height = floor(image.size.height / (image.size.width / self.scrollView.qim_width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.qim_width;
        if (height < 1 || isnan(height)) height = self.qim_height;
        height = floor(height);
        _imageContainerView.qim_height = height;
        _imageContainerView.qim_centerY = self.qim_height / 2;
    }
    if (_imageContainerView.qim_height > self.qim_height && _imageContainerView.qim_height - self.qim_height <= 1) {
        _imageContainerView.qim_height = self.qim_height;
    }
    CGFloat contentSizeH = MAX(_imageContainerView.qim_height, self.qim_height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.qim_width, contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.qim_height <= self.qim_height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    
    [self refreshScrollViewContentSize];
}

- (void)configMaximumZoomScale {
    _scrollView.maximumZoomScale = _allowCrop ? 4.0 : 2.5;
    
    if ([self.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)self.asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        // 优化超宽图片的显示
        if (aspectRatio > 1.5) {
            self.scrollView.maximumZoomScale *= aspectRatio / 1.5;
        }
    }
}

- (void)refreshScrollViewContentSize {
    if (_allowCrop) {
        // 1.7.2 如果允许裁剪,需要让图片的任意部分都能在裁剪框内，于是对_scrollView做了如下处理：
        // 1.让contentSize增大(裁剪框右下角的图片部分)
        CGFloat contentWidthAdd = self.scrollView.qim_width - CGRectGetMaxX(_cropRect);
        CGFloat contentHeightAdd = (MIN(_imageContainerView.qim_height, self.qim_height) - self.cropRect.size.height) / 2;
        CGFloat newSizeW = self.scrollView.contentSize.width + contentWidthAdd;
        CGFloat newSizeH = MAX(self.scrollView.contentSize.height, self.qim_height) + contentHeightAdd;
        _scrollView.contentSize = CGSizeMake(newSizeW, newSizeH);
        _scrollView.alwaysBounceVertical = YES;
        // 2.让scrollView新增滑动区域（裁剪框左上角的图片部分）
        if (contentHeightAdd > 0 || contentWidthAdd > 0) {
            _scrollView.contentInset = UIEdgeInsetsMake(contentHeightAdd, _cropRect.origin.x, 0, 0);
        } else {
            _scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = CGRectMake(10, 0, self.qim_width - 20, self.qim_height);
    static CGFloat progressWH = 40;
    CGFloat progressX = (self.qim_width - progressWH) / 2;
    CGFloat progressY = (self.qim_height - progressWH) / 2;
    _progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    
    [self recoverSubviews];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentSize];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.qim_width > _scrollView.contentSize.width) ? ((_scrollView.qim_width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.qim_height > _scrollView.contentSize.height) ? ((_scrollView.qim_height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

@end


@implementation QIMVideoPreviewCell

- (void)configSubviews {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)configPlayButton {
    if (_playButton) {
        [_playButton removeFromSuperview];
    }
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
}

- (void)setModel:(QIMAssetModel *)model {
    [super setModel:model];
    [self configMoviePlayer];
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    if (_player) {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        [_player pause];
        _player = nil;
    }
    
    if (self.model && self.model.asset) {
        [[QIMImagePickerManager manager] getPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            self.cover = photo;
        }];
        [[QIMImagePickerManager manager] getVideoWithAsset:self.model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configPlayerWithItem:playerItem];
            });
        }];
    } else {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
        [self configPlayerWithItem:playerItem];
    }
}

- (void)configPlayerWithItem:(AVPlayerItem *)playerItem {
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    [self configPlayButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
    _playButton.frame = CGRectMake(0, 64, self.qim_width, self.qim_height - 64 - 44);
}

- (void)photoPreviewCollectionViewDidScroll {
    if (_player && _player.rate != 0.0) {
        [self pausePlayerAndShowNaviBar];
    }
}

#pragma mark - Notification

- (void)appWillResignActiveNotification {
    if (_player && _player.rate != 0.0) {
        [self pausePlayerAndShowNaviBar];
    }
}

#pragma mark - Click Event

- (void)playButtonClick {
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        [_player play];
        [_playButton setImage:nil forState:UIControlStateNormal];
        [UIApplication sharedApplication].statusBarHidden = YES;
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
        }
    } else {
        [self pausePlayerAndShowNaviBar];
    }
}

- (void)pausePlayerAndShowNaviBar {
    [_player pause];
    [_playButton setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

@end


@implementation QIMGifPreviewCell

- (void)configSubviews {
    [self configPreviewView];
}

- (void)configPreviewView {
    _previewView = [[QIMPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [_previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf signleTapAction];
    }];
    [self addSubview:_previewView];
}

- (void)setModel:(QIMAssetModel *)model {
    [super setModel:model];
    _previewView.model = self.model;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _previewView.frame = self.bounds;
}

#pragma mark - Click Event

- (void)signleTapAction {    
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

@end

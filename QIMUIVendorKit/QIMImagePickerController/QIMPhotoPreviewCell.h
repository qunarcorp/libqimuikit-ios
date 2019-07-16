//
//  QIMPhotoPreviewCell.h
//  QIMImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QIMAssetModel;
@interface QIMAssetPreviewCell : UICollectionViewCell
@property (nonatomic, strong) QIMAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
- (void)configSubviews;
- (void)photoPreviewCollectionViewDidScroll;
@end


@class QIMAssetModel,QIMProgressView,QIMPhotoPreviewView;
@interface QIMPhotoPreviewCell : QIMAssetPreviewCell

@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, strong) QIMPhotoPreviewView *previewView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

- (void)recoverSubviews;

@end


@interface QIMPhotoPreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) QIMProgressView *progressView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) QIMAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, assign) int32_t imageRequestID;

- (void)recoverSubviews;
@end


@class AVPlayer, AVPlayerLayer;
@interface QIMVideoPreviewCell : QIMAssetPreviewCell
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIImage *cover;
@property (nonatomic, strong) NSURL *videoURL;
- (void)pausePlayerAndShowNaviBar;
@end


@interface QIMGifPreviewCell : QIMAssetPreviewCell
@property (strong, nonatomic) QIMPhotoPreviewView *previewView;
@end

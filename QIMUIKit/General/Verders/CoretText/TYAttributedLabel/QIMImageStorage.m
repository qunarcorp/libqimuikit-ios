//
//  QCDrawImageStorage.m
//  QIMAttributedLabelDemo
//
//  Created by chenjie on 16/7/7.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "QIMImageStorage.h"
#import "QIMImageCache.h"
#import "QIMImageView.h"
#import "MBProgressHUD.h"
#import "DACircularProgressView.h"

@interface QIMImageStorage () {
    QIMImageView * _imageView;
    CGRect        _rect;
}
@property (nonatomic, weak) UIView *ownerView;

//上传图片进度条
@property (nonatomic, strong) UIView    *uploadPropressView;
@property (nonatomic, strong) UILabel   *uploadProgressLabel;

@property (nonatomic, strong) UIView *propressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) BOOL isNeedUpdateFrame;
@property (nonatomic, strong) MBRoundProgressView *pv;
@property (nonatomic, strong) DACircularProgressView *loadingIndicator;

@end

@implementation QIMImageStorage

- (instancetype)init {
    
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUploadProgress:) name:kQIMUploadImageProgress object:nil];
    }
    return self;
}

- (MBRoundProgressView *)pv {
    if (!_pv) {
        _pv = [[MBRoundProgressView alloc] init];
    }
    return _pv;
}

- (void)initUploadProgressView {
    self.uploadPropressView = [[UIView alloc] initWithFrame:CGRectMake(_imageView.left, _imageView.top, _imageView.width, _imageView.height)];
    self.uploadPropressView.backgroundColor = [UIColor lightGrayColor];
    self.uploadPropressView.alpha = 0.5;
    self.uploadPropressView.hidden = YES;
    [self.ownerView addSubview:self.uploadPropressView];
    
    self.uploadProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _uploadPropressView.width, _uploadPropressView.height)];
    [self.uploadProgressLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.uploadProgressLabel setBackgroundColor:[UIColor clearColor]];
    [self.uploadProgressLabel setText:@""];
    [self.uploadProgressLabel setTextAlignment:NSTextAlignmentCenter];
    [self.uploadProgressLabel setTextColor:[UIColor whiteColor]];
    [self.uploadPropressView addSubview:self.uploadProgressLabel];
}

/*
- (UIView *)propressView {
    if (!_propressView) {
        _propressView = [[UIView alloc] initWithFrame:CGRectMake(_imageView.left, _imageView.top, _imageView.width, _imageView.height)];
        _propressView.backgroundColor = [UIColor lightGrayColor];
        _propressView.alpha = 0.5;
        _propressView.hidden = YES;
        [_imageView addSubview:_propressView];
    }
    return _propressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _propressView.width, _propressView.height)];
        [_progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setText:@""];
        [_progressLabel setTextAlignment:NSTextAlignmentCenter];
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [self.propressView addSubview:_progressLabel];
    }
    return _progressLabel;
}
*/

#pragma mark - protocol

- (void)setOwnerView:(UIView *)ownerView
{
    _ownerView = ownerView;
    if (!ownerView || !_imageURL) {
        return;
    }
}

- (void)drawStorageWithRect:(CGRect)rect
{
    if (rect.size.width == 0 || rect.size.height == 0) {
        return;
    }
    _rect = rect;
    
    UIImage *placeHolderImage = [UIImage qim_imageNamedFromQIMUIKitBundle:@"PhotoDownloadPlaceHolder"];
    __block QIMImage *image = nil;
    [_imageView setImage:placeHolderImage];
    _isNeedUpdateFrame = YES;
    if (self.emotionImage) {
        // 本地Emotion图片
        CGRect fitRect = [self rectFitOriginSize:self.emotionImage.size byRect:rect];
        //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
        fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.emotionImage) {
                [_imageView removeFromSuperview];
                _imageView = [[QIMImageView alloc] initWithFrame:fitRect];
                _imageView.image = self.emotionImage;
                [self.ownerView addSubview:_imageView];
            }
        });
    } else if (_imageName){
        // 图片网址
        image = (QIMImage *)[QIMImage qim_imageNamedFromQIMUIKitBundle:_imageName];
        if (image.images.count <= 1) {
            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawImage(context, fitRect, image.CGImage);
        } else {
            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
            //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
            fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [_imageView removeFromSuperview];
                    _imageView = [[QIMImageView alloc] initWithFrame:fitRect];
                    _imageView.image = image;
                    [self.ownerView addSubview:_imageView];
                }
            });
        }
    } else if (_imageURL){
        // 图片数据
        NSString *urlStr = _imageURL.absoluteString;
        NSURL *smallPicUrl = nil;
        if ([urlStr containsString:@"LocalFileName"]) {
            urlStr = [[urlStr componentsSeparatedByString:@"LocalFileName="] lastObject];
            self.imageStorageMD5 = urlStr;
            urlStr = [[QIMImageManager sharedInstance] defaultCachePathForKey:urlStr];
            smallPicUrl = [NSURL fileURLWithPath:urlStr];
        } else {
            if (![urlStr containsString:@"?"]) {
                urlStr = [urlStr stringByAppendingString:@"?"];
                if (![urlStr containsString:@"platform"]) {
                    urlStr = [urlStr stringByAppendingString:@"platform=touch"];
                }
                if (![urlStr containsString:@"imgtype"]) {
                    urlStr = [urlStr stringByAppendingString:@"&imgtype=thumb"];
                }
                if (![urlStr containsString:@"webp="]) {
                    urlStr = [urlStr stringByAppendingString:@"&webp=true"];
                }
            } else {
                if (![urlStr containsString:@"platform"]) {
                    urlStr = [urlStr stringByAppendingString:@"&platform=touch"];
                }
                if (![urlStr containsString:@"imgtype"]) {
                    urlStr = [urlStr stringByAppendingString:@"&imgtype=thumb"];
                }
                if (![urlStr containsString:@"webp="]) {
                    urlStr = [urlStr stringByAppendingString:@"&webp=true"];
                }
            }
            smallPicUrl = [NSURL URLWithString:urlStr];
        }

        CGFloat width = self.size.width;
        CGFloat height = self.size.height;
        if (self.size.width >= ([UIScreen mainScreen].bounds.size.width / 2.0f) || self.size.height >= ([UIScreen mainScreen].bounds.size.height / 2.0f)) {
            width = self.size.width / 2.0f;
            height = self.size.height / 2.0f;
        }
        _imageView = [[QIMImageView alloc] init];
        [_imageView qim_setImageWithURL:smallPicUrl placeholderImage:placeHolderImage options:SDWebImageProgressiveLoad progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            NSLog(@"receivedSize : %ld / expectedSize : %ld", receivedSize , expectedSize);
            dispatch_async(dispatch_get_main_queue(), ^{

                // Loading indicator
                _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                _loadingIndicator.thicknessRatio = 0.1;
                _loadingIndicator.progressTintColor = [UIColor whiteColor];
                _loadingIndicator.trackTintColor = [UIColor grayColor];
                _loadingIndicator.roundedCorners = NO;
                _loadingIndicator.progress = (CGFloat)((CGFloat)receivedSize / (CGFloat)expectedSize);
                //[self.ownerView addSubview:_loadingIndicator];
            });
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            CGRect fitRect = rect;
            //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
            fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
            dispatch_async(dispatch_get_main_queue(), ^{

                if (image) {
                    [_imageView removeFromSuperview];
                    _imageView = [[QIMImageView alloc] initWithFrame:fitRect];
                    if ([smallPicUrl.absoluteString containsString:@".gif"]) {
                        _imageView.image = image;
                        [self.ownerView addSubview:_imageView];
                    } else {
                        UIImage *imageTemp = image;
                        CGSize imageTempSize = imageTemp.size;
                        CGFloat rectRatio = fitRect.size.width * 1.0 / fitRect.size.height;
                        CGFloat imageRatio = imageTempSize.width * 1.0 / imageTempSize.height;
                        if (imageRatio > rectRatio) {
                            CGFloat scale = fitRect.size.width / fitRect.size.height;
                            CGFloat imageWidth = imageTempSize.height * scale;
                            imageTemp = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage],CGRectMake(imageTemp.size.width / 2.0 - imageWidth/2.0 ,0, imageWidth, image.size.height))];
                        } else {
                            CGFloat scale = fitRect.size.height / fitRect.size.width;
                            CGFloat imageHeight = scale * imageTemp.size.width;
                            imageTemp = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage],CGRectMake(0, imageTemp.size.height / 2.0 - imageHeight / 2.0, image.size.width, imageHeight))];
                        }
                        _imageView.image = imageTemp;
                        [self.ownerView addSubview:_imageView];
                    }
                    [self initUploadProgressView];
                } else {
                    
                }
            });
            return;
        }];
    }
}

- (CGRect)rectFitOriginSize:(CGSize)size byRect:(CGRect)byRect{
    if (_imageAlignment == QCImageAlignmentFill) {
        return byRect;
    }
    CGRect scaleRect = byRect;
    CGFloat originTargetWidth = size.width;
    CGFloat originTargetHeight = size.height;
    CGFloat targetWidth = byRect.size.width <= 0 ? size.width : byRect.size.width;
    CGFloat targetHeight = byRect.size.height <= 0 ? size.height : byRect.size.height;
    CGFloat widthFactor = targetWidth / size.width;
    CGFloat heightFactor = targetHeight / size.height;
    CGFloat scaleFactor = MIN(widthFactor, heightFactor);
    CGFloat scaledWidth  = size.width * scaleFactor;
    CGFloat scaledHeight = size.height * scaleFactor;
    // center the image
    if (originTargetHeight > SCREEN_HEIGHT * 3 && originTargetHeight / originTargetWidth >= 5) {
        scaleRect.size = CGSizeMake(50, 100);
        scaleRect.origin = CGPointMake(0, 0);
    } else {
        scaleRect.size = CGSizeMake(scaledWidth, scaledHeight);
        if (widthFactor < heightFactor) {
            scaleRect.origin.y += (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            switch (_imageAlignment) {
                case QCImageAlignmentCenter:
                    scaleRect.origin.x += (targetWidth - scaledWidth) * 0.5;
                    break;
                case QCImageAlignmentRight:
                    scaleRect.origin.x += (targetWidth - scaledWidth);
                default:
                    break;
            }
        }
    }
    return scaleRect;
}

// override
- (void)didNotDrawRun
{
    
}

#pragma mark - NSNotifications

- (void)updateUploadProgress:(NSNotification *)notify {
    NSDictionary *imageUploadProgressDic = notify.object;
//    @{@"ImageUploadKey":localImageKey, @"ImageUploadProgress":@(1.0)}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *imageUploadKey = [imageUploadProgressDic objectForKey:@"ImageUploadKey"];
        if ([imageUploadKey isEqualToString:self.imageStorageMD5]) {
            if (!_uploadPropressView) {
                [self initUploadProgressView];
            }
            NSLog(@"upload Notify : %@", notify);
            float progressValue = [[imageUploadProgressDic objectForKey:@"ImageUploadProgress"] floatValue];
            if (progressValue < 1.0 && progressValue > 0.0) {
                self.uploadPropressView.frame = CGRectMake(_imageView.left, _imageView.top, _imageView.width, _imageView.height * (1 - progressValue));
                NSString *str = [NSString stringWithFormat:@"%d%%",(int)(progressValue * 100)];
                [self.uploadProgressLabel setText:str];
                [self.uploadPropressView setHidden:NO];
            } else {
                [self.uploadPropressView setHidden:YES];
            }
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
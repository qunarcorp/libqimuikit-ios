//
//  QIMWorkMomentImageListView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentImageListView.h"
#import "QIMWorkMomentPicture.h"
#import "NSData+ImageContentType.h"

// 图片间距
#define kImagePadding       5
// 图片宽度
#define kImageWidth         96

@interface QIMWorkMomentImageListView ()

// 图片视图数组
@property (nonatomic, strong) NSMutableArray *imageViewsArray;

@end

@implementation QIMWorkMomentImageListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageViewsArray = [[NSMutableArray alloc] init];
        // 预先创建9个图片控件 避免动态创建
        for (int i = 0; i < 9; i++) {
            QIMWorkMomentImageView *imageView = [[QIMWorkMomentImageView alloc] initWithFrame:CGRectZero];
            imageView.tag = 1000 + i;
            [_imageViewsArray addObject:imageView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCallback:)];
            [imageView addGestureRecognizer:tap];
            [self addSubview:imageView];
        }
    }
    return self;
}

- (void)singleTapGestureCallback:(UITapGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    NSInteger tag = view.tag;
    if (self.tapSmallImageView) {
        self.tapSmallImageView(self.momentContentModel, tag - 1000);
    }
}

#pragma mark - Setter
- (void)setMomentContentModel:(QIMWorkMomentContentModel *)momentContentModel {
    _momentContentModel = momentContentModel;
    for (QIMWorkMomentImageView *imageView in _imageViewsArray) {
//        imageView.hidden = YES;
    }
    // 图片区
    // 添加图片
    NSInteger count = momentContentModel.imgList.count;
    if (count == 0) {
        self.size = CGSizeZero;
        return;
    }
    __block QIMWorkMomentImageView *imageView = nil;
    for (NSInteger i = 0; i < count; i++)
    {
        if (i > 8) {
            break;
        }
        __block QIMWorkMomentPicture *picture = (QIMWorkMomentPicture *)[momentContentModel.imgList objectAtIndex:i];
        NSInteger rowNum = i/3;
        NSInteger colNum = i%3;
        if(count == 4) {
            rowNum = i/2;
            colNum = i%2;
        }
        
        CGFloat imageX = colNum * (kImageWidth + kImagePadding);
        CGFloat imageY = rowNum * (kImageWidth + kImagePadding);
        CGRect frame = CGRectMake(imageX, imageY, kImageWidth, kImageWidth);
        
        //单张图片需计算实际显示size
        if (count == 1) {
            CGSize singleSize = CGSizeMake(180, 180);
            frame = CGRectMake(0, 0, singleSize.width, singleSize.height);
        }
        imageView = [self viewWithTag:1000+i];
        imageView.frame = frame;
        NSString *imageUrl = picture.imageUrl;
        picture.imageIndex = i;
        if (![imageUrl qim_hasPrefixHttpHeader]) {
            imageUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], imageUrl];
        } else {
            
        }
        if ([imageUrl rangeOfString:@"?"].location != NSNotFound) {

            imageUrl = [imageUrl stringByAppendingFormat:@"&w=%d&h=%d", (int)[[UIScreen mainScreen] qim_rightWidth], (int)[[UIScreen mainScreen] height]/2];
        } else {
            imageUrl = [imageUrl stringByAppendingFormat:@"?w=%d&h=%d", (int)[[UIScreen mainScreen] qim_rightWidth], (int)[[UIScreen mainScreen] height]/2];
//            [imageUrl stringByAppendingFormat:@"?w=%d&h=%d",
//                      (int)96*2,
//                      (int)96*2];
        }
        if (![imageUrl containsString:@"platform"]) {
            imageUrl = [imageUrl stringByAppendingString:@"&platform=touch"];
        }
        if (![imageUrl containsString:@"imgtype"]) {
            imageUrl = [imageUrl stringByAppendingString:@"&imgtype=thumb"];
        }
        if (![imageUrl containsString:@"webp="]) {
            imageUrl = [imageUrl stringByAppendingString:@"&webp=true"];
        }
        [imageView downLoadImageWithModel:imageUrl withFitRect:frame withTotalCount:count];
    }
    self.width = [[UIScreen mainScreen] qim_rightWidth] - 60 - 20;
    self.height = imageView.bottom;
}

@end


@implementation QIMWorkMomentImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"PhotoDownloadPlaceHolder"];
    }
    return self;
}

- (CGRect)rectFitOriginSize:(CGSize)size byRect:(CGRect)byRect{
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
        scaleRect.size = CGSizeMake(100, 180);
        scaleRect.origin = CGPointMake(0, 0);
    } else {
        scaleRect.size = CGSizeMake(180, 180);
    }
    return scaleRect;
}

- (void)downLoadImageWithModel:(NSString *)imageUrl withFitRect:(CGRect)frame withTotalCount:(NSInteger)totalCount {
    /*
    [self qim_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"PhotoDownloadPlaceHolder"] options:SDWebImageDecodeFirstFrameOnly progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    */
    [self qim_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"PhotoDownloadPlaceHolder"] options:SDWebImageDecodeFirstFrameOnly progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __block CGRect fitRect = frame;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image && totalCount != 1) {
                self.frame = fitRect;
                if ([imageUrl containsString:@".gif"]) {
                    self.image = image;
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
                    self.image = imageTemp;
                }
            } else if (image && totalCount == 1) {
                
                //单张图片处理
                CGRect newSingleFrame = [self rectFitOriginSize:image.size byRect:self.frame];
                fitRect = newSingleFrame;
                [UIView animateWithDuration:0.1 animations:^{
                    
                } completion:^(BOOL finished) {
                    self.frame = newSingleFrame;
                    if ([imageUrl containsString:@".gif"]) {
                        self.image = image;
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
                        self.image = imageTemp;
                    }
                }];
            }
        });
    }];
}

- (void)singleTapGestureCallback:(UIGestureRecognizer *)gesture {
    UIView *view = (UIView *)gesture.view;
    NSInteger tag = view.tag;
    
    if (self.tapSmallView) {
        self.tapSmallView(self);
    }
}

@end

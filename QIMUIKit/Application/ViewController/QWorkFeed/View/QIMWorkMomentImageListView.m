//
//  QIMWorkMomentImageListView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentImageListView.h"
#import "QIMWorkMomentPicture.h"
#import "QIMWorkMomentPictureMetadata.h"
#import "YLImageView.h"

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
        QIMWorkMomentPicture *picture = (QIMWorkMomentPicture *)[momentContentModel.imgList objectAtIndex:i];
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
        if (![imageUrl qim_hasPrefixHttpHeader]) {
            imageUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], imageUrl];
        } else {
            
        }
//        if ([imageUrl rangeOfString:@"?"].location != NSNotFound) {
//
//            imageUrl = [imageUrl stringByAppendingFormat:@"&w=%d&h=%d",
//                      (int)96*2,
//                      (int)96*2];
//        } else {
//            imageUrl = [imageUrl stringByAppendingFormat:@"?w=%d&h=%d",
//                      (int)96*2,
//                      (int)96*2];
//        }
//        QIMVerboseLog(@"imageUrl : %@", imageUrl);
        [imageView qim_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"q_work_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            __block CGRect fitRect = frame;//[self rectFitOriginSize:image.size byRect:rect];
            //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
            //            fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image && count != 1) {
                    imageView = [[YLImageView alloc] initWithFrame:fitRect];
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
                    imageView.image = imageTemp;
                } else if (image && count == 1) {
                    //单张图片处理
                    CGRect newSingleFrame = [self rectFitOriginSize:image.size byRect:imageView.frame];
                    fitRect = newSingleFrame;
                    [UIView animateWithDuration:0.1 animations:^{
                        
                    } completion:^(BOOL finished) {
                        imageView.frame = newSingleFrame;
                        imageView.hidden = NO;
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
                        imageView.image = imageTemp;
                    }];
                }
            });
        }];
    }
    self.width = SCREEN_WIDTH - 60 - 20;
    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
        self.width = [[UIScreen mainScreen] qim_rightWidth] - 60 - 20;
    }
    self.height = imageView.bottom;
}

- (CGSize)getSingleSize:(CGSize)singleSize {
    CGFloat max_width = SCREEN_WIDTH - 80;
    CGFloat max_height = SCREEN_WIDTH - 80;
    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
        max_width = [[UIScreen mainScreen] qim_rightWidth] - 80;
        max_height = [[UIScreen mainScreen] qim_rightWidth] - 80;
    }
    CGFloat image_width = singleSize.width;
    CGFloat image_height = singleSize.height;
    
    CGFloat result_width = 0;
    CGFloat result_height = 0;
    if (image_height/image_width > 3.0) {
        result_height = max_height;
        result_width = result_height/2;
    }  else  {
        result_width = max_width;
        result_height = max_width*image_height/image_width;
        if (result_height > max_height) {
            result_height = max_height;
            result_width = max_height*image_width/image_height;
        }
    }
    return CGSizeMake(result_width, result_height);
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
    }
    return self;
}

- (void)singleTapGestureCallback:(UIGestureRecognizer *)gesture {
    UIView *view = (UIView *)gesture.view;
    NSInteger tag = view.tag;
    
    if (self.tapSmallView) {
        self.tapSmallView(self);
    }
}

@end

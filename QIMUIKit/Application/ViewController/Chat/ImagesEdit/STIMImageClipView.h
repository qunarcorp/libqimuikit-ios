//
//  STIMImageClipView.h
//  STChatIphone
//
//  Created by haibin.li on 15/7/7.
//
//

typedef enum {
    STIMImageClipViewTransformUp,
    STIMImageClipViewTransformLeft,
    STIMImageClipViewTransformDown,
    STIMImageClipViewTransformRight,
} STIMImageClipViewTransformType;

#import "STIMCommonUIFramework.h"

@class STIMImageClipView;

@protocol STIMImageClipViewDelegate <NSObject>

- (void)imageClipView:(STIMImageClipView *)imageClipView didChangedByClipRect:(CGRect)rect;

@end

@interface STIMImageClipView : UIView
{
    UIImageView *imgView;
    CGRect cliprect;
    CGColorRef grayAlpha;
    CGPoint touchPoint;
    float   imageToViewScale;
}

@property (nonatomic,assign)id<STIMImageClipViewDelegate> delegate;
@property (nonatomic,assign) STIMImageClipViewTransformType transformType;

- (id)initWithFrame:(CGRect)frame imageView:(UIImage *)image;

- (UIImage*)getClipImage;
- (UIImage*)getClipImageForOriginalImage:(UIImage *)originalImage;

- (void) resetClipRectWithImage : (UIImage *)image;

@end

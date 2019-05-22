//
//  QIMChatBubbleView.m
//  qunarChatIphone
//
//  Created by chenjie on 16/2/16.
//
//

#import "QIMChatBubbleView.h"

@interface QIMChatBubbleView ()
{
    CALayer	  *_contentLayer;
    CAShapeLayer *_maskLayer;
    CAShapeLayer     * _borderLayer;
}

@end

@implementation QIMChatBubbleView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initMask];
}

/*
- (void)initMask {
    //创建一个CGMutablePathRef的可变路径，并返回其句柄
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat trigleSide = 10;
    CGFloat triglePaddingToTop = 15;
    CGPoint origin = self.bounds.origin;
    CGSize size =  CGSizeMake(self.bounds.size.width - trigleSide, self.bounds.size.height);
    if (self.direction == QIMChatBubbleViewDirectionRight) {
        CGFloat boderRadius = 12.0f;
        CGFloat sharpCorner = 12.0f;
        if (origin.y + size.height - boderRadius < origin.y + 7.0f + 4 * boderRadius) {
            sharpCorner = 3.0f;
        }
        CGPathMoveToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - sharpCorner, origin.y);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, origin.y + sharpCorner, sharpCorner, -M_PI_2, 0, NO);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f);
        CGPathAddArc(path, NULL, origin.x + size.width + boderRadius, 7.0f, boderRadius, M_PI, M_PI_2, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f +  boderRadius);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, size.height - sharpCorner);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, size.height - sharpCorner, sharpCorner, 0, M_PI_2, NO);
        
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, size.height);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - sharpCorner, sharpCorner, M_PI_2, M_PI, NO);
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + sharpCorner);
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + sharpCorner, sharpCorner, M_PI_2, 0, NO);
    } else {
        origin = CGPointMake(5, 0);
        CGFloat boderRadius = 6.0f;
        CGFloat sharpCorner = 8.0f;
        
        //先将画笔移至最右
        CGPathMoveToPoint(path, NULL, origin.x + size.width, origin.y);
        //再将画笔移至左边，距离origin 右sharpCorner
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner + boderRadius, origin.y);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + sharpCorner + boderRadius, boderRadius, M_PI_2, M_PI, YES);
        //将画笔移至距离Origin下8
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, origin.y + 8);
//        CGPathAddLineToPoint(path, NULL, origin.x, 5);
        //将画笔移动至(Origin, Origin.y + 13)
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + 16);
        
        //将画笔移动至(Origin.x + sharpCorner, Origin.y + 20 )
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, origin.y + 24);
        

        CGPathAddLineToPoint(path, NULL, origin.x, 5 + 2 * boderRadius / sqrt(2));

        //将画笔移动至(Origin.x + sharpCorner, Origin.y + Size.height)
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, size.height);
        
//        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height, sharpCorner, M_PI, M_PI_2, YES);
        //将画笔移动至(Origin.x + size.width - sharpCorner, Size.height)
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, size.height);
        
//        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, size.height - sharpCorner, sharpCorner, M_PI_2, 0, YES);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, origin.y);
//        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, origin.y + sharpCorner, sharpCorner, 3 * M_PI_2, 0, NO);
        CGPathCloseSubpath(path);
    }
    
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor blackColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.frame = self.bounds;
        _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
    }
    _maskLayer.path = path;
    
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.strokeColor    = [UIColor clearColor].CGColor;
        _borderLayer.lineWidth      = 2;
        _borderLayer.frame = self.bounds;
    }
    
    if (self.direction == QIMChatBubbleViewDirectionLeft) {
        _borderLayer.fillColor  = [UIColor qim_leftBallocColor].CGColor;
    }else{
        _borderLayer.fillColor  = [UIColor qim_rightBallocColor].CGColor;
    }
    _borderLayer.path = path;
    
    self.layer.mask = _maskLayer;
    [self.layer addSublayer:_borderLayer];
    CGPathRelease(path);
}
*/

/*
- (void)initMask {
    //创建一个CGMutablePathRef的可变路径，并返回其句柄
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat trigleSide = 10;
    CGFloat triglePaddingToTop = 15;
    CGPoint origin = self.bounds.origin;
    CGSize size =  CGSizeMake(self.bounds.size.width - trigleSide, self.bounds.size.height);
    if (self.direction == QIMChatBubbleViewDirectionRight) {
        CGFloat boderRadius = 12.0f;
        CGFloat sharpCorner = 12.0f;
        if (origin.y + size.height - boderRadius < origin.y + 7.0f + 4 * boderRadius) {
            sharpCorner = 3.0f;
        }
        CGPathMoveToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - sharpCorner, origin.y);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, origin.y + sharpCorner, sharpCorner, -M_PI_2, 0, NO);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f);
        CGPathAddArc(path, NULL, origin.x + size.width + boderRadius, 7.0f, boderRadius, M_PI, M_PI_2, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f +  boderRadius);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, size.height - sharpCorner);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, size.height - sharpCorner, sharpCorner, 0, M_PI_2, NO);
        
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, size.height);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - sharpCorner, sharpCorner, M_PI_2, M_PI, NO);
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + sharpCorner);
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + sharpCorner, sharpCorner, M_PI_2, 0, NO);
    } else {
        origin = CGPointMake(10, 0);
        CGFloat boderRadius = 6.0f;
        CGFloat sharpCorner = 12.0f;
        // 移动到
        CGPathMoveToPoint(path, NULL, origin.x + size.width - boderRadius, origin.y);
        //移动到最左侧
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        //画弧
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + boderRadius, boderRadius, 3*M_PI/2, M_PI, YES);
        //移动8
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner - boderRadius, 12);
        
        //将画笔移动至(Origin, Origin.y + 13)
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + 20);
        
        //将画笔移动至(Origin.x + sharpCorner, Origin.y + 20 )
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner - boderRadius, origin.y + 28);
        
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner - boderRadius, size.height - sharpCorner);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - sharpCorner, sharpCorner, M_PI, M_PI_2, YES);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - sharpCorner, size.height);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, size.height - sharpCorner, sharpCorner, M_PI_2, 0, YES);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, origin.y + sharpCorner);
        CGPathAddArc(path, NULL, origin.x + size.width - boderRadius, origin.y + boderRadius, boderRadius, 3 * M_PI_2, 0, NO);
        CGPathCloseSubpath(path);
    }
    
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor blackColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.frame = self.bounds;
        _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
    }
    _maskLayer.path = path;
    
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.strokeColor    = [UIColor redColor].CGColor;
        _borderLayer.lineWidth      = 0.5;
        _borderLayer.frame = self.bounds;
    }
    
    if (self.direction == QIMChatBubbleViewDirectionLeft) {
        _borderLayer.fillColor  = [UIColor qim_leftBallocColor].CGColor;
    }else{
        _borderLayer.fillColor  = [UIColor qim_rightBallocColor].CGColor;
    }
    _borderLayer.path = path;
    
    self.layer.mask = _maskLayer;
    [self.layer addSublayer:_borderLayer];
    CGPathRelease(path);
}
*/

/* 2019-05-07之前的气泡
 */
- (void)initMask {
    //创建一个CGMutablePathRef的可变路径，并返回其句柄
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat trigleSide = 10;
    CGFloat triglePaddingToTop = 15;
    CGPoint origin = self.bounds.origin;
    CGSize size =  CGSizeMake(self.bounds.size.width - trigleSide, self.bounds.size.height);
    if (self.direction == QIMChatBubbleViewDirectionRight) {
        CGFloat boderRadius = 6.0f;
        CGFloat sharpCorner = 12.0f;
        
        CGPathMoveToPoint(path, NULL, origin.x + size.width - 2 * boderRadius, origin.y);
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + boderRadius, boderRadius, 3*M_PI/2 , M_PI, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + boderRadius, size.height - boderRadius);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - boderRadius, boderRadius, M_PI, M_PI_2, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - 2 * boderRadius, size.height);
        CGPathAddArc(path, NULL, origin.x + size.width - 2 * boderRadius, size.height - boderRadius, boderRadius, M_PI_2, 0, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - boderRadius, 27);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 21);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - boderRadius, 15);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - boderRadius, 10);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - boderRadius, origin.y + boderRadius);
        CGPathAddArc(path, NULL, origin.x + size.width - 2 * boderRadius, origin.y + boderRadius, boderRadius, 0, 3 * M_PI_2, YES);
        
        CGPathMoveToPoint(path, NULL, origin.x + size.width - boderRadius, origin.y);
        
//        CGPathAddLineToPoint(path, NULL, origin.x + + size.wi boderRadius, 10);
//        CGPathAddLineToPoint(path, NULL, origin.x + boderRadius, 15);
//        CGPathAddLineToPoint(path, NULL, origin.x, 21);
//        CGPathAddLineToPoint(path, NULL, origin.x + boderRadius, 27);
        
        CGPathCloseSubpath(path);
        /*
        CGPathMoveToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - boderRadius, origin.y);
        
        CGPathAddArc(path, NULL, origin.x + size.width - boderRadius, origin.y + boderRadius, boderRadius, 3*M_PI/2, M_PI, NO);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f);
        CGPathAddArc(path, NULL, origin.x + size.width + boderRadius, 7.0f, boderRadius, M_PI, M_PI_2, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f +  boderRadius);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, size.height - sharpCorner);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, size.height - sharpCorner, sharpCorner, 0, M_PI_2, NO);
        
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, size.height);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - sharpCorner, sharpCorner, M_PI_2, M_PI, NO);
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + sharpCorner);
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + sharpCorner, sharpCorner, M_PI_2, 0, NO);
        */
    } else {
        origin = CGPointMake(5, 0);
        CGFloat boderRadius = 6.0f;
        CGFloat sharpCorner = 12.0f;

        CGPathMoveToPoint(path, NULL, origin.x + size.width - boderRadius, origin.y);
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + boderRadius, boderRadius, 3*M_PI/2 , M_PI, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + boderRadius, 10);
        CGPathAddLineToPoint(path, NULL, origin.x + boderRadius, 15);
        CGPathAddLineToPoint(path, NULL, origin.x, 21);
        CGPathAddLineToPoint(path, NULL, origin.x + boderRadius, 27);

        CGPathAddLineToPoint(path, NULL, origin.x + boderRadius, size.height - boderRadius);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - boderRadius, boderRadius, M_PI, M_PI_2, YES);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - boderRadius, size.height);
        
        CGPathAddArc(path, NULL, origin.x + size.width - boderRadius, size.height - boderRadius, boderRadius, M_PI_2, 0, YES);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, origin.y + boderRadius);
        CGPathAddArc(path, NULL, origin.x + size.width - boderRadius, origin.y + boderRadius, boderRadius, 0, 3 * M_PI_2, YES);
        CGPathMoveToPoint(path, NULL, origin.x + size.width - boderRadius, origin.y);
        CGPathCloseSubpath(path);
    }
    
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor blackColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.frame = self.bounds;
        _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
    }
    _maskLayer.path = path;
    
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth      = 0.5;
        _borderLayer.frame = self.bounds;
    }

    if (self.direction == QIMChatBubbleViewDirectionLeft) {
        _borderLayer.fillColor  = [UIColor qim_leftBallocColor].CGColor;
        _borderLayer.strokeColor = qim_messageLeftBubbleBorderColor.CGColor;
    } else{
        _borderLayer.fillColor  = [UIColor qim_rightBallocColor].CGColor;
        _borderLayer.strokeColor = qim_messageRightBubbleBorderColor.CGColor;
    }
    _borderLayer.path = path;
    
    self.layer.mask = _maskLayer;
    [self.layer addSublayer:_borderLayer];
    CGPathRelease(path);
}
 
-(void)setBgColor:(UIColor *)color {
    _borderLayer.fillColor = color.CGColor;
    _borderLayer.strokeColor = color.CGColor;
}

- (void)setStrokeColor:(UIColor *)color {
    _borderLayer.strokeColor = color.CGColor;
}

- (void)removeMask {
    self.layer.mask = nil;
    [_borderLayer removeFromSuperlayer];
}

@end

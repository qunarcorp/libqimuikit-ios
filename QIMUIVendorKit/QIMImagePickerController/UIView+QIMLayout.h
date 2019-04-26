//
//  UIView+QIMLayout.h
//
//  Created by 谭真 on 15/2/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    QIMOscillatoryAnimationToBigger,
    QIMOscillatoryAnimationToSmaller,
} QIMOscillatoryAnimationType;

@interface UIView (Layout)

@property (nonatomic) CGFloat qim_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat qim_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat qim_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat qim_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat qim_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat qim_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat qim_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat qim_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint qim_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  qim_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(QIMOscillatoryAnimationType)type;

@end

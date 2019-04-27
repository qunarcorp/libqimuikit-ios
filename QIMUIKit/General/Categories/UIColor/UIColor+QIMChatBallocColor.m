//
//  UIColor+QIMChatBallocColor.m
//  QIMUIKit
//
//  Created by 李露 on 2018/5/21.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "UIColor+QIMChatBallocColor.h"

@implementation UIColor (QIMChatBallocColor)

+ (UIColor *)qim_leftBallocColor{
    NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return qim_messageLeftBubbleBgColor;
    }
    return [UIColor qim_colorWithHex:[infoDic[kOtherBubbleColor][@"colorHex"] integerValue] alpha:[infoDic[kOtherBubbleColor][@"alpha"] floatValue]];
}

+ (UIColor *)qim_leftBallocFontColor{
    NSDictionary *infoDic = [[QIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return qim_messageLeftBubbleTextColor;
    }
    CGFloat alpha = [infoDic[kOtherFontColor][@"alpha"] floatValue];
    if (alpha == 0) {
        alpha = 0.05;
    }
    NSInteger colorHex = [infoDic[kOtherFontColor][@"colorHex"] integerValue];
    if (colorHex == 0xffffff) {
        colorHex = 0;
    }
    return [UIColor qim_colorWithHex:colorHex alpha:alpha];
}

+ (UIColor *)qim_rightBallocColor{
    NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return qim_messageRightBubbleBgColor;
    }
    return [UIColor qim_colorWithHex:[infoDic[kMyBubbleColor][@"colorHex"] integerValue] alpha:[infoDic[kMyBubbleColor][@"alpha"] floatValue]];
}

+ (UIColor *)qim_rightBallocFontColor{
    NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return qim_messageRightBubbleTextColor;
    }
    CGFloat alpha = [infoDic[kMyFontColor][@"alpha"] floatValue];
    if (alpha == 0) {
        alpha = 0.05;
    }
    NSInteger colorHex = [infoDic[kOtherFontColor][@"colorHex"] integerValue];
    if (colorHex == 0xffffff) {
        colorHex = 0;
    }
    return [UIColor qim_colorWithHex:colorHex alpha:alpha];
}

@end

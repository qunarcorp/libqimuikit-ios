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
    return qim_messageLeftBubbleBgColor;
    /*
    //老版本个性装扮后的左侧气泡颜色
    NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return qim_messageLeftBubbleBgColor;
    }
    return [UIColor qim_colorWithHex:[infoDic[kOtherBubbleColor][@"colorHex"] integerValue] alpha:[infoDic[kOtherBubbleColor][@"alpha"] floatValue]];
    */
}

+ (UIColor *)qim_leftBallocFontColor {
    return qim_messageLeftBubbleTextColor;
    /*
     //老版本个性装扮后的左侧字体颜色
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
     */
}

+ (UIColor *)qim_rightBallocColor {
    return qim_messageRightBubbleBgColor;
    /*
    //老版本个性装扮后的右侧气泡颜色
    NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return qim_messageRightBubbleBgColor;
    }
    return [UIColor qim_colorWithHex:[infoDic[kMyBubbleColor][@"colorHex"] integerValue] alpha:[infoDic[kMyBubbleColor][@"alpha"] floatValue]];
    */
}

+ (UIColor *)qim_rightBallocFontColor {
    return qim_messageRightBubbleTextColor;
    /*
     //老版本个性装扮后的右侧字体颜色
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
     */
}

@end

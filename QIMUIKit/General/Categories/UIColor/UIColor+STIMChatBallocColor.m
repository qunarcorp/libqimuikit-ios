//
//  UIColor+STIMChatBallocColor.m
//  STIMUIKit
//
//  Created by 李海彬 on 2018/5/21.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "UIColor+STIMChatBallocColor.h"

@implementation UIColor (STIMChatBallocColor)

+ (UIColor *)stimDB_leftBallocColor{
    return stimDB_messageLeftBubbleBgColor;
    /*
    //老版本个性装扮后的左侧气泡颜色
    NSDictionary * infoDic = [[STIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return stimDB_messageLeftBubbleBgColor;
    }
    return [UIColor stimDB_colorWithHex:[infoDic[kOtherBubbleColor][@"colorHex"] integerValue] alpha:[infoDic[kOtherBubbleColor][@"alpha"] floatValue]];
    */
}

+ (UIColor *)stimDB_leftBallocFontColor {
    return stimDB_messageLeftBubbleTextColor;
    /*
     //老版本个性装扮后的左侧字体颜色
    NSDictionary *infoDic = [[STIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return stimDB_messageLeftBubbleTextColor;
    }
    CGFloat alpha = [infoDic[kOtherFontColor][@"alpha"] floatValue];
    if (alpha == 0) {
        alpha = 0.05;
    }
    NSInteger colorHex = [infoDic[kOtherFontColor][@"colorHex"] integerValue];
    if (colorHex == 0xffffff) {
        colorHex = 0;
    }
    return [UIColor stimDB_colorWithHex:colorHex alpha:alpha];
     */
}

+ (UIColor *)stimDB_rightBallocColor {
    return stimDB_messageRightBubbleBgColor;
    /*
    //老版本个性装扮后的右侧气泡颜色
    NSDictionary * infoDic = [[STIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return stimDB_messageRightBubbleBgColor;
    }
    return [UIColor stimDB_colorWithHex:[infoDic[kMyBubbleColor][@"colorHex"] integerValue] alpha:[infoDic[kMyBubbleColor][@"alpha"] floatValue]];
    */
}

+ (UIColor *)stimDB_rightBallocFontColor {
    return stimDB_messageRightBubbleTextColor;
    /*
     //老版本个性装扮后的右侧字体颜色
    NSDictionary * infoDic = [[STIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (infoDic == nil) {
        return stimDB_messageRightBubbleTextColor;
    }
    CGFloat alpha = [infoDic[kMyFontColor][@"alpha"] floatValue];
    if (alpha == 0) {
        alpha = 0.05;
    }
    NSInteger colorHex = [infoDic[kOtherFontColor][@"colorHex"] integerValue];
    if (colorHex == 0xffffff) {
        colorHex = 0;
    }
    return [UIColor stimDB_colorWithHex:colorHex alpha:alpha];
     */
}

@end

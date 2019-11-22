//
//  STIMXMenu.h
//  STIMXMenuDemo_ObjC
//
//  Created by 牛萌 on 15/5/6.
//  Copyright (c) 2015年 NiuMeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STIMXMenuItem.h"

typedef void(^STIMXMenuSelectedItem)(NSInteger index, STIMXMenuItem *item);

typedef enum {
    STIMXMenuBackgrounColorEffectSolid      = 0, //!<背景显示效果.纯色
    STIMXMenuBackgrounColorEffectGradient   = 1, //!<背景显示效果.渐变叠加
} STIMXMenuBackgrounColorEffect;

@interface STIMXMenu : NSObject

+ (void)showMenuInView:(UIView *)view fromRect:(CGRect)rect menuItems:(NSArray *)menuItems selected:(STIMXMenuSelectedItem)selectedItem;

+ (void)dismissMenu;

// 主题色
+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;

// 标题字体
+ (UIFont *)titleFont;
+ (void)setTitleFont:(UIFont *)titleFont;

// 背景效果
+ (STIMXMenuBackgrounColorEffect)backgrounColorEffect;
+ (void)setBackgrounColorEffect:(STIMXMenuBackgrounColorEffect)effect;

// 是否显示阴影
+ (BOOL)hasShadow;
+ (void)setHasShadow:(BOOL)flag;

@end

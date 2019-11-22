//
//  STIMAppWindowManager.m
//  STIMUIKit
//
//  Created by 李露 on 2018/6/13.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMAppWindowManager.h"
#import "STIMCommonUIFramework.h"

@implementation STIMAppWindowManager

static STIMAppWindowManager *_windowManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _windowManager = [[STIMAppWindowManager alloc] init];
    });
    return _windowManager;
}

@end


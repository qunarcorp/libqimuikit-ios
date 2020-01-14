//
//  STIMSDKUIHelper.m
//  STIMSDK
//
//  Created by 李海彬 on 2018/9/29.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMSDKUIHelper.h"
#import "STIMFastEntrance.h"
#import "STIMNotificationManager.h"
//#import "STIMBusinessModleUpdate.h"
#import "STIMRemoteNotificationManager.h"

@interface STIMSDKUIHelper ()

@property (nonatomic, strong) UINavigationController *rootNav;

@property (nonatomic, strong) UIViewController *rootVc;

@end

@implementation STIMSDKUIHelper

+ (void)load {
    
    [STIMNotificationManager sharedInstance];
}

static STIMSDKUIHelper *_uiHelper = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uiHelper = [[STIMSDKUIHelper alloc] init];
        [STIMKit sharedInstance];
    });
    return _uiHelper;
}

+ (instancetype)sharedInstanceWithRootNav:(UINavigationController *)rootNav rootVc:(UIViewController *)rootVc {
    STIMSDKUIHelper *helper = [STIMSDKUIHelper shareInstance];
    if (rootNav && rootVc) {
        helper.rootNav = rootNav;
        helper.rootVc = rootVc;
        [STIMFastEntrance sharedInstanceWithRootNav:rootNav rootVc:rootVc];
    } else {
        NSAssert(rootNav, @"RootNav shuold not be nil, Please check the rootNav");
        NSAssert(rootVc, @"RootVc should not be nil, Please check the rootVC");
    }
    return helper;
}

- (void)checkUpNotifacationHandle {
    [STIMRemoteNotificationManager checkUpNotifacationHandle];
}

- (void)updateSTMicroTourModel {
//    [STIMBusinessModleUpdate updateSTMicroTourModel];
}

@end

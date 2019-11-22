//
//  STIMCommonUIFramework.h
//  STIMUIKit
//
//  Created by 李露 on 2018/9/28.
//  Copyright © 2018年 STIM. All rights reserved.
//

#ifndef STIMCommonUIFramework_h
#define STIMCommonUIFramework_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "STIMNavController.h"
#import "STIMImageManager.h"
#import "STIMFastEntrance.h"
#import "STIMWindowManager.h"
#import "STIMAppWindowManager.h"
#import "ASIHTTPRequest.h"

#import "UIImageView+STIMImageCache.h"
#import "UIImage+STIMUIKit.h"
#import "UIColor+STIMChatBallocColor.h"
#import "UIImage+STIMIconFont.h"
#import "UIImage+STIMButtonIcon.h"
#import "UIScreen+STIMIpad.h"

#import "UINavigationController+FDFullscreenPopGesture.h"
#import "STIMIconFont.h"
#import "STIMIconInfo.h"
#import "STIMImageView.h"
#import "STIMImage.h"
#import "STIMDeviceManager.h"

#if __has_include("STIMNoteManager.h")
    #import "STIMEncryptChat.h"
#endif

#if __has_include("STIMLocalLog.h")
    #import "STIMLocalLog.h"
#endif

#import "STIMKitPublicHeader.h"
#import "STIMCommonCategories.h"
#import "STIMPublicRedefineHeader.h"

//App颜色，字体全局配置
#import "STIMUIFontConfig.h"
#import "STIMUIColorConfig.h"
#import "STIMUISizeConfig.h"

#import "STIMJSONSerializer.h"
#import "Masonry.h"
#define FONT_NAME @"FZLTHJW--GB1-0"
#define FONT_SIZE 18

#define APP [[UIApplication sharedApplication] delegate]
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define UserDocumentsPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define UserCachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]

#define UserPath [[STIMKit sharedInstance] debugMode] ? @"_Beta": @"_Release"

#define IS_Ipad  [[STIMKit sharedInstance] getIsIpad]

// 判断是否是iPhone X
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

// 状态栏高度
#define STATUS_BAR_HEIGHT (iPhoneX ? 44.f : 20.f)
// 导航栏高度
#define NAVIGATION_BAR_HEIGHT (iPhoneX ? 88.f : 64.f)
// tabBar高度
#define TAB_BAR_HEIGHT (iPhoneX ? (49.f+34.f) : 49.f)
// home indicator
#define HOME_INDICATOR_HEIGHT (iPhoneX ? 34.f : 0.f)

#endif /* STIMCommonUIFramework_h */

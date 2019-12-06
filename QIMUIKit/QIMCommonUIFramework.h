//
//  QIMCommonUIFramework.h
//  QIMUIKit
//
//  Created by 李露 on 2018/9/28.
//  Copyright © 2018年 QIM. All rights reserved.
//

#ifndef QIMCommonUIFramework_h
#define QIMCommonUIFramework_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "QIMNavController.h"
#import "QIMImageManager.h"
#import "QIMFastEntrance.h"
#import "QIMWindowManager.h"
#import "QIMAppWindowManager.h"
//#import "ASIHTTPRequest.h"

#import "UIImageView+QIMImageCache.h"
#import "UIImage+QIMUIKit.h"
#import "UIColor+QIMChatBallocColor.h"
#import "UIImage+QIMIconFont.h"
#import "UIImage+QIMButtonIcon.h"
#import "UIScreen+QIMIpad.h"

#import "UINavigationController+FDFullscreenPopGesture.h"
#import "QIMIconFont.h"
#import "QIMIconInfo.h"
#import "QIMImageView.h"
#import "QIMImage.h"
#import "QIMDeviceManager.h"

#if __has_include("QIMNoteManager.h")
    #import "QIMEncryptChat.h"
#endif

#if __has_include("QIMLocalLog.h")
    #import "QIMLocalLog.h"
#endif

#import "QIMKitPublicHeader.h"
#import "QIMCommonCategories.h"
#import "QIMPublicRedefineHeader.h"

//App颜色，字体全局配置
#import "QIMUIFontConfig.h"
#import "QIMUIColorConfig.h"
#import "QIMUISizeConfig.h"

#import "QIMJSONSerializer.h"
#import "Masonry.h"
#define FONT_NAME @"FZLTHJW--GB1-0"
#define FONT_SIZE 18

#define APP [[UIApplication sharedApplication] delegate]
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define UserDocumentsPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define UserCachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]

#define UserPath [[QIMKit sharedInstance] debugMode] ? @"_Beta": @"_Release"

#define IS_Ipad  [[QIMKit sharedInstance] getIsIpad]

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

#endif /* QIMCommonUIFramework_h */

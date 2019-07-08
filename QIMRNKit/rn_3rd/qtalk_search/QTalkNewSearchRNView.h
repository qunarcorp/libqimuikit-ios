//
//  QTalkNewSearchRNView.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/1.
//  Copyright © 2019 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QIMCommonUIFramework.h"
#import <React/RCTBridge.h>
#import "MBProgressHUD.h"

#define kNotify_RN_QTALK_SEARCH_BUNDLE_UPDATE @"kNotify_RN_QTALK_SEARCH_BUNDLE_UPDATE"

NS_ASSUME_NONNULL_BEGIN

@interface QTalkNewSearchRNView : UIView {
    NSURL *_jsCodeLocation;
}
@property(nonatomic, weak) UIViewController *ownerVC;
@property(nonatomic, strong) MBProgressHUD *progressHUD;

+ (NSString *)getAssetZipBundleName;

+ (NSString *)getAssetBundleName;

+ (NSString *)getInnerBundleName;

+ (NSString *)getCachePath;

@end

NS_ASSUME_NONNULL_END

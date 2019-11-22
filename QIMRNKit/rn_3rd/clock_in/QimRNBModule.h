//
//  QTalkAuth.h
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/4/5.
//
//

#ifndef QTalkAuth_h
#define QTalkAuth_h

#import <React/RCTBridgeModule.h>
#import "STIMRnCheckUpdate.h"
#import "STIMCommonUIFramework.h"

#define kNotify_STIMRN_BUNDLE_UPDATE @"kNotify_STIMRN_BUNDLE_UPDATE"
#define kNotifyVCClose @"kNotifyVCClose"

typedef enum {
    STIMAppTypeInner = 1,    //内部应用
    STIMAppExternal = 2, //外部App
    STIMAppTypeH5 = 3,   //H5 App
} STIMAppType;

static RCTBridge *__innerCacheBridge = nil;

@interface QimRNBModule : NSObject <RCTBridgeModule>

+ (void)loadBridgeCache;

+ (RCTBridge *)getStaticCacheBridge;

+ (NSURL *)getOuterJsLocation:(NSString *)bundleName;

/**
 内嵌应用JSLocation
 */
+ (NSURL *)getJsCodeLocation;

+ (id)clockOnVC;

+ (id)TOTPVC;

+ (void)sendSTIMRNWillShow;

+ (id)createSTIMRNVCWithParam:(NSDictionary *)param;
+ (id)createSTIMRNVCWithBundleName:(NSString *)bundleName
                       WithModule:(NSString *)module
                   WithProperties:(NSDictionary *)properties;

+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module;

+ (UIViewController *)getVCWithParam:(NSDictionary *)param;
+ (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                           WithBundleName:(NSString *)bundleName
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties;

+ (void)openSTIMRNVCWithParam:(NSDictionary *)param;
+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module
              WithProperties:(NSDictionary *)properties;
/*
 * 依赖客户端升级 大版本号
 *
 */
+ (NSString *)getAssetBundleName;

/*
 * 离线资源包 压缩文件名
 *
 */
+ (NSString *)getAssetZipBundleName;

/*
 * 内置bundle 文件名
 *
 */
+ (NSString *)getInnerBundleName;

/*
 * 缓存路径
 *
 */
+ (NSString *)getCachePath;

@end

#endif /* QTalkAuth_h */

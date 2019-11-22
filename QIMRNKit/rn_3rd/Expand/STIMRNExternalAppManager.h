//
//  STIMRNExternalAppManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/23.
//

#import "STIMCommonUIFramework.h"

@interface STIMRNExternalAppManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)checkSTIMRNExternalAppWithBundleUrl:(NSString *)bundleUrl;

/**
 检查当前版本的Bundle是否存在

 @param bundleName bundleName
 @param version bundle Version
 @return 是否存在
 */
- (BOOL)checkSTIMRNExternalAppWithBundleName:(NSString *)bundleName BundleVersion:(NSString *)version;


/**
 下载外部App Bundle包
 */
- (BOOL)downloadSTIMRNExternalAppWithBundleParams:(NSDictionary *)params;

@end

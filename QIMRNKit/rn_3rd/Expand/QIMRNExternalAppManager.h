//
//  QIMRNExternalAppManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/23.
//

#import "QIMCommonUIFramework.h"

@interface QIMRNExternalAppManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)checkQIMRNExternalAppWithBundleUrl:(NSString *)bundleUrl;

/**
 检查当前版本的Bundle是否存在

 @param bundleName bundleName
 @param version bundle Version
 @return 是否存在
 */
- (BOOL)checkQIMRNExternalAppWithBundleName:(NSString *)bundleName BundleVersion:(NSString *)version;


/**
 下载外部App Bundle包
 */
- (void)downloadQIMRNExternalAppWithBundleParams:(NSDictionary *)params withCallBack:(QIMKitDownloadQIMRNExternalAppBundleSuccessCallBack)callBack;

@end

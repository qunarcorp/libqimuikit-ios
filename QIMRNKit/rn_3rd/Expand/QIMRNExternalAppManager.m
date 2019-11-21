//
//  QIMRNExternalAppManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/23.
//

#import "QIMRNExternalAppManager.h"
#import "QimRNBModule.h"
#import "QIMJSONSerializer.h"

static QIMRNExternalAppManager *_manager = nil;

#define rnExternalAppVersion @"rnExternalAppVersion"

@interface QIMRNExternalAppManager ()

@property (nonatomic, strong) NSMutableDictionary *rnExternalAppVersionDict;

@end

@implementation QIMRNExternalAppManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[QIMRNExternalAppManager alloc] init];
    });
    return _manager;
}

- (NSMutableDictionary *)rnExternalAppVersionDict {
    if (!_rnExternalAppVersionDict) {
        NSString *qimrnCachePath = [UserCachesPath stringByAppendingPathComponent:[QimRNBModule getCachePath]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:qimrnCachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:qimrnCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *rnAppVersionFileStr = [qimrnCachePath stringByAppendingPathComponent:rnExternalAppVersion];
        _rnExternalAppVersionDict = [NSMutableDictionary dictionaryWithContentsOfFile:rnAppVersionFileStr];
        if (!_rnExternalAppVersionDict) {
            _rnExternalAppVersionDict = [NSMutableDictionary dictionaryWithCapacity:5];
            
        }
    }
    return _rnExternalAppVersionDict;
}


- (BOOL)checkQIMRNExternalAppWithBundleUrl:(NSString *)bundleUrl {
    BOOL checkSuccess = NO;
    NSString *qimrnCachePath = [UserCachesPath stringByAppendingPathComponent:[QimRNBModule getCachePath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:qimrnCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:qimrnCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *bundleMD5Name = [[[QIMKit sharedInstance] qim_cachedFileNameForKey:bundleUrl] stringByAppendingFormat:@".jsbundle"];
    NSString *localBundlePath = [qimrnCachePath stringByAppendingPathComponent: bundleMD5Name];
    //版本号一致 && bundleName一致 && bundle文件存在
    if (localBundlePath && [[NSFileManager defaultManager] fileExistsAtPath:localBundlePath]) {
        checkSuccess = YES;
    } else {
        checkSuccess = NO;
    }
    return checkSuccess;
}

- (BOOL)checkQIMRNExternalAppWithBundleName:(NSString *)bundleName BundleVersion:(NSString *)version {
    BOOL checkSuccess = NO;
    NSString *localBundleName = [NSString stringWithFormat:@"%@.jsbundle", bundleName];
    NSString *localBundleVersion = [self.rnExternalAppVersionDict objectForKey:bundleName];
    NSString *qimrnCachePath = [UserCachesPath stringByAppendingPathComponent:[QimRNBModule getCachePath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:qimrnCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:qimrnCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *localBundlePath = [qimrnCachePath stringByAppendingPathComponent: localBundleName];
    //版本号一致 && bundleName一致 && bundle文件存在
    if (localBundleName && [localBundleVersion isEqualToString:version] && localBundlePath && [[NSFileManager defaultManager] fileExistsAtPath:localBundlePath]) {
        checkSuccess = YES;
    } else {
        checkSuccess = NO;
    }
    return checkSuccess;
}

- (void)downloadQIMRNExternalAppWithBundleParams:(NSDictionary *)params withCallBack:(QIMKitDownloadQIMRNExternalAppBundleSuccessCallBack)callBack {
    NSString *bundleName= [params objectForKey:@"Bundle"];
    NSString *bundleUrls = [params objectForKey:@"BundleUrls"];
    NSDictionary *bundleDic = [[QIMJSONSerializer sharedInstance] deserializeObject:bundleUrls error:nil];
    BOOL updateBundleSuccess = NO;
    if (bundleUrls.length > 0) {
        __weak __typeof(self) weakSelf = self;
        [[QIMKit sharedInstance] sendTPGetRequestWithUrl:bundleUrls withSuccessCallBack:^(NSData *bundleData) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (bundleData.length > 0) {
                NSString *qimrnCachePath = [UserCachesPath stringByAppendingPathComponent:[QimRNBModule getCachePath]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:qimrnCachePath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:qimrnCachePath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString *bundleMD5Name = [[[QIMKit sharedInstance] qim_cachedFileNameForKey:bundleUrls] stringByAppendingFormat:@".jsbundle"];
                
                NSString *localBundlePath = [qimrnCachePath stringByAppendingPathComponent: bundleMD5Name];
                [bundleData writeToFile:localBundlePath atomically:YES];
                [strongSelf updateLocalRNExternalAppVersion];
                if (callBack) {
                    callBack(YES);
                }
            } else {
                if (callBack) {
                    callBack(NO);
                }
            }
        } withFailedCallBack:^(NSError *error) {
            if (callBack) {
                callBack(NO);
            }
        }];
    }
}


/**
 缓存外部应用版本号Version
 */
- (void)updateLocalRNExternalAppVersion {
    NSString *qimrnCachePath = [UserCachesPath stringByAppendingPathComponent:[QimRNBModule getCachePath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:qimrnCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:qimrnCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *rnAppVersionFileStr = [qimrnCachePath stringByAppendingPathComponent:rnExternalAppVersion];
    [self.rnExternalAppVersionDict writeToFile:rnAppVersionFileStr atomically:YES];
}

- (void)setProgress:(float)newProgress {
    QIMVerboseLog(@"下载进度 : %f", newProgress);
}

@end

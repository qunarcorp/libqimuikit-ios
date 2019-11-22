//
//  STIMRNExternalAppManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/23.
//

#import "STIMRNExternalAppManager.h"
#import "QimRNBModule.h"
#import "ASIHTTPRequest.h"
#import "STIMJSONSerializer.h"

static STIMRNExternalAppManager *_manager = nil;

#define rnExternalAppVersion @"rnExternalAppVersion"

@interface STIMRNExternalAppManager () <ASIProgressDelegate>

@property (nonatomic, strong) NSMutableDictionary *rnExternalAppVersionDict;

@end

@implementation STIMRNExternalAppManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[STIMRNExternalAppManager alloc] init];
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


- (BOOL)checkSTIMRNExternalAppWithBundleUrl:(NSString *)bundleUrl {
    BOOL checkSuccess = NO;
    NSString *qimrnCachePath = [UserCachesPath stringByAppendingPathComponent:[QimRNBModule getCachePath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:qimrnCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:qimrnCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *bundleMD5Name = [[[STIMKit sharedInstance] stimDB_cachedFileNameForKey:bundleUrl] stringByAppendingFormat:@".jsbundle"];
    NSString *localBundlePath = [qimrnCachePath stringByAppendingPathComponent: bundleMD5Name];
    //版本号一致 && bundleName一致 && bundle文件存在
    if (localBundlePath && [[NSFileManager defaultManager] fileExistsAtPath:localBundlePath]) {
        checkSuccess = YES;
    } else {
        checkSuccess = NO;
    }
    return checkSuccess;
}

- (BOOL)checkSTIMRNExternalAppWithBundleName:(NSString *)bundleName BundleVersion:(NSString *)version {
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

- (BOOL)downloadSTIMRNExternalAppWithBundleParams:(NSDictionary *)params {
    NSString *bundleName= [params objectForKey:@"Bundle"];
    NSString *bundleUrls = [params objectForKey:@"BundleUrls"];
    NSDictionary *bundleDic = [[STIMJSONSerializer sharedInstance] deserializeObject:bundleUrls error:nil];
    BOOL updateBundleSuccess = NO;
    if (bundleUrls.length > 0) {
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:bundleUrls]];
        request.downloadProgressDelegate = self;
        [request setTimeOutSeconds:15];
        [request startSynchronous];
        NSError *error = request.error;
        if (!error && [request responseStatusCode] == 200) {
            NSData *bundleData = [request responseData];
            if (bundleData.length > 0) {
                NSString *qimrnCachePath = [UserCachesPath stringByAppendingPathComponent:[QimRNBModule getCachePath]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:qimrnCachePath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:qimrnCachePath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString *bundleMD5Name = [[[STIMKit sharedInstance] stimDB_cachedFileNameForKey:bundleUrls] stringByAppendingFormat:@".jsbundle"];

                NSString *localBundlePath = [qimrnCachePath stringByAppendingPathComponent: bundleMD5Name];
                [bundleData writeToFile:localBundlePath atomically:YES];
//                NSString *version = [params objectForKey:@"Version"];
//                [self.rnExternalAppVersionDict setObject:version forKey:bundleName];
                [self updateLocalRNExternalAppVersion];
                updateBundleSuccess = YES;
            } else {
                updateBundleSuccess = NO;
            }
        } else {
            updateBundleSuccess = NO;
        }
    }
    return updateBundleSuccess;
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
    STIMVerboseLog(@"下载进度 : %f", newProgress);
}

@end

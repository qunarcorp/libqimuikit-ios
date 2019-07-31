//
//  QIMImageCacheManager.m
//  QIMUIKit
//
//  Created by lilu on 2019/7/31.
//

#import "QIMImageCacheManager.h"

@implementation QIMImageCacheManager

+ (instancetype)shareInstance {
    static QIMImageCacheManager *_imageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageManager = [[QIMImageCacheManager alloc] init];
    });
    return _imageManager;
}

- (NSString *)defaultCachePathForKey:(NSString *)fileUrl {
    return [[SDImageCache sharedImageCache] cachePathForKey:fileUrl];
}

- (void)clearMemory {
    [[SDImageCache sharedImageCache] clearMemory];
}

@end

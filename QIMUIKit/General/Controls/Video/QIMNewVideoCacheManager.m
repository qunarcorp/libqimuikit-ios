//
//  QIMNewVideoCacheManager.m
//  QIMUIKit
//
//  Created by lilu on 2019/8/9.
//

#import "QIMNewVideoCacheManager.h"

@interface QIMNewVideoCacheManager ()

@property (nonatomic, copy) NSString *videoCachePath;

@end

@implementation QIMNewVideoCacheManager

+ (instancetype)sharedInstance {
    static QIMNewVideoCacheManager *__manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[QIMNewVideoCacheManager alloc] init];
        __manager.videoCachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/TXCache/txvodcache/tx_cache.plist"];
    });
    return __manager;
}

- (NSArray *)getTXVideoCache {
    NSArray *data = [[NSMutableArray alloc] initWithContentsOfFile:self.videoCachePath];
    return data;
}

- (NSString *)getVideoCachePathWithUrl:(NSString *)url {
    NSArray *cacheData = [self getTXVideoCache];
    for (NSDictionary *videoDic in cacheData) {
        NSString *videoUrl = [videoDic objectForKey:@"url"];
        if ([videoUrl isEqualToString:url]) {
            NSString *videoPath = [videoDic objectForKey:@"path"];
            return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/TXCache/txvodcache/%@", videoPath]];
        }
    }
    return nil;
}

@end

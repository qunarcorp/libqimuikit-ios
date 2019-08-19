//
//  QIMNewVideoCacheManager.h
//  QIMUIKit
//
//  Created by lilu on 2019/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMNewVideoCacheManager : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)getTXVideoCache;

- (NSString *)getVideoCachePathWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END

//
//  QIMImageCacheManager.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/31.
//

#import <Foundation/Foundation.h>
#import "SDWebImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMImageCacheManager : NSObject

+ (instancetype)shareInstance;

- (NSString *)defaultCachePathForKey:(NSString *)fileUrl;

- (void)clearMemory;

@end

NS_ASSUME_NONNULL_END

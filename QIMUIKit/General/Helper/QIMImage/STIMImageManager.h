//
//  STIMImageManager.h
//  STIMUIKit
//
//  Created by 李海彬 on 2018/8/27.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIImageView+STIMImageCache.h"
#import "SDWebImage.h"

@interface STIMImageManager : NSObject

+ (instancetype)sharedInstance;

- (void)initWithSTIMImageCacheNamespace:(NSString *)ns;

- (NSString *)defaultCachePathForKey:(NSString *)key;

- (NSString *)stimDB_getHeaderCachePathWithJid:(NSString *)jid;

- (NSString *)stimDB_getHeaderCachePathWithJid:(NSString *)jid WithChatType:(NSInteger)chatType;

- (NSString *)stimDB_getHeaderCachePathWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType;

- (NSString *)stimDB_getHeaderCachePathWithHeaderUrl:(NSString *)headerUrl;

- (UIImage *)getUserHeaderImageByUserId:(NSString *)jid;

- (NSInteger)stimDB_imageFormatForImageData:(nullable NSData *)data;

- (void)loadImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDInternalCompletionBlock)completedBlock;

- (void)clearMemory;

@end

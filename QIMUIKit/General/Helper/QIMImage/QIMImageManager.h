//
//  QIMImageManager.h
//  QIMUIKit
//
//  Created by 李露 on 2018/8/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIImageView+QIMImageCache.h"
#import "SDWebImage.h"

@interface QIMImageManager : NSObject

+ (instancetype)sharedInstance;

- (void)initWithQIMImageCacheNamespace:(NSString *)ns;

- (NSString *)defaultCachePathForKey:(NSString *)key;

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid;

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid WithChatType:(NSInteger)chatType;

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType;

- (NSString *)qim_getHeaderCachePathWithHeaderUrl:(NSString *)headerUrl;

- (UIImage *)getUserHeaderImageByUserId:(NSString *)jid;

- (NSInteger)qim_imageFormatForImageData:(nullable NSData *)data;

- (void)loadImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDInternalCompletionBlock)completedBlock;

- (void)clearMemory;

@end

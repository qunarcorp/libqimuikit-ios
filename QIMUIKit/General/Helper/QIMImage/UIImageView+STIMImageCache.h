//
//  UIImageView+STIMImageCache.h
//  STIMUIKit
//
//  Created by 李海彬 on 2018/8/27.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "UIImageView+WebCache.h"

@interface UIImageView (STIMImageCache)

- (void)stimDB_setImageWithJid:(NSString *)jid;

- (void)stimDB_setImageWithJid:(NSString *)jid placeholderImage:(UIImage *)placeholder;

- (void)stimDB_setImageWithJid:(NSString *)jid WithChatType:(NSInteger)chatType;

- (void)stimDB_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType;

- (void)stimDB_setImageWithJid:(NSString *)jid WithChatType:(NSInteger)chatType placeholderImage:(UIImage *)placeholder;

- (void)stimDB_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType placeholderImage:(UIImage *)placeholder;

- (void)stimDB_setCollectionImageWithJid:(NSString *)jid WithChatType:(NSInteger)chatType;

- (void)stimDB_setImageWithURL:(NSURL *)url;

- (void)stimDB_setImageWithURL:(NSURL *)url WithChatType:(NSInteger)chatType;

- (void)stimDB_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)stimDB_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock;

- (void)stimDB_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options progress:(nullable SDImageLoaderProgressBlock)progressBlock completed:(nullable SDExternalCompletionBlock)completedBlock;

@end

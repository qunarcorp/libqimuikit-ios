//
//  STIMImageManager.m
//  STIMUIKit
//
//  Created by 李海彬 on 2018/8/27.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMImageManager.h"
#import "NSBundle+STIMLibrary.h"
#import "SDImageCache.h"
#import "STIMKitPublicHeader.h"
#import "STIMCommonCategories.h"
#import "SDImageWebPCoder.h"

@implementation STIMImageManager

static STIMImageManager *__manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[STIMImageManager alloc] init];
        SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
        [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    });
    return __manager;
}

- (void)initWithSTIMImageCacheNamespace:(NSString *)ns {
    [[SDImageCache sharedImageCache] initWithNamespace:ns];
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [[SDImageCache sharedImageCache] cachePathForKey:key];
}

- (NSString *)stimDB_getHeaderCachePathWithJid:(NSString *)jid {
    return [self stimDB_getHeaderCachePathWithJid:jid WithChatType:ChatType_SingleChat];
}

- (NSString *)stimDB_getHeaderCachePathWithJid:(NSString *)jid WithChatType:(ChatType)chatType {
    return [self stimDB_getHeaderCachePathWithJid:jid WithRealJid:nil WithChatType:chatType];
}

- (NSString *)stimDB_getHeaderCachePathWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(ChatType)chatType {
    NSString *headerUrl = nil;
    switch (chatType) {
        case ChatType_SingleChat: {
            headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:jid];
        }
            break;
        case ChatType_GroupChat: {
            headerUrl = [[STIMKit sharedInstance] getGroupHeaderSrc:jid];
        }
            break;
        case ChatType_Consult: {
            headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:jid];
        }
            break;
        case ChatType_ConsultServer: {
            headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:realJid];
        }
            break;
        default:
            break;
    }
    if (headerUrl.length > 0) {
        if (![headerUrl stimDB_hasPrefixHttpHeader]) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        } else {
            
        }
    } else {
        headerUrl = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"QIMRNKit" BundleName:@"QIMRNKit" pathForResource:@"singleHeaderDefault" ofType:@"png"];
    }
    NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:headerUrl];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] && path.length > 0) {
        return path;
    } else {
        return headerUrl;
    }
}

- (NSString *)stimDB_getHeaderCachePathWithHeaderUrl:(NSString *)headerUrl {
    NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:headerUrl];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] && path.length > 0) {
        return path;
    } else {
        return headerUrl;
    }
}

- (UIImage *)getUserHeaderImageByUserId:(NSString *)jid {
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:[self stimDB_getHeaderCachePathWithJid:jid]]];
}

- (NSInteger)stimDB_imageFormatForImageData:(nullable NSData *)data {
    return [NSData sd_imageFormatForImageData:data];
}

- (void)loadImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDInternalCompletionBlock)completedBlock {
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:options progress:progressBlock completed:completedBlock];
}

- (void)clearMemory {
    [[SDImageCache sharedImageCache] clearMemory];
}

@end

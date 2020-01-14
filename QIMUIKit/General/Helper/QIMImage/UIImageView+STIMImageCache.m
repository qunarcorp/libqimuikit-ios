//
//  UIImageView+STIMImageCache.m
//  STIMUIKit
//
//  Created by 李海彬 on 2018/8/27.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "UIImageView+STIMImageCache.h"
#import "UIImage+STIMUIKit.h"
#import "YYDispatchQueuePool.h"

@implementation UIImageView (STIMImageCache)

- (void)stimDB_setImageWithJid:(NSString *)jid {
    [self stimDB_setImageWithJid:jid WithChatType:ChatType_SingleChat];
}

- (void)stimDB_setImageWithJid:(NSString *)jid placeholderImage:(UIImage *)placeholder{
    [self stimDB_setImageWithJid:jid WithChatType:ChatType_SingleChat placeholderImage:[UIImage imageWithData:[STIMKit defaultUserHeaderImage]]];
}

- (void)stimDB_setImageWithJid:(NSString *)jid WithChatType:(ChatType)chatType {
    [self stimDB_setImageWithJid:jid WithChatType:chatType placeholderImage:nil];
}

- (void)stimDB_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(ChatType)chatType {
    [self stimDB_setImageWithJid:jid WithRealJid:realJid WithChatType:chatType placeholderImage:nil];
}

- (void)stimDB_setImageWithJid:(NSString *)jid WithChatType:(ChatType)chatType placeholderImage:(UIImage *)placeholder {
    [self stimDB_setImageWithJid:jid WithRealJid:nil WithChatType:chatType placeholderImage:placeholder];
}

- (void)stimDB_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(ChatType)chatType placeholderImage:(UIImage *)placeholder {
    __block NSString *headerUrl = nil;
    __block UIImage *placeholderImage = placeholder;
    dispatch_async([[STIMKit sharedInstance] getLoadHeaderImageQueue], ^{

        switch (chatType) {
            case ChatType_SingleChat: {
                headerUrl = [[STIMKit sharedInstance] getUserBigHeaderImageUrlWithUserId:jid];
                if (!placeholder) {
                    placeholderImage = [UIImage imageWithData:[STIMKit defaultUserHeaderImage]];
                }
            }
                break;
            case ChatType_GroupChat: {
                headerUrl = [[STIMKit sharedInstance] getGroupBigHeaderImageUrlWithGroupId:jid];
                if (!placeholder) {
                    placeholderImage = [STIMKit defaultGroupHeaderImage];
                }
            }
                break;
            case ChatType_System: {
                if ([jid hasPrefix:@"FriendNotify"]) {
                    placeholderImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"conversation_address-book_avatar"];
                } else {
                    if ([jid hasPrefix:@"rbt-notice"]) {
                        placeholderImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"rbt_notice"];
                    } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                        placeholderImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"rbt-qiangdan"];
                    } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                        placeholderImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"rbt-qiangdan"];
                    } else {
                        placeholderImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"rbt-system"];
                    }
                }
            }
                break;
            case ChatType_PublicNumber: {
                placeholderImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"ReadVerified_icon"];
            }
                break;
            case ChatType_Consult: {
                headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:jid];
                if (!placeholderImage) {
                    placeholderImage = [UIImage imageWithData:[STIMKit defaultUserHeaderImage]];
                }
            }
                break;
            case ChatType_ConsultServer: {
                headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:realJid];
                if (!placeholderImage) {
                    placeholderImage = [UIImage imageWithData:[STIMKit defaultUserHeaderImage]];
                }
            }
                break;
            case ChatType_CollectionChat: {
                headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:realJid];
                placeholderImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"relation"];
            }
                break;
                
            default:
                break;
        }

        if (![headerUrl stimDB_hasPrefixHttpHeader] && headerUrl.length > 0) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        } else {

            if (!headerUrl.length && (jid || realJid)) {
                if (chatType == ChatType_GroupChat) {
                    [[STIMKit sharedInstance] updateGroupCardByGroupId:jid withCache:YES];
                } else if (chatType == ChatType_ConsultServer) {
                    [[STIMKit sharedInstance] updateUserCard:realJid withCache:YES];
                } else {
                    [[STIMKit sharedInstance] updateUserCard:jid withCache:YES];
                }
            } else {
                
            }
        }
        if (headerUrl.length > 0 && ![headerUrl containsString:@"?"]) {
            headerUrl = [headerUrl stringByAppendingString:@"?"];
            if (headerUrl.length > 0 && ![headerUrl containsString:@"platform"]) {
                headerUrl = [headerUrl stringByAppendingString:@"platform=touch"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"imgtype"]) {
                headerUrl = [headerUrl stringByAppendingString:@"&imgtype=thumb"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"webp="]) {
                headerUrl = [headerUrl stringByAppendingString:@"&webp=true"];
            }
        } else {
            if (headerUrl.length > 0 && ![headerUrl containsString:@"platform"]) {
                headerUrl = [headerUrl stringByAppendingString:@"&platform=touch"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"imgtype"]) {
                headerUrl = [headerUrl stringByAppendingString:@"&imgtype=thumb"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"webp="]) {
                headerUrl = [headerUrl stringByAppendingString:@"&webp=true"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stimDB_setImageWithURL:headerUrl placeholderImage:placeholderImage completed:nil];
        });
    });
}

- (void)stimDB_setCollectionImageWithJid:(NSString *)jid WithChatType:(ChatType)chatType {
    __block NSString *headerUrl = nil;
    __block UIImage *placeholderImage = nil;
    dispatch_async([[STIMKit sharedInstance] getLoadHeaderImageQueue], ^{
        switch (chatType) {
            case ChatType_SingleChat: {
                headerUrl = [[STIMKit sharedInstance] getCollectionUserHeaderUrlWithXmppId:jid];
                placeholderImage = [UIImage imageWithData:[STIMKit defaultUserHeaderImage]];
            }
                break;
            case ChatType_GroupChat: {
                headerUrl = [[STIMKit sharedInstance] getCollectionGroupHeaderUrlWithCollectionGroupId:jid];
                placeholderImage = [STIMKit defaultGroupHeaderImage];
            }
                break;
            default:
                break;
        }
        if (![headerUrl stimDB_hasPrefixHttpHeader] && headerUrl.length > 0) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        } else {
            if (!headerUrl && jid) {
                if (chatType == ChatType_GroupChat) {
                    [[STIMKit sharedInstance] updateCollectionGroupCardByGroupId:jid];
                } else {
                    [[STIMKit sharedInstance] updateCollectionUserCardByUserIds:@[jid]];
                }
            } else {
                
            }
        }
        if (headerUrl.length > 0 && ![headerUrl containsString:@"?"]) {
            headerUrl = [headerUrl stringByAppendingString:@"?"];
            if (headerUrl.length > 0 && ![headerUrl containsString:@"platform"]) {
                headerUrl = [headerUrl stringByAppendingString:@"platform=touch"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"imgtype"]) {
                headerUrl = [headerUrl stringByAppendingString:@"&imgtype=thumb"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"webp="]) {
                headerUrl = [headerUrl stringByAppendingString:@"&webp=true"];
            }
        } else {
            if (headerUrl.length > 0 && ![headerUrl containsString:@"platform"]) {
                headerUrl = [headerUrl stringByAppendingString:@"&platform=touch"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"imgtype"]) {
                headerUrl = [headerUrl stringByAppendingString:@"&imgtype=thumb"];
            }
            if (headerUrl.length > 0 && ![headerUrl containsString:@"webp="]) {
                headerUrl = [headerUrl stringByAppendingString:@"&webp=true"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stimDB_setImageWithURL:headerUrl placeholderImage:placeholderImage completed:nil];
        });
    });
}

- (void)stimDB_setImageWithURL:(NSURL *)url {
    [self stimDB_setImageWithURL:url placeholderImage:nil completed:nil];
}

- (void)stimDB_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage {
    if (placeholderImage == nil) {
        placeholderImage = [UIImage imageWithData:[STIMKit defaultUserHeaderImage]];
    }
    [self stimDB_setImageWithURL:url placeholderImage:placeholderImage completed:nil];
}


- (void)stimDB_setImageWithURL:(NSURL *)url WithChatType:(ChatType)chatType {
    
    UIImage *placeholderImage = nil;
    switch (chatType) {
        case ChatType_SingleChat: {
            placeholderImage = [UIImage imageWithData:[STIMKit defaultUserHeaderImage]];
        }
            break;
        case ChatType_GroupChat: {
            placeholderImage = [STIMKit defaultGroupHeaderImage];
        }
            break;
        default:
            break;
    }
    [self stimDB_setImageWithURL:url placeholderImage:placeholderImage completed:nil];
}

- (void)stimDB_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self stimDB_setImageWithURL:url placeholderImage:placeholder options:SDWebImageDecodeFirstFrameOnly progress:nil completed:completedBlock];
}

- (void)stimDB_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options progress:(nullable SDImageLoaderProgressBlock)progressBlock completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}


@end

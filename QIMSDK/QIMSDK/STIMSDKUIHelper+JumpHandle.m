//
//  STIMSDKUIHelper+JumpHandle.m
//  STIMSDK
//
//  Created by 李海彬 on 2018/9/29.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMSDKUIHelper+JumpHandle.h"
#import "STIMJumpURLHandle.h"
#import "STIMFastEntrance.h"

@implementation STIMSDKUIHelper (JumpHandle)

- (BOOL)parseURL:(NSURL *)url {
    return [STIMJumpURLHandle parseURL:url];
}

- (void)sendMailWithRootVc:(UIViewController *)rootVc ByUserId:(NSString *)userId {
    [[STIMFastEntrance sharedInstance] sendMailWithRootVc:rootVc ByUserId:userId];
}

+ (void)openUserChatInfoByUserId:(NSString *)userId {
    [STIMFastEntrance openUserChatInfoByUserId:userId];
}

+ (void)openUserCardVCByUserId:(NSString *)userId {
    [STIMFastEntrance openUserCardVCByUserId:userId];
}

+ (void)openSTIMGroupCardVCByGroupId:(NSString *)groupId {
    [STIMFastEntrance openSTIMGroupCardVCByGroupId:groupId];
}

+ (void)openConsultChatByChatType:(NSInteger)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    [STIMFastEntrance openConsultChatByChatType:chatType UserId:userId WithVirtualId:virtualId];
}

+ (void)openSingleChatVCByUserId:(NSString *)userId {
    [STIMFastEntrance openSingleChatVCByUserId:userId];
}

+ (void)openGroupChatVCByGroupId:(NSString *)groupId {
    [STIMFastEntrance openGroupChatVCByGroupId:groupId];
}

+ (void)openHeaderLineVCByJid:(NSString *)jid {
    [STIMFastEntrance openHeaderLineVCByJid:jid];
}

+ (void)openSTIMRNVCWithModuleName:(NSString *)moduleName WithProperties:(NSDictionary *)properties {
    [STIMFastEntrance openSTIMRNVCWithModuleName:moduleName WithProperties:properties];
}

+ (void)openRobotCard:(NSString *)robotJId {
    [STIMFastEntrance openRobotCard:robotJId];
}

+ (void)openWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar {
    [STIMFastEntrance openWebViewWithHtmlStr:htmlStr showNavBar:showNavBar];
}

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar {
    [STIMFastEntrance openWebViewForUrl:url showNavBar:showNavBar];
}

+ (void)openUserMedalFlutterWithUserId:(NSString *)userId {
    [STIMFastEntrance openUserMedalFlutterWithUserId:userId];
}

+ (void)openRNSearchVC {
    [STIMFastEntrance openRNSearchVC];
}

+ (void)openUserFriendsVC {
    [STIMFastEntrance openUserFriendsVC];
}

+ (void)openSTIMGroupListVC {
    [STIMFastEntrance openSTIMGroupListVC];
}

+ (void)openNotReadMessageVC {
    [STIMFastEntrance openNotReadMessageVC];
}

+ (void)openSTIMPublicNumberVC {
    [STIMFastEntrance openSTIMPublicNumberVC];
}

+ (void)openMyFileVC {
    [STIMFastEntrance openMyFileVC];
}

+ (void)openOrganizationalVC {
    [STIMFastEntrance openOrganizationalVC];
}

+ (void)openQRCodeVC {
    [STIMFastEntrance openQRCodeVC];
}

+ (void)openRobotChatVC:(NSString *)robotJid {
    [STIMFastEntrance openRobotChatVC:robotJid];
}

+ (void)openQTalkNotesVC {
    [STIMFastEntrance openQTalkNotesVC];
}

+ (void)openTransferConversation:(NSString *)shopId withVistorId:(NSString *)realJid {
    [STIMFastEntrance openTransferConversation:shopId withVistorId:realJid];
}

+ (void)openMyAccountInfo {
    [STIMFastEntrance openMyAccountInfo];
}

+ (void)showQRCodeWithQRId:(NSString *)qrId withType:(NSInteger)qrcodeType {
    [STIMFastEntrance showQRCodeWithQRId:qrId withType:qrcodeType];
}

+ (void)signOut {
    [STIMFastEntrance signOut];
}

+ (void)signOutWithNoPush {
    [STIMFastEntrance signOutWithNoPush];
}

@end

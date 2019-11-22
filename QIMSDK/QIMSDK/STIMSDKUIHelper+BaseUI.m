//
//  STIMSDKUIHelper+BaseUI.m
//  STIMSDK
//
//  Created by 李露 on 2018/9/29.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMSDKUIHelper+BaseUI.h"
#import "STIMKitPublicHeader.h"
#import "STIMFastEntrance.h"
#import "STIMAppWindowManager.h"

@implementation STIMSDKUIHelper (BaseUI)

- (void)launchMainControllerWithWindow:(UIWindow *)window {
    [[STIMFastEntrance sharedInstance] launchMainControllerWithWindow:window];
}

- (void)launchMainAdvertWindow {
    [[STIMFastEntrance sharedInstance] launchMainAdvertWindow];
}

- (UIView *)getSTIMSessionListViewWithBaseFrame:(CGRect)frame {
    return [[STIMFastEntrance sharedInstance] getSTIMSessionListViewWithBaseFrame:frame];
}

- (UIViewController *)getUserChatInfoByUserId:(NSString *)userId {
    return [[STIMFastEntrance sharedInstance] getUserChatInfoByUserId:userId];
}

- (UIViewController *)getUserCardVCByUserId:(NSString *)userId {
    return [[STIMFastEntrance sharedInstance] getUserCardVCByUserId:userId];
}

- (UIViewController *)getSTIMGroupCardVCByGroupId:(NSString *)groupId {
    return [[STIMFastEntrance sharedInstance] getSTIMGroupCardVCByGroupId:groupId];
}

- (UIViewController *)getConsultChatByChatType:(NSInteger)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    return [[STIMFastEntrance sharedInstance] getConsultChatByChatType:chatType UserId:userId WithVirtualId:virtualId];
}

- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId {
    return [[STIMFastEntrance sharedInstance] getSingleChatVCByUserId:userId];
}

- (UIViewController *)getGroupChatVCByGroupId:(NSString *)groupId {
    return [[STIMFastEntrance sharedInstance] getGroupChatVCByGroupId:groupId];
}

- (UIViewController *)getHeaderLineVCByJid:(NSString *)jid {
    return [[STIMFastEntrance sharedInstance] getHeaderLineVCByJid:jid];
}

- (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties {
    return [[STIMFastEntrance sharedInstance] getVCWithNavigation:navVC WithHiddenNav:hiddenNav WithModule:module WithProperties:properties];
}

- (UIViewController *)getRobotCard:(NSString *)robotJid {
    return [[STIMFastEntrance sharedInstance] getRobotCard:robotJid];
}

- (UIViewController *)getRNSearchVC {
    return [[STIMFastEntrance sharedInstance] getRNSearchVC];
}

- (UIViewController *)getUserFriendsVC {
    return [[STIMFastEntrance sharedInstance] getUserFriendsVC];
}

- (UIViewController *)getSTIMGroupListVC {
    return [[STIMFastEntrance sharedInstance] getSTIMGroupListVC];
}

- (UIViewController *)getNotReadMessageVC {
    return [[STIMFastEntrance sharedInstance] getNotReadMessageVC];
}

- (UIViewController *)getSTIMPublicNumberVC {
    return [[STIMFastEntrance sharedInstance] getSTIMPublicNumberVC];
}

- (UIViewController *)getMyFileVC {
    return [[STIMFastEntrance sharedInstance] getMyFileVC];
}

- (UIViewController *)getOrganizationalVC {
    return [[STIMFastEntrance sharedInstance] getOrganizationalVC];
}

- (UIViewController *)getRobotChatVC:(NSString *)robotJid {
    return [[STIMFastEntrance sharedInstance] getRobotChatVC:robotJid];
}

- (UIViewController *)getQTalkNotesVC {
    return [[STIMFastEntrance sharedInstance] getQTalkNotesVC];
}

- (UIViewController *)getMyRedPack {
    return [[STIMFastEntrance sharedInstance] getMyRedPack];
}

- (UIViewController *)getMyRedPackageBalance {
    return [[STIMFastEntrance sharedInstance] getMyRedPackageBalance];
}

- (UIViewController *)getQRCodeWithQRId:(NSString *)qrId withType:(NSInteger)qrcodeType {
    return [[STIMFastEntrance sharedInstance] getQRCodeWithQRId:qrId withType:qrcodeType];
}

- (UIViewController *)getContactSelectionVC:(Message *)msg withExternalForward:(BOOL)externalForward {
    return [[STIMFastEntrance sharedInstance] getContactSelectionVC:msg withExternalForward:externalForward];
}

@end

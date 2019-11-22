//
//  STIMRNBaseVc.m
//  STIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMRNBaseVc.h"
#import "QimRNBModule.h"
#import "QimRNBModule+STIMUser.h"
#import "QimRNBModule+STIMGroup.h"
#import "QimRNBModule+MySetting.h"
#import "UIApplication+STIMApplication.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTEventDispatcher.h>
//#import "UIView+Toast.h"
#import "STIMChatVC.h"
#import "STIMPhotoBrowserNavController.h"

@interface STIMRNBaseVc ()

@property (nonatomic, assign) BOOL prepNavHidden;

@end

@implementation STIMRNBaseVc

- (void)willReShow{
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"STIM_RN_Check_Version" body:@{@"name": @"aaa"}];
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"STIM_RN_Will_Show" body:@{@"name": @"aaa"}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _prepNavHidden = self.navigationController.navigationBarHidden;
    if (self.hiddenNav != _prepNavHidden) {
        _prepNavHidden = self.hiddenNav;
        [self.navigationController setNavigationBarHidden:self.hiddenNav animated:YES];
    }
    [self willReShow];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_prepNavHidden != self.navigationController.navigationBarHidden) {
        _prepNavHidden = self.hiddenNav;
        [self.navigationController setNavigationBarHidden:self.hiddenNav animated:YES];        
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registeNotifications];
        if ([[STIMKit sharedInstance] getIsIpad] == YES) {
            [self.view setFrame:CGRectMake(0, 0, [[STIMWindowManager shareInstance] getDetailWidth], [[UIScreen mainScreen] height])];
        }
    }
    return self;
}

#pragma mark - NSNotification

- (void)registeNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack:) name:kNotifyVCClose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBundle:) name:kNotify_STIMRN_BUNDLE_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveFriendPresence:) name:kFriendPresence object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseBigHeader:) name:@"BrowseBigHeader" object:nil];
    //        STIMGroupMemberWillUpdate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupMember:) name:@"STIMGroupMemberWillUpdate" object:nil];
    
    //update个性签名
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyPersonalSignature:) name:kUpdateMyPersonalSignature object:nil];

    //上传头像结果 成功 ：{"ok":YES, "headerUrl":xxx} / 失败 : {"ok":NO}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyPhotoSuccess:) name:kMyHeaderImgaeUpdateSuccess object:nil];
    
    //用户头像更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserHeader:) name:kUserVCardUpdate object:nil];
    //用户签名更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserMode:) name:kUserVCardUpdate object:nil];
    //群名称更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupName:) name:kGroupNickNameChanged object:nil];
    //群公告更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupTopic:) name:kGroupNickNameChanged object:nil];
    //上传日志进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUpdateProgress:) name:KNotifyUploadProgress object:nil];
    
    //销毁群
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delMuc:) name:kChatRoomDestroy object:nil];
    //退出群
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delMuc:) name:kChatRoomLeave object:nil];
    //更新用户勋章列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserMedal:) name:kUpdateUserMedal object:nil];
    
    //更新新版本的用户勋章列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserMedalList:) name:kUpdateNewUserMedalList object:nil];
    
    //更新用户Leader
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLeaderCard:) name:kUpdateUserLeaderCard object:nil];
}

- (void)updateBundle:(NSNotification *)notify {
    [self.view removeAllSubviews];
    
    NSURL *jsCodeLocation = [QimRNBModule getJsCodeLocation];
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:self.rnName
                                                 initialProperties:nil
                                                     launchOptions:nil];
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    self.view = rootView;
}

- (void)updateUserHeader:(NSNotification *)notify {
    NSArray *xmppIds = notify.object;
    NSString *userJid = [xmppIds firstObject];
    NSDictionary *userInfo = [QimRNBModule qimrn_getUserInfoByUserId:userJid];
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateNick" body:@{@"UserId":userJid, @"UserInfo":userInfo}];
}

- (void)updateUserMode:(NSNotification *)notify {
    NSArray *xmppIds = notify.object;
    NSString *userJid = [xmppIds firstObject];
    NSDictionary *userInfo = [QimRNBModule qimrn_getUserInfoByUserId:userJid];
    if (userInfo.count) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateNick" body:@{@"UserId":userJid, @"UserInfo":userInfo}];
    }
}

- (void)updateGroupName:(NSNotification *)notify {
    
    NSArray *groupIds = notify.object;
    NSString *groupId = [groupIds firstObject];
    NSDictionary *groupInfo = [QimRNBModule qimrn_getGroupInfoByGroupId:groupId];
    if (groupInfo.count) {
        NSString *groupName = [groupInfo objectForKey:@"Name"];
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateGroupName" body:@{@"GroupId":groupId, @"GroupName":groupName?groupName:@""}];
    }
}

- (void)updateGroupTopic:(NSNotification *)notify {
    
    NSArray *groupIds = notify.object;
    NSString *groupId = [groupIds firstObject];
    NSDictionary *groupInfo = [QimRNBModule qimrn_getGroupInfoByGroupId:groupId];
    if (groupInfo.count) {
        NSString *groupTopic = [groupInfo objectForKey:@"Topic"];
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateGroupTopic" body:@{@"GroupId":groupId, @"GroupTopic":groupTopic?groupTopic:@""}];
    }
}

- (void)updateUpdateProgress:(NSNotification *)notify {
    
    float uploadProgress = [notify.object floatValue];
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateFeedBackProgress" body:@{@"progress":@(uploadProgress)}];
}

- (void)delMuc:(NSNotification *)notify {
    NSString *groupId = notify.object;
    if (groupId) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"Del_Destory_Muc" body:@{@"groupId":groupId}];
    }
}

- (void)updateUserMedal:(NSNotification *)notify {
//    @{@"userId":xmppId, @"UserMedals":data}
    NSDictionary *notifyDic = notify.object;
    NSString *userId = [notifyDic objectForKey:@"UserId"];
    if (userId.length > 0 && notifyDic.count > 0) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateMedal" body:notifyDic];
    }
}

//更新新版本勋章列表
- (void)updateUserMedalList:(NSNotification *)notify {
    
    NSString *userId = notify.object;
    NSArray *userMedallist = [QimRNBModule qimrn_getNewUserMedalByUserId:userId];
    NSDictionary *userMedalListDic = @{@"UserId" : [[STIMKit sharedInstance] getLastJid], @"medalList": userMedallist ? userMedallist : @[]};
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateMedalList" body:userMedalListDic];
}

- (void)updateUserLeaderCard:(NSNotification *)notify {
    STIMVerboseLog(@"updateUserLeaderCard : %@", notify);
    NSDictionary *notifyDic = notify.object;
    NSString *userId = [notifyDic objectForKey:@"UserId"];
    NSDictionary *userLeaderInfo = [QimRNBModule qimrn_getUserLeaderInfoByUserId:userId];
    if (userId.length > 0 && userLeaderInfo.count > 0) {
        STIMVerboseLog(@"updateLeaderInfo : %@", userLeaderInfo);
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateLeader" body:@{@"LeaderInfo":userLeaderInfo ? userLeaderInfo : @{}, @"UserId": userId ? userId : @""}];
    }
}

- (void)goBack:(NSNotification *)notify {
    if ([self.rnName isEqualToString:notify.object]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onReceiveFriendPresence:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *presenceDic = notify.userInfo;
        NSString *result = [presenceDic objectForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            [self openChatSessionWithUserId:notify.object UserName:notify.object];
        } else {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Add friend"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] style:UIAlertActionStyleDefault handler:nil];
            [alertVc addAction:okAction];
            UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            [navVC presentViewController:alertVc animated:YES completion:nil];
        }
    });
}

- (void)updateGroupMember:(NSNotification *)notify {
    
    NSString *groupId = notify.object;
    if (groupId.length > 0) {
        NSArray *groupmembers = [QimRNBModule qimrn_getGroupMembersByGroupId:groupId];
        STIMGroupIdentity groupIdentity = [[STIMKit sharedInstance] GroupIdentityForUser:[[STIMKit sharedInstance] getLastJid] byGroup:groupId];
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateGroupMember" body:@{@"GroupId":groupId, @"GroupMembers": groupmembers?groupmembers:@[], @"permissions":@(groupIdentity)}];
    }
}

- (void)updateMyPersonalSignature:(NSNotification *)notify {
    
    NSString *personalSignature = notify.object;
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updatePersonalSignature" body:@{@"UserId":[[STIMKit sharedInstance] getLastJid], @"PersonalSignature":(personalSignature.length > 0) ? personalSignature : @""}];
}

- (void)updateMyPhotoSuccess:(NSNotification *)notify {
    if (notify.object) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"imageUpdateEnd" body:notify.object];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    STIMVerboseLog(@"STIMRNBaseVc %@ dealloc", self.rnName);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)openChatSessionWithUserId:(NSString *)userId UserName:(NSString *)userName {
    [STIMFastEntrance openSingleChatVCByUserId:userId];
    /*
    ChatType chatType = [[STIMKit sharedInstance] openChatSessionByUserId:userId];
    
    STIMChatVC *chatVC  = [[STIMChatVC alloc] init];
    [chatVC setStype:kSessionType_Chat];
    [chatVC setChatId:userId];
    [chatVC setName:userName];
    */
    /*
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        NSString *realJid = [[STIMKit sharedInstance] getRealJidForVirtual:[userId componentsSeparatedByString:@"@"].firstObject];
        realJid = [realJid stringByAppendingString:[NSString stringWithFormat:@"@%@", [[STIMKit sharedInstance] qimNav_Domain]]];
        [chatVC setVirtualJid:userId];
        [chatVC setChatId:realJid];
    }
    */
    /*
    [chatVC setChatType:chatType];
    NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    [chatVC setTitle:remarkName?remarkName:userName];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
    });
    UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [navVC popToRootVCThenPush:chatVC animated:YES];
    */
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end


@implementation STIMRNBaseVc (UserCard)

#pragma mark - 浏览大头像
// 查看大头像
- (void)browseBigHeader:(NSNotification *)notify {
    
    NSDictionary *param = [notify object];
    [[STIMFastEntrance sharedInstance] browseBigHeader:param];
}

@end

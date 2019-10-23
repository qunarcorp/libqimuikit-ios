//
//  QimRNBModule+QIMUser.m
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QimRNBModule+QIMUser.h"

@implementation QimRNBModule (QIMUser)

+ (NSDictionary *)qimrn_getUserInfoByUserId:(NSString *)userId {
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    NSString *headerSrc = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:userId];
    NSString *mood = [userInfo objectForKey:@"Mood"];
    NSNumber *sex = [userInfo objectForKey:@"Sex"];

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:userId forKey:@"UserId"];
    [properties setObject:[userInfo objectForKey:@"Name"]?[userInfo objectForKey:@"Name"]:[userId componentsSeparatedByString:@"@"].firstObject forKey:@"Name"];
    [properties setObject:headerSrc?headerSrc:@"" forKey:@"HeaderUri"];
    [properties setObject:remarkName?remarkName:@"" forKey:@"Remarks"];
    [properties setObject:[userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"" forKey:@"Department"];
    [properties setObject:mood ? mood : @"这家伙很懒,什么都没留下" forKey:@"Mood"];
    [properties setQIMSafeObject:sex forKey:@"Sex"];
    return properties;
}

+ (NSString *)qimrn_getUserMoodByUserId:(NSString *)userId {
    if (!userId || userId.length <= 0) {
        return @"这家伙很懒,什么都没留下";
    }
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    NSString *mood = [userInfo objectForKey:@"Mood"];
    return mood?mood:@"这家伙很懒,什么都没留下";
}

+ (NSArray *)qimrn_getNewUserMedalByUserId:(NSString *)xmppId {
    if (!xmppId || xmppId.length <= 0) {
        return nil;
    }
    return [[QIMKit sharedInstance] getUserWearMedalSmallIconListByUserid:xmppId];
}

+ (NSArray *)qimrn_getNewUserHaveMedalByUserId:(NSString *)xmppId {
    if (!xmppId || xmppId.length <= 0) {
        return nil;
    }
    return [[QIMKit sharedInstance] getUserHaveMedalSmallIconListByUserid:xmppId];
}

+ (NSArray *)qimrn_getUserMedalByUserId:(NSString *)xmppId {
    if (!xmppId || xmppId.length <= 0) {
        return nil;
    }
    NSArray *localUserMedals = [[QIMKit sharedInstance] getLocalUserMedalWithXmppJid:xmppId];
    return localUserMedals;
}

+ (NSDictionary *)qimrn_getUserLeaderInfoByUserId:(NSString *)userId {
    NSDictionary *userWorkInfo = nil;
    if ([QIMKit getQIMProjectType] != QIMProjectTypeQChat && [[[QIMKit sharedInstance] getDomain] isEqualToString:@"ejabhost1"]) {
        userWorkInfo = [[QIMKit sharedInstance] getUserWorkInfoByUserId:userId];
    } else {
        userWorkInfo = nil;
    }
    NSString *empno = [userWorkInfo objectForKey:@"sn"];
    NSString *leaderName = [userWorkInfo objectForKey:@"leader"];
    NSString *leaderId = [userWorkInfo objectForKey:@"qtalk_id"];
    NSString *leader = nil;
    if (leaderName > 0 && leaderId.length > 0) {
        leader = [NSString stringWithFormat:@"%@(%@)", leaderName, leaderId];
    }
    if (leaderId.length > 0 && ![leaderId containsString:@"@"]) {
        leaderId = [leaderId stringByAppendingFormat:@"@%@", [[QIMKit sharedInstance] getDomain]];
    }
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:empno ? empno : [NSBundle qim_localizedStringForKey:@"moment_Unknown"] forKey:@"Empno"];
    [properties setObject:leader ? leader : [NSBundle qim_localizedStringForKey:@"moment_Unknown"] forKey:@"Leader"];
    [properties setObject:leaderId ? leaderId : @"" forKey:@"LeaderId"];
    return properties;
}

@end

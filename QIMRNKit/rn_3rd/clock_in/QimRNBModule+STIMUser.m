//
//  QimRNBModule+STIMUser.m
//  QIMRNKit
//
//  Created by 李海彬 on 2018/8/23.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "QimRNBModule+STIMUser.h"

@implementation QimRNBModule (STIMUser)

+ (NSDictionary *)qimrn_getUserInfoByUserId:(NSString *)userId {
    NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    NSString *headerSrc = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:userId];
    NSString *mood = [userInfo objectForKey:@"Mood"];
    NSNumber *sex = [userInfo objectForKey:@"Sex"];

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:userId forKey:@"UserId"];
    [properties setObject:[userInfo objectForKey:@"Name"]?[userInfo objectForKey:@"Name"]:[userId componentsSeparatedByString:@"@"].firstObject forKey:@"Name"];
    [properties setObject:headerSrc?headerSrc:@"" forKey:@"HeaderUri"];
    [properties setObject:remarkName?remarkName:@"" forKey:@"Remarks"];
    [properties setObject:[userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"" forKey:@"Department"];
    [properties setObject:mood ? mood : @"这家伙很懒,什么都没留下" forKey:@"Mood"];
    [properties setSTIMSafeObject:sex forKey:@"Sex"];
    return properties;
}

+ (NSString *)qimrn_getUserMoodByUserId:(NSString *)userId {
    if (!userId || userId.length <= 0) {
        return @"这家伙很懒,什么都没留下";
    }
    NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    NSString *mood = [userInfo objectForKey:@"Mood"];
    return mood?mood:@"这家伙很懒,什么都没留下";
}

+ (NSArray *)qimrn_getNewUserMedalByUserId:(NSString *)xmppId {
    if (!xmppId || xmppId.length <= 0) {
        return nil;
    }
    return [[STIMKit sharedInstance] getUserWearMedalSmallIconListByUserid:xmppId];
}

+ (NSArray *)qimrn_getNewUserHaveMedalByUserId:(NSString *)xmppId {
    if (!xmppId || xmppId.length <= 0) {
        return nil;
    }
    return [[STIMKit sharedInstance] getUserHaveMedalSmallIconListByUserid:xmppId];
}

+ (NSArray *)qimrn_getUserMedalByUserId:(NSString *)xmppId {
    if (!xmppId || xmppId.length <= 0) {
        return nil;
    }
    NSArray *localUserMedals = [[STIMKit sharedInstance] getLocalUserMedalWithXmppJid:xmppId];
    return localUserMedals;
}

+ (NSDictionary *)qimrn_getUserLeaderInfoByUserId:(NSString *)userId {
    NSDictionary *userWorkInfo = nil;
    if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat && [[[STIMKit sharedInstance] getDomain] isEqualToString:@"ejabhost1"]) {
        userWorkInfo = [[STIMKit sharedInstance] getUserWorkInfoByUserId:userId];
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
        leaderId = [leaderId stringByAppendingFormat:@"@%@", [[STIMKit sharedInstance] getDomain]];
    }
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:empno ? empno : [NSBundle stimDB_localizedStringForKey:@"moment_Unknown"] forKey:@"Empno"];
    [properties setObject:leader ? leader : [NSBundle stimDB_localizedStringForKey:@"moment_Unknown"] forKey:@"Leader"];
    [properties setObject:leaderId ? leaderId : @"" forKey:@"LeaderId"];
    return properties;
}

@end

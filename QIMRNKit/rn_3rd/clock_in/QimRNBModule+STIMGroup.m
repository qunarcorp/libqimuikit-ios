//
//  QimRNBModule+STIMGroup.m
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "QimRNBModule+STIMGroup.h"

@implementation QimRNBModule (STIMGroup)

+ (NSArray *)qimrn_getGroupMembersByGroupId:(NSString *)groupId {
    NSArray *groupMembers = [[STIMKit sharedInstance] getGroupMembersByGroupId:groupId];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *member in groupMembers) {
        NSString *jid = [member objectForKey:@"xmppjid"];
        if (jid.length <= 0) {
            continue;
        }
        NSString *userJid = [member objectForKey:@"jid"];
        NSString *affiliation = [member objectForKey:@"affiliation"];
        NSString *name = [member objectForKey:@"name"];
        STIMGroupIdentity groupIdentity = [[STIMKit sharedInstance] GroupIdentityForUser:userJid byGroup:groupId];
        NSString *userName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userJid];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:member];
        NSString *uri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:jid];
        [dic setSTIMSafeObject:@(groupIdentity) forKey:@"affiliation"];
        [dic setSTIMSafeObject:uri forKey:@"headerUri"];
        [dic setSTIMSafeObject:groupId forKey:@"jid"];
        [dic setSTIMSafeObject:(userName.length > 0) ? userName : name forKey:@"name"];
        [dic setSTIMSafeObject:(jid.length > 0) ? jid : userJid forKey:@"xmppjid"];
        [list addObject:dic];
    }
    return list;
}

+ (NSDictionary *)qimrn_getGroupInfoByGroupId:(NSString *)groupId {
    if (!groupId || groupId.length <= 0) {
        return nil;
    }
    NSDictionary *groupInfo = [[STIMKit sharedInstance] getGroupCardByGroupId:groupId];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    if (groupInfo.count) {
        NSString *groupId = [groupInfo objectForKey:@"GroupId"];
        NSString *groupName = [groupInfo objectForKey:@"Name"];
        NSString *groupIntroduce = [groupInfo objectForKey:@"Introduce"];
        NSString *groupHeaderSrc = [groupInfo objectForKey:@"HeaderSrc"];
        NSString *groupTopic = [groupInfo objectForKey:@"Topic"];
        
        [properties setSTIMSafeObject:groupId forKey:@"GroupId"];
        [properties setSTIMSafeObject:groupName forKey:@"Name"];
        [properties setSTIMSafeObject:groupHeaderSrc forKey:@"HeaderSrc"];
        [properties setSTIMSafeObject:groupTopic forKey:@"Topic"];
        [properties setSTIMSafeObject:groupIntroduce forKey:@"Introduce"];
    }
    return properties;
}

@end

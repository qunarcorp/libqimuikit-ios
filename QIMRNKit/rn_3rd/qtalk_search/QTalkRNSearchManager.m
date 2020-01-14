//
//  QTalkRNSearchManager.m
//  STChatIphone
//
//  Created by Qunar-Lu on 2016/12/2.
//
//

#import "QTalkRNSearchManager.h"

@interface QTalkRNSearchManager ()

@end

@implementation QTalkRNSearchManager

+ (NSMutableArray *)localSearch:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset groupId:(NSString *)groupId{
    
    NSDictionary *ejabhost2GroupChatList = [QTalkRNSearchManager rnSearchEjabhost2GroupChatResultWithSearchKey:key limit:limit offset:offset];
    NSDictionary *publicNumberList = [QTalkRNSearchManager rnSearchPublicNumberResultWithSearchKey:key limit:limit offset:offset];
    NSDictionary *localUserList = [QTalkRNSearchManager rnSearchLocalUserChatResultWithSearchKey:key limit:limit offset:offset];
    NSDictionary *localGroupList = [QTalkRNSearchManager rnSearchLocalGroupChatResultWithSearchKey:key limit:limit offset:offset];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if(([groupId isEqualToString:@"Q04"] || [groupId isEqualToString:@""]) && ejabhost2GroupChatList != nil) {
        [data addObject:ejabhost2GroupChatList];
    }
    
    if(([groupId isEqualToString:@"Q03"] || [groupId isEqualToString:@""]) &&publicNumberList != nil) {
        [data addObject:publicNumberList];
    }
    
    if(([groupId isEqualToString:@"Q08"] || [groupId isEqualToString:@""]) &&localUserList != nil) {
        [data addObject:localUserList];
    }
    
    if(([groupId isEqualToString:@"Q09"] || [groupId isEqualToString:@""]) &&localGroupList != nil) {
        [data addObject:localGroupList];
    }

    return data;
}

+ (NSDictionary *)rnSearchLocalUserChatResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset  {
    
    NSArray *localUserList = [[STIMKit sharedInstance] searchUserListBySearchStr:key WithLimit:limit WithOffset:offset];
    NSInteger totalCount = [[STIMKit sharedInstance] searchUserListTotalCountBySearchStr:key];
    NSMutableDictionary *localUserDict = [NSMutableDictionary dictionary];
    if (localUserList.count) {
        [localUserDict setSTIMSafeObject:localUserList forKey:@"info"];
    } else {
        return nil;
    }
    [localUserDict setSTIMSafeObject:@"本地用户" forKey:@"groupLabel"];
    [localUserDict setSTIMSafeObject:@"Q08" forKey:@"groupId"];
    [localUserDict setSTIMSafeObject:@(QRNSearchGroupPriorityLocalUserList) forKey:@"groupPriority"];
    [localUserDict setSTIMSafeObject:@(0) forKey:@"todoType"];
    [localUserDict setSTIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/ff1a003aa731b0d4e2dd3d39687c8a54.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [localUserDict setSTIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [localUserDict setSTIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [localUserDict setSTIMSafeObject:@(true) forKey:@"isLoaclData"];
    return localUserDict;
}

+ (NSDictionary *)rnSearchLocalGroupChatResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset  {
    
    NSArray *localGroupList = [[STIMKit sharedInstance] searchGroupBySearchStr:key WithLimit:limit WithOffset:offset];
    NSInteger totalCount = [[STIMKit sharedInstance] searchGroupTotalCountBySearchStr:key];
    NSMutableDictionary *localGroupChatDict = [NSMutableDictionary dictionary];
    if (localGroupList.count) {
        [localGroupChatDict setSTIMSafeObject:localGroupList forKey:@"info"];
    } else {
        return nil;
    }
    [localGroupChatDict setSTIMSafeObject:@"本地群组" forKey:@"groupLabel"];
    [localGroupChatDict setSTIMSafeObject:@"Q09" forKey:@"groupId"];
    [localGroupChatDict setSTIMSafeObject:@(QRNSearchGroupPriorityLocalGroupList) forKey:@"groupPriority"];
    [localGroupChatDict setSTIMSafeObject:@(1) forKey:@"todoType"];
    [localGroupChatDict setSTIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/bc0fca9b398a0e4a1f981a21e7425c7a.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [localGroupChatDict setSTIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [localGroupChatDict setSTIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [localGroupChatDict setSTIMSafeObject:@(true) forKey:@"isLoaclData"];
    return localGroupChatDict;
}

+ (NSDictionary *)rnSearchEjabhost2GroupChatResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset  {
    
    NSArray *ejabhost2GroupChatList = [[STIMKit sharedInstance] rnSearchEjabHost2GroupChatListByKeyStr:key limit:limit offset:offset];
    NSInteger totalCount = [[STIMKit sharedInstance] getRNSearchEjabHost2GroupChatListByKeyStr:key];
    NSMutableDictionary *ejabhost2GroupChatDict = [NSMutableDictionary dictionary];
    if (ejabhost2GroupChatList.count) {
        [ejabhost2GroupChatDict setSTIMSafeObject:ejabhost2GroupChatList forKey:@"info"];
    } else {
        return nil;
    }
    [ejabhost2GroupChatDict setSTIMSafeObject:@"外域群组" forKey:@"groupLabel"];
    [ejabhost2GroupChatDict setSTIMSafeObject:@"Q04" forKey:@"groupId"];
    [ejabhost2GroupChatDict setSTIMSafeObject:@(QRNSearchGroupPriorityGroupOutDomainGroupList) forKey:@"groupPriority"];
    [ejabhost2GroupChatDict setSTIMSafeObject:@(1) forKey:@"todoType"];
    [ejabhost2GroupChatDict setSTIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/bc0fca9b398a0e4a1f981a21e7425c7a.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [ejabhost2GroupChatDict setSTIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [ejabhost2GroupChatDict setSTIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [ejabhost2GroupChatDict setSTIMSafeObject:@(true) forKey:@"isLoaclData"];

    return ejabhost2GroupChatDict;
}

+ (NSDictionary *)rnSearchPublicNumberResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset {
    NSArray *publicNumberList = [[STIMKit sharedInstance] rnSearchPublicNumberListByKeyStr:key limit:limit offset:offset];
    NSInteger totalCount = [[STIMKit sharedInstance] getRnSearchPublicNumberListByKeyStr:key];
    NSMutableDictionary *publicNumberDict = [NSMutableDictionary dictionary];
    if (publicNumberList.count) {
        [publicNumberDict setSTIMSafeObject:publicNumberList forKey:@"info"];
    } else {
        return nil;
    }
    [publicNumberDict setSTIMSafeObject:@"公众号列表" forKey:@"groupLabel"];
    [publicNumberDict setSTIMSafeObject:@"Q03" forKey:@"groupId"];
    [publicNumberDict setSTIMSafeObject:@(QRNSearchGroupPriorityGroupLocalPublicNumberList) forKey:@"groupPriority"];
    [publicNumberDict setSTIMSafeObject:@(8) forKey:@"todoType"];
    [publicNumberDict setSTIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/612752b6f60c3379077f71493d4e02ae.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [publicNumberDict setSTIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [publicNumberDict setSTIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [publicNumberDict setSTIMSafeObject:@(true) forKey:@"isLoaclData"];
 
    return publicNumberDict;
}

+ (NSString *)searchUrl {
    return [[STIMKit sharedInstance] qimNav_SearchUrl];
}

@end

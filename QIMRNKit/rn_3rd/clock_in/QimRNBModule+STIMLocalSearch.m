//
//  QimRNBModule+STIMLocalSearch.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2018/12/4.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "QimRNBModule+STIMLocalSearch.h"

@implementation QimRNBModule (STIMLocalSearch)

+ (NSString *)getTimeStr:(long long)time {
    NSDate *date = [NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:time];
    if ([date stimDB_isToday]) {
        return @"今天";
    } else if ([date stimDB_isThisWeek]) {
        return @"这周";
    } else if ([date stimDB_isThisMonth]) {
        return @"这个月";
    } else {
        return [date stimDB_MonthDescription];
    }
    return nil;
}

+ (NSString *)getFileTypeWithFileExtension:(NSString *)fileExtension {
    NSString *fileType = @"file";
    if ([fileExtension isEqualToString:@"docx"] || [fileExtension isEqualToString:@"doc"]) {
        fileType = @"word";
    } else if ([fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"gif"] || [fileExtension isEqualToString:@"png"]) {
        fileType = @"image";
    } else if ([fileExtension isEqualToString:@"xlsx"]) {
        fileType = @"excel";
    } else if ([fileExtension isEqualToString:@"pptx"] || [fileExtension isEqualToString:@"ppt"]) {
        fileType = @"powerPoint";
    } else if ([fileExtension isEqualToString:@"pdf"]) {
        fileType = @"pdf";
    } else if ([fileExtension isEqualToString:@"apk"]) {
        fileType = @"apk";
    } else if ([fileExtension isEqualToString:@"txt"]) {
        fileType = @"txt";
    } else if ([fileExtension isEqualToString:@"zip"]) {
        fileType = @"zip";
    } else {
        
    }
    return fileType;
}

+ (NSDictionary *)qimrn_searchLocalMsgWithUserParam:(NSDictionary *)param {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    ChatType chatType = [[param objectForKey:@"chatType"] integerValue];
    NSString *searchText = [param objectForKey:@"searchText"];
    NSMutableDictionary *msgsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *localMsgs = @[];
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        localMsgs = [[STIMKit sharedInstance] getMsgsByKeyWord:searchText ByXmppId:xmppId ByReadJid:realjid];
        NSLog(@"msgs : %@", localMsgs);
    } else {
        localMsgs = [[STIMKit sharedInstance] getMsgsByKeyWord:searchText ByXmppId:xmppId ByReadJid:nil];
        NSLog(@"msgs : %@", localMsgs);
    }
    NSMutableArray *dateArray = [NSMutableArray arrayWithCapacity:3];
    for (STIMMessageModel * msg in localMsgs) {
        NSString *timeStr = [QimRNBModule getTimeStr:msg.messageDate];
        if (![dateArray containsObject:timeStr]) {
            [dateArray addObject:timeStr];
        }
        NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:3];
        
        NSString *msgSendJid = msg.from;
        NSString *msgContent = msg.message;
        NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:msgSendJid];
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:msgSendJid];
        NSString *userName = [userInfo objectForKey:@"Name"];
        if (searchText.length > 0) {
            if (![[msgContent lowercaseString] containsString:[searchText lowercaseString]]  && ![[remarkName lowercaseString] containsString:[searchText lowercaseString]] && ![[userName lowercaseString] containsString:[searchText lowercaseString]]) {
                continue;
            }
        }
        NSDate *msgDate = [NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:msg.messageDate];
        NSString *msgDateStr = [msgDate stimDB_formattedTime];
        
        [msgDic setSTIMSafeObject:msgDateStr forKey:@"time"];
        [msgDic setSTIMSafeObject:msg.from forKey:@"from"];
        [msgDic setSTIMSafeObject:msg.messageId forKey:@"msgId"];
        [msgDic setSTIMSafeObject:remarkName forKey:@"nickName"];
        [msgDic setSTIMSafeObject:msgContent forKey:@"content"];
        [msgDic setSTIMSafeObject:@(msg.messageDate) forKey:@"timeLong"];
        NSString *headerUrl = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:msgSendJid];
        [msgDic setSTIMSafeObject:headerUrl ? headerUrl : [STIMKit defaultUserHeaderImagePath] forKey:@"headerUrl"];
        
        
        NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
        if (timeStrMsgsGroup) {
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        } else {
            timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *cMap = [NSMutableDictionary dictionaryWithCapacity:2];
    for (NSInteger i = 0; i < dateArray.count; i++) {
        NSString *dateStr = [dateArray objectAtIndex:i];
        for (NSString *mapKey in [msgsMap allKeys]) {
            if ([mapKey isEqualToString:dateStr]) {
                NSArray *dateArray = [msgsMap objectForKey:mapKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                [dic setSTIMSafeObject:dateArray forKey:@"data"];
                [dic setSTIMSafeObject:mapKey forKey:@"key"];
                [array addObject:dic];
            }
        }
    }
    
    [cMap setSTIMSafeObject:@(YES) forKey:@"ok"];
    [cMap setSTIMSafeObject:array forKey:@"data"];
    STIMVerboseLog(@"msgsMap : %@", cMap);
    return cMap;
}

+ (NSDictionary *)qimrn_searchLocalFileWithUserParam:(NSDictionary *)param {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    ChatType chatType = [[param objectForKey:@"chatType"] integerValue];
    NSString *searchText = [param objectForKey:@"searchText"];
    NSMutableDictionary *msgsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *localMsgs = @[];
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        localMsgs = [[STIMKit sharedInstance] getMsgsForMsgType:@[@(STIMMessageType_File)] ByXmppId:xmppId ByReadJid:realjid];
        NSLog(@"msgs : %@", localMsgs);
    } else {
        localMsgs = [[STIMKit sharedInstance] getMsgsForMsgType:@[@(STIMMessageType_File)] ByXmppId:xmppId];
        NSLog(@"msgs : %@", localMsgs);
    }
    NSMutableArray *dateArray = [NSMutableArray arrayWithCapacity:3];
    for (STIMMessageModel * msg in localMsgs) {
        NSString *timeStr = [QimRNBModule getTimeStr:msg.messageDate];
        if (![dateArray containsObject:timeStr]) {
            [dateArray addObject:timeStr];
        }
        NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:3];
        NSDictionary *fileExtendInfoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:msg.extendInformation.length > 0 ? msg.extendInformation : msg.message error:nil];
        if (!fileExtendInfoDic) {
            continue;
        }
        NSString *fileName = [[fileExtendInfoDic objectForKey:@"FileName"] lowercaseString];
        NSString *msgSendJid = msg.from;
        NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:msgSendJid];
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:msgSendJid];
        NSString *userName = [userInfo objectForKey:@"Name"];
        if (searchText.length > 0) {
            if (![[fileName lowercaseString] containsString:[searchText lowercaseString]]  && ![[remarkName lowercaseString] containsString:[searchText lowercaseString]] && ![[userName lowercaseString] containsString:[searchText lowercaseString]]) {
                continue;
            }
        }
        NSString *fileSize = [fileExtendInfoDic objectForKey:@"FileSize"];
        NSString *fileType = [QimRNBModule getFileTypeWithFileExtension:[fileName pathExtension]];
        NSString *fileUrl = [fileExtendInfoDic objectForKey:@"HttpUrl"];
        
        [msgDic setSTIMSafeObject:fileName forKey:@"fileName"];
        [msgDic setSTIMSafeObject:fileType forKey:@"fileType"];
        [msgDic setSTIMSafeObject:fileSize forKey:@"fileSize"];
        [msgDic setSTIMSafeObject:fileUrl forKey:@"fileUrl"];
        [msgDic setSTIMSafeObject:msg.from forKey:@"from"];
        [msgDic setSTIMSafeObject:msg.messageId forKey:@"msgId"];
        [msgDic setSTIMSafeObject:remarkName forKey:@"nickName"];
        NSString *headerUrl = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:msgSendJid];
        [msgDic setSTIMSafeObject:headerUrl ? headerUrl : [STIMKit defaultUserHeaderImagePath] forKey:@"headerUrl"];
        
        
        NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
        if (timeStrMsgsGroup) {
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        } else {
            timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *cMap = [NSMutableDictionary dictionaryWithCapacity:2];
    for (NSInteger i = 0; i < dateArray.count; i++) {
        NSString *dateStr = [dateArray objectAtIndex:i];
        for (NSString *mapKey in [msgsMap allKeys]) {
            if ([mapKey isEqualToString:dateStr]) {
                NSArray *dateArray = [msgsMap objectForKey:mapKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                [dic setSTIMSafeObject:dateArray forKey:@"data"];
                [dic setSTIMSafeObject:mapKey forKey:@"key"];
                [array addObject:dic];
            }
        }
    }

    [cMap setSTIMSafeObject:@(YES) forKey:@"ok"];
    [cMap setSTIMSafeObject:array forKey:@"data"];
    STIMVerboseLog(@"msgsMap : %@", cMap);
    return cMap;
}

+ (NSDictionary *)qimrn_searchLocalLinkWithUserParam:(NSDictionary *)param {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    NSString *searchText = [param objectForKey:@"searchText"];
    ChatType chatType = [[param objectForKey:@"chatType"] integerValue];
    NSMutableDictionary *msgsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *localMsgs = @[];
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        localMsgs = [[STIMKit sharedInstance] getMsgsForMsgType:@[@(STIMMessageType_CommonTrdInfo), @(STIMMessageType_CommonTrdInfoPer)] ByXmppId:xmppId ByReadJid:realjid];
        NSLog(@"msgs : %@", localMsgs);
    } else {
        localMsgs = [[STIMKit sharedInstance] getMsgsForMsgType:@[@(STIMMessageType_CommonTrdInfo), @(STIMMessageType_CommonTrdInfoPer)] ByXmppId:xmppId];
        NSLog(@"msgs : %@", localMsgs);
    }
    NSMutableArray *dateArray = [NSMutableArray arrayWithCapacity:3];
    for (STIMMessageModel * msg in localMsgs) {
        NSString *timeStr = [QimRNBModule getTimeStr:msg.messageDate];
        if (![dateArray containsObject:timeStr]) {
            [dateArray addObject:timeStr];
        }
        NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:3];
        NSDictionary *linkExtendInfoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:msg.extendInformation.length > 0 ? msg.extendInformation : msg.message error:nil];
        if (!linkExtendInfoDic) {
            continue;
        }
        NSString *linkDesc = [linkExtendInfoDic objectForKey:@"desc"];
        NSString *linkTitle = [linkExtendInfoDic objectForKey:@"title"];
        linkTitle = (linkDesc.length > 0) ? linkDesc : linkTitle;
        NSString *msgSendJid = msg.from;
        NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:msgSendJid];
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:msgSendJid];
        NSString *userName = [userInfo objectForKey:@"Name"];
        if (searchText.length > 0) {
            if (![[linkTitle lowercaseString] containsString:[searchText lowercaseString]]  && ![[remarkName lowercaseString] containsString:[searchText lowercaseString]] && ![[userName lowercaseString] containsString:[searchText lowercaseString]]) {
                continue;
            }
        }
        NSString *linkUrl = [linkExtendInfoDic objectForKey:@"linkurl"];
        NSString *reactUrl = [linkExtendInfoDic objectForKey:@"reacturl"];
        NSString *linkIcon = [linkExtendInfoDic objectForKey:@"img"];
        if (linkIcon.length <= 0) {
            linkIcon = [STIMKit defaultCommonTrdInfoImagePath];
        }
        NSDate *msgDate = [NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:msg.messageDate];
        
        NSString *linkDate = [msgDate stimDB_formattedTime];
        
        [msgDic setSTIMSafeObject:(linkTitle.length > 0) ? linkTitle : linkUrl forKey:@"linkTitle"];
        [msgDic setSTIMSafeObject:linkUrl forKey:@"linkUrl"];
        [msgDic setSTIMSafeObject:reactUrl forKey:@"reacturl"];
        [msgDic setSTIMSafeObject:linkIcon forKey:@"linkIcon"];
        [msgDic setSTIMSafeObject:@"系统分享" forKey:@"linkType"];
        [msgDic setSTIMSafeObject:linkDate forKey:@"linkDate"];
        
        [msgDic setSTIMSafeObject:msg.from forKey:@"from"];
        [msgDic setSTIMSafeObject:msg.messageId forKey:@"msgId"];
        
        [msgDic setSTIMSafeObject:remarkName forKey:@"nickName"];
        NSString *headerUrl = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:msgSendJid];
        [msgDic setSTIMSafeObject:headerUrl ? headerUrl : [STIMKit defaultUserHeaderImagePath] forKey:@"headerUrl"];
        
        NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
        if (timeStrMsgsGroup) {
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        } else {
            timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *cMap = [NSMutableDictionary dictionaryWithCapacity:2];
    for (NSInteger i = 0; i < dateArray.count; i++) {
        NSString *dateStr = [dateArray objectAtIndex:i];
        for (NSString *mapKey in [msgsMap allKeys]) {
            if ([mapKey isEqualToString:dateStr]) {
                NSArray *dateArray = [msgsMap objectForKey:mapKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                [dic setSTIMSafeObject:dateArray forKey:@"data"];
                [dic setSTIMSafeObject:mapKey forKey:@"key"];
                [array addObject:dic];
            }
        }
    }
    [cMap setSTIMSafeObject:@(YES) forKey:@"ok"];
    [cMap setSTIMSafeObject:array forKey:@"data"];
    STIMVerboseLog(@"msgsMap : %@", cMap);
    return cMap;
}

@end

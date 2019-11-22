//
//  QimRNBModule+TravelCalendar.m
//  STIMRNKit
//
//  Created by 李露 on 2018/9/7.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "QimRNBModule+TravelCalendar.h"
#import "STIMJSONSerializer.h"

@implementation QimRNBModule (TravelCalendar)

- (NSDictionary *)qimrn_grtRNDataByTrip:(NSDictionary *)tripItem {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:tripItem];
    NSString *memberListJson = [tripItem objectForKey:@"memberList"];
    NSArray *memberList = [[STIMJSONSerializer sharedInstance] deserializeObject:memberListJson error:nil];
    NSMutableArray *newMemberList = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *memberItem in memberList) {
        NSMutableDictionary *newMemberDic = [NSMutableDictionary dictionaryWithDictionary:memberItem];
        NSString *memberId = [memberItem objectForKey:@"memberId"];
        
        NSString *userRemarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:memberId];
        NSString *userHeaderUrl = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:memberId];
        [newMemberDic setSTIMSafeObject:userRemarkName forKey:@"memberName"];
        [newMemberDic setSTIMSafeObject:userHeaderUrl forKey:@"headerUrl"];
        
        [newMemberList addObject:newMemberDic];
    }
    [temp setSTIMSafeObject:newMemberList forKey:@"memberList"];
    return temp;
}

- (void)qimrn_selectUserTripByDate:(NSDictionary *)params {
    
}

- (NSArray *)qimrn_getTripArea {
    NSArray *localAreaList = [[STIMKit sharedInstance] getLocalAreaList];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:3];
    for (NSDictionary *areaItem in localAreaList) {
        NSString *areaName = [areaItem objectForKey:@"areaName"];
        NSString *areaId = [areaItem objectForKey:@"areaId"];
        NSString *morningStarts = [areaItem objectForKey:@"morningStarts"];
        NSString *eveningEnds = [areaItem objectForKey:@"eveningEnds"];
        
        NSMutableDictionary *newAreaItem = [NSMutableDictionary dictionaryWithCapacity:3];
        [newAreaItem setSTIMSafeObject:areaName forKey:@"AddressName"];
        [newAreaItem setSTIMSafeObject:areaId forKey:@"AddressNumber"];
        [newAreaItem setSTIMSafeObject:morningStarts forKey:@"rStartTime"];
        [newAreaItem setSTIMSafeObject:eveningEnds forKey:@"rEndTime"];
        [list addObject:newAreaItem];
    }
    return list;
}

@end

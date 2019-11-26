//
//  QimRNBModule+STIMUser.h
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "QimRNBModule.h"

@interface QimRNBModule (STIMUser)

+ (NSDictionary *)qimrn_getUserInfoByUserId:(NSString *)userId;

+ (NSString *)qimrn_getUserMoodByUserId:(NSString *)userId;

+ (NSArray *)qimrn_getNewUserMedalByUserId:(NSString *)xmppId;

+ (NSArray *)qimrn_getNewUserHaveMedalByUserId:(NSString *)xmppId;

+ (NSArray *)qimrn_getUserMedalByUserId:(NSString *)xmppId;

+ (NSDictionary *)qimrn_getUserLeaderInfoByUserId:(NSString *)userId;

@end

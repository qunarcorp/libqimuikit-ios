//
//  STIMWorkMomentModel.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/2.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentModel.h"
#import "STIMWorkMomentContentModel.h"

@implementation STIMWorkMomentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"attachCommentList" : @"STIMWorkCommentModel" };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"rId": @"id",
             @"momentId" : @[@"uuid", @"postUUID"],
             @"ownerId":@[@"owner", @"userFrom"],
             @"ownerHost":@[@"ownerHost", @"userFromHost"],
             @"isAnonymous":@[@"isAnonymous", @"fromIsAnonymous"],
             @"anonymousName":@[@"anonymousName", @"fromAnonymousName"],
             @"anonymousPhoto":@[@"anonymousPhoto", @"fromAnonymousPhoto"],
             };
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self stimDB_properties_aps]];
    return str;
}

@end

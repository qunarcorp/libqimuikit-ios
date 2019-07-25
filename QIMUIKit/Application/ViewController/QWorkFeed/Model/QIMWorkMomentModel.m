//
//  QIMWorkMomentModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/2.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentModel.h"
#import "QIMWorkMomentContentModel.h"

@implementation QIMWorkMomentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"attachCommentList" : @"QIMWorkCommentModel" };
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
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end

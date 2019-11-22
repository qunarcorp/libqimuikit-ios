//
//  STIMWorkCommentModel.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/15.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkCommentModel.h"

@implementation STIMWorkCommentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"rId": @"id",
             @"childComments": @"newChild",
             @"fromUser":@[@"fromUser", @"userFrom"],
             @"fromHost":@[@"fromHost", @"userFromHost"],
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"childComments" : @"STIMWorkCommentModel" };
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self stimDB_properties_aps]];
    return str;
}

@end

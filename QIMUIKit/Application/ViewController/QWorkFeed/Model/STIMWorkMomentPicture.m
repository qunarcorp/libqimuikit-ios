//
//  STIMWorkMomentPicture.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/8.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentPicture.h"

@implementation STIMWorkMomentPicture

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"imageUrl": @"data",
             @"imageWidth" : @"width",
             @"imageHeight":@"height"
             };
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self stimDB_properties_aps]];
    return str;
}

@end

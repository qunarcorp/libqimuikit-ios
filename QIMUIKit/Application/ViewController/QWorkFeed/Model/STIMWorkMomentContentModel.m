//
//  STIMWorkMomentContentModel.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentContentModel.h"

@implementation STIMWorkMomentContentModel

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"imgList" : @"STIMWorkMomentPicture", @"linkContent" : @"STIMWorkMomentContentLinkModel", @"videoContent":@"STIMVideoModel"};
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self stimDB_properties_aps]];
    return str;
}

@end

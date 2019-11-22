//
//  STIMVideoModel.m
//  STIMUIKit
//
//  Created by lilu on 2019/8/9.
//

#import "STIMVideoModel.h"

@implementation STIMVideoModel

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self stimDB_properties_aps]];
    return str;
}

@end

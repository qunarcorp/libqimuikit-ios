//
//  QIMVideoModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/8/9.
//

#import "QIMVideoModel.h"

@implementation QIMVideoModel

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end

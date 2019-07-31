//
//  QIMWorkMomentContentVideoModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/7/31.
//

#import "QIMWorkMomentContentVideoModel.h"

@implementation QIMWorkMomentContentVideoModel

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end

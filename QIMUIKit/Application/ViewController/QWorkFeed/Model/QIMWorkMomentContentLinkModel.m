//
//  QIMWorkMomentContentLinkModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/5/19.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentContentLinkModel.h"

@implementation QIMWorkMomentContentLinkModel

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end

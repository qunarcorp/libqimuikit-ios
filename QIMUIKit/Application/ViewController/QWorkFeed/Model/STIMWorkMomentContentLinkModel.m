//
//  STIMWorkMomentContentLinkModel.m
//  STIMUIKit
//
//  Created by lilu on 2019/5/19.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentContentLinkModel.h"

@implementation STIMWorkMomentContentLinkModel

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self stimDB_properties_aps]];
    return str;
}

@end

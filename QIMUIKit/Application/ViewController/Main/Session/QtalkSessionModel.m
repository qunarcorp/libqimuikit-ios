//
//  QtalkSessionModel.m
//
//  Created by qitmac000645 on 2019/5/27.
//

#import "QtalkSessionModel.h"

@implementation QtalkSessionModel

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end

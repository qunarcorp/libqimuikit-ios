//
//  BSDiff.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/8/31.
//
//

#import "BSDiff.h"
#include "bspatch.h"


@implementation BSDiff

+ (BOOL)bsdiffPatch:(NSString *)patch
             origin:(NSString *)origin
      toDestination:(NSString *)destination
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:patch]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:origin]) {
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destination]) {
        [[NSFileManager defaultManager] removeItemAtPath:destination error:nil];
    }
    
    int err = beginPatch([origin UTF8String], [destination UTF8String], [patch UTF8String]);
    if (err) {
        return NO;
    }
    return YES;
}

@end
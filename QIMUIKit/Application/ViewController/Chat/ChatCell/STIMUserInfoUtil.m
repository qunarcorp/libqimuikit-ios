//
//  STIMUserInfoUtil.m
//  STChatIphone
//
//  Created by haibin.li on 16/1/5.
//
//
#import "STIMUserInfoUtil.h"
static STIMUserInfoUtil *__global_userInfo_util = nil;

@interface STIMUserInfoUtil (){
    NSMutableDictionary * _userInfoDic;
}

@end

@implementation STIMUserInfoUtil

+ (id)sharedInstance{
    if (__global_userInfo_util == nil) {
        __global_userInfo_util = [[STIMUserInfoUtil alloc] init];
    }
    return __global_userInfo_util;
}

- (NSMutableDictionary *)userInfoDic
{
    if (_userInfoDic == nil) {
        _userInfoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _userInfoDic;
}


@end

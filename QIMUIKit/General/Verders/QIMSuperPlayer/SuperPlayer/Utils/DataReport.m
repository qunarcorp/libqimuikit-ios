//
//  DataReport.m
//  TXLiteAVDemo
//
//  Created by annidyfeng on 2018/7/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "DataReport.h"

//错误码
#define kError_InvalidParam                            -10001
#define kError_ConvertJsonFailed                       -10002
#define kError_HttpError                               -10003

//数据上报
#define DEFAULT_ELK_HOST                     @"https://ilivelog.qcloud.com"
#define kHttpTimeout                         30
@implementation DataReport

+ (void)report:(NSString *)action param:(NSDictionary *)param
{
}

+ (NSString *)getPackageName {
    static NSString *packname = nil;
    if (packname)
        return packname;
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    packname = [infoDict objectForKey:@"CFBundleDisplayName"];
    if (packname == nil || [packname isEqual:@""]) {
        packname = [infoDict objectForKey:@"CFBundleIdentifier"];
    }
    return packname;
}

+ (void)report:(NSMutableDictionary *)param handler:(void (^)(int resultCode, NSString *message))handler;
{
}

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict
{
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
        }
        return data;
    }
    else
    {
        NSLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}
@end

//
//  QIMVoicePathManage.m
//  AudioTempForQT
//
//  Created by danzheng on 15/4/21.
//  Copyright (c) 2015年 fresh. All rights reserved.
//

#import "QIMVoicePathManage.h"

@implementation QIMVoicePathManage

/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}

/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory
{
    NSString *voicePath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/QIMVoice/"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:voicePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:voicePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return voicePath;
}

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}


/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[QIMVoicePathManage getCacheDirectory] stringByAppendingPathComponent:_fileName] stringByAppendingPathExtension:_type];
    return fileDirectory;
}

/**
 保存文件到路径
 @param dataToSave 要保存的data信息
 @param fileName   要保存的文件名
 @param type       要保存的文件类型
 @return  最终保存的文件名
 */
+ (NSString *)getPathToSaveWithSaveData:(NSData *)dataToSave ToFileName:(NSString *)fileName ofType:(NSString *)type
{
    NSString *fileDirectory  = [[[QIMVoicePathManage getCacheDirectory] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:type];
    [dataToSave writeToFile:fileDirectory atomically:YES];
    QIMVerboseLog(@"保存到了： %@",fileDirectory);
    
    return fileDirectory;
}

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName {
    NSString* fileDirectory = [[QIMVoicePathManage getCacheDirectory] stringByAppendingPathComponent:_fileName];
    return fileDirectory;
}

@end

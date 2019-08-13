//
//  QTalkPatchDownloadHelper.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/11/29.
//
//

#import "BSDiff.h"
// zipHelper
#import "ZipArchive.h"
#import "QTalkPatchDownloadHelper.h"
#import "ASIHTTPRequest.h"
#import "QIMUUIDTools.h"

@implementation QTalkPatchDownloadHelper

+ (BOOL) downloadFullPackageAndCheck:(NSString *)url  // 资源下载路径 md5文件
                                 md5:(NSString *)md5  // zip 包md5
                          bundleName:(NSString *)bundleName // zip包中的bundle文件名
                             zipName:(NSString *)zipName    // 存储zip包文件名 rn-qtalk-search.ios.jsbundle.tar.gz
                           cachePath:(NSString *)cachePath  // 本地缓存路径  rnRes/
                       destAssetName:(NSString *)destAssetName // bundle 存储文件名 index.ios.jsbundle_v8
{
    // download bundle
    ASIHTTPRequest *request = [QTalkPatchDownloadHelper downloadJSBundleWithUrl:url];
    NSError *error = [request error];
    
    NSNumber *is_ok = 0;
    
    if (!error) {
        
        NSString *errorMsg = @"";
        
        @try {
            // check package md5
            NSString* md5 =[QIMKit getFileDataMD5WithFileData: [request responseData]];
            if(![md5 isEqualToString:md5]){
                // QIMVerboseLog(@"md5 check error");
                errorMsg = @"md5 check error";
                
                return is_ok;
            }
            
            [QTalkPatchDownloadHelper saveBundleToCache:[request responseData] cachePath:cachePath zipName:zipName];
            
            // unzip
            [QTalkPatchDownloadHelper unzipBundle:cachePath zipName:zipName];
            
            // rename jsbundle filename
            NSString *filePath = [QTalkPatchDownloadHelper getDestCachePath:cachePath];
            NSString *sourceFilePath =[filePath stringByAppendingPathComponent: bundleName];
            NSString *destFilePath =[filePath stringByAppendingPathComponent: destAssetName];
            
            [QTalkPatchDownloadHelper renameFile:sourceFilePath dest:destFilePath];
            
            is_ok = @YES;
        } @catch (NSException *exception) {
            QIMVerboseLog(@"main: Caught %@: %@", [exception name], [exception reason]);
            is_ok = 0;
            errorMsg = [exception reason];
        } @finally {
            
        }
    }
    
    return is_ok;
}

+ (BOOL) downloadPatchAndCheck:(NSString *)url
                      patchMd5:(NSString *)patchMd5
                       fullMd5:(NSString *)fullMd5
                     cachePath:(NSString *)cachePath  // 本地缓存路径  rnRes/
                 destAssetName:(NSString *)destAssetName // bundle 存储文件名 index.ios.jsbundle_v8
                 innerBundleName:(NSString *)innerBundleName // 内置bundle 文件名 index.ios
{
    // TODO download patch
    ASIHTTPRequest *request = [QTalkPatchDownloadHelper downloadJSBundleWithUrl:url];
    NSError *error = [request error];
    
    NSNumber *is_ok = 0;
    
    if (!error) {
        
        NSString *errorMsg = @"";
        
        @try {
            // TODO check patch md5
            NSString* md5 =[QIMKit getFileDataMD5WithFileData: [request responseData]];
            if(![patchMd5 isEqualToString:md5]){
                // QIMVerboseLog(@"md5 check error");
                errorMsg = @"md5 check error";
                
                return is_ok;
            }
            
            NSString *patchPath = [QTalkPatchDownloadHelper getDestCachePath:cachePath];
            // append patch name 随机生成patch存储文件名
            patchPath = [patchPath stringByAppendingPathComponent: [QIMUUIDTools UUID]];
            // save patch file
            [[request responseData] writeToFile:patchPath atomically:YES];
            
            // TODO patch
            NSString *originPath = [QTalkPatchDownloadHelper getOriginBundlePath:cachePath assetBundleName:destAssetName innerBundleName:innerBundleName]
            ;
            NSString *destPath = [QTalkPatchDownloadHelper getDestBundlePath:cachePath assetBundleName:destAssetName];
            
            // patch result
            BOOL success = [BSDiff bsdiffPatch:patchPath origin:originPath toDestination:destPath];
            if(success){
                
                // check full md5 with after patch md5
                
                
                NSString* md5 =[QIMKit getFileMD5WithPath: destPath];
                if([fullMd5 isEqualToString:md5]){
                    // rename jsbundle filename
                    NSString *filePath = [QTalkPatchDownloadHelper getDestCachePath:cachePath];
                    
                    NSString *sourceFilePath =[filePath stringByAppendingPathComponent: [QTalkPatchDownloadHelper getAssetTempBundleName:destAssetName]];
                    NSString *destFilePath =[filePath stringByAppendingPathComponent:destAssetName];
                    
                    [QTalkPatchDownloadHelper renameFile:sourceFilePath dest:destFilePath];
                    
                    is_ok = @YES;
                }
            }
            
        } @catch (NSException *exception) {
            QIMVerboseLog(@"main: Caught %@: %@", [exception name], [exception reason]);
            is_ok = 0;
            errorMsg = [exception reason];
        } @finally {
            
        }
    }
    
    return is_ok;
}


+(NSString*) getDestCachePath:(NSString *)path{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *cachePath = [paths objectAtIndex:0];

    NSString *rnCache = [cachePath stringByAppendingPathComponent: path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:rnCache] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rnCache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return rnCache;
}

+(NSString *)getOriginBundlePath:(NSString *)cachePath
                 assetBundleName:(NSString *)assetBundleName
                 innerBundleName:(NSString *)innerBundleName
{
    
    NSString *filePath = [QTalkPatchDownloadHelper getDestCachePath:cachePath];
    NSString *assetBundle =[filePath stringByAppendingPathComponent: assetBundleName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // hot update bundle not existed
    if(![manager fileExistsAtPath:assetBundle]){
        // get inner bundle
        assetBundle = [[NSBundle mainBundle] pathForResource: innerBundleName ofType:@"jsbundle"];
    }
    
    return assetBundle;
}


+(NSString *)getAssetTempBundleName:(NSString *)filename{
    return [filename stringByAppendingString:@".tmp"];
}


+(NSString *)getDestBundlePath:(NSString *)cachePath
               assetBundleName:(NSString *)assetBundleName{
    
    NSString *filePath = [QTalkPatchDownloadHelper getDestCachePath:cachePath];
    
    assetBundleName =[filePath stringByAppendingPathComponent:[QTalkPatchDownloadHelper getAssetTempBundleName:assetBundleName]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // patch dest file not existed
    if(![manager fileExistsAtPath:assetBundleName]){
        NSString *str = @"";
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        // before patch, create empty dest file
        BOOL sucess = [manager createFileAtPath:filePath contents:data attributes:nil];
    }
    
    return assetBundleName;
}

// ######### file helper

+(void) saveBundleToCache:(NSData *) bundleInfo
                cachePath:(NSString *)cachePath
                  zipName:(NSString *)zipName{
    // cache path
    NSString *filePath = [QTalkPatchDownloadHelper getDestCachePath:cachePath];
    // append bundle name
    filePath = [filePath stringByAppendingPathComponent: zipName];
    // save zip file
    [bundleInfo writeToFile:filePath atomically:YES];
}


+(void) unzipBundle:(NSString *)cachePath
                    zipName:(NSString *)zipName
{
    // cache path
    NSString *filePath = [QTalkPatchDownloadHelper getDestCachePath:cachePath];
    NSString *zipFilePath =[filePath stringByAppendingPathComponent: zipName];
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:zipFilePath];
    [zip UnzipFileTo:filePath overWrite:YES];
}


+(ASIHTTPRequest *) downloadJSBundleWithUrl:(NSString *)url{
    NSURL *requestUrl = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request startSynchronous];
    
    return request;
}


+(void) renameFile:(NSString *)source
              dest:(NSString *)dest{
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    if([manager fileExistsAtPath:dest]){
        [manager removeItemAtPath:dest error:nil];
    }
    
    [manager moveItemAtPath:source toPath:dest error:nil];
}


@end

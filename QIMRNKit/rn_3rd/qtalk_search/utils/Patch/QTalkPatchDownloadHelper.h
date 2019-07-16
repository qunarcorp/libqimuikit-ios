//
//  QTalkPatchDownloadHelper.h
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/11/29.
//
//

#ifndef QTalkPatchDownloadHelper_h
#define QTalkPatchDownloadHelper_h

#import "QIMCommonUIFramework.h"

@interface  QTalkPatchDownloadHelper : NSObject

+ (BOOL) downloadFullPackageAndCheck:(NSString *)url
                                 md5:(NSString *)md5
                          bundleName:(NSString *)bundleName
                            zipName:(NSString *)zipName
                           cachePath:(NSString *)cachePath
                       destAssetName:(NSString *)destAssetName;


+ (BOOL) downloadPatchAndCheck:(NSString *)url
                      patchMd5:(NSString *)patchMd5
                       fullMd5:(NSString *)fullMd5
                     cachePath:(NSString *)cachePath
                 destAssetName:(NSString *)destAssetName
               innerBundleName:(NSString *)innerBundleName;

@end

#endif /* QTalkPatchDownloadHelper_h */

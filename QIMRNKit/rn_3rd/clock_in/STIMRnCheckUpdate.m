//
//  STIMRnCheckUpdate.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/1.
//

#import "STIMRnCheckUpdate.h"
#import "QTalkNewSearchRNView.h"
#import "QTalkSearchCheckUpdate.h"
#import "BSDiff.h"
// zipHelper
#import "ZipArchive.h"
#import "QTalkPatchDownloadHelper.h"

@implementation STIMRnCheckUpdate

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(update:(NSDictionary *) param: (RCTResponseSenderBlock)callback) {
    BOOL updateResult = NO;
    
    // update param
    NSString *fullpackageUrl = [param objectForKey:@"bundleUrl"];
    NSString *fullpackageMd5 = [param objectForKey:@"zipMd5"];
    NSString *patchUrl = [param objectForKey:@"patchUrl"];
    NSString *patchMd5 = [param objectForKey:@"patchMd5"];
    NSString *fullMd5 = [param objectForKey:@"bundleMd5"];
    NSString *bundleName = [param objectForKey:@"bundleName"];
    
    NSString *localCachePath = [QTalkNewSearchRNView getCachePath];
    NSString *localZipBundleName = [QTalkNewSearchRNView getAssetZipBundleName];
    NSString *localDestAssetName = [QTalkNewSearchRNView getAssetBundleName];
    NSString *localInnerBundeName = [QTalkNewSearchRNView getInnerBundleName];
    
    // check have new version
    if ([[param objectForKey:@"new"] boolValue]) {
        // check patch
        NSString *updateType = [param objectForKey:@"update_type"];
        if ([updateType isEqualToString:@"full"]) {
            // download full zip
            // check md5
            // unzip
            updateResult = [QTalkPatchDownloadHelper downloadFullPackageAndCheck:fullpackageUrl md5:fullMd5 bundleName:bundleName zipName:localZipBundleName cachePath:localCachePath destAssetName:localDestAssetName];
            
        } else if ([updateType isEqualToString:@"auto"]) {
            // try use patch first
            // patch error download full package
            updateResult = [QTalkPatchDownloadHelper downloadPatchAndCheck:patchUrl patchMd5:patchMd5 fullMd5:fullMd5 cachePath:localCachePath destAssetName:localDestAssetName innerBundleName:localInnerBundeName];
            if (!updateResult) {
                
                updateResult = [QTalkPatchDownloadHelper downloadFullPackageAndCheck:fullpackageUrl md5:fullMd5 bundleName:bundleName zipName:localZipBundleName cachePath:localCachePath destAssetName:localDestAssetName];
            }
            
        } else if ([updateType isEqualToString:@"patch"]) {
            // TODO download patch
            // check patch md5
            // patch
            // check after patch md5
            updateResult = [QTalkPatchDownloadHelper downloadPatchAndCheck:patchUrl patchMd5:patchMd5 fullMd5:fullMd5 cachePath:localCachePath destAssetName:localDestAssetName innerBundleName:localInnerBundeName];
            
        }
    }
    
    if (updateResult) {
        NSDictionary *resp1 = @{@"is_ok": @YES, @"errorMsg": @""};
        
        // TODO reload jsbundle
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SEARCH_BUNDLE_UPDATE object:nil];
        });
        
        callback(@[resp1]);
    } else {
        NSDictionary *resp2 = @{@"is_ok": @NO, @"errorMsg": @""};
        callback(@[resp2]);
    }
    NSDictionary *resp2 = @{@"is_ok": @NO, @"errorMsg": @""};
    callback(@[resp2]);
}

@end

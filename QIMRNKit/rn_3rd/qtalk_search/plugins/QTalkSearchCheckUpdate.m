//
//  QTalkSearchCheckUpdate.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/11/29.
//
//

#import "QTalkSearchRNView.h"
#import "QTalkNewSearchRNView.h"
#import "QTalkSearchCheckUpdate.h"
#import "BSDiff.h"
// zipHelper
#import "ZipArchive.h"
#import "QTalkPatchDownloadHelper.h"

@implementation QTalkSearchCheckUpdate

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(update:(NSDictionary *)param: (RCTResponseSenderBlock)callback) {
    
    __block BOOL updateResult = NO;
    
    // update param
    NSString *fullpackageUrl = [param objectForKey:@"bundleUrl"];
    NSString *fullpackageMd5 = [param objectForKey:@"zipMd5"];
    NSString *patchUrl = [param objectForKey:@"patchUrl"];
    NSString *patchMd5 = [param objectForKey:@"patchMd5"];
    NSString *fullMd5 = [param objectForKey:@"bundleMd5"];
    NSString *bundleName = [param objectForKey:@"bundleName"];
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    // check have new version
    if([[param objectForKey:@"new"] boolValue]){
        // check patch
        NSString *updateType = [param objectForKey:@"update_type"];
        if([updateType isEqualToString:@"full"]) {
            // download full zip
            // check md5
            // unzip
            [QTalkPatchDownloadHelper downloadFullPackageAndCheck:fullpackageUrl md5:fullMd5 bundleName:bundleName zipName: [QTalkSearchRNView getAssetZipBundleName] cachePath:[QTalkSearchRNView getCachePath] destAssetName: [QTalkSearchRNView getAssetBundleName] withCallBack:^(BOOL res) {
                updateResult = res;
                dispatch_semaphore_signal(sema);
            }];
            
        } else if ([updateType isEqualToString:@"auto"]) {
            // try use patch first
            // patch error download full package
            [QTalkPatchDownloadHelper downloadPatchAndCheck:patchUrl patchMd5:patchMd5 fullMd5:fullMd5 cachePath: [QTalkSearchRNView getCachePath] destAssetName:[QTalkSearchRNView getAssetBundleName] innerBundleName: [QTalkSearchRNView getInnerBundleName] withCallBack:^(BOOL res) {
                if(!res){
                    
                    [QTalkPatchDownloadHelper downloadFullPackageAndCheck:fullpackageUrl md5:fullMd5 bundleName:bundleName zipName: [QTalkSearchRNView getAssetZipBundleName] cachePath:[QTalkSearchRNView getCachePath] destAssetName: [QTalkSearchRNView getAssetBundleName] withCallBack:^(BOOL res) {
                        updateResult = res;
                        dispatch_semaphore_signal(sema);
                    }];
                } else {
                    updateResult = res;
                    dispatch_semaphore_signal(sema);
                }
            }];
        } else if ([updateType isEqualToString:@"patch"]){
            // TODO download patch
            // check patch md5
            // patch
            // check after patch md5
            [QTalkPatchDownloadHelper downloadPatchAndCheck:patchUrl patchMd5:patchMd5 fullMd5:fullMd5 cachePath:[QTalkSearchRNView getCachePath] destAssetName:[QTalkSearchRNView getAssetBundleName] innerBundleName: [QTalkSearchRNView getInnerBundleName] withCallBack:^(BOOL res) {
                updateResult = res;
                dispatch_semaphore_signal(sema);
            }];
            
        }
    }
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if(updateResult) {
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
    
}

@end


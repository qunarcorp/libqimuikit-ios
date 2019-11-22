//
//  STIMMWQRCodeActivity.m
//  STIMUIKit
//
//  Created by 李露 on 2018/6/27.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMMWQRCodeActivity.h"
#import "STIMWebView.h"
#import "UIApplication+STIMApplication.h"
#import "STIMJumpURLHandle.h"
#import "STIMGroupCardVC.h"

@interface STIMMWQRCodeActivity()

@property (nonatomic, copy) NSString *symbolData;

@end

@implementation STIMMWQRCodeActivity

+ (instancetype)sharedInstance {
    static STIMMWQRCodeActivity *_qrCodeActivity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qrCodeActivity = [[STIMMWQRCodeActivity alloc] init];
    });
    return _qrCodeActivity;
}

- (NSString *)scanQRCodeForImage:(UIImage *)image {
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:[image CGImage]]];
    //判断是否有数据（即是否是二维码）
    if (features.count >=1) {
        /**结果对象 */
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        return scannedResult;
    } else{
        return nil;
    }
}

- (BOOL)canPerformQRCodeWithImage:(UIImage *)image {
    if ([image isKindOfClass:[UIImage class]]) {
        NSString *result = [self scanQRCodeForImage:image];
        if (result.length > 0) {
            _symbolData = result;
            return YES;
        } else {
            _symbolData = nil;
            return NO;
        }
    } else {
        _symbolData = nil;
        return NO;
    }
}

- (void)performActivity {
    
    [self.fromPhotoBrowser dismissViewControllerAnimated:NO completion:^{
        NSString *str = _symbolData;
        UINavigationController *rootNav = [[UIApplication sharedApplication] visibleNavigationController];
        if ([str stimDB_hasPrefixHttpHeader]) {
            STIMWebView *webVC = [[STIMWebView alloc] init];
            [webVC setUrl:str];
            [rootNav pushViewController:webVC animated:YES];
        } else {
            NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if (url) {
                if ([url.scheme.lowercaseString isEqualToString:@"qtalk"]) {
                    [STIMJumpURLHandle parseURL:url];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            } else {
                NSString *subString = [str substringWithRange:NSMakeRange(0, 7)];
                if ([subString isEqualToString:@"GroupId"]) {
                    NSString *sub = [str substringFromIndex:8];
                    STIMGroupCardVC *GVC = [[STIMGroupCardVC alloc] init];
                    GVC.groupId = sub;
                    [rootNav pushViewController:GVC animated:YES];
                } else if ([subString isEqualToString:@"MuserId"]) {
                    NSString *sub = [str substringFromIndex:8];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [STIMFastEntrance openUserCardVCByUserId:sub];
                    });
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSString stringWithFormat:@"结果：%@",str]delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles: nil];
                    [alertView show];
                }
            }
        }
    }];
}

@end

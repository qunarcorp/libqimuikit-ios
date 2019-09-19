//
//  QIMMWQRCodeActivity.m
//  QIMUIKit
//
//  Created by 李露 on 2018/6/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMMWQRCodeActivity.h"
#import "QIMWebView.h"
#import "UIApplication+QIMApplication.h"
#import "QIMJumpURLHandle.h"
#import "QIMGroupCardVC.h"

@interface QIMMWQRCodeActivity()

@property (nonatomic, copy) NSString *symbolData;

@end

@implementation QIMMWQRCodeActivity

+ (instancetype)sharedInstance {
    static QIMMWQRCodeActivity *_qrCodeActivity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qrCodeActivity = [[QIMMWQRCodeActivity alloc] init];
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
        if ([str qim_hasPrefixHttpHeader]) {
            QIMWebView *webVC = [[QIMWebView alloc] init];
            [webVC setUrl:str];
            [rootNav pushViewController:webVC animated:YES];
        } else {
            NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if (url) {
                if ([url.scheme.lowercaseString isEqualToString:@"qtalk"]) {
                    [QIMJumpURLHandle parseURL:url];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            } else {
                NSString *subString = [str substringWithRange:NSMakeRange(0, 7)];
                if ([subString isEqualToString:@"GroupId"]) {
                    NSString *sub = [str substringFromIndex:8];
                    QIMGroupCardVC *GVC = [[QIMGroupCardVC alloc] init];
                    GVC.groupId = sub;
                    [rootNav pushViewController:GVC animated:YES];
                } else if ([subString isEqualToString:@"MuserId"]) {
                    NSString *sub = [str substringFromIndex:8];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [QIMFastEntrance openUserCardVCByUserId:sub];
                    });
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Reminder"] message:[NSString stringWithFormat:@"结果：%@",str]delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Confirm"] otherButtonTitles: nil];
                    [alertView show];
                }
            }
        }
    }];
}

@end

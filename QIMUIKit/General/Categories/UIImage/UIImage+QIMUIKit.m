//
//  UIImage+QIMUIKit.m
//  QIMUIKit
//
//  Created by lilu on 2019/4/28.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "UIImage+QIMUIKit.h"
#import "NSBundle+QIMLibrary.h"

@implementation UIImage (QIMUIKit)

+ (UIImage *)qim_imageNamedFromQIMUIKitBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle qimBundleWithClassName:@"QIMUIKit" BundleName:@"QIMUIKit"];
    NSError *error = nil;
    [imageBundle loadAndReturnError:&error];
    
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png" inDirectory:@"images"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}


@end

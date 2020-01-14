//
//  UIImage+STIMUIKit.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/4/28.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "UIImage+STIMUIKit.h"
#import "NSBundle+STIMLibrary.h"

@implementation UIImage (STIMUIKit)

+ (UIImage *)stimDB_imageNamedFromSTIMUIKitBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle qimBundleWithClassName:@"QIMUIKit" BundleName:@"QIMUIKit"];
    NSError *error = nil;
    [imageBundle loadAndReturnError:&error];
    
    name = [NSString stringWithFormat:@"stim_%@", [name stringByAppendingString:@"@2x"]];
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

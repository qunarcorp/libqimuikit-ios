//
//  UIImage+STIMImagePicker.m
//  STIMUIKit
//
//  Created by lilu on 2019/4/24.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "UIImage+STIMImagePicker.h"
#import "NSBundle+STIMImagePicker.h"

@implementation UIImage (STIMImagePicker)

+ (UIImage *)qim_imageNamedFromSTIMImagePickerBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle qim_imagePickerBundle];
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end

//
//  NSBundle+QIMImagePicker.m
//  QIMImagePickerController
//
//  Created by 谭真 on 16/08/18.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "NSBundle+QIMImagePicker.h"
#import "QIMImagePickerController.h"

@implementation NSBundle (QIMImagePicker)

+ (NSBundle *)qim_imagePickerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[QIMImagePickerController class]];
    NSURL *url = [bundle URLForResource:@"QIMImagePickerController" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)qim_localizedStringForKey:(NSString *)key {
    return [self qim_localizedStringForKey:key value:@""];
}

+ (NSString *)qim_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = [QIMImagePickerConfig sharedInstance].languageBundle;
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    return value1;
}

@end

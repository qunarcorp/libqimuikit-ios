//
//  NSBundle+QIMImagePicker.h
//  QIMImagePickerController
//
//  Created by 谭真 on 16/08/18.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (QIMImagePicker)

+ (NSBundle *)qim_imagePickerBundle;

+ (NSString *)qim_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)qim_localizedStringForKey:(NSString *)key;

@end


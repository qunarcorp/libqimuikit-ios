//
//  UIImage+QIMImagePicker.h
//  QIMUIKit
//
//  Created by lilu on 2019/4/24.
//  Copyright © 2019 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QIMImagePicker)

+ (UIImage *)qim_imageNamedFromQIMImagePickerBundle:(NSString *)name;

@end

NS_ASSUME_NONNULL_END

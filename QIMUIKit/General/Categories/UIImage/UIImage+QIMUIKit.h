//
//  UIImage+QIMUIKit.h
//  QIMUIKit
//
//  Created by lilu on 2019/4/28.
//  Copyright © 2019 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QIMUIKit)

+ (UIImage *)qim_imageNamedFromQIMUIKitBundle:(NSString *)name;

@end

NS_ASSUME_NONNULL_END

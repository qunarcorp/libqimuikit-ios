//
//  STIMCustomPopManager.h
//  STIMUIVendorKit
//
//  Created by 李海彬 on 11/7/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface STIMCustomPopManager : NSObject

+ (void)showPopVC:(UIViewController *)popVc withRootVC:(UIViewController *)rootVc;

@end

NS_ASSUME_NONNULL_END

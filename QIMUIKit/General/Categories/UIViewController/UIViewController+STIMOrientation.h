//
//  UIViewController+STIMOrientation.h
//  STIMUIKit
//
//  Created by 李海彬 on 2018/9/1.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@interface UIViewController (STIMOrientation)

- (BOOL)shouldAutorotate;

- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end

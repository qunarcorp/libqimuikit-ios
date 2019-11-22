//
//  UIViewController+STIMOrientation.m
//  STIMUIKit
//
//  Created by 李露 on 2018/9/1.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "UIViewController+STIMOrientation.h"

@implementation UIViewController (STIMOrientation)

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

@end

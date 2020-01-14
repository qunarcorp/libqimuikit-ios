//
//  UINavigationController+STIMOrientation.m
//  STIMUIKit
//
//  Created by 李海彬 on 2018/9/3.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "UINavigationController+STIMOrientation.h"

@implementation UINavigationController (STIMOrientation)

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

@end

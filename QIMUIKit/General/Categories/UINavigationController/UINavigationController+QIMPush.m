//
//  UINavigationController+QIMPush.m
//  QIMUIKit
//
//  Created by lilu on 2019/8/4.
//

#import "UINavigationController+QIMPush.h"
#import "QIMKitPublicHeader.h"
#import "QIMWindowManager.h"
#import <objc/runtime.h>

@implementation UINavigationController (QIMPush)

+ (void)load
{
    // Inject "-pushViewController:animated:"
    Method originalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(qim_pushViewController:animated:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)qim_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    Class mainClass = NSClassFromString(@"QIMMainVC");
    if ([[QIMKit sharedInstance] getIsIpad] == YES && [self.topViewController isKindOfClass:mainClass]) {
        [[QIMWindowManager shareInstance] showDetailVC:viewController];
//        [self.topViewController showDetailViewController:viewController sender:nil];
    } else {
        [self qim_pushViewController:viewController animated:animated];
    }
}

@end

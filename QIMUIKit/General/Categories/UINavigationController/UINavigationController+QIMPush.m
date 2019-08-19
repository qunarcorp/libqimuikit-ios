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
//    Method originalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
//    Method swizzledMethod = class_getInstanceMethod(self, @selector(qim_pushViewController:animated:));
//    method_exchangeImplementations(originalMethod, swizzledMethod);
    
//    Method preOriginalMethod = class_getInstanceMethod(self, @selector(presentViewController:animated:completion:));
//    Method preSwizzledMethod = class_getInstanceMethod(self, @selector(qim_presentViewController:animated:completion:));
//    method_exchangeImplementations(preOriginalMethod, preSwizzledMethod);
}

- (void)qim_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    Class mainClass = NSClassFromString(@"QIMMainVC");
    if ([[QIMKit sharedInstance] getIsIpad] == YES && [self.topViewController isKindOfClass:mainClass] && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) == NO) {
        [[QIMWindowManager shareInstance] showDetailVC:viewController];
//        [self.topViewController showDetailViewController:viewController sender:nil];
    } else {
        [self qim_pushViewController:viewController animated:animated];
    }
}

//- (void)qim_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
//    Class mainClass = NSClassFromString(@"QIMMainVC");
//    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
//        viewControllerToPresent.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [self qim_presentViewController:viewControllerToPresent animated:flag completion:completion];
////        [[QIMWindowManager shareInstance] showDetailVC:viewController];
//        //        [self.topViewController showDetailViewController:viewController sender:nil];
//    } else {
//        [self qim_presentViewController:viewControllerToPresent animated:flag completion:completion];
//    }
//}

@end

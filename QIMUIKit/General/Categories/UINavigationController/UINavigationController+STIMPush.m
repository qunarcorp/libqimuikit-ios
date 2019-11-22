//
//  UINavigationController+STIMPush.m
//  STIMUIKit
//
//  Created by lilu on 2019/8/4.
//

#import "UINavigationController+STIMPush.h"
#import "STIMKitPublicHeader.h"
#import "STIMWindowManager.h"
#import <objc/runtime.h>

@implementation UINavigationController (STIMPush)

+ (void)load
{
    // Inject "-pushViewController:animated:"
//    Method originalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
//    Method swizzledMethod = class_getInstanceMethod(self, @selector(stimDB_pushViewController:animated:));
//    method_exchangeImplementations(originalMethod, swizzledMethod);
    
//    Method preOriginalMethod = class_getInstanceMethod(self, @selector(presentViewController:animated:completion:));
//    Method preSwizzledMethod = class_getInstanceMethod(self, @selector(stimDB_presentViewController:animated:completion:));
//    method_exchangeImplementations(preOriginalMethod, preSwizzledMethod);
}

- (void)stimDB_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    Class mainClass = NSClassFromString(@"STIMMainVC");
    if ([[STIMKit sharedInstance] getIsIpad] == YES && [self.topViewController isKindOfClass:mainClass] && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) == NO) {
        [[STIMWindowManager shareInstance] showDetailVC:viewController];
//        [self.topViewController showDetailViewController:viewController sender:nil];
    } else {
        [self stimDB_pushViewController:viewController animated:animated];
    }
}

//- (void)stimDB_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
//    Class mainClass = NSClassFromString(@"STIMMainVC");
//    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
//        viewControllerToPresent.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [self stimDB_presentViewController:viewControllerToPresent animated:flag completion:completion];
////        [[STIMWindowManager shareInstance] showDetailVC:viewController];
//        //        [self.topViewController showDetailViewController:viewController sender:nil];
//    } else {
//        [self stimDB_presentViewController:viewControllerToPresent animated:flag completion:completion];
//    }
//}

@end

//
//  UIViewController+QIMPush.m
//  QIMUIKit
//
//  Created by lilu on 2019/8/18.
//

#import "UIViewController+QIMPush.h"
#import "QIMKitPublicHeader.h"
#import "QIMWindowManager.h"
#import <objc/runtime.h>

@implementation UIViewController (QIMPush)

+ (void)load
{
//    Method preOriginalMethod = class_getInstanceMethod(self, @selector(presentViewController:animated:completion:));
//    Method preSwizzledMethod = class_getInstanceMethod(self, @selector(qim_presentViewController:animated:completion:));
//    method_exchangeImplementations(preOriginalMethod, preSwizzledMethod);
}

- (void)qim_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    Class mainClass = NSClassFromString(@"QIMMainVC");
    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self qim_presentViewController:viewControllerToPresent animated:flag completion:completion];
        //        [[QIMWindowManager shareInstance] showDetailVC:viewController];
        //        [self.topViewController showDetailViewController:viewController sender:nil];
    } else {
        [self qim_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

@end

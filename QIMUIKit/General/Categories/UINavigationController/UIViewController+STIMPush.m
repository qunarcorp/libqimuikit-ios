//
//  UIViewController+STIMPush.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/8/18.
//

#import "UIViewController+STIMPush.h"
#import "STIMKitPublicHeader.h"
#import "STIMWindowManager.h"
#import <objc/runtime.h>

@implementation UIViewController (STIMPush)

+ (void)load
{
//    Method preOriginalMethod = class_getInstanceMethod(self, @selector(presentViewController:animated:completion:));
//    Method preSwizzledMethod = class_getInstanceMethod(self, @selector(stimDB_presentViewController:animated:completion:));
//    method_exchangeImplementations(preOriginalMethod, preSwizzledMethod);
}

- (void)stimDB_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    Class mainClass = NSClassFromString(@"STIMMainVC");
    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self stimDB_presentViewController:viewControllerToPresent animated:flag completion:completion];
        //        [[STIMWindowManager shareInstance] showDetailVC:viewController];
        //        [self.topViewController showDetailViewController:viewController sender:nil];
    } else {
        [self stimDB_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

@end

//
//  STIMWindowManager.m
//  STIMUIKit
//
//  Created by lilu on 2019/7/29.
//

#import "STIMWindowManager.h"
#import "STIMKitPublicHeader.h"

@interface STIMWindowManager ()

@end

@implementation STIMWindowManager

static STIMWindowManager *_windowManager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _windowManager = [[STIMWindowManager alloc] init];
    });
    return _windowManager;
}

- (CGFloat)stimDB_dockWidth{
    //mark by oldipad
    if ([UIScreen mainScreen].bounds.size.width * 0.06 < 80) {
        return 80;
    }
    return [UIScreen mainScreen].bounds.size.width * 0.06;
}

- (CGFloat)stimDB_rightWidth {
    //mark by oldipad
#if __has_include("STIMIPadWindowManager.h")
    if ([[STIMKit sharedInstance] getIsIpad] && [STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
        //iPad
        UIView *view = [[[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers lastObject] view];
        return CGRectGetWidth(view.frame);
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
#else
    return [UIScreen mainScreen].bounds.size.width;
#endif
}

- (CGFloat)getPrimaryWidth {
    //mark by oldipad
#if __has_include("STIMIPadWindowManager.h")
    
    if ([[STIMKit sharedInstance] getIsIpad] && [STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
        
        CGFloat leftWidth = [UIScreen mainScreen].bounds.size.width - [self stimDB_dockWidth] - [self stimDB_rightWidth];
        return leftWidth;
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
#else
    return [UIScreen mainScreen].bounds.size.width;
#endif
    
    //mark by newipad
    if ([[STIMKit sharedInstance] getIsIpad] && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return self.mainSplitVC.primaryColumnWidth;
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
}

- (CGFloat)getPrimaryHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGFloat)getDetailWidth {
    //mark by oldipad
    return [self stimDB_rightWidth];
    
    //mark by newipad
    if ([[STIMKit sharedInstance] getIsIpad] && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return [UIScreen mainScreen].bounds.size.width - self.mainSplitVC.primaryColumnWidth;
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
}

- (CGFloat)getDetailHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (UIViewController *)getMasterRootVC {
    return self.mainSplitVC.masterVC.visibleViewController;
}

- (UINavigationController *)getMasterRootNav {
    return self.mainSplitVC.masterVC;
}

- (UIViewController *)getDetailRootVC {
    return self.mainSplitVC.detailVC.visibleViewController;
}

- (UINavigationController *)getDetailRootNav {
    return self.mainSplitVC.detailVC;
}

- (void)showDetailVC:(UIViewController *)viewController {
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [self.mainSplitVC showDetailViewController:viewController];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.mainSplitVC showDetailViewController:nav];
    }
}

@end

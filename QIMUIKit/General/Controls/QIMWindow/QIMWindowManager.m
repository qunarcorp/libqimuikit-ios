//
//  QIMWindowManager.m
//  QIMUIKit
//
//  Created by lilu on 2019/7/29.
//

#import "QIMWindowManager.h"
#import "QIMKitPublicHeader.h"

@interface QIMWindowManager ()

@end

@implementation QIMWindowManager

static QIMWindowManager *_windowManager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _windowManager = [[QIMWindowManager alloc] init];
    });
    return _windowManager;
}

- (CGFloat)qim_dockWidth{
    //mark by oldipad
    if ([UIScreen mainScreen].bounds.size.width * 0.06 < 80) {
        return 80;
    }
    return [UIScreen mainScreen].bounds.size.width * 0.06;
}

- (CGFloat)qim_rightWidth {
    //mark by oldipad
#if __has_include("QIMIPadWindowManager.h")
    if ([[QIMKit sharedInstance] getIsIpad] && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
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
#if __has_include("QIMIPadWindowManager.h")
    
    if ([[QIMKit sharedInstance] getIsIpad] && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        
        CGFloat leftWidth = [UIScreen mainScreen].bounds.size.width - [self qim_dockWidth] - [self qim_rightWidth];
        return leftWidth;
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
#else
    return [UIScreen mainScreen].bounds.size.width;
#endif
    
    //mark by newipad
    if ([[QIMKit sharedInstance] getIsIpad] && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
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
    return [self qim_rightWidth];
    
    //mark by newipad
    if ([[QIMKit sharedInstance] getIsIpad] && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
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

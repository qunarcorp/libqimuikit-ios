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

- (CGFloat)getPrimaryWidth {
    if ([[QIMKit sharedInstance] getIsIpad] && [[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
        return self.mainSplitVC.primaryColumnWidth;
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
}

- (CGFloat)getPrimaryHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGFloat)getDetailWidth {
    if ([[QIMKit sharedInstance] getIsIpad] && [[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
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

@end

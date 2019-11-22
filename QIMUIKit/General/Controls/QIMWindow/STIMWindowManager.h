//
//  STIMWindowManager.h
//  STIMUIKit
//
//  Created by lilu on 2019/7/29.
//

#import <Foundation/Foundation.h>
#import "STIMMainSplitViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWindowManager : NSObject

@property (nonatomic, strong) STIMMainSplitViewController *mainSplitVC;

+ (instancetype)shareInstance;

- (CGFloat)getPrimaryWidth;

- (CGFloat)getPrimaryHeight;

- (CGFloat)getDetailWidth;

- (CGFloat)getDetailHeight;

- (UIViewController *)getMasterRootVC;

- (UINavigationController *)getMasterRootNav;

- (UIViewController *)getDetailRootVC;

- (UINavigationController *)getDetailRootNav;

- (void)showDetailVC:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END

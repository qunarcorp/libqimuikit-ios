//
//  QIMWindowManager.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/29.
//

#import <Foundation/Foundation.h>
#import "QIMMainSplitViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWindowManager : NSObject

@property (nonatomic, strong) QIMMainSplitViewController *mainSplitVC;

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

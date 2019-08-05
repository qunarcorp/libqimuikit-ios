//
//  QIMMainSplitViewController.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMMainSplitViewController : UISplitViewController

@property (nonatomic, strong) UINavigationController *masterVC;

@property (nonatomic, strong) UINavigationController *detailVC;

@property (nonatomic, strong) id placeholderViewControllerClass;

- (instancetype)initWithMaster:(UINavigationController *)masterNav detail:(UINavigationController *)detailNav;

- (void)showMasterViewController:(UIViewController *)vc;

- (void)showDetailViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END

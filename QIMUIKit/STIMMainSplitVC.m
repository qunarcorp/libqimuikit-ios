//
//  STIMMainSplitVC.m
//  STIMUIKit
//
//  Created by lilu on 2019/7/27.
//

#import "STIMMainSplitVC.h"
#import "STIMMainVC.h"

@interface STIMMainSplitVC () <UISplitViewControllerDelegate>

@end

@implementation STIMMainSplitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
//    STIMMainVC *mainVC1 = [STIMMainVC sharedInstanceWithSkipLogin:NO];
//    STIMNavController *navVC1 = [[STIMNavController alloc] initWithRootViewController:mainVC1];
//    
//    STIMMainVC *mainVC2 = [STIMMainVC sharedInstanceWithSkipLogin:NO];
//    STIMNavController *navVC2 = [[STIMNavController alloc] initWithRootViewController:mainVC2];
//    self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
//    self.viewControllers = @[mainVC1];
//    self show
    self.delegate = self;
    
    /*
    [[STIMIPadWindowManager sharedInstance] setMainSplitVC:self];
    //    self.delegate = self;
    IPAD_LeftMainVC *leftMainVC = [[IPAD_LeftMainVC alloc] init];
    leftMainVC.delegate = self;
    UINavigationController *masterNav = [[UINavigationController alloc] initWithRootViewController:leftMainVC];
    
    IPAD_DetailVC *iPadDetailVC = [[IPAD_DetailVC alloc] init];
    UINavigationController *detailVc = [[UINavigationController alloc] initWithRootViewController:iPadDetailVC];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    //手势识别器，让用户使用划动动作更改显示模式
    self.presentsWithGesture = NO;
    self.viewControllers = @[masterNav,iPadDetailVC];
     */
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(nullable id)sender NS_AVAILABLE_IOS(8_0) {
    return NO;
}

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor greenColor];
//    STIMMainVC *mainVC1 = [STIMMainVC sharedInstanceWithSkipLogin:NO];
//    STIMNavController *navVC1 = [[STIMNavController alloc] initWithRootViewController:mainVC1];
    return vc;
}

- (UIViewController *)primaryViewControllerForExpandingSplitViewController:(UISplitViewController *)splitViewController {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor purpleColor];
    return vc;
//    STIMMainVC *mainVC1 = [STIMMainVC sharedInstanceWithSkipLogin:NO];
//    STIMNavController *navVC1 = [[STIMNavController alloc] initWithRootViewController:mainVC1];
//    return mainVC1;
}


@end

//
//  QIMMainSplitViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/7/29.
//

#import "QIMMainSplitViewController.h"

@interface QIMMainSplitViewController () <UISplitViewControllerDelegate> {
    CGFloat maxMasterWidth;
}

@end

@implementation QIMMainSplitViewController

- (BOOL)isPortrait {
    return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
}

- (instancetype)initWithMaster:(UINavigationController *)masterNav detail:(UINavigationController *)detailNav {
    self = [super init];
    if (self) {
        self.masterVC = masterNav;
        self.detailVC = detailNav;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.viewControllers = @[self.masterVC, self.detailVC];
    maxMasterWidth = MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    if ([self isPortrait]) {
        [self toPortraitWidth];
    } else {
        [self toLandscapeWidth];
    }
    // Do any additional setup after loading the view.
}

- (void)toPortraitWidth {
    self.maximumPrimaryColumnWidth = maxMasterWidth;
    self.preferredPrimaryColumnWidthFraction = 1;
}

- (void)toLandscapeWidth {
    
    self.maximumPrimaryColumnWidth = UISplitViewControllerAutomaticDimension;
    self.preferredPrimaryColumnWidthFraction = UISplitViewControllerAutomaticDimension;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    NSArray *subVCs = self.masterVC.viewControllers;
    NSMutableArray *submutableVCs = [[NSMutableArray alloc] initWithArray:subVCs];
    if (![self isPortrait]) {
        
        BOOL flag = NO;
        if (![self.detailVC.topViewController isKindOfClass:self.placeholderViewControllerClass]) {
            [submutableVCs addObjectsFromArray:self.detailVC.viewControllers];
            flag = YES;
        }
        
        if (flag == YES) {
            UIViewController *placeVC = [[self.placeholderViewControllerClass alloc] init];
            self.detailVC.viewControllers = @[placeVC];
        }
        [self toPortraitWidth];
        
    } else {
        if (submutableVCs.count > 1) {
            [submutableVCs removeObjectAtIndex:0];
            [self.masterVC popToRootViewControllerAnimated:NO];
            self.detailVC.viewControllers = submutableVCs;
        }
        [self toLandscapeWidth];
    }
}

- (UIInterfaceOrientationMask)splitViewControllerSupportedInterfaceOrientations:(UISplitViewController *)splitViewController {
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return YES;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(id)sender {
    return YES;
}

@end

//
//  STIMNavController.m
//  STChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import "STIMNavController.h"
#import "STIMNavBar.h"
#import "UIApplication+STIMApplication.h"

#if __has_include("STIMNotifyManager.h")

    #import "STIMNotifyManager.h"
    #import "STIMNotifyView.h"
#endif
#import "STIMMessageHelperVC.h"
@interface QTalkViewController()
@end

@implementation UINavigationController(QTalk)

- (void)popToViewControllorClass:(Class)popViewController ThenPush:(UIViewController *)toViewController animated:(BOOL)animated{
    NSArray *list = self.viewControllers;
    NSMutableArray *vcList = [NSMutableArray array];
    BOOL isNeedPushToList = YES;
    for (id vc in list) {
        if ([vc isKindOfClass:popViewController]) {
            isNeedPushToList = NO;
        }
        if (isNeedPushToList) {
            [vcList addObject:vc];
        } else {
            if ([vc isKindOfClass:[QTalkViewController class]]) {
                [(QTalkViewController *)vc selfPopedViewController];
            }
        }
    }
    [vcList addObject:toViewController];
    [self setViewControllers:vcList animated:animated];
}

- (void)popToRootVCThenPush:(UIViewController *)toViewController animated:(BOOL)animated {
    NSArray *list = self.viewControllers;
    id root = [list firstObject];
    for (id vc in list) {
        if (![vc isEqual:root]) {
            if ([vc isKindOfClass:[QTalkViewController class]] || [vc respondsToSelector:@selector(selfPopedViewController)]) {
                [(QTalkViewController *)vc selfPopedViewController];
            }
        }
    }
    if (root) {
        list = @[root,toViewController];
    } else {
        list = @[toViewController];
    }
    [self setViewControllers:list animated:animated];
}

@end

@interface STIMNavController ()

@end

@implementation STIMNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO Startalk start
//    [self.navigationBar setTintColor: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]];
//    [self.navigationBar setBackgroundImage:[UIImage stimDB_imageWithColor:[UIColor whiteColor]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationBar setTintColor: [UIColor spectralColorWhiteColor]];
    [self.navigationBar setBackgroundImage:[UIImage stimDB_imageWithColor:[UIColor stimDB_colorWithHex:0x00CABE]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //TODO Startalk end
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self becomeFirstResponder];
}

- (void)goBack:(id)sender{
    [self popViewControllerAnimated:YES];
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    //检测到摇动
}



- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
    //摇动取消
    
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    //Debug模式开启RN摇一摇调试
    if (self.cancelMotion == NO && [STIMKit getCurrentAppConfigurationMode] != STIMAppConfigurationModeDebug) {
        id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ([nav isKindOfClass:[STIMNavController class]]) {
            //摇动结束
            if (event.subtype == UIEventSubtypeMotionShake) {
                //something happens
                if ([self.viewControllers.lastObject isKindOfClass:[STIMMessageHelperVC class]]) {
                    [nav popToRootViewControllerAnimated:YES];
                }else{
                    STIMMessageHelperVC *helperVC = [[STIMMessageHelperVC alloc] init];
                    [nav popToRootVCThenPush:helperVC animated:YES];
                }
            }
        }
    } else {
        if (event.subtype == UIEventSubtypeMotionShake) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCTShowDevMenuNotification" object:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
   UIViewController *viewController = [super popViewControllerAnimated:animated];
    if ([viewController isKindOfClass:[QTalkViewController class]]) {
        [(QTalkViewController *)viewController selfPopedViewController];
    }
    return viewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSArray *list = [super popToViewController:viewController animated:animated];
    for (id viewController in list) {
        if ([viewController isKindOfClass:[QTalkViewController class]]) {
            [(QTalkViewController *)viewController selfPopedViewController];
        }
    }
    return list;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    NSArray *list = [super popToRootViewControllerAnimated:animated];
    for (id viewController in list) {
        if ([viewController isKindOfClass:[QTalkViewController class]]) {
            [(QTalkViewController *)viewController selfPopedViewController];
        }
    }
    return list;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)shouldAutorotate {
    if ([[self.viewControllers lastObject] isKindOfClass:[QTalkViewController class]]) {
        return [[self.viewControllers lastObject] shouldAutorotate];
    }
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[self.viewControllers lastObject] isKindOfClass:[QTalkViewController class]]) {
        return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{

    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ([[self.viewControllers lastObject] isKindOfClass:[QTalkViewController class]]) {
        return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationPortrait;
}


@end

#if __has_include("STIMNotifyManager.h")

@interface QTalkViewController () <STIMNotifyManagerDelegate>

@end

#endif

@implementation QTalkViewController

- (void)registNSNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeNotifyView:) name:@"kNotifyViewCloseNotification" object:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self registNSNotification];
#if __has_include("STIMNotifyManager.h")

    [[STIMNotifyManager shareNotifyManager] setNotifyManagerGlobalDelegate:self];
    
#endif
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGRect frame =  [UIScreen mainScreen].applicationFrame;
    CGFloat height = 0;
    height += self.navigationController.navigationBar.frame.size.height;
    frame.origin.y = height;
    frame.size.height -= height;
    [self.view setFrame:frame];
}

- (void)selfPopedViewController{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#if __has_include("STIMNotifyManager.h")

- (void)closeNotifyView:(NSNotification *)notify {
    STIMVerboseLog(@"closeNotifyView : %@", notify);
    STIMNotifyView *notifyView = notify.object;
    [notifyView removeFromSuperview];
}

#pragma mark - STIMNotifyManagerDelegate

- (void)showGloablNotifyWithView:(STIMNotifyView *)view {
    [self.view addSubview:view];
}
#endif

@end
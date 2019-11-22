//
//  QTalkSearchViewManager.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/11/28.
//
//

#import "QTalkSearchRNView.h"
#import "QTalkNewSearchRNView.h"
#import "QTalkSearchViewManager.h"
#import "STIMNavPopTransition.h"

@interface QTalkSearchViewManager () <UINavigationControllerDelegate>

@end

@implementation QTalkSearchViewManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![[STIMKit sharedInstance] getIsIpad] && [[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack) name:kNotify_RN_QTALK_SEARCH_GO_BACK object:nil];
    NSNumber *forceOldSearch = [[STIMKit sharedInstance] userObjectForKey:@"forceOldSearch"];
    //Mark by oldiPad
    if ([forceOldSearch boolValue] == YES || [[STIMKit sharedInstance] getIsIpad] == YES || [STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        QTalkSearchRNView *reactView = [[QTalkSearchRNView alloc] initWithFrame:self.view.bounds];
        [reactView setOwnerVC:self];
        
        [reactView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        [self.view addSubview:reactView];
    } else {
        QTalkNewSearchRNView *newReactView = [[QTalkNewSearchRNView alloc] initWithFrame:self.view.bounds];
        [newReactView setOwnerVC:self];
        [newReactView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        [self.view addSubview:newReactView];
    }
    /* mark by newipad
    QTalkNewSearchRNView *newReactView = [[QTalkNewSearchRNView alloc] initWithFrame:self.view.bounds];
    [newReactView setOwnerVC:self];
    [newReactView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    
    [self.view addSubview:newReactView];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(setCancelMotion:)]) {
        [(STIMNavController *) self.navigationController setCancelMotion:YES];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(setCancelMotion:)]) {
        [(STIMNavController *) self.navigationController setCancelMotion:NO];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)goBack {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //Mark by oldiPad
    if ([[STIMKit sharedInstance] getIsIpad]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.navigationController.delegate = self;
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    /* mark by newipad
    self.navigationController.delegate = self;
    [self dismissViewControllerAnimated:YES completion:nil];
     */
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        return (id <UIViewControllerAnimatedTransitioning>) [[STIMNavPopTransition alloc] init];
    }
    //返回nil则使用默认的动画效果
    return nil;
}

- (void)dealloc {
    self.navigationController.delegate = nil;
}

@end

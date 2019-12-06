//
//  QIMFlutterViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/9/20.
//

#import "QIMFlutterViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#if __has_include(<FlutterPluginRegistrant/GeneratedPluginRegistrant.h>)
#import <FlutterPluginRegistrant/GeneratedPluginRegistrant.h> // Only if you have Flutter Plugins
#else
#if __has_include("GeneratedPluginRegistrant.h")
#import "GeneratedPluginRegistrant.h" // Only if you have Flutter Plugins
#endif
#endif
#import "UIView+QIMToast.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMFlutterViewController ()

@end

@implementation QIMFlutterViewController

#if __has_include(<Flutter/Flutter.h>)

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.fd_interactivePopDisabled = YES;
#if __has_include("GeneratedPluginRegistrant.h")
    [GeneratedPluginRegistrant registerWithRegistry:self];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUpdateMedalStatusToast:) name:@"kNotifyUpdateMedalStatus" object:nil];

    // Do any additional setup after loading the view.
}

- (void)showUpdateMedalStatusToast:(NSNotification *)note {
    NSDictionary *noteDic = note.object;
    NSInteger status = [[noteDic objectForKey:@"status"] integerValue];
    BOOL success = [[noteDic objectForKey:@"success"] boolValue];
    NSString *toastStr = nil;
    if ((status & 0x02) == 0x02) {
        if (success) {
            toastStr = [NSBundle qim_localizedStringForKey:@"wear_Already_worn"];
        } else {
            toastStr = [NSBundle qim_localizedStringForKey:@"wear_failure"];
        }
    } else {
        if (success) {
            toastStr = [NSBundle qim_localizedStringForKey:@"wear_Already_removed"];
        } else {
            toastStr = [NSBundle qim_localizedStringForKey:@"remove_failure"];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view qim_hideAllToasts];
        });
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view qim_makeToast:toastStr];
        });
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#endif
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


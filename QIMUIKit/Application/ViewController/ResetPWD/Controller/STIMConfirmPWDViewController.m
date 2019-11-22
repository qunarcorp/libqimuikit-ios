//
//  STIMConfirmPWDViewController.m
//  STIMUIKit
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMConfirmPWDViewController.h"

@interface STIMConfirmPWDViewController ()

@end

@implementation STIMConfirmPWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *image = [UIImage stimDB_imageWithColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = [NSBundle stimDB_localizedStringForKey:@"Reset_password"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor stimDB_colorWithHex:0x333333]}];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

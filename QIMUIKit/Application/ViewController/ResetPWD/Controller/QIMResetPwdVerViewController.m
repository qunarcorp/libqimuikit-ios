//
//  QIMResetPwdVerViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMResetPwdVerViewController.h"

@interface QIMResetPwdVerViewController ()

@property (nonatomic, strong) UITextField *phoneTextField;  //手机号

@property (nonatomic, strong) UITextField *captchaField;  //图形验证码输入框

@property (nonatomic, strong) UIImageView *captchaImageView;  //图形验证码

@property (nonatomic, strong) UITextField *smsTextField;    //短信验证码

@property (nonatomic, strong) UIButton *smsCodeBtn; //获取短信验证码按钮

@property (nonatomic, strong) UIButton *nextBtn;  //下一步

@end

@implementation QIMResetPwdVerViewController

#pragma mark - setter and getter

- (UITextField *)phoneTextField {
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc] init];
        _phoneTextField.placeholder = @"请输入手机号";
        _phoneTextField.delegate = self;
        _phoneTextField.backgroundColor = [UIColor whiteColor];
    }
    return _phoneTextField;
}

- (UITextField *)captchaField {
    if (!_captchaField) {
        _captchaField = [[UITextField alloc] init];
        _captchaField.placeholder = @"请输入图形验证码";
        
    }
    return _captchaField;
}

- (UITextField *)smsTextField {
    if (!_smsTextField) {
        _smsTextField = [[UITextField alloc] init];
        _smsTextField.placeholder = @"请输入短信验证码";
    }
    return _smsTextField;
}

- (UIButton *)smsCodeBtn {
    if (!_smsCodeBtn) {
        _smsCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_smsCodeBtn setBackgroundColor:[UIColor whiteColor]];
        [_smsCodeBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_smsCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
    return _smsCodeBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *image = [UIImage qim_imageWithColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = @"重置密码";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x333333]}];

    // Do any additional setup after loading the view.
}

@end

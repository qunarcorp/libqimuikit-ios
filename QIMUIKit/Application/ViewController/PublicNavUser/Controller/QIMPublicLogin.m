//
//  QIMPublicLogin.m
//  QIMUIKit
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMPublicLogin.h"
#import "YYKeyboardManager.h"
#import "QIMPublicCompanyModel.h"
#import "QIMNavConfigManagerVC.h"
#import "YYModel.h"
#import "QIMUUIDTools.h"
#import "QIMProgressHUD.h"
#import "QIMAgreementViewController.h"
#import "QIMSelectComponyViewController.h"

static const int companyTag = 10001;

@interface QIMPublicLogin () <UITextFieldDelegate, YYKeyboardObserver, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *loginTitleLabel;  //登录Label

@property (nonatomic, strong) UIButton *registerBtn;  //注册按钮

@property (nonatomic, assign) BOOL multipleLogin;  //是否为多次登录

@property (nonatomic, strong) UILabel *companyShowLabel; //二次登录公司名

@property (nonatomic, strong) UIButton *switchCompanyBtn; //二次登录公司切换名按钮

@property (nonatomic, strong) UITextField *userNameTextField;   //用户名TextField

@property (nonatomic, strong) UIView *userNameLineView;         //用户名LineView

@property (nonatomic, strong) UITextField *userPwdTextField;    //用户密码TextField

@property (nonatomic, strong) UIView *userPwdLineView;         //用户密码LineView

@property (nonatomic, strong) UITextField *companyTextField;    //公司名TextField

@property (nonatomic, strong) UIView *companyLineView;         //公司名LineView

@property (nonatomic, strong) UIButton *checkBtn;               //条款Btn

@property (nonatomic, strong) UILabel *textLabel;               //条款Label

@property (nonatomic, strong) UIButton *loginBtn;   //登录按钮

@property (nonatomic, strong) UIButton *forgotBtn;  //忘记密码

@property (nonatomic, strong) UIButton *settingBtn;             //设置Btn

@property (nonatomic, assign) CGFloat keyboardOriginY;

@property (nonatomic, strong) QIMPublicCompanyModel *companyModel;

@end

@implementation QIMPublicLogin

#pragma mark - setter and getter

- (UILabel *)loginTitleLabel {
    if (!_loginTitleLabel) {
        _loginTitleLabel = [[UILabel alloc] init];
        _loginTitleLabel.font = [UIFont boldSystemFontOfSize:26];
        _loginTitleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
        _loginTitleLabel.text = @"登录";
        [_loginTitleLabel sizeToFit];
    }
    return _loginTitleLabel;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:@"创建公司" forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(registerNew:) forControlEvents:UIControlEventTouchUpInside];
        [_registerBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    }
    return _registerBtn;
}

- (UILabel *)companyShowLabel {
    if (!_companyShowLabel) {
        _companyShowLabel = [[UILabel alloc] init];
        _companyShowLabel.textColor = [UIColor qim_colorWithHex:0x999999];
        _companyShowLabel.font = [UIFont systemFontOfSize:15];
        [_companyShowLabel sizeToFit];
    }
    return _companyShowLabel;
}

- (UIButton *)switchCompanyBtn {
    if (!_switchCompanyBtn) {
        _switchCompanyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCompanyBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e31f" size:12 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateNormal];
        [_switchCompanyBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e31f" size:12 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
        [_switchCompanyBtn addTarget:self action:@selector(gotoSelectCompany:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCompanyBtn;
}

- (UITextField *)userNameTextField {
    if (!_userNameTextField) {
        _userNameTextField = [[UITextField alloc] init];
        _userNameTextField.placeholder = @"请输入用户名";
        _userNameTextField.delegate = self;
        _userNameTextField.backgroundColor = [UIColor whiteColor];
    }
    return _userNameTextField;
}

- (UIView *)userNameLineView {
    if (!_userNameLineView) {
        _userNameLineView = [[UIView alloc] init];
        _userNameLineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    }
    return _userNameLineView;
}

- (UITextField *)userPwdTextField {
    if (!_userPwdTextField) {
        _userPwdTextField = [[UITextField alloc] init];
        _userPwdTextField.placeholder = @"请输入密码";
        _userPwdTextField.delegate = self;
        _userPwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _userPwdTextField.secureTextEntry = YES;
        _userPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _userPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userPwdTextField.backgroundColor = [UIColor whiteColor];
    }
    if (self.companyModel) {
        _userPwdTextField.returnKeyType = UIReturnKeyGo;
    } else {
        _userPwdTextField.returnKeyType = UIReturnKeyNext;
    }
    return _userPwdTextField;
}

- (UIView *)userPwdLineView {
    if (!_userPwdLineView) {
        _userPwdLineView = [[UIView alloc] init];
        _userPwdLineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    }
    return _userPwdLineView;
}

- (UITextField *)companyTextField {
    if (!_companyTextField) {
        _companyTextField = [[UITextField alloc] init];
        _companyTextField.placeholder = @"请输入公司名";
        _companyTextField.delegate = self;
        _companyTextField.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSelectCompany:)];
        [_companyTextField addGestureRecognizer:tap];
    }
    return _companyTextField;
}

- (UIView *)companyLineView {
    if (!_companyLineView) {
        _companyLineView = [[UIView alloc] init];
        _companyLineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    }
    return _companyLineView;
}

- (UIButton *)forgotBtn {
    if (!_forgotBtn) {
        _forgotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_forgotBtn.titleLabel setTextAlignment:NSTextAlignmentRight];
        [_forgotBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgotBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_forgotBtn addTarget:self action:@selector(forgotPWD:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgotBtn;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor qim_colorWithHex:0x999999];
        _textLabel.font = [UIFont systemFontOfSize:14];
        NSString *commentNumStr = @"《使用条款和隐私政策》";
        NSString *titleText = [NSString stringWithFormat:@"同意%@", commentNumStr];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:titleText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor spectralColorGrayBlueColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                range:[titleText rangeOfString:commentNumStr]];
        [_textLabel setAttributedText:attributedText];
        _textLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementBtnHandle:)];
        [_textLabel addGestureRecognizer:tap];
    }
    return _textLabel;
}

- (UIButton *)checkBtn {
    if (!_checkBtn) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:17 color:[UIColor qim_colorWithHex:0xE4E4E4]]] forState:UIControlStateNormal];
        [_checkBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:17 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
        _checkBtn.selected = YES;
        [_checkBtn addTarget:self action:@selector(agreeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkBtn;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        UIImage *disableImage = [UIImage qim_imageWithColor:[UIColor qim_colorWithHex:0xABE9E5]];
        [_loginBtn setBackgroundImage:disableImage forState:UIControlStateDisabled];
        UIImage *normalImage = [UIImage qim_imageWithColor:[UIColor qim_colorWithHex:0x00CABE]];
        [_loginBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginBtn.layer.cornerRadius = 24.0f;
        _loginBtn.layer.masksToBounds = YES;
        [_loginBtn addTarget:self action:@selector(clickLogin:) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.enabled = NO;
    }
    return _loginBtn;
}

- (UIButton *)settingBtn {
    if (_settingBtn == nil) {
        
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_settingBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
        [_settingBtn setTitle:@"设置服务地址" forState:UIControlStateNormal];
        [_settingBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"iconSetting"] forState:UIControlStateNormal];
        [_settingBtn addTarget:self action:@selector(onSettingClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotify:) name:kNotificationLoginState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNavDicts:) name:@"NavConfigSettingChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamEnd:) name:@"kNotificationOutOfDate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamEnd:) name:@"kNotificationStreamEnd" object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    NSString *lastUserName = [QIMKit getLastUserName];
    NSString * userToken = [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
    if (userToken && lastUserName) {
        
        [self autoLogin];
        
    } else if (lastUserName && !userToken) {
        //如果本地还有用户名，自动输入
        _userNameTextField.text = lastUserName;
    } else {
        
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.userPwdTextField) {
        if (textField.text.length - range.length + string.length >= 1 && self.userNameTextField.text.length > 0 && self.companyModel.domain.length > 0) {
            [self updateLoginEnable:YES];
        } else {
            [self updateLoginEnable:NO];
        }
    } else if (textField == self.userNameTextField) {
        if (textField.text.length - range.length + string.length >= 1 && self.userPwdTextField.text.length > 0 && self.companyModel.domain.length > 0) {
            [self updateLoginEnable:YES];
        } else {
            [self updateLoginEnable:NO];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.userPwdTextField) {
        [self updateLoginEnable:NO];
    } else if (textField == self.userNameTextField) {
        [self updateLoginEnable:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.userPwdTextField == textField) {
        if (self.companyModel && self.userNameTextField.text.length) {
            [self clickLogin:nil];
        }
    } else {
        
    }
    return YES;
}

- (void)updateLoginEnable:(BOOL)flag {
    [self.loginBtn setEnabled:flag];
}

- (void)updateLoginUI {
    if (self.userNameTextField.text.length > 0 && self.userPwdTextField.text.length > 0 && self.companyModel.domain.length > 0) {
        [self.loginBtn setEnabled:YES];
    } else {
        [self.loginBtn setEnabled:NO];
    }
}

- (void)setupUI {
    NSMutableDictionary *oldNavConfigUrlDict = [[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
    QIMVerboseLog(@"本地找到的oldNavConfigUrlDict : %@", oldNavConfigUrlDict);
    if (oldNavConfigUrlDict.count) {
        self.multipleLogin = YES;
        QIMPublicCompanyModel *companyModel = [[QIMPublicCompanyModel alloc] init];
        companyModel.name = [oldNavConfigUrlDict objectForKey:QIMNavNameKey];
        companyModel.domain = [oldNavConfigUrlDict objectForKey:QIMNavNameKey];
        companyModel.nav = [oldNavConfigUrlDict objectForKey:QIMNavUrlKey];
        self.companyModel = companyModel;
    } else {
        self.multipleLogin = NO;
    }
    
    [self.view addSubview:self.loginTitleLabel];
    [self.loginTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(33);
        make.top.mas_offset(55);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(38);
    }];
    
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-16);
        make.top.mas_offset(55);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(18);
    }];
    
    if (self.multipleLogin) {
        //多次登录，展示切换公司按钮，不展示公司TextField
        
        NSMutableDictionary *oldNavConfigUrlDict = [[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
        QIMVerboseLog(@"本地找到的oldNavConfigUrlDict : %@", oldNavConfigUrlDict);
        NSString *navTitle = [oldNavConfigUrlDict objectForKey:@"title"];
        [self.companyShowLabel setText:navTitle];
        [self.view addSubview:self.companyShowLabel];
        [self.companyShowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.loginTitleLabel.mas_left);
            make.height.mas_equalTo(18);
            make.top.mas_equalTo(self.loginTitleLabel.mas_bottom).mas_offset(16);
        }];
        
        [self.view addSubview:self.switchCompanyBtn];
        [self.switchCompanyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.companyShowLabel.mas_right).mas_offset(5);
            make.width.mas_equalTo(12);
            make.height.mas_equalTo(12);
            make.centerY.mas_equalTo(self.companyShowLabel.mas_centerY);
        }];
        
        [self.view addSubview:self.userNameTextField];
        [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.companyShowLabel.mas_bottom).offset(50);
            make.left.mas_offset(33);
            make.right.mas_offset(-33);
            make.height.mas_equalTo(35);
        }];
        [self.view addSubview:self.userNameLineView];
        [self.userNameLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userNameTextField.mas_bottom).mas_offset(5);
            make.left.mas_equalTo(self.userNameTextField.mas_left);
            make.right.mas_equalTo(self.userNameTextField.mas_right);
            make.height.mas_equalTo(1);
        }];
        [self updateLoginUI];
    } else {
        
        //第一次登录，展示公司TextField，不展示切换公司按钮
        [self.view addSubview:self.userNameTextField];
        [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_loginTitleLabel.mas_bottom).offset(50);
            make.left.mas_offset(33);
            make.right.mas_offset(-33);
            make.height.mas_equalTo(35);
        }];
        [self.view addSubview:self.userNameLineView];
        [self.userNameLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userNameTextField.mas_bottom).mas_offset(5);
            make.left.mas_equalTo(self.userNameTextField.mas_left);
            make.right.mas_equalTo(self.userNameTextField.mas_right);
            make.height.mas_equalTo(1);
        }];
    }

    
    
    [self.view addSubview:self.userPwdTextField];
    [self.userPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userNameLineView.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(self.userNameLineView.mas_left);
        make.right.mas_equalTo(self.userNameLineView.mas_right);
        make.height.mas_equalTo(35);
    }];
    [self.view addSubview:self.userPwdLineView];
    [self.userPwdLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userPwdTextField.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(self.userPwdTextField.mas_left);
        make.right.mas_equalTo(self.userPwdTextField.mas_right);
        make.height.mas_equalTo(1);
    }];
    
    if (self.multipleLogin) {
        
        [self.view addSubview:self.forgotBtn];
        [self.forgotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userPwdLineView.mas_bottom).mas_offset(31);
            make.right.mas_equalTo(self.userPwdLineView.mas_right);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(80);
        }];
        
        
        [self.view addSubview:self.checkBtn];
        [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userPwdLineView.mas_bottom).mas_offset(31);
            make.left.mas_equalTo(self.userPwdTextField.mas_left);
            make.height.mas_equalTo(17);
            make.width.mas_equalTo(17);
        }];
        
    } else {
        
        [self.view addSubview:self.companyTextField];
        [self.companyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userPwdLineView.mas_bottom).mas_offset(30);
            make.left.mas_equalTo(self.userPwdLineView.mas_left);
            make.right.mas_equalTo(self.userPwdLineView.mas_right);
            make.height.mas_equalTo(35);
        }];
        [self.view addSubview:self.companyLineView];
        [self.companyLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.companyTextField.mas_bottom).mas_offset(5);
            make.left.mas_equalTo(self.companyTextField.mas_left);
            make.right.mas_equalTo(self.companyTextField.mas_right);
            make.height.mas_equalTo(1);
        }];
        
        [self.view addSubview:self.forgotBtn];
        [self.forgotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.companyLineView.mas_bottom).mas_offset(31);
            make.right.mas_equalTo(self.companyLineView.mas_right);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(80);
        }];
        
        
        [self.view addSubview:self.checkBtn];
        [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.companyLineView.mas_bottom).mas_offset(31);
            make.left.mas_equalTo(self.companyTextField.mas_left);
            make.height.mas_equalTo(17);
            make.width.mas_equalTo(17);
        }];
    }
    
    
    [self.view addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.checkBtn.mas_right).mas_offset(8);
        make.right.mas_equalTo(self.forgotBtn.mas_left).mas_offset(8);
        make.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.forgotBtn.mas_centerY);
    }];
    
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.forgotBtn.mas_bottom).mas_offset(44);
        make.left.mas_offset(40);
        make.right.mas_offset(-40);
        make.height.mas_equalTo(48);
    }];
    
    [self.view addSubview:self.settingBtn];
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-30);
        make.height.mas_equalTo(24);
    }];
}

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGRect kbFrame1 = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    CGFloat kbFrameOriginY = CGRectGetMinY(kbFrame1);
    self.keyboardOriginY = kbFrameOriginY;
}

#pragma mark - Action

- (void)registerNew:(id)sender {
    [QIMFastEntrance openWebViewForUrl:@"http://im.qunar.com/new/#/register" showNavBar:YES];
}

- (void)forgotPWD:(id)sender {

    [QIMFastEntrance openWebViewForUrl:[[QIMKit sharedInstance] qimNav_resetPwdUrl] showNavBar:NO];
}

- (void)agreementBtnHandle:(UIButton *)sender {
    QIMAgreementViewController * agreementVC = [[QIMAgreementViewController alloc] init];
    QIMNavController * nav = [[QIMNavController alloc]initWithRootViewController:agreementVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)autoLogin {
    // 增加 appstore 验证通过能力
    // 修正偶尔无法登录的问题
    NSString *lastUserName = [QIMKit getLastUserName];
    _userNameTextField.text = lastUserName;
    _userPwdTextField.text = @"......";
    
    if ([[lastUserName lowercaseString] isEqualToString:@"appstore"]) {
        NSDictionary *testQTalkNav = @{QIMNavNameKey:@"Startalk", QIMNavUrlKey:@"https://qt.qunar.com/package/static/qtalk/nav"};
        [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithNavDict:testQTalkNav WithUserName:lastUserName Check:YES WithForcedUpdate:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] setUserObject:@"appstore" forKey:@"kTempUserToken"];
            [[QIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:lastUserName];
        });
    } else {
        NSString *token = [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:token];
        });
    }
}

- (void)clickLogin:(id)sender {
    
    if (self.checkBtn.selected == NO) {
        __weak __typeof(self) weakSelf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择同意Startalk服务条款后登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSString *userName = [[self.userNameTextField text] lowercaseString];
        userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *validCode = self.userPwdTextField.text;
#warning 报错即将登陆的用户名 并请求导航
        [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:@"登录中..."];
        [[QIMKit sharedInstance] setUserObject:userName forKey:@"currentLoginUserName"];
        if ([[userName lowercaseString] isEqualToString:@"appstore"]) {
            NSDictionary *testQTalkNav = @{QIMNavNameKey:@"Startalk", QIMNavUrlKey:@"https://qt.qunar.com/package/static/qtalk/nav"};
            [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithNavDict:testQTalkNav WithUserName:userName Check:YES WithForcedUpdate:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[QIMKit sharedInstance] loginWithUserName:userName WithPassWord:userName];
            });
        } else {
            NSDictionary *publicQTalkNav = @{QIMNavNameKey:(self.companyModel.name.length > 0) ? self.companyModel.name : self.companyModel.domain, QIMNavUrlKey:self.companyModel.nav};
            [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithNavDict:publicQTalkNav WithUserName:userName Check:YES WithForcedUpdate:YES];
            __weak id weakSelf = self;
            NSString *pwd = self.userPwdTextField.text;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[QIMKit sharedInstance] setUserObject:pwd forKey:@"kTempUserToken"];
                [[QIMKit sharedInstance] loginWithUserName:userName WithPassWord:pwd];
            });
        }
    }
}

- (void)agreeBtnHandle:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)onSettingClick:(UIButton *)sender{
    QIMNavConfigManagerVC *navURLsSettingVc = [[QIMNavConfigManagerVC alloc] init];
    QIMNavController *navURLsSettingNav = [[QIMNavController alloc] initWithRootViewController:navURLsSettingVc];
    [self presentViewController:navURLsSettingNav animated:YES completion:nil];
}

- (void)gotoSelectCompany:(UITapGestureRecognizer *)tap {
    QIMSelectComponyViewController *companyVC = [[QIMSelectComponyViewController alloc] init];
    __weak __typeof(self) weakSelf = self;
    [companyVC setCompanyBlock:^(QIMPublicCompanyModel * _Nonnull companyModel) {
        weakSelf.companyModel = companyModel;
        NSString *companyName = companyModel.name;
        QIMVerboseLog(@"companyName : %@", companyName);
        if (companyName.length > 0) {
            [self.companyTextField setText:companyName];
            [self.companyShowLabel setText:companyName];
        } else {
            NSString *companyDomain = companyModel.domain;
            [self.companyTextField setText:companyDomain];
            [self.companyShowLabel setText:companyDomain];
        }
        [self updateLoginUI];
    }];
    [self.navigationController pushViewController:companyVC animated:YES];
}

#pragma mark - NSNotification

- (void)loginNotify:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[QIMProgressHUD sharedInstance] closeHUD];
        if ([notify.object boolValue]) {

            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [[QIMKit sharedInstance] setUserObject:[infoDictionary objectForKey:@"CFBundleVersion"] forKey:@"QTalkApplicationLastVersion"];
            [QIMFastEntrance showMainVc];
        } else {
            __weak __typeof(self) weakSelf = self;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录失败" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

- (void)streamEnd:(NSNotification *)notify {
    [[QIMProgressHUD sharedInstance] closeHUD];
}

- (void)reloadNavDicts:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupUI];
    });
}

@end

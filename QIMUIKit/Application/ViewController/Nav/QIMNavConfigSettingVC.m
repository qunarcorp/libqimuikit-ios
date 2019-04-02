//
//  QIMNavConfigSettingVC.m
//  qunarChatIphone
//
//  Created by admin on 16/3/29.
//
//

#import "QIMNavConfigSettingVC.h"
#import "QIMZBarViewController.h"
#import "MBProgressHUD.h"

@interface QIMNavConfigSettingVC()<UIAlertViewDelegate>{
    UILabel *_navNickNameLable;
    UILabel *_navAddressLabel;
    UITextField *_navNickNameTextField;
    UITextField *_navAddressTextField;
    UIButton *_qrcodeNavBtn;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *navConfigUrls;
@property (nonatomic, strong) NSDictionary *navDict;
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, copy) NSString *navUrl;
@property (nonatomic, assign) BOOL edited;
@property (nonatomic, assign) BOOL added;
@end

@implementation QIMNavConfigSettingVC

- (NSMutableArray *)navConfigUrls {
    if (!_navConfigUrls) {
        _navConfigUrls = [[QIMKit sharedInstance] qimNav_localNavConfigs];  
    }
    return _navConfigUrls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupUI];
}

- (void)setAddedNavDict:(NSDictionary *)navDict {
    self.navDict = navDict;
    self.navTitle = [navDict objectForKey:QIMNavNameKey];
    self.navUrl = [navDict objectForKey:QIMNavUrlKey];
    self.added = YES;
}

- (void)setEditedNavDict:(NSDictionary *)navDict {
    self.navDict = navDict;
    self.navTitle = [navDict objectForKey:QIMNavNameKey];
    self.navUrl = [navDict objectForKey:QIMNavUrlKey];
    self.edited = YES;
}

- (void)setupUI {
    _navNickNameLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, self.view.width - 40, 20)];
    [_navNickNameLable setText:@"导航名"];
    [_navNickNameLable setBackgroundColor:[UIColor clearColor]];
    [_navNickNameLable setFont:[UIFont systemFontOfSize:16]];
    [_navNickNameLable setTextColor:[UIColor blackColor]];
    [_navNickNameLable setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:_navNickNameLable];
    
    UIView *navNickNameTextBgView = [[UIView alloc] initWithFrame:CGRectMake(_navNickNameLable.left, _navNickNameLable.bottom + 10, _navNickNameLable.width, 36)];
    navNickNameTextBgView.layer.borderWidth = 1.0f;
    navNickNameTextBgView.layer.borderColor = [UIColor qim_colorWithHex:0xDDDDDD].CGColor;
    
    _navNickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, _navNickNameLable.width - 10, 36)];
    [_navNickNameTextField setBackgroundColor:[UIColor clearColor]];
    [_navNickNameTextField setFont:[UIFont systemFontOfSize:14]];
    [_navNickNameTextField setTextColor:[UIColor blackColor]];
    [_navNickNameTextField setPlaceholder:@"请输入导航服务器名称或公司名"];
    if (self.navTitle.length > 0) {
        [_navNickNameTextField setText:self.navTitle];
    }
    [self.view addSubview:navNickNameTextBgView];
    [navNickNameTextBgView addSubview:_navNickNameTextField];
    [_navNickNameTextField becomeFirstResponder];
    
    _navAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(navNickNameTextBgView.left, navNickNameTextBgView.bottom+30, navNickNameTextBgView.width, 20)];
    [_navAddressLabel setBackgroundColor:[UIColor clearColor]];
    [_navAddressLabel setFont:[UIFont systemFontOfSize:16]];
    [_navAddressLabel setTextColor:[UIColor blackColor]];
    [_navAddressLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:_navAddressLabel];
    [_navAddressLabel setText:@"域名/服务器地址（必填）"];
    
    UIView *navAddressTextBgView = [[UIView alloc] initWithFrame:CGRectMake(_navAddressLabel.left, _navAddressLabel.bottom + 10, _navAddressLabel.width, 36)];
    navAddressTextBgView.layer.borderWidth = 1.0f;
    navAddressTextBgView.layer.borderColor = [UIColor qim_colorWithHex:0xDDDDDD].CGColor;
    
    _navAddressTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, _navAddressLabel.width - 55, 36)];
    [_navAddressTextField setBackgroundColor:[UIColor clearColor]];

    [_navAddressTextField setFont:[UIFont systemFontOfSize:14]];
    [_navAddressTextField setTextColor:[UIColor qtalkTextBlackColor]];
    [_navAddressTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    if (self.navUrl) {
        [_navAddressTextField setText:self.navUrl];
    } else {
        [_navAddressTextField setPlaceholder:@"请输入您的公司域名，如qunar.com"];
    }
    [navAddressTextBgView addSubview:_navAddressTextField];
    
    _qrcodeNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _qrcodeNavBtn.frame = CGRectMake(_navAddressTextField.right + 5, 0, 36, 36);
    _qrcodeNavBtn.layer.masksToBounds = YES;
    _qrcodeNavBtn.layer.cornerRadius = CGRectGetWidth(_qrcodeNavBtn.frame) / 2.0;
    [_qrcodeNavBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
    [_qrcodeNavBtn addTarget:self action:@selector(scanNav:) forControlEvents:UIControlEventTouchUpInside];
    [navAddressTextBgView addSubview:_qrcodeNavBtn];
    [self.view addSubview:navAddressTextBgView];
}

- (void)scanNav:(id)sender {
    __weak typeof(self) weakSelf = self;
    QIMZBarViewController *vc=[[QIMZBarViewController alloc] initWithBlock:^(NSString *str, BOOL isScceed) {
        if (isScceed) {
            QIMVerboseLog(@"str : %@", str);
            if ([str containsString:@"publicnav?c="]) {
                str = [[str componentsSeparatedByString:@"publicnav?c="] lastObject];
                weakSelf.navUrl = str;
            } else if ([str containsString:@"confignavigation?configurl="]) {
                NSString *base64NavUrl = [[str componentsSeparatedByString:@"confignavigation?configurl="] lastObject];
                str = [base64NavUrl qim_base64DecodedString];
                weakSelf.navUrl = str;
            } else {
                weakSelf.navUrl = str;
            }
            _navAddressTextField.text = str;
            if (!_navNickNameTextField.text.length) {
                _navNickNameTextField.text = [[str.lastPathComponent componentsSeparatedByString:@"="] lastObject];
            }
        }
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setupNav {
    
    self.title = self.navTitle.length > 0 ? self.navTitle : @"新增导航";
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    [self.navigationItem setLeftBarButtonItem:cancelItem];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    [self.navigationItem setRightBarButtonItem:saveItem];
}

- (void)onCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSave{
    NSString *navHttpName = _navNickNameTextField.text;
    self.navUrl = _navAddressTextField.text;
    if (self.navUrl.length > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __block NSDictionary *userWillsaveNavDict = @{QIMNavNameKey:(navHttpName.length > 0) ? navHttpName : [[self.navUrl.lastPathComponent componentsSeparatedByString:@"="] lastObject], QIMNavUrlKey:self.navUrl};
        [[QIMKit sharedInstance] setUserObject:userWillsaveNavDict forKey:@"QC_UserWillSaveNavDict"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL success = [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [[QIMKit sharedInstance] setUserObject:userWillsaveNavDict forKey:@"QC_CurrentNavDict"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NavConfigSettingChanged object:userWillsaveNavDict];
                    });
                    [self onCancel];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                        message:@"无可用的导航信息"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
            });
        });
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"请输入可用的导航地址"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end

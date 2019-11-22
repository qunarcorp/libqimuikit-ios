//
//  QIMLoginVC.m
//  qunarChatIphone
//
//  Created by chenjie on 16/8/1.
//
//

#define kSelfViewBGColorHex     0x111720
#define kLoginViewBGColorHex    0xffffff
#define kPlaceholderColorHex    0xb0b0b0
#define kSepLineColorHex        0xdddddd
#define kHighlightedColorHex    0x00CABE
#define kNomalInputColorHex    0x3d3d3d

#define kLoginViewSpaceToSide   ([UIScreen mainScreen].bounds.size.width / 16)
#define kLoginViewSpaceToTop    ([UIScreen mainScreen].bounds.size.height / 4)
#define kLoginViewHeight        ([UIScreen mainScreen].bounds.size.height * 3 / 5)
#define kInputViewSpaceToSide   30
#define kPlaceholderHeight      25
#define kInputViewHeight        30
#define kValidCodeBtnNomalWidth      120
#define kValidCodeBtnWaitingWidth      50
#define kValidCodeDisplayString      [NSBundle qim_localizedStringForKey:@"login_get_code"]
#define kValidCodeSendingString      [NSBundle qim_localizedStringForKey:@"login_sending"]

#define kPlaceholderFontSize   14
#define kNomalFontSize         17

#import "QIMLoginVC.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMUUIDTools.h"
#import "QIMActivityIndicatorView.h"
#import <CoreText/CoreText.h>
#import "QIMAgreementViewController.h"
#import "QIMNavConfigSettingVC.h"
#import "QIMNavConfigManagerVC.h"
#import "QIMRemoteNotificationManager.h"
#import "MBProgressHUD.h"


@interface QIMLoginVC () <UITextFieldDelegate,UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource> {
    UIView          * _loginBgView;
    UIView          * _signView;
    
    UILabel         * _userNamePlaceholder;
    UITextField     * _userNameInputView;
    UIButton        * _userNameDropBtn;
    UIView          * _userNameSepline;
    UITableView     * _accountTableView;
    
    UILabel         * _validCodePlaceholder;
    UITextField     * _validCodeInputView;
    UIView          * _validCodeSepline;
    
    UIView          * _highlightedSepline;
    
    UILabel         * _getValidCodeBtn;
    
    UILabel         * _commitBtn;
    
    UIButton        * _agreeBtn;
    
    UIButton        * _settingBtn;
    
    QIMActivityIndicatorView     * _indicatorView;
    
    int               _waiting;
    
    CABasicAnimation        * _writingStrokeStartAnimation;
    CABasicAnimation        * _writingStrokeEndAnimation;
    CAShapeLayer            * _writingLayer;
    CAGradientLayer         * _gradLayer;
}

@property (nonatomic, assign) BOOL isQuit;  //判断是否退出

@property (nonatomic, assign) QTLoginType loginType;
@property (nonatomic, strong) NSMutableArray *loginUsers;

@end

@implementation QIMLoginVC

- (NSMutableArray *)loginUsers {
    if (!_loginUsers) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[QIMKit sharedInstance] userObjectForKey:@"Users"]];
        NSArray *localLoginUsers = [NSArray arrayWithArray:[dict allValues]];
        _loginUsers = [NSMutableArray arrayWithArray:localLoginUsers];
    }
    return _loginUsers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLoginType];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotify:) name:kNotificationLoginState object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [self initUI];
    NSString *userToken = [[QIMKit sharedInstance] getLastUserToken];
//    [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
    NSString *lastUserName = [QIMKit getLastUserName];
    if (userToken && lastUserName) {
        
        [self autoLogin];
        
    } else if (lastUserName && !userToken) {
        //如果本地还有用户名，自动输入
        _userNameInputView.text = lastUserName;
        [self becomeFirstResponderForView:_userNameInputView];
        [self setValidCodeBtnEnabled:YES];
    } else {
        [self quit];
    }
}

- (void)autoLogin {
    // 增加 appstore 验证通过能力
    // 修正偶尔无法登录的问题
    NSString *lastUserName = [QIMKit getLastUserName];
    _userNameInputView.text = lastUserName;
    _validCodeInputView.text = @"......";
    [self resetAutoUIFrame];
//    [self startLoginAnimation];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([[lastUserName lowercaseString] isEqualToString:@"appstore"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:lastUserName];
        });
    } else {
        NSString *token = [[QIMKit sharedInstance] getLastUserToken];
//        [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
        if ([lastUserName isEqualToString:@"appstore"]) {
            [[QIMKit sharedInstance] updateLastTempUserToken:@"appstore"];
//            [[QIMKit sharedInstance] setUserObject:@"appstore" forKey:@"kTempUserToken"];
            [[QIMKit sharedInstance] loginWithUserName:@"appstore" WithPassWord:@"appstore"];
        } else if ([[lastUserName lowercaseString] isEqualToString:@"qtalktest"]) {
            [[QIMKit sharedInstance] updateLastTempUserToken:@"qtalktest123"];
//            [[QIMKit sharedInstance] setUserObject:@"qtalktest123" forKey:@"kTempUserToken"];
            [[QIMKit sharedInstance] loginWithUserName:@"qtalktest" WithPassWord:@"qtalktest123"];
        } else {
            if ([lastUserName length] > 0 && [token length] > 0 && self.loginType == QTLoginTypeSms) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *pwd = [NSString stringWithFormat:@"%@@%@",[QIMUUIDTools deviceUUID],token];
                    [[QIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:pwd];
                });
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[QIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:token];
                });
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self loadLoginType];
}

- (void)loadLoginType {
    self.loginType = [[QIMKit sharedInstance] qimNav_LoginType];
    [self initUI];
}

//设置退出
-(void)quit
{
    self.isQuit = YES;
}

#pragma mark - initUI

- (void)resetAutoUIFrame {
    [self userNamePlaceholder].frame = CGRectMake([self userNameInputView].left, [self userNameInputView].top - kPlaceholderHeight, [self userNameInputView].width, kPlaceholderHeight);
    [self userNamePlaceholder].font = [UIFont systemFontOfSize:kPlaceholderFontSize];
    
    [self validCodePlaceholder].frame = CGRectMake([self validCodeInputView].left, [self validCodeInputView].top - kPlaceholderHeight, [self validCodeInputView].width, kPlaceholderHeight);
    [self validCodePlaceholder].font = [UIFont systemFontOfSize:kPlaceholderFontSize];
}

- (void)resetFailedUI {
    _validCodeInputView.text = @"";
    _validCodePlaceholder.frame = _validCodeInputView.frame;
    _validCodePlaceholder.font = [UIFont systemFontOfSize:kNomalFontSize];
    [self setValidCodeBtnEnabled:_userNameInputView.text.length];
}

- (void)initUI {
    [self loginBgView];
    [self signView];
    [self userNameInputView];
    [self userNamePlaceholder];
    [self validCodeInputView];
    [self validCodePlaceholder];
    [self commitBtn];
    [self getValidCodeBtn];
    
    [self setLoginBtnEnabled:NO];
    
//    [self initWritingAnimations];
    
    [self agreeBtn];
    [self settingBtn];
    

}


- (UIView *)loginBgView {
    if (_loginBgView == nil) {
        _loginBgView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _loginBgView.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF alpha:1.0];
        [self.view addSubview:_loginBgView];
    }
    return _loginBgView;
}

- (UIView *)signView {
    if (_signView == nil) {
        _signView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH , 200)];
        _signView.backgroundColor = [UIColor whiteColor];

        [[self loginBgView] addSubview:_signView];
        
        
        UIImageView * iConImg = [[UIImageView alloc]initWithImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"loginPageLogo"]];
        [iConImg setFrame:CGRectMake((SCREEN_WIDTH - iConImg.image.size.width)/2, 101, iConImg.image.size.width, iConImg.image.size.height)];
        
        [_signView addSubview:iConImg];
    }
    return _signView;
}

- (UIView *)userNameSepline {
    if (_userNameSepline == nil) {
        _userNameSepline = [[UIView alloc] initWithFrame:CGRectMake(kInputViewSpaceToSide, [self signView].bottom + kPlaceholderHeight + kInputViewHeight + 10, _loginBgView.width - kInputViewSpaceToSide * 2, 1)];
        _userNameSepline.backgroundColor = [UIColor qim_colorWithHex:kSepLineColorHex alpha:1.0];
        _userNameSepline.layer.cornerRadius = 0.5;
        [_loginBgView addSubview:_userNameSepline];
    }
    return _userNameSepline;
}

- (UILabel *)userNamePlaceholder {
    if (_userNamePlaceholder == nil) {
        _userNamePlaceholder = [[UILabel alloc] initWithFrame:CGRectMake([self userNameSepline].left, [self userNameSepline].top - kInputViewHeight, [self userNameSepline].width, kInputViewHeight)];
        _userNamePlaceholder.backgroundColor = [UIColor clearColor];
        _userNamePlaceholder.textColor = [UIColor qim_colorWithHex:kPlaceholderColorHex alpha:1.0];
        _userNamePlaceholder.font = [UIFont systemFontOfSize:kNomalFontSize];
        _userNamePlaceholder.text = [NSBundle qim_localizedStringForKey:@"Login_name"];
        [_loginBgView addSubview:_userNamePlaceholder];
    }
    return _userNamePlaceholder;
}

- (UITextField *)userNameInputView {
    if (_userNameInputView == nil) {
        
        if (self.loginUsers.count > 0) {
            _userNameInputView = [[UITextField alloc] initWithFrame:CGRectMake([self userNameSepline].left, [self userNameSepline].top - kInputViewHeight, [self userNameSepline].width, kInputViewHeight)];
            /*
            _userNameDropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _userNameDropBtn.frame = CGRectMake(_userNameInputView.right + 10, _userNameInputView.top, kInputViewHeight-5, kInputViewHeight);
            [_userNameDropBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"chat_bottom_arrowdown_nor"] forState:UIControlStateNormal];
            [_userNameDropBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"chat_bottom_arrowup_nor"] forState:UIControlStateSelected];
            [_userNameDropBtn addTarget:self action:@selector(dropLoginUserTableView:) forControlEvents:UIControlEventTouchUpInside];
             */
        } else {
            _userNameInputView = [[UITextField alloc] initWithFrame:CGRectMake([self userNameSepline].left, [self userNameSepline].top - kInputViewHeight, [self userNameSepline].width, kInputViewHeight)];
        }
        _userNameInputView.backgroundColor = [UIColor clearColor];
        _userNameInputView.textColor = [UIColor qim_colorWithHex:kNomalInputColorHex alpha:1.0];
        _userNameInputView.font = [UIFont systemFontOfSize:kNomalFontSize];
        _userNameInputView.delegate = self;
        _userNameInputView.tintColor = [UIColor qim_colorWithHex:kHighlightedColorHex alpha:1.0];
        _userNameInputView.autocorrectionType = UITextAutocorrectionTypeNo;
        _userNameInputView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userNameInputView.returnKeyType = UIReturnKeyNext;
        [_loginBgView addSubview:_userNameInputView];
//        [_loginBgView addSubview:_userNameDropBtn];
    }
    return _userNameInputView;
}

- (UITableView *)accountTableView {
    if (_accountTableView == nil) {
        _accountTableView = [[UITableView alloc] initWithFrame:CGRectMake(_userNameInputView.left, _userNameSepline.bottom, _userNameSepline.width, _agreeBtn.top - _userNameSepline.bottom) style:UITableViewStylePlain];
        _getValidCodeBtn.backgroundColor = [UIColor clearColor];
        _accountTableView.hidden = YES;
        _accountTableView.delegate = self;
        _accountTableView.dataSource = self;
        _accountTableView.tableFooterView = [UIView new];
        if ([_accountTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_accountTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_accountTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_accountTableView setLayoutMargins:UIEdgeInsetsZero];
        }
//        [_loginBgView addSubview:_accountTableView];
    }
    return _accountTableView;
}

- (UIView *)validCodeSepline {
    if (_validCodeSepline == nil) {
        _validCodeSepline = [[UIView alloc] initWithFrame:CGRectMake(kInputViewSpaceToSide, [self userNameSepline].bottom + kPlaceholderHeight + kInputViewHeight + 10, _loginBgView.width - kInputViewSpaceToSide * 2, 1)];
        _validCodeSepline.backgroundColor = [UIColor qim_colorWithHex:kSepLineColorHex alpha:1.0];
        _validCodeSepline.layer.cornerRadius = 0.5;
        [_loginBgView addSubview:_validCodeSepline];
    }
    return _validCodeSepline;
}

- (UILabel *)validCodePlaceholder {
    if (_validCodePlaceholder == nil) {
        _validCodePlaceholder = [[UILabel alloc] initWithFrame:CGRectMake([self validCodeSepline].left, [self validCodeSepline].top - kInputViewHeight, [self validCodeSepline].width, kInputViewHeight)];
        _validCodePlaceholder.backgroundColor = [UIColor clearColor];
        _validCodePlaceholder.textColor = [UIColor qim_colorWithHex:kPlaceholderColorHex alpha:1.0];
        _validCodePlaceholder.font = [UIFont systemFontOfSize:kNomalFontSize];
        [_loginBgView addSubview:_validCodePlaceholder];
    }
    if (self.loginType == QTLoginTypePwd || self.loginType == QTLoginTypeNewPwd) {
        _validCodePlaceholder.text = [NSBundle qim_localizedStringForKey:@"Login_password"];
    } else {
        _validCodePlaceholder.text = [NSBundle qim_localizedStringForKey:@"login_code"];
    }
    return _validCodePlaceholder;
}

- (UITextField *)validCodeInputView {
    if (_validCodeInputView == nil) {
        _validCodeInputView = [[UITextField alloc] initWithFrame:CGRectMake([self validCodeSepline].left, [self validCodeSepline].top - kInputViewHeight, [self validCodeSepline].width - kValidCodeBtnNomalWidth, kInputViewHeight)];
        _validCodeInputView.backgroundColor = [UIColor clearColor];
        _validCodeInputView.textColor = [UIColor qim_colorWithHex:kNomalInputColorHex alpha:1.0];
        _validCodeInputView.font = [UIFont systemFontOfSize:kNomalFontSize];
        _validCodeInputView.delegate = self;
        _validCodeInputView.tintColor = [UIColor qim_colorWithHex:kHighlightedColorHex alpha:1.0];
        _validCodeInputView.autocorrectionType = UITextAutocorrectionTypeNo;
        _validCodeInputView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _validCodeInputView.keyboardType = UIKeyboardTypeNumberPad;
        _validCodeInputView.returnKeyType = UIReturnKeyGo;
        [_loginBgView addSubview:_validCodeInputView];
    }
    if (self.loginType == QTLoginTypePwd || self.loginType == QTLoginTypeNewPwd) {
        _validCodeInputView.frame = CGRectMake([self validCodeSepline].left, [self validCodeSepline].top - kInputViewHeight, [self userNameSepline].width, kInputViewHeight);
        _validCodeInputView.keyboardType = UIKeyboardTypeASCIICapable;
        _validCodeInputView.secureTextEntry = YES;
    } else {
        _validCodeInputView.frame = CGRectMake([self validCodeSepline].left, [self validCodeSepline].top - kInputViewHeight, [self validCodeSepline].width - kValidCodeBtnNomalWidth, kInputViewHeight);
        _validCodeInputView.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _validCodeInputView ;
}

- (UILabel *)commitBtn {
    if (_commitBtn == nil) {
        _commitBtn = [[UILabel alloc] initWithFrame:CGRectMake(40, [self validCodeSepline].bottom + 50, SCREEN_WIDTH - 80, 48)];
        _commitBtn.backgroundColor = [UIColor qim_colorWithHex:0xABE9E5];
        _commitBtn.layer.cornerRadius = 24;
        _commitBtn.clipsToBounds = YES;
        _commitBtn.textColor = [UIColor qim_colorWithHex:0xFFFFFF];
        _commitBtn.textAlignment = NSTextAlignmentCenter;
        _commitBtn.font = [UIFont boldSystemFontOfSize:17];
        _commitBtn.text = [NSBundle qim_localizedStringForKey:@"login"];
        [_loginBgView addSubview:_commitBtn];
        
        UITapGestureRecognizer * commitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commitTapHandle:)];
        [_commitBtn addGestureRecognizer:commitTap];
    }
    return _commitBtn;
}

- (UIView *)highlightedSepline {
    if (_highlightedSepline == nil) {
        _highlightedSepline = [[UIView alloc] initWithFrame:CGRectZero];
        _highlightedSepline.backgroundColor = [UIColor qim_colorWithHex:kHighlightedColorHex alpha:1.0];
    }
    return _highlightedSepline;
}

- (UILabel *)getValidCodeBtn {
    if (_getValidCodeBtn == nil) {
        _getValidCodeBtn = [[UILabel alloc] initWithFrame:CGRectMake([self validCodeSepline].right - kValidCodeBtnNomalWidth, [self validCodeSepline].top - kInputViewHeight + 0.5, kValidCodeBtnNomalWidth, kInputViewHeight)];
        _getValidCodeBtn.backgroundColor = [UIColor clearColor];
//        _getValidCodeBtn.layer.borderColor = [UIColor qim_colorWithHex:kHighlightedColorHex alpha:1.0].CGColor;
//        _getValidCodeBtn.layer.borderWidth = 0.5;
        _getValidCodeBtn.textColor = [UIColor colorWithRGBHex:0xBFBFBF];
        _getValidCodeBtn.textAlignment = NSTextAlignmentRight;
        _getValidCodeBtn.font = [UIFont boldSystemFontOfSize:kNomalFontSize];
        _getValidCodeBtn.text = kValidCodeDisplayString;
        
        UITapGestureRecognizer * getValidCodeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getValidCodeTapHandle:)];
        [_getValidCodeBtn addGestureRecognizer:getValidCodeTap];
    }
    if (self.loginType == QTLoginTypePwd || self.loginType == QTLoginTypeNewPwd) {
        [_getValidCodeBtn removeFromSuperview];
    } else {
        [_loginBgView insertSubview:_getValidCodeBtn belowSubview:[self validCodeSepline]];
        if (_userNameInputView.text.length > 0) {
            [self setValidCodeBtnEnabled:YES];
        } else {
            [self setValidCodeBtnEnabled:NO];
        }
    }
    return _getValidCodeBtn;
}

- (QIMActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[QIMActivityIndicatorView alloc] initWithTintColor:[UIColor whiteColor] size:[self commitBtn].height - 4];
        _indicatorView.frame = [self commitBtn].bounds;
        _indicatorView.backgroundColor = [UIColor qim_colorWithHex:kHighlightedColorHex alpha:1.0];
        [[self commitBtn] addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UIButton *)agreeBtn {
    if (_agreeBtn == nil) {
        _agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeBtn.frame = CGRectMake(([self loginBgView].width - 180) / 2, [self commitBtn].bottom + 30, 18, 18);
        [_agreeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:17 color:[UIColor qim_colorWithHex:0xE4E4E4]]] forState:UIControlStateNormal];
        [_agreeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:17 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
        _agreeBtn.selected = YES;
        [_agreeBtn addTarget:self action:@selector(agreeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [[self loginBgView] addSubview:_agreeBtn];
        
        NSString *login_agree = [NSBundle qim_localizedStringForKey:@"login_agree"];
        UIFont *login_agreeFont = [UIFont systemFontOfSize:14];
        // 根据字体得到NSString的尺寸
        CGSize login_agreeSize = [login_agree sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:login_agreeFont,NSFontAttributeName,nil]];

        UILabel * agreeLabel = [[UILabel  alloc] initWithFrame:CGRectMake(_agreeBtn.right + 5, _agreeBtn.top, login_agreeSize.width + 5, _agreeBtn.height)];
        agreeLabel.backgroundColor = [UIColor clearColor];
        agreeLabel.text = login_agree;
        agreeLabel.textColor = [UIColor qim_colorWithHex:0x999999];
        agreeLabel.font = [UIFont systemFontOfSize:14];
        [[self loginBgView] addSubview:agreeLabel];
        
        UIButton * agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        agreementBtn.frame = CGRectMake(agreeLabel.right, _agreeBtn.top, 160, _agreeBtn.height);
        [agreementBtn setTitle:[NSBundle qim_localizedStringForKey:@"login_privacy_policy"] forState:UIControlStateNormal];
        [agreementBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
        agreementBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        agreementBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [agreementBtn.titleLabel setFont:agreeLabel.font];
        [agreementBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
        [agreementBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateHighlighted];
        [agreementBtn addTarget:self action:@selector(agreementBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [[self loginBgView] addSubview:agreementBtn];
    }
    return _agreeBtn;
}

- (UIButton *)settingBtn {
    if (_settingBtn == nil) {
        
        _settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.height - 65 , self.view.width, 24)];
        [_settingBtn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_settingBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_settingBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_settingBtn setTitle:[NSBundle qim_localizedStringForKey:@"nav_Set_Service_Address"] forState:UIControlStateNormal];
        [_settingBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"iconSetting"] forState:UIControlStateNormal];
        [_settingBtn addTarget:self action:@selector(onSettingClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_settingBtn];
    }
    return _settingBtn;
}

#pragma mark - animation

- (void)becomeFirstResponderForView:(UITextField *)inputView {
    if (![inputView isFirstResponder]) {
//        [inputView becomeFirstResponder];
//        if (inputView.text.length == 0) {
            UILabel * placeholderView = _userNamePlaceholder;
            if (inputView == _validCodeInputView) {
                placeholderView = _validCodePlaceholder;
            }
            [UIView animateWithDuration:0.3 animations:^{
                placeholderView.frame = CGRectMake(inputView.left, inputView.top - kPlaceholderHeight, inputView.width, kPlaceholderHeight);
                placeholderView.font = [UIFont systemFontOfSize:kPlaceholderFontSize];
            } completion:^(BOOL finished) {
                if (inputView == _userNameInputView) {
                    inputView.placeholder = [NSBundle qim_localizedStringForKey:@"login_userNameInputView_placeholder"];
                }
            }];
//        }
        UIView * sepLine = _userNameSepline;
        if (inputView == _validCodeInputView) {
            sepLine = _validCodeSepline;
        }
        [self takeFocusOfView:sepLine];
    }
}

- (void)takeFocusOfView:(UIView *) view {
    
    [view addSubview:[self highlightedSepline]];
    [self highlightedSepline].hidden = NO;
    [self highlightedSepline].frame = CGRectMake(0, 0, 0, _validCodeSepline.height);
    [UIView animateWithDuration:0.5 animations:^{
        [self highlightedSepline].frame = CGRectMake(0, 0, _validCodeSepline.width, _validCodeSepline.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resignFirstResponderForView:(UITextField *)inputView {
    if ([inputView isFirstResponder]) {
//        [inputView resignFirstResponder];
        if (inputView.text.length == 0) {
            inputView.placeholder = nil;
            UILabel * placeholderView = _userNamePlaceholder;
            if (inputView == _validCodeInputView) {
                placeholderView = _validCodePlaceholder;
            }
            [UIView animateWithDuration:0.3 animations:^{
                placeholderView.frame = inputView.frame;
                placeholderView.font = [UIFont systemFontOfSize:kNomalFontSize];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)startLoginAnimation {
    [self indicatorView].frame = CGRectMake([self commitBtn].width / 2, [self commitBtn].height / 2, 0, 0);
    [UIView animateWithDuration:0.5 animations:^{
        [self indicatorView].frame = CGRectMake(0, - ([self commitBtn].width - [self commitBtn].height) / 2, [self commitBtn].width, [self commitBtn].width);
    } completion:^(BOOL finished) {
        
    }];
    [[self indicatorView] startAnimating];
    [self setUIEnabled:NO];
}

- (void)stopLoginAnimation {
    [UIView animateWithDuration:0.5 animations:^{
        [self indicatorView].frame = CGRectMake([self commitBtn].width / 2, [self commitBtn].height / 2, 0, 0);
    } completion:^(BOOL finished) {
        [[self indicatorView] stopAnimating];
    }];
    [self setUIEnabled:YES];
}

- (void)setUIEnabled:(BOOL)enabled {
    if (enabled) {
        self.view.userInteractionEnabled = YES;
    }else {
        self.view.userInteractionEnabled = NO;
    }
}

- (void)setValidCodeBtnUIWaiting:(BOOL)isWaiting {
    if (isWaiting) {
        [self getValidCodeBtn].frame = CGRectMake([self validCodeSepline].right - kValidCodeBtnWaitingWidth, [self validCodeSepline].top - kInputViewHeight + 0.5, kValidCodeBtnWaitingWidth, kInputViewHeight);
        [self validCodeInputView].frame = CGRectMake([self validCodeSepline].left, [self validCodeSepline].top - kInputViewHeight, [self validCodeSepline].width - [self getValidCodeBtn].width, kInputViewHeight);
    }else{
        [self getValidCodeBtn].frame = CGRectMake([self validCodeSepline].right - kValidCodeBtnNomalWidth, [self validCodeSepline].top - kInputViewHeight + 0.5, kValidCodeBtnNomalWidth, kInputViewHeight);
        [self validCodeInputView].frame = CGRectMake([self validCodeSepline].left, [self validCodeSepline].top - kInputViewHeight, [self validCodeSepline].width - [self getValidCodeBtn].width, kInputViewHeight);
    }
}

- (void)initWritingAnimations{
    if (_writingLayer == nil) {
        UIBezierPath *bezierPath = [self transformToBezierPath:[QIMKit getQIMProjectTitleName]];
       
        CGSize size= CGPathGetBoundingBox(bezierPath.CGPath).size;
        _writingLayer = [CAShapeLayer layer];
        _writingLayer.bounds = CGPathGetBoundingBox(bezierPath.CGPath);
        _writingLayer.position = CGPointMake(size.width/2, size.height/2);
        _writingLayer.geometryFlipped = YES;
        _writingLayer.path = bezierPath.CGPath;
        _writingLayer.fillColor = [UIColor clearColor].CGColor;
        _writingLayer.lineWidth = 1;
        _writingLayer.strokeColor = [UIColor qim_colorWithHex:0x11cd6e alpha:1.0].CGColor;
        
    }else{
        [_writingLayer removeAllAnimations];
    }
    if (_gradLayer == nil) {
        CGSize size = _writingLayer.bounds.size;
        _gradLayer = [CAGradientLayer layer];
        _gradLayer.frame = CGRectMake((self.view.width - size.width) / 2 - 5, kLoginViewSpaceToTop - 100, size.width + 10, size.height + 10);
        _gradLayer.colors = @[(__bridge id)[UIColor redColor].CGColor,(__bridge id)[UIColor orangeColor].CGColor,(__bridge id)[UIColor yellowColor].CGColor,(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor cyanColor].CGColor,(__bridge id)[UIColor blueColor].CGColor,(__bridge id)[UIColor purpleColor].CGColor];
        _gradLayer.startPoint = CGPointMake(0.7,0);//(x,y) 左上角（0，0）右下角（1，1）
        _gradLayer.endPoint = CGPointMake(0.3,1);
        
        //Using arc as a mask instead of adding it as a sublayer.
        //[self.view.layer addSublayer:arc];
        _gradLayer.mask = _writingLayer;
    }
    [self.view.layer addSublayer:_gradLayer];
    
    if (_writingStrokeEndAnimation == nil) {
        _writingStrokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _writingStrokeEndAnimation.fromValue = @(0);
        _writingStrokeEndAnimation.toValue = @(1);
        _writingStrokeEndAnimation.duration = _writingLayer.bounds.size.width/10;
    }
    if (_writingStrokeStartAnimation == nil) {
        _writingStrokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        _writingStrokeStartAnimation.fromValue = @(0);
        _writingStrokeStartAnimation.toValue = @(1);
        _writingStrokeStartAnimation.duration = _writingLayer.bounds.size.width/10;
    }
    [self startWritingLogoIsStart:@(NO)];
}

- (void)startWritingLogoIsStart:(NSNumber *)isStart {
    CABasicAnimation * animation = [isStart boolValue]? _writingStrokeStartAnimation : _writingStrokeEndAnimation;
    [self stopWritingLogo];
    [_writingLayer addAnimation:animation forKey:[isStart boolValue]?@"start":@"end"];
    [self performSelector:@selector(startWritingLogoIsStart:) withObject:@(NO) afterDelay:animation.duration + arc4random() % 10];
}

- (void)stopWritingLogo {
    [_writingLayer removeAllAnimations];
}

- (UIBezierPath *)transformToBezierPath:(NSString *)string
{
    CGMutablePathRef paths = CGPathCreateMutable();
    CFStringRef fontNameRef = CFSTR("Zapfino");
    CTFontRef fontRef = CTFontCreateWithName(fontNameRef, 35, nil);
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:@{(__bridge NSString *)kCTFontAttributeName: (__bridge UIFont *)fontRef}];
    CTLineRef lineRef = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArrRef = CTLineGetGlyphRuns(lineRef);
    for (int runIndex = 0; runIndex < CFArrayGetCount(runArrRef); runIndex++) {
        const void *run = CFArrayGetValueAtIndex(runArrRef, runIndex);
        CTRunRef runb = (CTRunRef)run;
        
        const void *CTFontName = kCTFontAttributeName;
        
        const void *runFontC = CFDictionaryGetValue(CTRunGetAttributes(runb), CTFontName);
        CTFontRef runFontS = (CTFontRef)runFontC;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        int temp = 0;
        CGFloat offset = .0;
        
        for (int i = 0; i < CTRunGetGlyphCount(runb); i++) {
            CFRange range = CFRangeMake(i, 1);
            CGGlyph glyph = 0;
            CTRunGetGlyphs(runb, range, &glyph);
            CGPoint position = CGPointZero;
            CTRunGetPositions(runb, range, &position);
            
            CGFloat temp3 = position.x;
            int temp2 = (int)temp3/width;
            CGFloat temp1 = 0;
            
            if (temp2 > temp1) {
                temp = temp2;
                offset = position.x - (CGFloat)temp;
            }
            
            CGPathRef path = CTFontCreatePathForGlyph(runFontS, glyph, nil);
            CGFloat x = position.x - (CGFloat)temp*width - offset;
            CGFloat y = position.y - (CGFloat)temp * 80;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
            CGPathAddPath(paths, &transform, path);
            
            CGPathRelease(path);
        }
        CFRelease(runb);
        CFRelease(runFontS);
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:paths]];
    
    CGPathRelease(paths);
    CFRelease(fontNameRef);
    CFRelease(fontRef);
    
    return bezierPath;
}

#pragma mark - action

- (void)dropLoginUserTableView:(id)sender {
    UIButton *dropAccountBtn = (UIButton *)sender;
    if (self.loginUsers.count > 0) {
        [self accountTableView];
    }
    if (!sender) {
        _userNameDropBtn.selected = NO;
        _accountTableView.hidden = YES;
    } else {
        _userNameDropBtn.selected = !dropAccountBtn.selected;
        _accountTableView.hidden = !dropAccountBtn.selected;
    }
}

- (void)setValidCodeBtnEnabled:(BOOL)enabled {
    _getValidCodeBtn.userInteractionEnabled = enabled;
    _getValidCodeBtn.layer.borderColor = enabled ? [UIColor qim_colorWithHex:kHighlightedColorHex alpha:1.0].CGColor : [UIColor qim_colorWithHex:kPlaceholderColorHex alpha:1.0].CGColor;
    _getValidCodeBtn.textColor = enabled ? [UIColor qim_colorWithHex:kHighlightedColorHex alpha:1.0] : [UIColor qim_colorWithHex:kPlaceholderColorHex alpha:1.0];
}

- (void)setLoginBtnEnabled:(BOOL)enabled {
    if ([self agreeBtn].selected == NO) {
        enabled = NO;
    }
    [self commitBtn].userInteractionEnabled = enabled;
    
    if (enabled == YES) {
        _commitBtn.backgroundColor = [UIColor colorWithRGBHex:0x00CABE];
    }
    else{
         _commitBtn.backgroundColor = [UIColor qim_colorWithHex:0xABE9E5];
    }
}

- (void)commitTapHandle:(UITapGestureRecognizer *)sender {

    if (!_userNameInputView.text.length) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"common_input_username"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_got_it"] otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (!_validCodeInputView.text.length) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"login_input_code"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_got_it"] otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }

    if (_agreeBtn.selected == NO) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请查看并同意\n《使用条款和隐私政策》" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
//    [self startLoginAnimation];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *userName = [[_userNameInputView text] lowercaseString];
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *validCode = _validCodeInputView.text;
#warning 报错即将登陆的用户名 并请求导航
    [[QIMKit sharedInstance] setUserObject:userName forKey:@"currentLoginUserName"];
    [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES withCallBack:^(BOOL success) {
        //获取导航成功
        if (success) {
            if ([userName isEqualToString:@"appstore"]) {
                [[QIMKit sharedInstance] updateLastTempUserToken:@"appstore"];
                //        [[QIMKit sharedInstance] setUserObject:@"appstore" forKey:@"kTempUserToken"];
                [[QIMKit sharedInstance] loginWithUserName:@"appstore" WithPassWord:@"appstore"];
            } else if ([[userName lowercaseString] isEqualToString:@"qtalktest"]) {
                [[QIMKit sharedInstance] updateLastTempUserToken:@"qtalktest123"];
                //        [[QIMKit sharedInstance] setUserObject:@"qtalktest123" forKey:@"kTempUserToken"];
                [[QIMKit sharedInstance] loginWithUserName:@"qtalktest" WithPassWord:@"qtalktest123"];
            } else {
                __weak id weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (self.loginType == QTLoginTypeSms) {
                        __block NSString *token = [[QIMKit sharedInstance] getLastUserToken];
                        //                [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
                        if (token.length <= 0) {
                            [[QIMKit sharedInstance] getUserTokenWithUserName:userName WithVerifyCode:validCode withCallback:^(NSDictionary *tokenDic) {
                                int statusId = (tokenDic && [[tokenDic allKeys] containsObject:@"status_id"]) ?
                                [[tokenDic objectForKey:@"status_id"] intValue] : -1;
                                
                                if (statusId == 0) {
                                    token = [[tokenDic objectForKey:@"data"] objectForKey:@"token"];
                                    [[QIMKit sharedInstance] updateLastTempUserToken:token];
                                    //                            [[QIMKit sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
                                    NSString *pwd = [NSString stringWithFormat:@"%@@%@",[QIMUUIDTools deviceUUID],token];
                                    [[QIMKit sharedInstance] loginWithUserName:userName WithPassWord:pwd];
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSString *error = [tokenDic objectForKey:@"msg"];
                                        if (error) {
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"]
                                                                                                message:error ? error : @"发生未知错误"
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_got_it"]
                                                                                      otherButtonTitles:nil];
                                            [alertView show];
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                            //                                [weakSelf stopLoginAnimation];
                                        } else {
                                            [weakSelf showNetWorkUnableAlert];
                                        }
                                    });
                                    return;
                                }
                            }];
                        } else {
                            [[QIMKit sharedInstance] updateLastTempUserToken:token];
                            //                    [[QIMKit sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
                            NSString *pwd = [NSString stringWithFormat:@"%@@%@",[QIMUUIDTools deviceUUID],token];
                            [[QIMKit sharedInstance] loginWithUserName:userName WithPassWord:pwd];
                        }
                    } else if (self.loginType ==  QTLoginTypeNewPwd) {
                        [[QIMKit sharedInstance] getNewUserTokenWithUserName:userName WithPassword:validCode withCallback:^(NSDictionary *result) {
                            if (result) {
                                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                                NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
                                if (ret && errcode == 0) {
                                    NSDictionary *data = [result objectForKey:@"data"];
                                    NSString *newUserName = [data objectForKey:@"u"];
                                    NSString *newToken = [data objectForKey:@"t"];
                                    if (newUserName.length && newToken.length) {
                                        [[QIMKit sharedInstance] updateLastTempUserToken:newToken];
                                        //                                [[QIMKit sharedInstance] setUserObject:newToken forKey:@"kTempUserToken"];
                                        [[QIMKit sharedInstance] loginWithUserName:newUserName WithPassWord:newToken];
                                    }
                                } else {
                                    NSString *errmsg = [result objectForKey:@"data"];
                                    if (!errmsg.length) {
                                        errmsg = @"验证失败";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:errmsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                        [alertView show];
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    });
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf showNetWorkUnableAlert];
                                });
                            }
                        }];
                    } else {
                        [[QIMKit sharedInstance] updateLastTempUserToken:validCode];
                        //                [[QIMKit sharedInstance] setUserObject:validCode forKey:@"kTempUserToken"];
                        [[QIMKit sharedInstance] loginWithUserName:userName WithPassWord:validCode];
                    }
                });
            }
        } else {
            
        }
    }];
}

- (void)showNetWorkUnableAlert {
    
    __weak id weakSelf = self;
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"network_unavailable_tip"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf stopLoginAnimation];
    }];
    UIAlertAction *helpAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"Help"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf stopLoginAnimation];
        NSString *netHelperPath = [[NSBundle mainBundle] pathForResource:@"NetWorkSetting" ofType:@"html"];
        NSString *netHelperString = [NSString stringWithContentsOfFile:netHelperPath encoding:NSUTF8StringEncoding error:nil];
        [QIMFastEntrance openWebViewWithHtmlStr:netHelperString showNavBar:YES];
    }];
    [alertVc addAction:okAction];
    [alertVc addAction:helpAction];
    [weakSelf presentViewController:alertVc animated:YES completion:nil];
}

//更新验证码读秒
- (void)updateIndentifyText{
    [_getValidCodeBtn setText:[NSString stringWithFormat:@"%d s",_waiting]];
    if (_waiting > 0) {
        [self setValidCodeBtnUIWaiting:YES];
        [_getValidCodeBtn setUserInteractionEnabled:NO];
        [self performSelector:@selector(updateIndentifyText) withObject:nil afterDelay:1];
    } else {
        [_getValidCodeBtn setUserInteractionEnabled:YES];
        [_getValidCodeBtn setText:kValidCodeDisplayString];
        [self setValidCodeBtnUIWaiting:NO];
    }
    _waiting--;
}

- (void)getValidCodeTapHandle:(UITapGestureRecognizer *)sender {
    if (_userNameInputView.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSBundle qim_localizedStringForKey:@"common_input_username"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_got_it"] otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [_getValidCodeBtn setUserInteractionEnabled:NO];
    [_getValidCodeBtn setText:kValidCodeSendingString];

    NSString *userName = [[_userNameInputView text] lowercaseString];
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    __weak id weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QIMKit sharedInstance] getVerifyCodeWithUserName:userName withCallback:^(NSDictionary *result) {
            if (!result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showNetWorkUnableAlert];
                    [_getValidCodeBtn setUserInteractionEnabled:YES];
                    [_getValidCodeBtn setText:kValidCodeDisplayString];
                    [self setValidCodeBtnUIWaiting:NO];
                });
            } else {
                int statusId = [[result allKeys] containsObject:@"status_id"] ? [[result objectForKey:@"status_id"] intValue] : -1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (statusId == 501 && [[userName lowercaseString] isEqualToString:@"appstore"]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"对不起,订单信息未找到,请直接输入6位密码登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                        [_getValidCodeBtn setUserInteractionEnabled:YES];
                        [_getValidCodeBtn setText:kValidCodeDisplayString];
                        [self setValidCodeBtnUIWaiting:NO];
                    } else if (statusId != 0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[result objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                        [_getValidCodeBtn setUserInteractionEnabled:YES];
                        [_getValidCodeBtn setText:kValidCodeDisplayString];
                        [self setValidCodeBtnUIWaiting:NO];
                    } else {
                        _waiting = 59;
                        [self performSelector:@selector(updateIndentifyText) withObject:nil afterDelay:1];
                        [[QIMKit sharedInstance] clearUserToken];
                    }
                });
            }
        }];
        /*
        NSDictionary *dic = [QIMKit getVerifyCodeWithUserName:userName];
        QIMVerboseLog(@"登录用户名：%@，验证Dict：%@", userName, dic);
        if (!dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//                                                                    message:@"发生未知错误"
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"确定"
//                                                          otherButtonTitles:nil];
//                [alertView show];
                [weakSelf showNetWorkUnableAlert];
                [_getValidCodeBtn setUserInteractionEnabled:YES];
                [_getValidCodeBtn setText:kValidCodeDisplayString];
                [self setValidCodeBtnUIWaiting:NO];
            });
        } else {
            int statusId = [[dic allKeys] containsObject:@"status_id"] ? [[dic objectForKey:@"status_id"] intValue] : -1;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (statusId == 501 && [[userName lowercaseString] isEqualToString:@"appstore"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"对不起,订单信息未找到,请直接输入6位密码登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    [_getValidCodeBtn setUserInteractionEnabled:YES];
                    [_getValidCodeBtn setText:kValidCodeDisplayString];
                    [self setValidCodeBtnUIWaiting:NO];
                } else if (statusId != 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    [_getValidCodeBtn setUserInteractionEnabled:YES];
                    [_getValidCodeBtn setText:kValidCodeDisplayString];
                    [self setValidCodeBtnUIWaiting:NO];
                } else {
                    _waiting = 59;
                    [self performSelector:@selector(updateIndentifyText) withObject:nil afterDelay:1];
                    [[QIMKit sharedInstance] removeUserObjectForKey:@"userToken"];
                    [[QIMKit sharedInstance] removeUserObjectForKey:@"kTempUserToken"];
                }
            });
        }
        */
    });
}

- (void)agreeBtnHandle:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ((self.loginType == QTLoginTypePwd || self.loginType == QTLoginTypeNewPwd) && _userNameInputView.text.length && _validCodeInputView.text.length > 0) {
        [self setLoginBtnEnabled:sender.selected];
    } else if (_userNameInputView.text.length && _validCodeInputView.text.length == 6) {
        [self setLoginBtnEnabled:sender.selected];
    }
    if (sender.selected == NO) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle qim_localizedStringForKey:@"Reminder"] message:@"亲，请查看并同意\n《使用条款和隐私政策》\n才可以登录哟～" delegate:self cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Confirm"] otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)agreementBtnHandle:(UIButton *)sender
{
    QIMAgreementViewController * agreementVC = [[QIMAgreementViewController alloc] init];
    QIMNavController * nav = [[QIMNavController alloc]initWithRootViewController:agreementVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onSettingClick:(UIButton *)sender{
    QIMNavConfigManagerVC *navURLsSettingVc = [[QIMNavConfigManagerVC alloc] init];
    QIMNavController *navURLsSettingNav = [[QIMNavController alloc] initWithRootViewController:navURLsSettingVc];
    [self presentViewController:navURLsSettingNav animated:YES completion:nil];
}

#pragma mark - NSNotification

- (void)loginNotify:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([notify.object boolValue]) {
            [self stopLoginAnimation];
            [self stopWritingLogo];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [[QIMKit sharedInstance] setUserObject:[infoDictionary objectForKey:@"CFBundleVersion"] forKey:@"QTalkApplicationLastVersion"];
            [QIMFastEntrance showMainVc];
            [QIMRemoteNotificationManager checkUpNotifacationHandle];
        } else {
            [self resetFailedUI];
            [self stopLoginAnimation];
            [self stopWritingLogo];
            __weak __typeof(self) weakSelf = self;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"login_faild"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf dropLoginUserTableView:nil];
                [weakSelf becomeFirstResponderForView:_validCodeInputView];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}


//- (void)keyboardWillShow:(NSNotification*)notification{
//    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//
//    [UIView animateWithDuration:0.5 animations:^{
//        float movHeight = keyboardRect.size.height - (self.view.height - _loginBgView.bottom);
//        movHeight = MAX(0, movHeight);
//        self.view.frame = CGRectMake(0, -movHeight, self.view.width, self.view.height);
//    }];
    
//}

//- (void)keyboardWillHide:(NSNotification*)notification{
//    [UIView animateWithDuration:0.5 animations:^{
//        self.view.frame = CGRectMake(0, 0, self.view.width, self.view.height);
//    }];
    
//}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _validCodeInputView) {
        if (_userNameInputView.text.length > 0) {
        }else{
            [self takeFocusOfView:_userNameSepline];
            return NO;
        }
    } else if (textField == _userNameInputView) {
        [self dropLoginUserTableView:nil];
    }
    [self becomeFirstResponderForView:textField];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self resignFirstResponderForView:textField];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _validCodeInputView) {
        if ((self.loginType == QTLoginTypePwd || self.loginType == QTLoginTypeNewPwd) && textField.text.length - range.length + string.length >= 1) {
            
            [self setLoginBtnEnabled:YES];
        } else if (textField.text.length - range.length + string.length == 6) {
            [self setLoginBtnEnabled:YES];
        }else {
            [self setLoginBtnEnabled:NO];
        }
    }else if (textField == _userNameInputView) {
        if (textField.text.length - range.length + string.length >= 1) {
            [self setValidCodeBtnEnabled:YES];
        }else{
            [self setValidCodeBtnEnabled:NO];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == _userNameInputView) {
        [self setValidCodeBtnEnabled:NO];
    }else if (textField == _validCodeInputView) {
        [self setLoginBtnEnabled:NO];
    }
    _commitBtn.backgroundColor = [UIColor qim_colorWithHex:0xABE9E5];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _userNameInputView) {
        [_validCodeInputView becomeFirstResponder];
    }else if (textField == _validCodeInputView) {
        if (_commitBtn.userInteractionEnabled) {
            [self commitTapHandle:nil];
        }
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self.view];
    if (CGRectContainsPoint(_loginBgView.frame, location)) {
        location = [touch locationInView:_loginBgView];
        if (CGRectContainsPoint(_userNameInputView.frame, location) || CGRectContainsPoint(_validCodeInputView.frame, location) || CGRectContainsPoint(_getValidCodeBtn.frame, location) || CGRectContainsPoint(_commitBtn.frame, location)) {
            return NO;
        }
    }
    
    [_userNameInputView resignFirstResponder];
    [_validCodeInputView resignFirstResponder];
    
    return NO;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.loginUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *accountDict = [self.loginUsers objectAtIndex:indexPath.row];
    NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSString *userFullJid = [accountDict objectForKey:@"userFullJid"];
    NSString *userId = [[userFullJid componentsSeparatedByString:@"@"] firstObject];
//    [cell.imageView setImage:[[QIMKit sharedInstance] getUserHeaderImageByUserId:userFullJid]];
    [cell.imageView qim_setImageWithJid:userFullJid];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = userId;
    cell.detailTextLabel.text = userFullJid;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *accountDict = [self.loginUsers objectAtIndex:indexPath.row];
    NSString *userFullJid = [accountDict objectForKey:@"userFullJid"];
    NSString *userId = [[userFullJid componentsSeparatedByString:@"@"] firstObject];
    [[QIMKit sharedInstance] setUserObject:userId forKey:@"currentLoginUserName"];
    NSString *pwd = [accountDict objectForKey:@"LoginToken"];
    NSDictionary *navDict = [accountDict objectForKey:@"NavDict"];
    if (userId && pwd) {
        [[QIMKit sharedInstance] setCacheName:userFullJid];
        [[QIMKit sharedInstance] qimNav_swicthLocalNavConfigWithNavDict:navDict];
        [[QIMKit sharedInstance] loginWithUserName:userId WithPassWord:pwd WithLoginNavDict:navDict];
    } else {
        [self dropLoginUserTableView:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

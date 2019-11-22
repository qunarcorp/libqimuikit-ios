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

@interface QIMNavConfigSettingVC()<UIAlertViewDelegate,NSURLSessionTaskDelegate>{
    UILabel *_navNickNameLable;
    UILabel *_navAddressLabel;
    UITextField *_navNickNameTextField;
    UITextField *_navAddressTextField;
//    UIButton *_qrcodeNavBtn;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *navConfigUrls;
@property (nonatomic, strong) NSDictionary *navDict;
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, copy) NSString *navUrl;
@property (nonatomic, assign) BOOL edited;
@property (nonatomic, assign) BOOL added;
@property (nonatomic, strong) UIButton * scanSettingNavBtn;
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
    
    [self.scanSettingNavBtn setFrame:CGRectMake((SCREEN_WIDTH - 175)/2, 26, 175, 40)];
    [self.view addSubview:self.scanSettingNavBtn];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(20, self.scanSettingNavBtn.bottom + 36, SCREEN_WIDTH - 20, 16)];
    label.text = [NSBundle qim_localizedStringForKey:@"Configure_Navigation_Manually"];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor qim_colorWithHex:0xBFBFBF];
    [self.view addSubview:label];
    
    _navNickNameLable = [[UILabel alloc] initWithFrame:CGRectMake(20, label.bottom + 16, self.view.width - 40, 20)];
    [_navNickNameLable setText:[NSBundle qim_localizedStringForKey:@"Navigation_Name"]];
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
    [_navNickNameTextField setPlaceholder:[NSBundle qim_localizedStringForKey:@"company_name"]];
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
    [_navAddressLabel setText:[NSBundle qim_localizedStringForKey:@"nav_required_domain_name"]];
    
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
        [_navAddressTextField setPlaceholder:[NSBundle qim_localizedStringForKey:@"company_domain"]];
    }
    [navAddressTextBgView addSubview:_navAddressTextField];
    
//    _qrcodeNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _qrcodeNavBtn.frame = CGRectMake(_navAddressTextField.right + 5, 0, 36, 36);
//    _qrcodeNavBtn.layer.masksToBounds = YES;
//    _qrcodeNavBtn.layer.cornerRadius = CGRectGetWidth(_qrcodeNavBtn.frame) / 2.0;
//    [_qrcodeNavBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
//    [_qrcodeNavBtn addTarget:self action:@selector(scanNav:) forControlEvents:UIControlEventTouchUpInside];
//    [navAddressTextBgView addSubview:_qrcodeNavBtn];
    [self.view addSubview:navAddressTextBgView];
}

- (void)scanNav:(id)sender {
    __weak typeof(self) weakSelf = self;
    QIMZBarViewController *vc=[[QIMZBarViewController alloc] initWithBlock:^(NSString *str, BOOL isScceed) {
        if (isScceed) {
            QIMVerboseLog(@"str : %@", str);
            
            NSString * navAddress;
            NSString * navUrl = str;
            
            NSURL * myurl = [NSURL URLWithString:str];
            NSString * query = [myurl query];
            NSArray * parameters = [query componentsSeparatedByString:@"&"];
            if (parameters && parameters.count > 0) {
                for (NSString * item in parameters) {
                    NSArray * value = [item componentsSeparatedByString:@"="];
                    NSString * key = [value objectAtIndex:0];
                    if ([key isEqualToString:@"c"]) {
                        navUrl = str;
                        navAddress = [item stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                        weakSelf.navUrl = str;
                        _navAddressTextField.text = str;
                        _navNickNameTextField.text = navAddress;
                        [self onSave];
                    } else if([key isEqualToString:@"configurl"]){
                        NSString * configUrlStr = [[item stringByReplacingOccurrencesOfString:@"configurl=" withString:@""] qim_base64DecodedString];
                        NSURL *  configUrl = [NSURL URLWithString:configUrlStr];
                        NSString * configQuery = [configUrl query];
                        NSArray * parameters = [configQuery componentsSeparatedByString:@"&"];
                        if (parameters.count > 0 && parameters) {
                            for (NSString * tempItems in parameters) {
                                NSArray * tempValue = [tempItems componentsSeparatedByString:@"="];
                                NSString * tempKey = [tempValue objectAtIndex:0];
                                if ([tempKey isEqualToString:@"c"]) {
                                    navUrl = configUrl.absoluteString;
                                    navAddress = [tempItems stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                                    weakSelf.navUrl = navUrl;
                                    _navAddressTextField.text = navUrl;
                                    _navNickNameTextField.text = navAddress;
                                }
                            }
                        } else{
                            navUrl = configUrl.absoluteString;
                            navAddress =configUrl.absoluteString;
                            [self requestByURLSessionWithUrl:configUrl.absoluteString];
                            [self onSave];
                        }
                    }
                }
            } else{
                navUrl = str;
                navAddress = str;
                [self requestByURLSessionWithUrl:str];
            }
            
//            if ([str containsString:@"publicnav?c="]) {
//                str = [[str componentsSeparatedByString:@"publicnav?c="] lastObject];
//                weakSelf.navUrl = str;
//            } else if ([str containsString:@"confignavigation?configurl="]) {
//                NSString *base64NavUrl = [[str componentsSeparatedByString:@"confignavigation?configurl="] lastObject];
//                str = [base64NavUrl qim_base64DecodedString];
//                weakSelf.navUrl = str;
//            } else {
//                weakSelf.navUrl = str;
//                [weakSelf requestByURLSessionWithUrl:str];
//            }
            _navAddressTextField.text = navUrl;
            _navNickNameTextField.text = navAddress;
            if (!_navNickNameTextField.text.length) {
                _navNickNameTextField.text = [[str.lastPathComponent componentsSeparatedByString:@"="] lastObject];
            }
        }
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)requestByURLSessionWithUrl:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:url];
    quest.HTTPMethod = @"GET";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                  {
                                      NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                                      
                                      NSLog(@"statusCode: %ld", urlResponse.statusCode);
                                      NSDictionary * dataSerialDic = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
                                      
                                      if (dataSerialDic && dataSerialDic.count > 0) {
                                          NSDictionary * baseAddress = [dataSerialDic objectForKey:@"baseaddess"];
                                          if (baseAddress && baseAddress.count >0) {
                                              NSString * domain = [baseAddress objectForKey:@"domain"];
                                              if (domain && domain.length >0) {
                                                  self.navUrl = urlStr;
                                                  _navAddressTextField.text = urlStr;
                                                  _navNickNameTextField.text = domain;
                                                  [self onSave];
                                                  return;
                                              }
                                          }
                                      }
                                      NSLog(@"%@", urlResponse.allHeaderFields);
                                      if (urlResponse.allHeaderFields.count >0 && urlResponse.allHeaderFields) {
                                          NSString * requestLocation = [urlResponse.allHeaderFields objectForKey:@"Location"];
                                          if (requestLocation.length >0 && requestLocation) {
                                              QIMVerboseLog(@"%@",requestLocation);
                                              NSString * navAddress;
                                              NSString * navUrl;
                                              NSURL * requestLocationUrl = [NSURL URLWithString:requestLocation];
                                              NSString * queryStr = [requestLocationUrl query];
                                              NSArray * parameters = [queryStr componentsSeparatedByString:@"&"];
                                              if (parameters.count>0 && parameters) {
                                                  for (NSString * item in parameters) {
                                                      NSArray * value = [item componentsSeparatedByString:@"="];
                                                      
                                                      NSString * key = [value objectAtIndex:0];
                                                      if ([key isEqualToString:@"c"]) {
                                                          //c=qunar.com
                                                          navUrl = requestLocationUrl;
                                                          navAddress = [item stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                                                          self.navUrl = navUrl;
                                                          _navAddressTextField.text = navUrl;
                                                          _navNickNameTextField.text = navAddress;
                                                          [self onSave];
                                                      } else if([key isEqualToString:@"configurl"]){
                                                          //加密的导航，需要二次请求
                                                          NSString * configUrlStr = [[item stringByReplacingOccurrencesOfString:@"configurl=" withString:@""] qim_base64DecodedString];
                                                          NSURL * configUrl = [NSURL URLWithString:configUrlStr];
                                                          NSString * configQuery = [configUrl query];
                                                          NSArray * parameters = [configQuery componentsSeparatedByString:@"&"];
                                                          if (parameters.count > 0 && parameters) {
                                                              for (NSString * tempItems in parameters) {
                                                                  NSArray * tempValue = [tempItems componentsSeparatedByString:@"="];
                                                                  NSString * tempKey = [tempValue objectAtIndex:0];
                                                                  if ([tempKey isEqualToString:@"c"]) {
                                                                      navUrl = configUrl.absoluteString;
                                                                      navAddress = [tempItems stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                                                                      self.navUrl = navUrl;
                                                                      _navAddressTextField.text = navUrl;
                                                                      _navNickNameTextField.text = navAddress;
                                                                      [self onSave];
                                                                  }
                                                                  else{
                                                                      //                                                                      navUrl = configUrl.absoluteString;
                                                                      //                                                                      navAddress =configUrl.absoluteString;
                                                                      //                                                                      [self onSaveWith:navAddress navUrl:navUrl];
                                                                  }
                                                              }
                                                          }
                                                          else if([configUrlStr containsString:@"startalk_nav"]){
                                                              //包含startalk_nav的，直接请求
                                                              [self requestByURLSessionWithUrl:configUrlStr];
                                                              [self onSave];
                                                              return;
                                                          }
                                                          else{
                                                              //其他外部网页生成的二维码
                                                              navUrl = configUrlStr;
                                                              self.navUrl = navUrl;
                                                              _navAddressTextField.text = navUrl;
                                                              _navNickNameTextField.text = navAddress;
                                                              [self onSave];
                                                          }
                                                      }
                                                  }
                                              }
                                              else {
                                                  navUrl = requestLocation;
                                                  self.navUrl = navUrl;
                                                  _navAddressTextField.text = navUrl;
                                                  _navNickNameTextField.text = navAddress;
                                              }
                                          }
                                          else{
                                              self.navUrl = urlStr;
                                              _navAddressTextField.text = urlStr;
                                              _navNickNameTextField.text = urlStr;
                                          }
                                      }
                                  }];
    [task resume];
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    NSLog(@"statusCode: %ld", response.statusCode);
    
    NSDictionary *headers = response.allHeaderFields;
    NSString * requestLocation = [headers objectForKey:@"Location"];
    if (requestLocation.length >0 && requestLocation) {
        completionHandler(nil);
    }
    else{
        completionHandler(request);
    }
}

- (void)setupNav {
    
    self.title = self.navTitle.length > 0 ? self.navTitle : [NSBundle qim_localizedStringForKey:@"nav_new_Navigation"];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    [self.navigationItem setLeftBarButtonItem:cancelItem];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_save"] style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    [self.navigationItem setRightBarButtonItem:saveItem];
}

- (void)onCancel{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[QIMFastEntrance sharedInstance] launchMainControllerWithWindow:[UIApplication sharedApplication].delegate.window];
        /*
        UIViewController *parentVC = self.presentingViewController;
        UIViewController *bottomVC;
        while (parentVC) {
            bottomVC = parentVC;
            parentVC = parentVC.presentingViewController;
        }
        [bottomVC dismissViewControllerAnimated:NO completion:^{
            //dismiss后再切换根视图
            [[QIMFastEntrance sharedInstance] launchMainControllerWithWindow:[UIApplication sharedApplication].delegate.window];
        }];
        */
    });
}

- (void)onSave{
    NSString *navHttpName = _navNickNameTextField.text;
    self.navUrl = _navAddressTextField.text;
    if (self.navUrl.length > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __block NSDictionary *userWillsaveNavDict = @{QIMNavNameKey:(navHttpName.length > 0) ? navHttpName : [[self.navUrl.lastPathComponent componentsSeparatedByString:@"="] lastObject], QIMNavUrlKey:self.navUrl};
        [[QIMKit sharedInstance] setUserObject:userWillsaveNavDict forKey:@"QC_UserWillSaveNavDict"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES withCallBack:^(BOOL success) {
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
                                                                            message:[NSBundle qim_localizedStringForKey:@"nav_no_available_Navigation"]
                                                                           delegate:nil
                                                                  cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"ok"]
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                });
            }];
        });
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[NSBundle qim_localizedStringForKey:@"nav_valid_promot"]
                                                           delegate:nil
                                                  cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"ok"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (UIButton *)scanSettingNavBtn{
    if (!_scanSettingNavBtn) {
        _scanSettingNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scanSettingNavBtn.backgroundColor = [UIColor qim_colorWithHex:0x00CABE];
        [_scanSettingNavBtn setTitle:[NSBundle qim_localizedStringForKey:@"nav_scan_Configure_Navigation"] forState:UIControlStateNormal];
        [_scanSettingNavBtn setTitleColor:[UIColor qim_colorWithHex:0xFFFFFF] forState:UIControlStateNormal];
        _scanSettingNavBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:4];
        [_scanSettingNavBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor qim_colorWithHex:0xFFFFFF]]] forState:UIControlStateNormal];
        [_scanSettingNavBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor qim_colorWithHex:0xFFFFFF]]] forState:UIControlStateSelected];
        [_scanSettingNavBtn addTarget:self action:@selector(scanNav:) forControlEvents:UIControlEventTouchUpInside];
        _scanSettingNavBtn.layer.masksToBounds = YES;
        _scanSettingNavBtn.layer.cornerRadius = 4;
        _scanSettingNavBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 - 7 / 2, 0, 0 + 7 / 2);
        _scanSettingNavBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 + 7 / 2, 0, 0 - 7 / 2);
    }
    return _scanSettingNavBtn;
}
@end

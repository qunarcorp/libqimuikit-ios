//
//  QIMNavConfigManagerVC.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/10/31.
//
//

#import "QIMNavConfigManagerVC.h"
#import "QIMNavConfigSettingVC.h"
#import "MBProgressHUD.h"
#import "QIMZBarViewController.h"
#import "SCLAlertView.h"
#import "MBProgressHUD.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMNacConfigTableViewCell.h"

@interface QIMNavConfigManagerVC () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, QIMNavConfigDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *navConfigs;

@property (nonatomic, strong) NSDictionary *tempNavDict;

@property (nonatomic, strong) UIBarButtonItem *cancelItem;

@property (nonatomic, strong) UIButton *addNavServerBtn;
@property (nonatomic, strong) UIButton *xmppProtocolButton;
@property (nonatomic, strong) UIButton *protobufProtocolButton;
@property (nonatomic, strong) SCLAlertView *vaildPwdAlert;

@end

@implementation QIMNavConfigManagerVC

- (UIButton *)addNavServerBtn {
    
    if (!_addNavServerBtn) {
        _addNavServerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addNavServerBtn.frame = CGRectMake(45, [UIScreen mainScreen].bounds.size.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - 49 - 29, self.view.width - 90, 48);
        _addNavServerBtn.backgroundColor = [UIColor whiteColor];
        [_addNavServerBtn setTitle:[NSBundle qim_localizedStringForKey:@"nav_new_Configuration"] forState:UIControlStateNormal];
        [_addNavServerBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_addNavServerBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _addNavServerBtn.layer.borderColor = [UIColor qim_colorWithHex:0x00CABE].CGColor;
        _addNavServerBtn.layer.borderWidth = 1.0f;
        _addNavServerBtn.layer.cornerRadius = 24.0f;
        _addNavServerBtn.layer.masksToBounds = YES;
        _addNavServerBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_addNavServerBtn addTarget:self action:@selector(onSettingClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNavServerBtn;
}

- (UIBarButtonItem *)cancelItem {
    
    if (!_cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    }
    return _cancelItem;
}
 
- (void)initUI {
    
    self.title = [NSBundle qim_localizedStringForKey:@"nav_title_configManager"];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIBarButtonItem *feedBackItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    self.navigationItem.rightBarButtonItem = feedBackItem;
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - 49 - 35) style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor whiteColor];
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset=UIEdgeInsetsMake(0,0, 0, 0);           //top left bottom right 左右边距相同
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNavDicts) name:NavConfigSettingChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    self.navConfigs = [[QIMKit sharedInstance] qimNav_localNavConfigs];
    [self initUI];
    if (![[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"]) {
        
        [[QIMKit sharedInstance] setUserObject:self.navConfigs[0] forKey:@"QC_CurrentNavDict"];
        [self.tableView reloadData];
    }
}

#pragma mark - 重新修改frame
- (void)reloadIPadViewFrame {
    if ([[QIMKit sharedInstance] getIsIpad]) {
        _tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.view.height - 59);
        QIMVerboseLog(@"%@",NSStringFromCGRect(_tableView.frame));
        [_tableView setValue:nil forKey:@"reusableTableCells"];
        [self.tableView reloadData];
        [self.addNavServerBtn removeFromSuperview];
        self.addNavServerBtn = nil;
        [[UIApplication sharedApplication].keyWindow addSubview:self.addNavServerBtn];
        self.addNavServerBtn.enabled = YES;
    }
}

#pragma mark - 监听屏幕旋转

- (void)statusBarOrientationChange:(NSNotification *)notification {
    QIMVerboseLog(@"屏幕发送旋转 : %@", notification);
    [self reloadIPadViewFrame];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication].keyWindow addSubview:self.addNavServerBtn];
    self.addNavServerBtn.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.addNavServerBtn removeFromSuperview];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _vaildPwdAlert = nil;
}

- (void)reloadNavDicts {
    
    self.navConfigs = [[QIMKit sharedInstance] qimNav_localNavConfigs];
    [self.tableView reloadData];
}

- (void)onSaveWithNavUrl:(NSString *)navUrl WithNavDict:(NSDictionary *)navUrlDict needSaveAllDict:(BOOL)needSaveAllDict {
    if (navUrl.length > 0) {
        [[QIMKit sharedInstance] setUserObject:navUrlDict forKey:@"QC_UserWillSaveNavDict"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES withCallBack:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if (success) {
                        [[QIMKit sharedInstance] setUserObject:navUrlDict forKey:@"QC_CurrentNavDict"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NavConfigSettingChanged object:navUrlDict];
                            [self onCancel];
                        });
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSBundle qim_localizedStringForKey:@"nav_valid_promot"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"ok"] otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)onSave{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.tempNavDict.count) {
        NSString *navUrl = [self.tempNavDict objectForKey:QIMNavUrlKey];;
        [self onSaveWithNavUrl:navUrl WithNavDict:self.tempNavDict needSaveAllDict:YES];
    } else {
        __block NSDictionary *navUrlDict = [[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
        NSString *navUrl;
        if (navUrlDict) {
            navUrl = [navUrlDict objectForKey:QIMNavUrlKey];;
        }
        [self onSaveWithNavUrl:navUrl WithNavDict:navUrlDict needSaveAllDict:NO];
    }
}

#pragma mark - ButtonItem Action

- (void)onCancel{
    UIViewController *vc =  self;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onFeedBack {
#if __has_include("QIMLocalLog.h")
    [[QIMLocalLog sharedInstance] submitFeedBackWithContent:nil withUserInitiative:NO];
#endif
}

#pragma mark - UITableViewDelegate and DataSource Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.navConfigs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [self.navConfigs objectAtIndex:indexPath.row];
    NSString *title;
    NSString *navHttpURL;
    if (dict) {
        title = dict[QIMNavNameKey];
        navHttpURL = dict[QIMNavUrlKey];
        if ([navHttpURL containsString:@"publicnav?c="]) {
            navHttpURL = [[navHttpURL componentsSeparatedByString:@"publicnav?c="] lastObject];
        }
        NSString *cellIdentifier = @"NavConfigManagerCell";
        QIMNacConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            
            cell = [[QIMNacConfigTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        cell.navInfo = dict;
        if ([dict isEqualToDictionary:[[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"]]) {
            
            [cell setUpUISelected];
        } else {
            [cell setUpUINormal];
        }
        if (self.tempNavDict.count > 0) {
            if ([dict isEqualToDictionary:self.tempNavDict]) {
                [cell setUpUISelected];
                
            } else {
                
                [cell setUpUINormal];
            }
        }
 
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - QIMNavConfigDelegate

- (void)modifyNavWithNavCell:(id)cell {
    
    UITableViewCell *navCell = (UITableViewCell *)cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *willEditedNavDict = [self.navConfigs objectAtIndex:indexPath.row];
    QIMNavConfigSettingVC *settingVC = [[QIMNavConfigSettingVC alloc] init];
    [settingVC setEditedNavDict:willEditedNavDict];
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:settingVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)deleteNavWithNavCell:(id)cell {
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell *navCell = (UITableViewCell *)cell;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSUInteger row = [indexPath row];
        [self.navConfigs removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [[QIMKit sharedInstance] setUserObject:self.navConfigs forKey:@"QC_NavAllDicts"];
    });
}

- (void)showNavQRWithNavCell:(id)cell {
    UITableViewCell *navCell = (UITableViewCell *)cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *willEditedNavDict = [self.navConfigs objectAtIndex:indexPath.row];
    NSString *navUrl = [willEditedNavDict objectForKey:QIMNavUrlKey];
    NSString *navName = [willEditedNavDict objectForKey:QIMNavNameKey];
    NSString *name = [NSString stringWithFormat:@"%@ : %@", navName, navUrl];
    [QIMFastEntrance showQRCodeWithQRId:navUrl withType:QRCodeType_ClientNav];
}

- (void)selectNavWithNavCell:(id)cell {
    UITableViewCell *navCell = (UITableViewCell *)cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *willEditedNavDict = [self.navConfigs objectAtIndex:indexPath.row];
    self.tempNavDict = willEditedNavDict;
    [self.tableView reloadData];
}

- (void)advanceAddServer {
    QIMNavConfigSettingVC *settingVC = [[QIMNavConfigSettingVC alloc] init];
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:settingVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onSettingClick:(UIButton *)sender{
    QIMVerboseLog(@"%s", __func__);
    QIMNavConfigSettingVC *settingVC = [[QIMNavConfigSettingVC alloc] init];
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:settingVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSString *touchClass = NSStringFromClass([touch.view class]);
    if ([touchClass isEqualToString:@"UIButton"] || [touchClass isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}
@end

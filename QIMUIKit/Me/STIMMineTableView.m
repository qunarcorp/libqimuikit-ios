//
//  STIMMineTableView.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/12/25.
//

#import "STIMMineTableView.h"
#import "STIMCommonTableViewCellData.h"
#import "STIMCommonTableViewCellManager.h"
#import "STIMCommonFont.h"
#import "STIMUserInfoModel.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMMineTableView ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) STIMCommonTableViewCellManager *tableViewManager;

@property (nonatomic) NSMutableArray<NSArray<STIMCommonTableViewCellData *> *> *dataSource;

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *userVCardInfo;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) STIMUserInfoModel *model;


@end

@implementation STIMMineTableView

#pragma mark - setter and getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor stimDB_colorWithHex:0xf5f5f5 alpha:1.0f];
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset=UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

- (NSMutableArray<NSArray<STIMCommonTableViewCellData *> *> *)dataSource {
    _dataSource = [NSMutableArray arrayWithCapacity:5];
    NSArray<STIMCommonTableViewCellData *> *section0 = @[[[STIMCommonTableViewCellData alloc] initWithTitle:@"我" iconName:nil cellDataType:STIMCommonTableViewCellDataTypeMine]                                               ];
    
    NSArray<STIMCommonTableViewCellData *> *section1 = @[[[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_red_package"] iconName:@"\U0000f0e4"   cellDataType:STIMCommonTableViewCellDataTypeMyRedEnvelope],
                                                 [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_balance"] iconName:@"\U0000f0f1" cellDataType:STIMCommonTableViewCellDataTypeBalanceInquiry],
                                                 ];

    NSArray<STIMCommonTableViewCellData *> *section2 = @[];
    if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
        section2 =  @[
                      [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"explore_tab_sign_in_check"] iconName:@"\U0000f1b7" cellDataType:STIMCommonTableViewCellDataTypeAttendance],[[STIMCommonTableViewCellData alloc] initWithTitle:@"QTalk Token" iconName:@"\U0000f1b7" cellDataType:STIMCommonTableViewCellDataTypeTotpToken],
                      [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"explore_tab_my_file"] iconName:@"\U0000e213" cellDataType:STIMCommonTableViewCellDataTypeMyFile],
                      ];
    } else {
        section2 = @[[[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"explore_tab_my_file"] iconName:@"\U0000e213" cellDataType:STIMCommonTableViewCellDataTypeMyFile]];
    }
    NSArray<STIMCommonTableViewCellData *> *section4 = @[[[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_setting"] iconName:@"\U0000f0ed" cellDataType:STIMCommonTableViewCellDataTypeSetting],
                                                 ];
    [_dataSource addObject:section0];
    [_dataSource addObject:section1];
    [_dataSource addObject:section2];
    [_dataSource addObject:section4];
    return _dataSource;
}

- (STIMCommonTableViewCellManager *)tableViewManager {
    if (!_tableViewManager) {
        _tableViewManager = [[STIMCommonTableViewCellManager alloc] initWithRootViewController:self.rootViewController];
    }
    _tableViewManager.dataSource = self.dataSource;
    return _tableViewManager;
}


#pragma mark - NSNotification

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyHeader) name:kUserHeaderImgUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyHeader) name:kMyHeaderImgaeUpdateSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:kNotificationCurrentFontUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSwitchAccount:) name:kNotifySwichUserSuccess object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (void)initUI {
    self.backgroundColor = [UIColor stimDB_colorWithHex:0xf5f5f5 alpha:1.0f];
    [self addSubview:self.tableView];
}

#pragma mark - life ctyle

- (void)loadUserInfo {
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        self.userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:[[STIMKit sharedInstance] getLastJid]];
        _userId = [[STIMKit sharedInstance] getLastJid];
        
        NSString *type = [_userInfo objectForKey:@"type"];
        if ([type isEqualToString:@"merchant"]) {
            [[STIMKit sharedInstance] setIsMerchant:YES];
        } else {
            [[STIMKit sharedInstance] setIsMerchant:NO];
        }
        
        NSString * qCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
        NSString * vCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
        NSString * tCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
        
        NSMutableDictionary * passwordDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [passwordDic setSTIMSafeObject:qCookie forKey:@"q"];
        [passwordDic setSTIMSafeObject:vCookie forKey:@"v"];
        [passwordDic setSTIMSafeObject:tCookie forKey:@"t"];
        [passwordDic setSTIMSafeObject:type forKey:@"type"];
        
        [[STIMKit sharedInstance] setUserObject:passwordDic forKey:@"QChatCookie"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserTypeInfoDidChangeNotification" object:nil];
        });
    } else {
        self.userInfo = [NSMutableDictionary dictionaryWithDictionary:[[STIMKit sharedInstance] getUserInfoByUserId:[[STIMKit sharedInstance] getLastJid]]];
        self.userId = [self.userInfo objectForKey:@"XmppId"];
    }
}

- (void)loadUserModel {
    self.model = [[STIMUserInfoModel alloc]init];
    NSString *name = [self.userInfo objectForKey:@"Name"];
    if (name.length <= 0) {
        name = [self.userId componentsSeparatedByString:@"@"].firstObject;
    }
    self.model.name       = name;
    self.model.ID         = self.userId;
    self.model.department = [self.userInfo valueForKey:@"DescInfo"];
    self.model.personalSignature = [self.userVCardInfo objectForKey:@"M"];
}

- (void)getUserVcardInfo {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (weakSelf.userId) {
            NSDictionary * usersInfo = [[STIMKit sharedInstance] getUserInfoByUserId:weakSelf.userId];
            if (usersInfo.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.model.personalSignature = [usersInfo objectForKey:@"Mood"];
                    [weakSelf.tableView reloadData];
                });
            }
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerObserver];
        [self loadUserInfo];
        [self getUserVcardInfo];
        [self loadUserModel];
        [self initUI];
    }
    return self;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    _rootViewController = rootViewController;
//    [self loadUserModel];
    self.tableViewManager.model = self.model;
    self.tableView.delegate = self.tableViewManager;
    self.tableView.dataSource = self.tableViewManager;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden == NO) {
        [self.rootViewController.navigationItem setTitle:[NSBundle stimDB_localizedStringForKey:@"tab_title_myself"]];
    }
}

#pragma mark - NSNotification

- (void)refreshSwitchAccount:(NSNotification *)nofity {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self updateMineTableViewManager];
    });
}

- (void)updateMyHeader {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.tableView reloadData];
    });
}

- (void)updateMineTableViewManager {
    [self loadUserInfo];
    [self getUserVcardInfo];
    [self loadUserModel];
    self.tableViewManager.model = self.model;
    [self.tableView reloadData];
}

- (void)updateFont:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end

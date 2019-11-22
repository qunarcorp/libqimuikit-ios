//
//  STIMUserProfileViewController.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/25.
//

#import "STIMUserProfileViewController.h"
#import "STIMCommonUserProfileCellManager.h"
#import "STIMFriendSettingCell.h"
#import "STIMQNValidationFriendVC.h"
#import "STIMValidationFriendVC.h"
#import "STIMChatVC.h"
#import "STIMIconInfo.h"

@interface STIMUserProfileViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) CGFloat reactViewCellHeight;
@property (nonatomic, strong) STIMCommonUserProfileCellManager *manager;

@property (nonatomic, strong) NSDictionary *userVCardInfo;

//FooterView
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *chatBtn;
@property (nonatomic, strong) UIButton *friendBtn;


@property (nonatomic, assign) BOOL isAddFriend;
@property (nonatomic, assign) BOOL isFriend;

@end

@implementation STIMUserProfileViewController

#pragma mark - setter and getter

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:5];
        if (self.myOwnerProfile) {
            NSArray *section0 = @[@(QCUserProfileHeader), @(QCUserProfileUserSignature), @(QCUserProfileMyQrcode)];
            NSArray *section1 = @[];
            if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
                section1 = @[@(QCUserProfileUserName), @(QCUserProfileUserId), @(QCUserProfileDepartment)];
            } else {
                section1 = @[@(QCUserProfileUserName), @(QCUserProfileUserId)];
            }
            [_dataSource addObject:section0];
            [_dataSource addObject:section1];
        } else {
            NSArray *section0 = @[@(QCUserProfileUserInfo)];
            NSArray *section1 = @[@(QCUserProfileRemark)];
            NSArray *section2 = @[@(QCUserProfileUserId)];
            if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
                section2 = @[@(QCUserProfileUserId), @(QCUserProfileDepartment)];
            }
            NSArray *section3 = @[@(QCUserProfileComment), @(QCUserProfileSendMail)];
            [_dataSource addObject:section0];
            [_dataSource addObject:section1];
            [_dataSource addObject:section2];
            if ([[STIMKit sharedInstance] qimNav_OpsHost].length > 0 && [STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
                [_dataSource addObject:section3];
            }
        }
    }
    return _dataSource;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor stimDB_colorWithHex:0xf5f5f5 alpha:1.0];
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset=UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

- (STIMCommonUserProfileCellManager *)manager {
    if (!_manager) {
        _manager = [[STIMCommonUserProfileCellManager alloc] initWithRootViewController:self WithUserId:self.userId];
        _manager.dataSource = self.dataSource;
    }
    return _manager;
}

- (UIView *)footerView {
    
    if (!_footerView) {
        
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 64.0 - [[STIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT], self.view.width, 64.0)];
    }
    return _footerView;
}

- (UIButton *)friendBtn {
    
    if (!_friendBtn) {
        
        _friendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _friendBtn.frame = CGRectMake(12, 10, ((self.view.width - 30) / 2.0), 44);
        _friendBtn.layer.cornerRadius = 5.0;
        _friendBtn.layer.masksToBounds = YES;
        _friendBtn.layer.borderColor = [UIColor clearColor].CGColor;
        _friendBtn.titleLabel.font = [UIFont fontWithName:FONT_NAME size:16];
        [_friendBtn.titleLabel sizeToFit];
        _friendBtn.clipsToBounds = YES;
    }
    if (_isFriend) {
        
        [_friendBtn setTitle:@"删除好友" forState:UIControlStateNormal];
        [_friendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_friendBtn addTarget:self action:@selector(deleteFriend) forControlEvents:UIControlEventTouchUpInside];
        [_friendBtn setBackgroundImage:[UIImage stimDB_imageFromColor:[UIColor redColor]] forState:UIControlStateNormal];
        
    } else {
        
        [_friendBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Add friend"] forState:UIControlStateNormal];
        [_friendBtn setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateNormal];
        [_friendBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        [_friendBtn setBackgroundImage:[UIImage stimDB_imageFromColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0]] forState:UIControlStateNormal];
    }
    return _friendBtn;
}

- (UIButton *)chatBtn {
    
    if (!_chatBtn) {
        
        _chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chatBtn.frame = CGRectMake(CGRectGetMaxX(self.friendBtn.frame) + 12, 10, ((self.view.width - 36) / 2.0), 44);
        _chatBtn.layer.cornerRadius = 5.0;
        _chatBtn.layer.masksToBounds = YES;
        _chatBtn.clipsToBounds = YES;
        [_chatBtn setTitle:@"发消息" forState:UIControlStateNormal];
        [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _chatBtn.titleLabel.font = [UIFont fontWithName:FONT_NAME size:16];
        [_chatBtn.titleLabel sizeToFit];
        [_chatBtn.layer setBorderColor:[UIColor clearColor].CGColor];
        [_chatBtn setBackgroundImage:[UIImage stimDB_imageFromColor:[UIColor qtalkIconSelectColor]] forState:UIControlStateNormal];
        [_chatBtn setBackgroundImage:[UIImage stimDB_imageFromColor:[UIColor qtalkIconSelectColor]] forState:UIControlStateHighlighted];
        [_chatBtn addTarget:self action:@selector(openChatSession) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatBtn;
}

#pragma mark - UI

- (void)setupNav {
    self.title = @"个人资料";
    self.navigationController.navigationBar.translucent = NO;
}

- (void)setToolBar {
    
    [self.view addSubview:self.footerView];
    if (!self.myOwnerProfile) {
        [self.footerView addSubview:self.friendBtn];
        [self.footerView addSubview:self.chatBtn];
    }
}

- (void)initUI {
    [self setupNav];
    [self.view addSubview:self.tableView];
    [self setToolBar];
}

#pragma mark - NSNotification

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markNameUpdate) name:kMarkNameUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyHeader) name:kMyHeaderImgaeUpdateSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:kNotificationCurrentFontUpdate object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - life ctyle

- (void)loadUserInfo {
    self.userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.userId];
}

- (void)getUserVcardInfo {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:weakSelf.userId];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.model.personalSignature = [userInfo objectForKey:@"Mood"];
            [weakSelf.tableView reloadData];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserVcardInfo];
    self.tableView.dataSource = self.manager;
    self.tableView.delegate = self.manager;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveFriendPresence:) name:kFriendPresence object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFriendPresence object:nil];
}

- (void)registerNSNotifications {
#if __has_include("RNSchemaParse.h")
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRNCardViewHeight:) name:@"kNotify_RN_QTALK_CARD_ViewHeight_UPDATE" object:nil];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerObserver];
    [self getUserVcardInfo];
    [self loadUserInfo];
    NSDictionary *friendDic = [[STIMKit sharedInstance] selectFriendInfoWithUserId:[self.userInfo objectForKey:@"XmppId"]];
    _isFriend = friendDic != nil;
    
    self.model            = [[STIMUserInfoModel alloc]init];
    NSString *name = [self.userInfo objectForKey:@"Name"];
    if (name.length <= 0) {
        name = [self.userId componentsSeparatedByString:@"@"].firstObject;
    }
    self.model.name       = name;
    self.model.ID         = [self.userId componentsSeparatedByString:@"@"].firstObject;
    self.model.department = [self.userInfo valueForKey:@"DescInfo"];
    self.model.personalSignature = [self.userVCardInfo objectForKey:@"M"];
    self.manager.userInfo = self.userInfo;
    self.manager.model = self.model;
    
    [self initUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QTalkCardRNViewDelegate

- (void)changeRNCardViewHeight:(NSNotification *)notify {
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)deleteFriend {
    UIAlertController *delteFriendSheetVC = [UIAlertController alertControllerWithTitle:@"确定要删除该好友吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除好友" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL isSuccess = [[STIMKit sharedInstance] deleteFriendWithXmppId:[self.userInfo objectForKey:@"XmppId"] WithMode:2];
            dispatch_async(dispatch_get_main_queue(), ^{
//                [[self progressHUD] hide:YES];
                if (isSuccess) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"删除好友失败。" delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
                    [alertView show];
                }
            });
        });
    }];
    [delteFriendSheetVC addAction:cancelAction];
    [delteFriendSheetVC addAction:deleteAction];
    [self presentViewController:delteFriendSheetVC animated:YES completion:nil];
}

- (void)addFriend {
    NSDictionary *modeDic = [[STIMKit sharedInstance] getVerifyFreindModeWithXmppId:self.userId];
    int mode = [[modeDic objectForKey:@"mode"] intValue];
    
    switch (mode) {
        case VerifyMode_AllRefused:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Your friend request was rejected."] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case VerifyMode_AllAgree:
        {
            [[STIMKit sharedInstance] addFriendPresenceWithXmppId:self.userId WithAnswer:nil];
        }
            break;
        case VerifyMode_Validation:
        {
            STIMValidationFriendVC *valiVC = [[STIMValidationFriendVC alloc] init];
            [valiVC setXmppId:[self.userInfo objectForKey:@"XmppId"]];
            [self.navigationController pushViewController:valiVC animated:YES];
        }
            break;
        case VerifyMode_Question_Answer:
        {
            STIMQNValidationFriendVC *validVC = [[STIMQNValidationFriendVC alloc] init];
            [validVC setValidDic:modeDic];
            [validVC setXmppId:self.userId];
            [self.navigationController pushViewController:validVC animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)openChatSession {
    [STIMFastEntrance openSingleChatVCByUserId:self.userId];
}

#pragma mark - NSNotification

- (void)markNameUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.tableView reloadData];
    });
}

- (void)onReceiveFriendPresence:(NSNotification *)notify {
    if ([self.userId isEqualToString:notify.object]) {
        NSDictionary *presenceDic = notify.userInfo;
        NSString *result = [presenceDic objectForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            [self openChatSession];
        } else {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Add friend"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] style:UIAlertActionStyleDefault handler:nil];
            [alertVc addAction:okAction];
            [self presentViewController:alertVc animated:YES completion:nil];
        }
    }
}

- (void)updateMyHeader {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadUserInfo];
        [self.tableView reloadData];
    });
}

- (void)updateFont:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end

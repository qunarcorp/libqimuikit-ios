//
//  QIMOrganizationalVC.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "QIMOrganizationalVC.h"
#import "QIMBuddyTitleCell.h"
#import "QIMBuddyItemCell.h"
#import "QIMDatasourceItem.h"
#import "QIMDatasourceItemManager.h"
#import "NSBundle+QIMLibrary.h"
#import "MBProgressHUD.h"

@interface QIMOrganizationalVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation QIMOrganizationalVC

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.tableView];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [self.tableView addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressHUD.hidden = NO;
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        [self.progressHUD show:YES];
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    });
}

- (void)hideProgressHUD:(BOOL)animated {
    [self.progressHUD hide:animated];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)loadRosterList {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
        if ([[[[QIMDatasourceItemManager sharedInstance] getTotalItems] allKeys] count] <= 0) {
            [weakSelf showProgressHUDWithMessage:@"正在加载中..."];
            [[QIMDatasourceItemManager sharedInstance] createDataSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [weakSelf hideProgressHUD:YES];
            });
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor qim_colorWithHex:0xeaeaea alpha:1]];
    [self initWithNav];
    [self initWithTableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadRosterList];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAccessibilityIdentifier:@"QTalkOrganizational"];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

- (void)initWithNav{
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_organization"]];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeStartalk) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"邀请" forState:UIControlStateNormal];
        [button setTitle:@"邀请" forState:UIControlStateSelected];
        [button setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateSelected];
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:button]];
        [button addTarget:self action:@selector(inviteMemberToCompany:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.shareCard == YES) {
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
        [[self navigationItem] setRightBarButtonItem:rightBar];
    }
}

- (void)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)inviteMemberToCompany:(id)sender {
    NSString *inviteStr = [NSString stringWithFormat:@"https://im.qunar.com/new/#/user_list?domain=%@", [[QIMKit sharedInstance] getDomain]];
    [QIMFastEntrance openWebViewForUrl:inviteStr showNavBar:YES];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    QIMVerboseLog(@"numberOfSectionsInTableView getQIMMergedRootBranch");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([[[[QIMDatasourceItemManager sharedInstance] getTotalItems] allKeys] count] <= 0) {
        return 0;
    } else {
        NSInteger count = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] count];
        return count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] objectAtIndex:indexPath.row];
    QIMDatasourceItem *item = [[QIMDatasourceItemManager sharedInstance] getTotalDataSourceItemWithId:key];
    if (!item) {
        item = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    CGFloat height = (item.childNodesDict.count > 0) ? 38 : 60;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] objectAtIndex:indexPath.row];
    QIMDatasourceItem *item = [[[QIMDatasourceItemManager sharedInstance] getTotalItems] objectForKey:key];
    if (!item) {
        item = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    if (item.childNodesDict.count > 0) {
        
        NSString *cellIdentifier1 = [NSString stringWithFormat:@"CONTACT_BUDDY_TITLE_%ld", (long)[item nLevel]];
        QIMBuddyTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell == nil) {
            cell = [[QIMBuddyTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            [cell initSubControls];
        }
        NSString * userName = item.nodeName;
        [cell setUserName:[[userName componentsSeparatedByString:@"/"] lastObject]];
        [cell setExpanded:item.isExpand];
        [cell setNLevel:[userName componentsSeparatedByString:@"/"].count];
        [cell refresh];
        return cell;
    } else {
        static NSString *cellIdentifier2 = @"CONTACT_BUDDY";
        QIMBuddyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        NSString * userName  =  item.nodeName;
        NSString *jid      =   item.jid;
        [cell initSubControls];
        [cell setNLevel:[userName componentsSeparatedByString:@"/"].count];
        [cell setUserName:userName];
        [cell setJid:jid];
        [cell refrash];
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] objectAtIndex:indexPath.row];
    
    QIMDatasourceItem *item = [[[QIMDatasourceItemManager sharedInstance] getTotalItems] objectForKey:key];
    if (!item) {
        item = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    if (item.childNodesDict.count > 0) {
        if ([item isExpand]) {
            //合起
            [[QIMDatasourceItemManager sharedInstance] collapseBranchAtIndex:indexPath.row];
            id cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[QIMBuddyTitleCell class]]) {
                [cell setExpanded:NO];
                [_tableView reloadData];
            }
        } else {
            //展开
            [[QIMDatasourceItemManager sharedInstance] expandBranchAtIndex:indexPath.row];
            id cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[QIMBuddyTitleCell class]]) {
                [cell setExpanded:YES];
                [_tableView reloadData];
            }
        }
    } else {
        //普通用户或者无子结点
        NSString *xmppId = item.jid;
        if (self.shareCard == YES) {
            if (self.shareCardDelegate && [self.shareCardDelegate respondsToSelector:@selector(selectShareContactWithJid:)]) {
                [self.shareCardDelegate selectShareContactWithJid:xmppId];
            }
            if (self.shareCard == YES) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [QIMFastEntrance openUserCardVCByUserId:xmppId];
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

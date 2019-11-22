//
//  STIMFriendListViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "STIMFriendListViewController.h"
#import "STIMJSONSerializer.h"
#import "STIMFriendNodeItem.h"
#import "STIMFriendListCell.h"
#import "STIMFriendTitleListCell.h"
#import "STIMAddIndexViewController.h"
#import "STIMAddSomeViewController.h"
#import "STIMDatasourceItemManager.h"
#import "STIMDatasourceItem.h"
#import "STIMBuddyTitleCell.h"
#import "STIMBuddyItemCell.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMFriendListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    UITableView *_tableView;
    NSMutableArray *_rosterList;
    NSMutableArray *_friendList;
    NSMutableArray *_dataSource;
    BOOL _friendIsExpanded;
    BOOL _blackIsExpanded;
    BOOL _rosterIsExpanded;
}

@end

@implementation STIMFriendListViewController


- (void)loadRosterList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
        if ([[[[STIMDatasourceItemManager sharedInstance] getTotalItems] allKeys] count] <= 0) {
            [[STIMDatasourceItemManager sharedInstance] createDataSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    });
}

- (void)updateFriendList{
    [_friendList removeAllObjects];
    [_dataSource removeAllObjects];
    int onlineCount = 0;
    
    STIMFriendNodeItem *friendNode = [[STIMFriendNodeItem alloc] init];
    [friendNode setIsParentNode:YES];
    [friendNode setIsFriend:YES];
    [friendNode setName:[NSBundle stimDB_localizedStringForKey:@"contact_tab_friend"]];
    [friendNode setDescInfo:[NSString stringWithFormat:@"%d/%ld",onlineCount,(unsigned long)_friendList.count]];
    [friendNode setContentValue:_friendList];
    [_dataSource addObject:friendNode];
    if (_friendIsExpanded) {
        [_dataSource insertObjects:friendNode.contentValue atIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(1,_friendList.count)]];
    }
    
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendList) name:kFriendListUpdate object:nil];
    
    [self.view setBackgroundColor:[UIColor stimDB_colorWithHex:0xeaeaea alpha:1]];
    
    _dataSource = [NSMutableArray array];
    _friendList = [NSMutableArray array];
    [self updateFriendList];
    [self initWithNav];
    [self initWithTableView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat && [[STIMKit sharedInstance] isMerchant]) {
        [self loadRosterList];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - init UI
- (void)onAddClick{
    STIMAddIndexViewController *indexVC = [[STIMAddIndexViewController alloc] init];
    [self.navigationController pushViewController:indexVC animated:YES];
}

- (void)initWithNav{
    [self.navigationItem setTitle:[NSBundle stimDB_localizedStringForKey:@"contact_tab_friend"]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"common_add"] style:UIBarButtonItemStyleDone target:self action:@selector(onAddClick)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAccessibilityIdentifier:@"FriendList"];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
    NSDictionary *valueCountDic = @{@"FriendCount":@(_friendList.count)};
    [_tableView setAccessibilityValue:[[STIMJSONSerializer sharedInstance] serializeObject:valueCountDic]];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = [[[STIMDatasourceItemManager sharedInstance] getSTIMMergedRootBranch] count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = [[[STIMDatasourceItemManager sharedInstance] getSTIMMergedRootBranch] objectAtIndex:indexPath.row];
    STIMDatasourceItem *item = [[STIMDatasourceItemManager sharedInstance] getTotalDataSourceItemWithId:key];
    if (!item) {
        item = [[STIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    CGFloat height = (item.childNodesDict.count > 0) ? 38 : 60;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = [[[STIMDatasourceItemManager sharedInstance] getSTIMMergedRootBranch] objectAtIndex:indexPath.row];
    STIMDatasourceItem *item = [[[STIMDatasourceItemManager sharedInstance] getTotalItems] objectForKey:key];
    if (!item) {
        item = [[STIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    if (item.childNodesDict.count > 0) {
        
        NSString *cellIdentifier1 = [NSString stringWithFormat:@"CONTACT_BUDDY_TITLE_%ld", (long)[item nLevel]];
        STIMBuddyTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell == nil) {
            cell = [[STIMBuddyTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
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
        STIMBuddyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[STIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        NSString * userName  =  item.nodeName;
        NSString *jid      =   item.jid;
        NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
        [cell initSubControls];
        [cell setNLevel:[userName componentsSeparatedByString:@"/"].count];
        [cell setUserName:remarkName?remarkName:userName];
        [cell setJid:jid];
        [cell refrash];
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [[[STIMDatasourceItemManager sharedInstance] getSTIMMergedRootBranch] objectAtIndex:indexPath.row];
    
    STIMDatasourceItem *item = [[[STIMDatasourceItemManager sharedInstance] getTotalItems] objectForKey:key];
    if (!item) {
        item = [[STIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    if (item.childNodesDict.count > 0) {
        if ([item isExpand]) {
            //合起
            [[STIMDatasourceItemManager sharedInstance] collapseBranchAtIndex:indexPath.row];
            id cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[STIMBuddyTitleCell class]]) {
                [cell setExpanded:NO];
                [_tableView reloadData];
            }
        } else {
            //展开
            [[STIMDatasourceItemManager sharedInstance] expandBranchAtIndex:indexPath.row];
            id cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[STIMBuddyTitleCell class]]) {
                [cell setExpanded:YES];
                [_tableView reloadData];
            }
        }
    } else {
        STIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
        if (item.isParentNode) {
            STIMFriendTitleListCell *titleCell = [tableView cellForRowAtIndexPath:indexPath];
            [titleCell setExpanded:!titleCell.isExpanded];
            if (item.isFriend) {
                _friendIsExpanded = titleCell.isExpanded;
            } else {
                _blackIsExpanded = titleCell.isExpanded;
            }
            NSInteger loc = indexPath.row+1;
            NSInteger len = [item.contentValue count];
            if (titleCell.isExpanded) {
                [_dataSource insertObjects:item.contentValue atIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(loc,len)]];
            } else {
                [_dataSource removeObjectsInArray:item.contentValue];
            }
            [_tableView reloadData];
        } else {
            NSString *jid = [item.contentValue objectForKey:@"XmppId"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [STIMFastEntrance openUserCardVCByUserId:jid];
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

@end

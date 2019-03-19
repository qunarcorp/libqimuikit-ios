//
//  QIMFriendListViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMFriendListViewController.h"
#import "QIMJSONSerializer.h"
#import "QIMFriendNodeItem.h"
#import "QIMFriendListCell.h"
#import "QIMFriendTitleListCell.h"
#import "QIMAddIndexViewController.h"
#import "QIMAddSomeViewController.h"
#import "QIMDatasourceItemManager.h"
#import "QIMDatasourceItem.h"
#import "QIMBuddyTitleCell.h"
#import "QIMBuddyItemCell.h"
#import "NSBundle+QIMLibrary.h"
#import "SearchBar.h"

#define kKeywordSearchBarHeight 44

@interface QIMFriendListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    UITableView *_tableView;
    NSMutableArray *_friendList;
    NSMutableArray *_dataSource;
    BOOL _friendIsExpanded;
    BOOL _blackIsExpanded;
    BOOL _rosterIsExpanded;
}

@property (nonatomic, strong) SearchBar *searchBarKeyTmp;

@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation QIMFriendListViewController


- (void)loadRosterList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
        if ([[[[QIMDatasourceItemManager sharedInstance] getTotalItems] allKeys] count] <= 0) {
            [[QIMDatasourceItemManager sharedInstance] createDataSource];
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
    for (NSDictionary *infoDic in [[QIMKit sharedInstance] selectFriendList]) {
        NSString *jid = [infoDic objectForKey:@"XmppId"];
        QIMFriendNodeItem *item = [[QIMFriendNodeItem alloc] init];
        [item setIsParentNode:NO];
        [item setName:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
        [item setContentValue:infoDic];
        [_friendList addObject:item];
    }
    [[_friendList lastObject] setIsLast:YES];
    
    QIMFriendNodeItem *friendNode = [[QIMFriendNodeItem alloc] init];
    [friendNode setIsParentNode:YES];
    [friendNode setIsFriend:YES];
    [friendNode setName:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
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
    
    [self.view setBackgroundColor:[UIColor qim_colorWithHex:0xeaeaea alpha:1]];
    
    _dataSource = [NSMutableArray array];
    _friendList = [NSMutableArray array];
    _searchResults = [NSMutableArray array];
    [self updateFriendList];
    [self initWithNav];
    [self initWithTableView];
    [self setupSearchBar];
}

- (void)setUseShare:(BOOL)useShare {
    _useShare = useShare;
    _commonFriendAndOrgan = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (_searchResults.count == 0) {
        _searchBarKeyTmp.text = nil;
        //        [self searchBar:_searchBarKeyTmp textDidChange:nil];
        [_searchBarKeyTmp resignFirstResponder];
    }
    return NO;
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
    if (self.onlyShowOrgan || self.commonFriendAndOrgan) {
        [self loadRosterList];
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - init UI

- (void)onAddClick {
    
    QIMAddIndexViewController *indexVC = [[QIMAddIndexViewController alloc] init];
    [self.navigationController pushViewController:indexVC animated:YES];
}

- (void)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initWithNav {
    if (self.onlyShowOrgan) {
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
    } else if (self.commonFriendAndOrgan) {
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_contact"]];
    } else if (self.useShare) {
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_contact"]];
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
        [[self navigationItem] setRightBarButtonItem:rightBar];
    } else {
        [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_add"] style:UIBarButtonItemStyleDone target:self action:@selector(onAddClick)];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
}

-(void)setupSearchBar{
    _searchBarKeyTmp = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
    [_searchBarKeyTmp setPlaceHolder:[NSBundle qim_localizedStringForKey:@"common_search_tips"]];
    [_searchBarKeyTmp setReturnKeyType:UIReturnKeySearch];
    [_searchBarKeyTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBarKeyTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBarKeyTmp setDelegate:self];
    [_searchBarKeyTmp setText:nil];
    [_searchBarKeyTmp setFrame:CGRectMake(0, 0, self.view.frame.size.width, kKeywordSearchBarHeight)];
    [_tableView setTableHeaderView:_searchBarKeyTmp];
}

- (void)initWithTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAccessibilityIdentifier:@"FriendList"];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:_tableView];
    NSDictionary *valueCountDic = @{@"FriendCount":@(_friendList.count)};
    [_tableView setAccessibilityValue:[[QIMJSONSerializer sharedInstance] serializeObject:valueCountDic]];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.onlyShowFriend) {
        return 1;
    } else if (self.onlyShowOrgan) {
        return 1;
    } else if (self.commonFriendAndOrgan) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.onlyShowFriend) {
        return _dataSource.count;
    } else if (self.onlyShowOrgan) {
        NSInteger count = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] count];
        return count;
    } else if (self.commonFriendAndOrgan) {
        if (section == 0) {
            return _dataSource.count;
        } else {
            NSInteger count = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] count];
            return count;
        }
    } else if (_searchResults.count > 0) {
        return _searchResults.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.onlyShowFriend) {
        //只展示好友列表
        return [self getFriendHeightWithIndexPath:indexPath];
    } else if (self.onlyShowOrgan) {
        //只展示组织架构
        return [self getOrganHeightWithIndexPath:indexPath];
        
    } else if (self.commonFriendAndOrgan) {
        if (indexPath.section == 0) {
            //展示好友列表
            return [self getFriendHeightWithIndexPath:indexPath];
        } else {
            //展示组织架构
            return [self getOrganHeightWithIndexPath:indexPath];
        }
    } else {
        
    }
    if (_searchResults.count > 0) {
        
    } else {
        return 30;
    }
    return 0;
}

- (CGFloat)getFriendHeightWithIndexPath:(NSIndexPath *)indexPath {
    QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
    if (item.isParentNode) {
        return [QIMFriendTitleListCell getCellHeight];
    } else {
        QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
        return [QIMFriendListCell getCellHeightForDesc:[item.contentValue objectForKey:@"DescInfo"]];
    }
}

- (CGFloat)getOrganHeightWithIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] objectAtIndex:indexPath.row];
    QIMDatasourceItem *item = [[QIMDatasourceItemManager sharedInstance] getTotalDataSourceItemWithId:key];
    if (!item) {
        item = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    CGFloat height = (item.childNodesDict.count > 0) ? 38 : 60;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.onlyShowFriend) {
        //只展示好友列表
        UITableViewCell *cell = [self getFriendCellWithIndexPath:indexPath];
        return cell;
    } else if (self.onlyShowOrgan) {
        //只展示组织架构
        UITableViewCell *cell = [self getOrganizationalCellWithIndexPath:indexPath];
        return cell;
    } else if (self.commonFriendAndOrgan) {
        
        //先好友再组织架构
        if (indexPath.section == 0) {
            //好友列表
            UITableViewCell *cell = [self getFriendCellWithIndexPath:indexPath];
            return cell;
        } else {
            
            //组织架构
            UITableViewCell *cell = [self getOrganizationalCellWithIndexPath:indexPath];
            return cell;
        }
    } else if (self.searchResults.count > 0) {
        
        //搜索单人
        NSString *searchUserCell = [NSString stringWithFormat:@"Search User Cell"];
        QIMBuddyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:searchUserCell];
        if (cell == nil) {
            cell = [[QIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchUserCell];
        }
        [cell initSubControls];
        NSString *jid = [[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"XmppId"];
        NSString * remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
        [cell setUserName:remarkName?remarkName:[[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"Name"]];
        [cell setJid:jid];
        [cell refrash];
        return  cell;
    } else {
        //单人
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.onlyShowFriend) {
        [self didSelectFriendWithIndexPath:indexPath];
    } else if (self.onlyShowOrgan) {
        [self didSelectOrganWithIndexPath:indexPath];
    } else if (self.commonFriendAndOrgan) {
        if (indexPath.section == 0) {
            [self didSelectFriendWithIndexPath:indexPath];
        } else {
            [self didSelectOrganWithIndexPath:indexPath];
        }
    } else {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001f;
}

- (UITableViewCell *)getFriendCellWithIndexPath:(NSIndexPath *)indexPath {
    //好友列表
    QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
    if (item.isParentNode) {
        NSString *cellIdentifier = @"Parent Node Cell";
        QIMFriendTitleListCell *titleCell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (titleCell == nil) {
            titleCell = [[QIMFriendTitleListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (item.isFriend) {
            [titleCell setExpanded:_friendIsExpanded];
        } else {
            [titleCell setExpanded:_blackIsExpanded];
        }
        [titleCell setTitle:item.name];
        [titleCell setDesc:item.descInfo];
        [titleCell refresh];
        return titleCell;
    } else {
        NSString *cellIdentifier = @"Node Cell";
        QIMFriendListCell *nodeCell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nodeCell == nil) {
            nodeCell = [[QIMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [nodeCell setUserInfoDic:item.contentValue];
        [nodeCell setIsLast:item.isLast];
        [nodeCell refreshUI];
        return nodeCell;
    }
}

- (UITableViewCell *)getOrganizationalCellWithIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] objectAtIndex:indexPath.row];
    QIMDatasourceItem *item = [[[QIMDatasourceItemManager sharedInstance] getTotalItems] objectForKey:key];
    if (!item) {
        item = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    if (item.childNodesDict.count > 0) {
        
        NSString *cellIdentifier1 = [NSString stringWithFormat:@"CONTACT_BUDDY_TITLE_%ld", (long)[item nLevel]];
        QIMBuddyTitleCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
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
        QIMBuddyItemCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        NSString * userName  =  item.nodeName;
        NSString *jid      =   item.jid;
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
        [cell initSubControls];
        [cell setNLevel:[userName componentsSeparatedByString:@"/"].count];
        [cell setUserName:remarkName?remarkName:userName];
        [cell setJid:jid];
        [cell refrash];
        
        return cell;
    }
}

- (void)didSelectFriendWithIndexPath:(NSIndexPath *)indexPath {
    QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
    if (item.isParentNode) {
        QIMFriendTitleListCell *titleCell = [_tableView cellForRowAtIndexPath:indexPath];
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
        if (self.useShare) {
            if (self.shareDelegate && [self.shareDelegate respondsToSelector:@selector(selectShareContactWithXmppJid:)]) {
                [self.shareDelegate selectShareContactWithXmppJid:jid];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [QIMFastEntrance openUserCardVCByUserId:jid];
            });
        }
    }
}

- (void)didSelectOrganWithIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[QIMDatasourceItemManager sharedInstance] getQIMMergedRootBranch] objectAtIndex:indexPath.row];
    
    QIMDatasourceItem *item = [[[QIMDatasourceItemManager sharedInstance] getTotalItems] objectForKey:key];
    if (!item) {
        item = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:key];
    }
    if (item.childNodesDict.count > 0) {
        if ([item isExpand]) {
            //合起
            [[QIMDatasourceItemManager sharedInstance] collapseBranchAtIndex:indexPath.row];
            id cell = [_tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[QIMBuddyTitleCell class]]) {
                [cell setExpanded:NO];
                [_tableView reloadData];
            }
        } else {
            //展开
            [[QIMDatasourceItemManager sharedInstance] expandBranchAtIndex:indexPath.row];
            id cell = [_tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[QIMBuddyTitleCell class]]) {
                [cell setExpanded:YES];
                [_tableView reloadData];
            }
        }
    } else {
        //普通用户或者无子结点
        NSString *xmppId = item.jid;
        if (self.useShare) {
            if (self.shareDelegate && [self.shareDelegate respondsToSelector:@selector(selectShareContactWithXmppJid:)]) {
                [self.shareDelegate selectShareContactWithXmppJid:xmppId];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [QIMFastEntrance openUserCardVCByUserId:xmppId];
            });
        }
    }
}

- (void)searchBarTextDidBeginEditing:(SearchBar *)SectionSearchBar
{
}
- (void)searchBar:(SearchBar *)SectionSearchBar textDidChange:(NSString *)searchText {
}

- (void)searchBarTextDidEndEditing:(SearchBar *)searchBar {
    //    if (searchBar.text.length <= 0) {
    //        [_searchResults removeAllObjects];
    //        [_tableView reloadData];
    //    }
}

- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)searchBarBarButtonClicked:(SearchBar *)SectionSearchBar
{
    // 取消焦点
}

- (void)searchBarBackButtonClicked:(SearchBar *)SectionSearchBar
{
    
}

- (void)searchBarSearchButtonClicked:(SearchBar *)SectionSearchBar
{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidChange:(NSInteger)index
{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidClicked:(NSInteger)index
{
    // 取消焦点
    [self cancelInputSearchKeyWord:SectionSearchBar];
}

//取消搜索
- (void)cancelInputSearchKeyWord:(id)sender
{
    
}

// 进入搜索
- (void)enterInputSearchKeyWord
{
    
}

@end

//
//  STIMPGroupSelectionView.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/16.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "STIMPGroupSelectionView.h"

#import "HeadView.h"
#import "STIMBuddyItemCell.h"
#import "NSBundle+STIMLibrary.h"
#import "STIMPGroupSelectionCell.h"
#import "SearchBar.h"
#import "STIMContactDatasourceManager.h"
#import "STIMDatasourceItem.h"
#import "STIMBuddyTitleCell.h"
#import "STIMFriendNodeItem.h"

#define kKeywordSearchBarHeight 44

@interface STIMPGroupSelectionView ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SearchBarDelgt,UIGestureRecognizerDelegate>

{
    
    UITableView *_tableView;
    
    NSMutableArray * _dataSource;
    NSMutableArray * _frientList;
    NSMutableDictionary *_rosterInfo;
    
    NSMutableDictionary  * openActionDictionary;
    
    
    BOOL             _isShowContactList;
    
    
    UIButton   *      _joinToGroupBtn;
    
    NSMutableArray *  _groupIDArray;
    
    NSMutableArray *searchResults;
    
    SearchBar * _searchBarKeyTmp;
}

@property (nonatomic, strong) NSMutableSet *existsMember;

@property (nonatomic, strong) NSMutableSet *newInviteMember;

@end


@interface STIMPGroupSelectionView (HeadViewDelegate) <HeadViewDelegate>

@end

@implementation STIMPGroupSelectionView (HeadViewDelegate)

- (void)clickHeadViewWithSection:(NSInteger) secion {
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:[_dataSource objectAtIndex:secion]];
    BOOL isOpened = [[item objectForKey:@"opened"] boolValue];
    [item setObject:@(!isOpened) forKey:@"opened"];
    [_dataSource replaceObjectAtIndex:secion withObject:item];
    [_tableView reloadData];
}

@end

@implementation STIMPGroupSelectionView

#pragma mark - setter and getter

- (NSMutableSet *)existsMember {
    if (!_existsMember) {
        _existsMember = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _existsMember;
}

- (NSMutableSet *)newInviteMember {
    if (!_newInviteMember) {
        _newInviteMember = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _newInviteMember;
}

- (void)initNSNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addPersonToGroup:)
                                                 name:@"ADD_PERSON_TO_GROUP"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deletePersonToGroup:)
                                                 name:@"DELETE_PERSON_TO_GROUP"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNSNotifications];
    _isShowContactList = NO;
    [self initNavbar];
    [self initTableView];
    
    [self setupSearchBar];
    
    [self loadContractList];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tempClick:)];
    
    [tap setDelegate:self];
    
    [self.view addGestureRecognizer:tap];
    
    _groupIDArray = [NSMutableArray array];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public method

- (void)setAlreadyExistsMember:(NSArray *) members withGroupId:(NSString *) groupId {

    [self.existsMember removeAllObjects];
    _groupID = groupId;
    
    [self.existsMember addObjectsFromArray:members];
}

#pragma mark  - load contact list data
-(void)loadContractList {
    
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
           _frientList = [[STIMKit sharedInstance] selectFriendList];
       }
       dispatch_async(dispatch_get_main_queue(), ^{
           [_tableView reloadData];
       });
   });    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([searchResults count] > 0) {
        return 60;
    }else if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat){
        return 60;
    }
    STIMDatasourceItem * item  = [[[STIMContactDatasourceManager getInstance] QtalkDataSourceItem]  objectAtIndex:indexPath.row];
    
    CGFloat height  = item.isParentNode ? 35 : 60;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        return nil;
    }
    
    if (_isShowContactList) {
        static NSString *headIdentifier = @"header";
        
        HeadView *headView = (HeadView *)[tableView dequeueReusableCellWithIdentifier:headIdentifier];
        if (headView == nil) {
            headView = [[HeadView alloc] initWithReuseIdentifier:headIdentifier];
            
            
            [headView setDelegate:self];
        }
        
        NSDictionary *info = [_dataSource objectAtIndex:section];
        [headView  setTitle:[info objectForKey:@"name"]
                     online:[[info objectForKey:@"online"] intValue]
                      count:[[info objectForKey:@"total"] intValue]];
        [headView setSection:section];
        return headView;
    }
    return nil;
}


#pragma mark - tableView dataSounce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([searchResults count] > 0) {
        
        NSInteger rowNum = [searchResults count];
        
        return rowNum;
    } else if([STIMKit getSTIMProjectType] == STIMProjectTypeQChat){
        return _frientList.count;
    }
    int count = (int)[[[STIMContactDatasourceManager getInstance] QtalkDataSourceItem] count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([searchResults count] > 0) {
        static NSString *cellIdentifier2 = @"CONTACT_BUDDY";
        STIMPGroupSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[STIMPGroupSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            [cell initSubControls];
        }
        
        [cell setUserName:[[searchResults objectAtIndex:[indexPath row]] objectForKey:@"Name"]];
        
        NSString *jid = [[searchResults objectAtIndex:[indexPath row]] objectForKey:@"XmppId"];
        [cell setNlevel:1];
        [cell setJid:jid];
        [cell refrash];
        [cell setStatus:[self.newInviteMember containsObject:jid]];
        [cell setSelectedEnabled:[self.existsMember containsObject:jid]];
        return  cell;
    } else if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat){
        
        static NSString *cellIdentifier2 = @"CONTACT_BUDDY";
        STIMPGroupSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[STIMPGroupSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            [cell initSubControls];
        }
        
        [cell setUserName:[[_frientList objectAtIndex:[indexPath row]] objectForKey:@"Name"]];
        NSString *jid = [[_frientList objectAtIndex:[indexPath row]] objectForKey:@"XmppId"];
        [cell setNlevel:1];
        [cell setJid:jid];
        [cell refrash];
        [cell setStatus:[self.newInviteMember containsObject:jid]];
        [cell setSelectedEnabled:[self.existsMember containsObject:jid]];
        return cell;
    }
     
    STIMDatasourceItem * item = [[[STIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
    
    if (item.isParentNode) {
        
        NSString *cellIdentifier2 = [NSString stringWithFormat:@"Cell Title Level {%d}",(int)item.nLevel];
        STIMBuddyTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[STIMBuddyTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            [cell setNLevel:(int)item.nLevel];
            [cell initSubControls];
        }
        NSString *userName  =  item.nodeName;
        [cell setUserName:userName];
        [cell setExpanded:item.isExpand];
        [cell refresh];
        return cell;
        
    } else{
        
        NSString *cellIdentifier2 = [NSString stringWithFormat:@"Cell PGroup Level {%d}",(int)item.nLevel];
        STIMPGroupSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            
            cell = [[STIMPGroupSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            [cell setNlevel:(int)item.nLevel];
            [cell initSubControls];
        }
        
        NSString *userName = item.nodeName;
        NSString *jid = item.jid;
        
        [cell setUserName:userName];
        [cell setJid:jid];
        [cell refrash];
        [cell setStatus:[self.newInviteMember containsObject:jid]];
        [cell setSelectedEnabled:[self.existsMember containsObject:jid]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([searchResults count] > 0) {
        
        return;
    } else if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat){
        
        return;
    }
    
    if ([[[STIMContactDatasourceManager getInstance] QtalkDataSourceItem] count] > 0 ) {
        
        STIMDatasourceItem *qtalkItem = [[[STIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
        if ([qtalkItem isParentNode]) {
            
            if ([qtalkItem isExpand]) {
                
                [[STIMContactDatasourceManager getInstance] collapseBranchAtIndex:indexPath.row];
                
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                
                if ([cell isKindOfClass: [STIMBuddyTitleCell class]]) {
                    
                    [cell setExpanded:NO];
                    
                    [_tableView reloadData];
                }
            } else {
                
                [[STIMContactDatasourceManager getInstance] expandBranchAtIndex:indexPath.row];
                
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                
                if ([cell isKindOfClass:[STIMBuddyTitleCell class]]) {
                    
                    [cell setExpanded:YES];
                    
                    [_tableView reloadData];
                }
            }
        }
    }
}

- (void)initTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)
                                              style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    [_tableView reloadData];
}

- (void)initNavbar {
    
    [self.navigationItem setTitle:@"添加群成员"];
    NSString *title = [NSBundle stimDB_localizedStringForKey:@"Confirm"];
    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:16] forWidth:INT16_MAX lineBreakMode:NSLineBreakByCharWrapping];
    _joinToGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,size.width,30)];
    [_joinToGroupBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_joinToGroupBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] forState:UIControlStateNormal];
    //TODO Startalk start
//    [_joinToGroupBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
//    [_joinToGroupBtn setTitleColor:[UIColor stimDB_colorWithHex:0xc1c1c1 alpha:1] forState:UIControlStateDisabled];
    [_joinToGroupBtn setTitleColor:[UIColor spectralColorWhiteColor] forState:UIControlStateNormal];
    [_joinToGroupBtn setTitleColor:[UIColor stimDB_colorWithHex:0xDDDDDD alpha:1] forState:UIControlStateDisabled];
    //TODO Startalk end
    [_joinToGroupBtn addTarget:self action:@selector(joinGroupById:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_joinToGroupBtn];
    [self.navigationItem setRightBarButtonItem:rightItem];
    [_joinToGroupBtn setEnabled:NO];
}

- (void)goBack:(id)sender {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addPersonToGroup:(NSNotification *)notification {
    
   NSString *personId = (NSString *)[notification object];
    
    [_groupIDArray addObject:personId];
    [self.newInviteMember addObject:personId];
    
    NSString *title  = [NSString stringWithFormat:@"确定(%lu)",(unsigned long)[_groupIDArray count]];
    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:16] forWidth:INT16_MAX lineBreakMode:NSLineBreakByCharWrapping];
    [_joinToGroupBtn setWidth:size.width];
    [_joinToGroupBtn setTitle:title forState:UIControlStateNormal];
    
    if ([_groupIDArray count] > 0) {
        
        [_joinToGroupBtn setEnabled:YES];
    }
}

- (void)deletePersonToGroup:(NSNotification *)notification {
    
    NSString *groupID = (NSString *)[notification object];
    
    [_groupIDArray removeObject:groupID];
    [self.newInviteMember removeObject:groupID];
    
    if ([_groupIDArray count] > 0) {
        
        [_joinToGroupBtn setEnabled:YES];
        NSString * title  = [NSString stringWithFormat:@"确定(%lu)",(unsigned long)[_groupIDArray count]];
        [_joinToGroupBtn  setTitle:title forState:UIControlStateNormal];
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:16] forWidth:INT16_MAX lineBreakMode:NSLineBreakByCharWrapping];
        [_joinToGroupBtn setWidth:size.width];
    } else {
        
        [_joinToGroupBtn setEnabled:NO];
        NSString * title  = [NSBundle stimDB_localizedStringForKey:@"Confirm"];
        [_joinToGroupBtn  setTitle:title forState:UIControlStateNormal];
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:16] forWidth:INT16_MAX lineBreakMode:NSLineBreakByCharWrapping];
        [_joinToGroupBtn setWidth:size.width];
        [_joinToGroupBtn  setTitle:title forState:UIControlStateNormal];
    }
}

- (void)joinGroupById:(id)sender {
    
    if ([_groupIDArray count] > 0 && ([self.groupID length] > 0) && self.existGroup) {
        
        __weak STIMPGroupSelectionView *weakView = self;
        [[STIMKit sharedInstance] joinGroupWithBuddies:self.groupID groupName:self.groupName WithInviteMember:_groupIDArray withCallback:^{
            [weakView goBack:nil];
        }];
    } else {
        
        if ([_groupIDArray count] > 0) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectionBuddiesArrays:)]) {
                
                [self.delegate selectionBuddiesArrays:_groupIDArray];
            }
        }
        [self goBack:nil];
    }
}


- (void)setupSearchBar {
    
    CGFloat spaceYStart = 64.0f;
    
    // =======================================================================
    // SectionSearchBar
    // =======================================================================
    // 创建SectionSearchBar
    _searchBarKeyTmp = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
    [_searchBarKeyTmp setPlaceHolder:[NSBundle stimDB_localizedStringForKey:@"common_search_tips"]];
    [_searchBarKeyTmp setReturnKeyType:UIReturnKeySearch];
    [_searchBarKeyTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBarKeyTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBarKeyTmp setDelegate:self];
    [_searchBarKeyTmp setText:nil];
    [_searchBarKeyTmp setFrame:CGRectMake(0, spaceYStart, self.view.frame.size.width, kKeywordSearchBarHeight)];
    
    // 调整子窗口高宽
    spaceYStart += [_searchBarKeyTmp frame].size.height;
    
    // 保存
    [_tableView setTableHeaderView:_searchBarKeyTmp];
}

// =======================================================================
#pragma mark - SectionSearchBar代理函数
// =======================================================================
- (void)searchBarTextDidBeginEditing:(SearchBar *)SectionSearchBar {
    
    //[self enterInputSearchKeyWord];
}

- (void)searchBar:(SearchBar *)SectionSearchBar textDidChange:(NSString *)searchText {
    
    if (searchResults == nil) {
        
        searchResults = [[NSMutableArray alloc]init];
    }
    
    [searchResults removeAllObjects];
    if (searchText.length > 0) {
        [searchResults addObjectsFromArray:[[STIMKit sharedInstance] searchUserListBySearchStr:searchText]];
    }
       
    [_tableView reloadData];
}

- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(SearchBar *)SectionSearchBar {
    
}

- (void)searchBarBarButtonClicked:(SearchBar *)SectionSearchBar {
    // 取消焦点
    [SectionSearchBar resignFirstResponder];
}

- (void)searchBarBackButtonClicked:(SearchBar *)SectionSearchBar {
    
}

- (void)searchBarSearchButtonClicked:(SearchBar *)SectionSearchBar {
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidChange:(NSInteger)index {
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidClicked:(NSInteger)index {
    // 取消焦点
    // [self cancelInputSearchKeyWord:SectionSearchBar];
}

//取消搜索
- (void)cancelInputSearchKeyWord:(id)sender {
    
}

// 进入搜索
- (void)enterInputSearchKeyWord {
    
}

//隐藏键盘逻辑
-(void)tempClick:(UITapGestureRecognizer *)tap {
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (searchResults.count == 0) {
        _searchBarKeyTmp.text = nil;
        //    [self searchBar:_searchBarKeyTmp textDidChange:nil];
        [_searchBarKeyTmp resignFirstResponder];
    }
    return NO;
}

@end

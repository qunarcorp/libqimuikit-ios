//
//  STIMWorkFeedAtNotifyViewController.m
//  STIMUIKit
//
//  Created by lilu on 2019/2/27.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkFeedAtNotifyViewController.h"
#import "STIMWorkFeedAtUserTableViewCell.h"
#import "SearchBar.h"
#import "NSBundle+STIMLibrary.h"
#import <MJRefresh/MJRefresh.h>

@interface STIMWorkFeedAtNotifyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UIButton *complateBtn;

@property (nonatomic, strong) SearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, copy) onSTIMWorkFeedSelectUserBlock callbackBlock;


@end

@implementation STIMWorkFeedAtNotifyViewController

#pragma mark - setter and getter

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.estimatedRowHeight = 0;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        _mainTableView.estimatedSectionFooterHeight = 0;
        _mainTableView.backgroundColor = [UIColor stimDB_colorWithHex:0xf5f5f5 alpha:1.0];
        _mainTableView.tableFooterView = [UIView new];
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _mainTableView;
}

- (SearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
        [_searchBar setPlaceHolder:[NSBundle stimDB_localizedStringForKey:@"common_search_tips"]];
        [_searchBar setReturnKeyType:UIReturnKeySearch];
        [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_searchBar setDelegate:self];
        [_searchBar setText:nil];
        [_searchBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
    }
    return _searchBar;
}

- (NSMutableArray *)selectUsers {
    if (!_selectUsers) {
        _selectUsers = [NSMutableArray arrayWithCapacity:3];
    }
    return _selectUsers;
}

- (UIButton *)complateBtn {
    if (!_complateBtn) {
        _complateBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_complateBtn setTitleColor:[UIColor stimDB_colorWithHex:0x4DC1B5] forState:UIControlStateNormal];
        [_complateBtn setTitle:@"完成" forState:UIControlStateNormal];
        _complateBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_complateBtn addTarget:self action:@selector(complateClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _complateBtn;
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWithNav];
    [self.view addSubview:self.mainTableView];
    [self.mainTableView setTableHeaderView:self.searchBar];
}

- (void)initWithNav {
    [self.navigationItem setTitle:[NSBundle stimDB_localizedStringForKey:@"moment_mention"]];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.complateBtn];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)goBack:(id)sender {
    self.callbackBlock(self.selectUsers);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)complateClick:(id)sender {
    self.callbackBlock(self.selectUsers);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)onSTIMWorkFeedSelectUser:(onSTIMWorkFeedSelectUserBlock)block {
    self.callbackBlock = block;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    STIMWorkFeedAtUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[STIMWorkFeedAtUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSMutableDictionary * dict  =  [_searchResults objectAtIndex:indexPath.row];
    NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:[dict objectForKey:@"XmppId"]];
    NSString *userXmppJid = [dict objectForKey:@"XmppId"];
    [cell setUserXmppId:userXmppJid];
    [cell setUserName:remarkName?remarkName:[dict objectForKey:@"Name"]];
    [cell refreshUI];
    [cell setUserSelected:[self.selectUsers containsObject:userXmppJid]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [STIMWorkFeedAtUserTableViewCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    STIMWorkFeedAtUserTableViewCell *cell = (STIMWorkFeedAtUserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setUserSelected:YES];
    NSMutableDictionary *dict = [_searchResults objectAtIndex:indexPath.row];
    NSString *name = [dict objectForKey:@"Name"];
    NSString *jid = cell.userXmppId;
    NSDictionary *memberInfoDic = @{@"name":name.length?name:@"", @"jid":jid.length?jid:@""};
    if (jid.length > 0 && ![self.selectUsers containsObject:jid]) {
        [self.selectUsers addObject:jid];
        [cell setUserSelected:YES];
    } else {
        [self.selectUsers removeObject:jid];
        [cell setUserSelected:NO];
    }
}

@end

@interface STIMWorkFeedAtNotifyViewController (Search) <SearchBarDelgt>

@end


@implementation STIMWorkFeedAtNotifyViewController (Search)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[STIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    } else {
        return YES;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[STIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ([[STIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}

// =======================================================================
#pragma mark - SectionSearchBar代理函数
// =======================================================================
- (void)searchBarTextDidBeginEditing:(SearchBar *)SectionSearchBar {
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar textDidChange:(NSString *)searchText {
    if (_searchResults == nil) {
        _searchResults = [[NSMutableArray alloc]init];
    }
    [_searchResults removeAllObjects];
    BOOL hasChinese = [searchText stimDB_checkIsChinese];
    if (hasChinese && searchText.length >= 2) {
        NSArray *searchUsers = [[STIMKit sharedInstance] selectUserListExMySelfBySearchStr:searchText WithLimit:20 WithOffset:0];
        [_searchResults addObjectsFromArray:searchUsers];
        STIMVerboseLog(@"_searchResults :%d", _searchResults.count);
    } else if (searchText.length >= 4){
        NSArray *searchUsers = [[STIMKit sharedInstance] selectUserListExMySelfBySearchStr:searchText WithLimit:20 WithOffset:0];
        [_searchResults addObjectsFromArray:searchUsers];
        STIMVerboseLog(@"_searchResults :%d", _searchResults.count);
    } else {
        
    }
    [self.mainTableView reloadData];
    if (_searchResults.count < 20 && _searchResults.count > 0) {
        [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)searchBarTextDidEndEditing:(SearchBar *)searchBar {
    
}

- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBarBarButtonClicked:(SearchBar *)SectionSearchBar {
    
    // 取消焦点
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

@end

//
//  QIMWorkFeedAtNotifyViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/2/27.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkFeedAtNotifyViewController.h"
#import "QIMAtUserTableViewCell.h"
#import "SearchBar.h"
#import "NSBundle+QIMLibrary.h"
#import <MJRefresh/MJRefresh.h>

@interface QIMWorkFeedAtNotifyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) SearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, copy) onQIMWorkFeedSelectUserBlock callbackBlock;


@end

@implementation QIMWorkFeedAtNotifyViewController

#pragma mark - setter and getter

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.estimatedRowHeight = 0;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        _mainTableView.estimatedSectionFooterHeight = 0;
        _mainTableView.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0];
        _mainTableView.tableFooterView = [UIView new];
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchMoreUsers)];
        _mainTableView.mj_footer.automaticallyHidden = YES;
    }
    return _mainTableView;
}

- (SearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
        [_searchBar setPlaceHolder:[NSBundle qim_localizedStringForKey:@"common_search_tips"]];
        [_searchBar setReturnKeyType:UIReturnKeySearch];
        [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_searchBar setDelegate:self];
        [_searchBar setText:nil];
        [_searchBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    }
    return _searchBar;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:3];
    }
    return _dataSource;
}

- (void)initUI {
    [self initWithNav];
    [self.view addSubview:self.mainTableView];
    [self.mainTableView setTableHeaderView:self.searchBar];
}

- (void)initWithNav {
    [self.navigationItem setTitle:@"选择提醒的人"];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:leftItem];
}

- (void)goBack:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.callbackBlock(@{});
        }];
    } else {
        //适配iPad Push进来
        self.callbackBlock(@{});
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)searchMoreUsers {
    NSArray *searchUsers = [[QIMKit sharedInstance] searchUserListBySearchStr:self.searchBar.text WithLimit:20 WithOffset:self.dataSource.count];
    if (searchUsers.count > 0) {
        [self.dataSource addObject:searchUsers];
        [self.mainTableView reloadData];
        [self.mainTableView.mj_footer endRefreshing];
    } else {
        [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)onQIMWorkFeedSelectUser:(onQIMWorkFeedSelectUserBlock)block {
    self.callbackBlock = block;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchBar.text.length > 0) {
        return _searchResults.count;
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    QIMAtUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QIMAtUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.searchBar.text.length > 0) {
        NSMutableDictionary * dict  =  [_searchResults objectAtIndex:indexPath.row];
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:[dict objectForKey:@"XmppId"]];
        
        [cell setJid:[dict objectForKey:@"XmppId"]];
        [cell setName:remarkName?remarkName:[dict objectForKey:@"Name"]];
        [cell refreshUI];
    } else {
        
        NSMutableDictionary * dict  =  [self.dataSource objectAtIndex:indexPath.row];
        NSString *jid = [dict objectForKey:@"xmppjid"];
        if (jid == nil) {
            jid = [dict objectForKey:@"jid"];
        }
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
        
        NSString *realUserName = [userInfo objectForKey:@"Name"];
        //备注
        if (!realUserName) {
            realUserName = [dict objectForKey:@"name"];
        }
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
        NSString * name  = remarkName?remarkName:realUserName;
        [cell setJid:jid];
        [cell setName:name];
        [cell refreshUI];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [QIMAtUserTableViewCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QIMAtUserTableViewCell *cell = (QIMAtUserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary * dict  = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString * name  = nil;
    if (self.searchBar.text.length > 0) {
        dict = [_searchResults objectAtIndex:indexPath.row];
        name = [dict objectForKey:@"Name"];
    } else {
        dict = [self.dataSource objectAtIndex:indexPath.row];
        name = [dict objectForKey:@"name"];
    }
    NSString *jid = cell.jid;
    NSDictionary *memberInfoDic = @{@"name":name.length?name:@"", @"jid":jid.length?jid:@""};
    if (self.callbackBlock != nil) {
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                self.callbackBlock(memberInfoDic);
            }];
        } else {
            self.callbackBlock(memberInfoDic);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end

@interface QIMWorkFeedAtNotifyViewController (Search)<SearchBarDelgt>

@end


@implementation QIMWorkFeedAtNotifyViewController (Search)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    } else {
        return YES;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ([[QIMKit sharedInstance] getIsIpad]) {
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
    if (searchText.length > 0) {
        NSArray *searchUsers = [[QIMKit sharedInstance] searchUserListBySearchStr:searchText WithLimit:20 WithOffset:0];
        [_searchResults addObjectsFromArray:searchUsers];
        QIMVerboseLog(@"_searchResults :%d", _searchResults.count);
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

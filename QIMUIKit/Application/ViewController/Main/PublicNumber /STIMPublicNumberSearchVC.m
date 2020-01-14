//
//  STIMPublicNumberSearchVC.m
//  STChatIphone
//
//  Created by admin on 15/8/28.
//
//

#import "STIMPublicNumberSearchVC.h"
#import "STIMPublicNumberCell.h"
#import "STIMPublicNumberCardVC.h"
#import "STIMJSONSerializer.h"
#import "NSBundle+STIMLibrary.h"
@interface STIMPublicNumberSearchVC ()<UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    NSArray *_searchDataSource;
    UISearchDisplayController *_mySearchDisplayController;
}

@end

@implementation STIMPublicNumberSearchVC


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initWithNav];
    [self initWithTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init UI
- (void)initWithNav{
    [self.navigationItem setTitle:[NSBundle stimDB_localizedStringForKey:@"common_search_public_number"]];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [self.view addSubview:_tableView];
    
    _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[self getSearchBar] contentsController:self];
    _mySearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mySearchDisplayController setDelegate:self];
    [_mySearchDisplayController setSearchResultsDataSource:self];
    [_mySearchDisplayController setSearchResultsDelegate:self];
    [_mySearchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setTableHeaderView:_mySearchDisplayController.searchBar];
    
}

- (UISearchBar *)getSearchBar
{
    UISearchBar *searchBar  = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [searchBar sizeToFit];
    [searchBar setShowsSearchResultsButton:YES];
    searchBar.placeholder = [NSBundle stimDB_localizedStringForKey:@"common_search_pn_tips"];
    [searchBar setTintColor:[UIColor spectralColorBlueColor]];
    if ([searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        [searchBar setBarTintColor:[UIColor stimDB_colorWithHex:0xe6e7e9 alpha:1.0]];
    }
    [searchBar setBackgroundImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"searchbar_bg"]];
    return searchBar;
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_mySearchDisplayController.searchResultsTableView]) {
        return _searchDataSource.count;
    } else {
        return _dataSource.count;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [STIMPublicNumberCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    STIMPublicNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[STIMPublicNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([tableView isEqual:_mySearchDisplayController.searchResultsTableView]) {
        NSString *body = [[_searchDataSource objectAtIndex:indexPath.row] objectForKey:@"rbt_body"];
        NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:body error:nil];
        [cell setPublicNumberId:[infoDic objectForKey:@"robotEnName"]];
        [cell setJid:[NSString stringWithFormat:@"%@@%@",cell.publicNumberId,[[STIMKit sharedInstance] getDomain]]];
        [cell setName:[infoDic objectForKey:@"robotCnName"]];
        [cell setHeaderSrc:[infoDic objectForKey:@"headerUrl"]];
        [cell refreshUI];
        return cell;
    } else {
        NSString *body = [_dataSource objectAtIndex:indexPath.row];
        NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:body error:nil];
        [cell setPublicNumberId:[infoDic objectForKey:@"robotEnName"]];
        [cell setJid:[NSString stringWithFormat:@"%@@%@",cell.publicNumberId,[[STIMKit sharedInstance] getDomain]]];
        [cell setName:[infoDic objectForKey:@"robotCnName"]];
        [cell setHeaderSrc:[infoDic objectForKey:@"headerUrl"]];
        [cell refreshUI];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *publicRobotDic = nil;
    if ([tableView isEqual:_mySearchDisplayController.searchResultsTableView]) {
        NSDictionary *dic = [_searchDataSource objectAtIndex:indexPath.row];
        NSMutableDictionary *pubDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        publicRobotDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[dic objectForKey:@"rbt_body"] error:nil];
        [pubDic setObject:publicRobotDic forKey:@"rbt_body"];
        publicRobotDic = pubDic;
    } else {
        NSString *body = [_dataSource objectAtIndex:indexPath.row];
        publicRobotDic = [[STIMJSONSerializer sharedInstance] deserializeObject:body error:nil];
    }
    
    STIMPublicNumberCell *cell = (STIMPublicNumberCell *)[tableView cellForRowAtIndexPath:indexPath];
    STIMPublicNumberCardVC *robotVC = [[STIMPublicNumberCardVC alloc] init];
    [robotVC setJid:cell.jid];
    [robotVC setPublicNumberId:cell.publicNumberId];
    [robotVC setTitle:cell.name];
    [robotVC setPublicRobotDic:publicRobotDic];
    if ([[STIMKit sharedInstance] getPublicNumberCardByJid:cell.jid]) {
        [robotVC setNotConcern:NO];
    } else {
        [robotVC setNotConcern:YES];
    }
    [self.navigationController pushViewController:robotVC animated:YES];
}

#pragma mark UISearchBar and UISearchDisplayController Delegate Methods
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    STIMVerboseLog(@"search text :%@",[searchBar text]);
    _searchDataSource = [[STIMKit sharedInstance] searchRobotByKeyStr:[searchBar text]];
    [_mySearchDisplayController.searchResultsTableView reloadData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{ 
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}


@end
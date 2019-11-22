//
//  STIMMySettingController.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "STIMMySettingController.h"
#import "STIMCommonTableViewCellData.h"
#import "STIMCommonTableViewCell.h"
#import "STIMCommonTableViewCellManager.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMMySettingController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) STIMCommonTableViewCellManager *tableViewManager;
@property (nonatomic) NSArray <NSArray<STIMCommonTableViewCellData *> *> *dataSource;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation STIMMySettingController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset=UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray arrayWithCapacity:5];
        [_titleArray addObjectsFromArray:@[@"通知", @"对话", @"", @"通用设置", @"", @"其他", @""]];
    }
    return _titleArray;
}

- (NSArray<NSArray<STIMCommonTableViewCellData *> *> *)dataSource {
    if (!_dataSource) {
        
        STIMCommonTableViewCellData *onlinePush = [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_myPush"] iconName:nil  cellDataType:STIMCommonTableViewCellDataTypeMessageOnlineNotification];
        STIMCommonTableViewCellData *mconfig = [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_mconfig"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeMconfig];
        NSArray<STIMCommonTableViewCellData *> *section0 = nil;
        if ([[[STIMKit sharedInstance] qimNav_GetPushState] length] > 0 && [STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
            section0 = @[onlinePush, [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_notify_tone"] iconName:nil   cellDataType:STIMCommonTableViewCellDataTypeMessageNotification]];
        } else {
            section0 = @[[[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_notify_tone"] iconName:nil   cellDataType:STIMCommonTableViewCellDataTypeMessageNotification]];
        }
        
        NSArray<STIMCommonTableViewCellData *> *section1 = @[
                                                     [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"explore_tab_personality_dress_up"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeDressUp],
                                                     [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_show_mood"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeShowSignature]
                                                     ];
//
        NSArray<STIMCommonTableViewCellData *> *section2 = @[[[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"explore_tab_history"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeSearchHistory],
                                                     [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"explore_tab_clear_message_list"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeClearSessionList]];
        NSArray<STIMCommonTableViewCellData *> *section3 = nil;
        if ([[[STIMKit sharedInstance] qimNav_Mconfig] length] > 0) {
            section3 = @[
                         mconfig,
                         [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_update_config"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeUpdateConfig]
                         ];
        } else {
            if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
                section3 = @[
                             [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_service"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeServiceMode],
                             [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_update_config"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeUpdateConfig]
                             ];
            } else {
                section3 = @[
                             [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_update_config"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeUpdateConfig]
                             ];
            }
        }
        NSArray<STIMCommonTableViewCellData *> *section4 = @[
                                                     [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_clear_image"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeClearCache]
                                                     ];
        NSArray<STIMCommonTableViewCellData *> *section5 = @[
                                                    [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Setting_tab_Help"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeFeedback],
                                                     [[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_about"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeAbout],
                                                     ];
        
        NSArray<STIMCommonTableViewCellData *> *section6 = @[[[STIMCommonTableViewCellData alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"myself_tab_quit_log"] iconName:nil cellDataType:STIMCommonTableViewCellDataTypeLogout]];
        
        _dataSource = @[section0, section1, section2, section3, section4, section5, section6];
    }
    return _dataSource;
}

- (STIMCommonTableViewCellManager *)tableViewManager {
    if (!_tableViewManager) {
        _tableViewManager = [[STIMCommonTableViewCellManager alloc] initWithRootViewController:self];
        _tableViewManager.dataSource = self.dataSource;
        _tableViewManager.dataSourceTitle = self.titleArray;
     }
    return _tableViewManager;
}

#pragma mark - NSNotification

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeImageCache:) name:kQCRemoveImageCachePathSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:kNotificationCurrentFontUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyOnlinePushFlag:) name:kNotificationUserOnLinePushFlagUpdate object:nil];
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.dataSource = self.tableViewManager;
    self.tableView.delegate = self.tableViewManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    [self registerObserver];
    [self.view addSubview:self.tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.dataSource = nil;
    self.tableViewManager = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - NSNotification

- (void)removeImageCache:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updateFont:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updateMyOnlinePushFlag:(NSNotification *)notify {
    [self.tableView reloadData];
}

@end

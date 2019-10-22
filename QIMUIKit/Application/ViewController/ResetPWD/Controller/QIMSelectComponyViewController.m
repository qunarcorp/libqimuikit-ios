//
//  QIMSelectComponyViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMSelectComponyViewController.h"
#import "YYKeyboardManager.h"
#import "QIMPublicCompanyModel.h"
#import "YYModel.h"

@interface QIMSelectComponyViewController () <UITableViewDelegate, UITableViewDataSource, YYKeyboardObserver, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *companyTextField;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UITableView *companyListView;

@property (nonatomic, strong) NSMutableArray *companies;

@property (nonatomic, assign) CGFloat keyboardOriginY;

@end

@implementation QIMSelectComponyViewController

#pragma mark - setter and getter

- (UITextField *)companyTextField {
    if (!_companyTextField) {
        _companyTextField = [[UITextField alloc] init];
        _companyTextField.placeholder = [NSBundle qim_localizedStringForKey:@"input_company_name"];
        _companyTextField.delegate = self;
        _companyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _companyTextField.backgroundColor = [UIColor whiteColor];
        [_companyTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _companyTextField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    }
    return _lineView;
}

- (UITableView *)companyListView {
    if (!_companyListView) {
        _companyListView = [[UITableView alloc] init];
        _companyListView.delegate = self;
        _companyListView.dataSource = self;
        _companyListView.backgroundColor = [UIColor whiteColor];
        _companyListView.showsVerticalScrollIndicator = YES;
        _companyListView.estimatedRowHeight = 0;
        _companyListView.estimatedSectionHeaderHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _companyListView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _companyListView.tableFooterView = [UIView new];
        
        _companyListView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);           //top left bottom right 左右边距相同
        _companyListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _companyListView.separatorColor = [UIColor qim_colorWithHex:0xE4E4E4];
        _companyListView.layer.cornerRadius = 3.0f;
        _companyListView.layer.borderColor = [UIColor qim_colorWithHex:0xE4E4E4].CGColor;
        _companyListView.layer.borderWidth = 1.0f;
        
        _companyListView.layer.shadowColor = [UIColor qim_colorWithHex:0x000000 alpha:0.08].CGColor;
        _companyListView.layer.shadowOffset = CGSizeMake(0, 5);
        _companyListView.layer.shadowOpacity = 1;
        _companyListView.layer.shadowRadius = 12.5;
        
        [self.view addSubview:_companyListView];
        [_companyListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lineView.mas_bottom).mas_offset(15);
            make.left.mas_equalTo(self.lineView.mas_left);
            make.right.mas_equalTo(self.lineView.mas_right);
            make.height.mas_equalTo(self.keyboardOriginY - self.lineView.bottom - 50);
        }];
    }
    return _companyListView;
}

- (NSMutableArray *)companies {
    if (!_companies) {
        _companies = [NSMutableArray arrayWithCapacity:3];
    }
    return _companies;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[YYKeyboardManager defaultManager] addObserver:self];
    UIImage *image = [UIImage qim_imageWithColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"Select_company"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x333333]}];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor qim_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
    [barItem setTintColor:[UIColor qim_colorWithHex:0x333333]];
    self.navigationItem.leftBarButtonItem = barItem;
    
    [self setupUI];
}

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGRect kbFrame1 = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    CGFloat kbFrameOriginY = CGRectGetMinY(kbFrame1);
    self.keyboardOriginY = kbFrameOriginY;
}

- (void)setupUI {
    [self.view addSubview:self.companyTextField];
    [self.companyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(50);
        make.left.mas_offset(33);
        make.right.mas_offset(-33);
        make.height.mas_equalTo(35);
    }];
    [self.view addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.companyTextField.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(self.companyTextField.mas_left);
        make.right.mas_equalTo(self.companyTextField.mas_right);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self.companyListView setHidden:YES];
}

- (QIMPublicCompanyModel *)getCompanyModelWithDic:(NSDictionary *)modelDic {
    QIMPublicCompanyModel *model = [QIMPublicCompanyModel yy_modelWithDictionary:modelDic];
    return model;
}

- (void)textFieldDidChange:(UITextField *)textField {
    //搜索公司
    if (textField.text.length > 0) {
        self.lineView.backgroundColor = [UIColor qim_colorWithHex:0x00CABE];
    } else {
        self.lineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    }
    if (textField.text.length > 0) {
        [[QIMKit sharedInstance] getPublicNavCompanyWithKeyword:textField.text withCallBack:^(NSArray *companies) {
            dispatch_async(dispatch_get_main_queue(), ^{
                QIMVerboseLog(@"companies : %@", companies);
                [self.companies removeAllObjects];
                for (NSDictionary *companyDic in companies) {
                    if ([companyDic isKindOfClass:[NSDictionary class]]) {
                        QIMPublicCompanyModel *model = [self getCompanyModelWithDic:companyDic];
                        [self.companies addObject:model];
                    }
                }
                [self.companyListView setHidden:NO];
                [self.companyListView reloadData];
            });
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [[QIMKit sharedInstance] getPublicNavCompanyWithKeyword:textField.text withCallBack:^(NSArray *companies) {
            dispatch_async(dispatch_get_main_queue(), ^{
                QIMVerboseLog(@"companies : %@", companies);
                [self.companies removeAllObjects];
                for (NSDictionary *companyDic in companies) {
                    if ([companyDic isKindOfClass:[NSDictionary class]]) {
                        QIMPublicCompanyModel *model = [self getCompanyModelWithDic:companyDic];
                        [self.companies addObject:model];
                    }
                }
                [self.companyListView setHidden:NO];
                [self.companyListView reloadData];
            });
        }];
    }
    return YES;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.companies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QIMPublicCompanyModel *companyModel = [self.companies objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    cell.textLabel.text = (companyModel.name.length > 0) ? companyModel.name : companyModel.domain;
    cell.textLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QIMPublicCompanyModel *companyModel = [self.companies objectAtIndex:indexPath.row];
    if (companyModel) {
        [self.navigationController popViewControllerAnimated:YES];
        if (self.companyBlock) {
            self.companyBlock(companyModel);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0f;
}

@end

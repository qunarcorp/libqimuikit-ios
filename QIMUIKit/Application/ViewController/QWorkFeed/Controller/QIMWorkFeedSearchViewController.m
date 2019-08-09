//
//  QIMWorkFeedSearchViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/7/16.
//

#import "QIMWorkFeedSearchViewController.h"
#import "QIMWorkMomentCell.h"
#import "QIMWorkMomentModel.h"
#import "QIMWorkMomentContentModel.h"
#import "QIMWorkNoticeMessageModel.h"
#import "QIMWorkCommentModel.h"
#import "QIMWorkCommentCell.h"
#import "QIMWorkMessageCell.h"
#import "YYModel.h"

@interface QIMWorkFeedSearchField : UITextField
@end

@implementation QIMWorkFeedSearchField

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 13; //像右边偏15
    return iconRect;
}

//UITextField 文字与输入框的距离
- (CGRect)textRectForBounds:(CGRect)bounds{
    
    return CGRectInset(bounds, 35, 0);
    
}

//控制文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds{
    
    return CGRectInset(bounds, 35, 0);
}

@end

@interface QIMWorkFeedSearchViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UIView *searchBgView;

@property (nonatomic, strong) QIMWorkFeedSearchField *textField;

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *searchDataList;

@end

@implementation QIMWorkFeedSearchViewController

- (NSMutableArray *)searchDataList {
    if (!_searchDataList) {
        _searchDataList = [NSMutableArray arrayWithCapacity:3];
    }
    return _searchDataList;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBgView.bottom, self.view.width, self.view.height) style:UITableViewStyleGrouped];
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.estimatedRowHeight = 0;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _mainTableView.separatorColor = [UIColor qim_colorWithHex:0xdddddd];
        
//        _mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadRemoteRecenteMoments)];
//        _mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMoment)];
//        _mainTableView.mj_footer.automaticallyHidden = YES;
    }
    return _mainTableView;
}

- (void)initNav {
    UIView *searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, [[QIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT], self.view.width, 40)];
    searchBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchBgView];
    self.searchBgView = searchBgView;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor qim_colorWithHex:0x666666] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [searchBgView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(17);
        make.top.mas_offset(12);
    }];
    
    QIMWorkFeedSearchField *textField = [[QIMWorkFeedSearchField alloc] initWithFrame:CGRectZero];
    textField.placeholder = @"搜索";
    textField.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE];
    textField.layer.cornerRadius = 4.0f;
    textField.layer.masksToBounds = YES;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeySearch;
    [searchBgView addSubview:textField];

    self.textField = textField;
    self.textField.delegate = self;
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.bottom.mas_offset(0);
        make.left.mas_offset(15);
        make.right.mas_equalTo(cancelBtn.mas_left).mas_offset(-15);
    }];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 14, 14)];
    iconView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e752" size:30 color:[UIColor qim_colorWithHex:0xBFBFBF]]];
    textField.leftView = iconView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)cancelSearch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNav];
    [self.view addSubview:self.mainTableView];
    // Do any additional setup after loading the view.
}

#pragma mark - ss

- (QIMWorkMomentModel *)getMomentModelWithDic:(NSDictionary *)momentDic {
    
    QIMWorkMomentModel *model = [QIMWorkMomentModel yy_modelWithDictionary:momentDic];
    NSDictionary *contentModelDic = [[QIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    QIMWorkMomentContentModel *conModel = [QIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    model.content = conModel;
    return model;
}

- (QIMWorkCommentModel *)getCommentModelWithDic:(NSDictionary *)momentDic {
    
    QIMWorkCommentModel *model = [QIMWorkCommentModel yy_modelWithDictionary:momentDic];
    return model;
}

- (QIMWorkNoticeMessageModel *)getNoticeMessageModelWithDict:(NSDictionary *)modelDict {
    QIMWorkNoticeMessageModel *model = [QIMWorkNoticeMessageModel yy_modelWithDictionary:modelDict];
    NSLog(@"QIMWorkNoticeMessageModel *model : %@", model);
    return model;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = [self.searchDataList objectAtIndex:indexPath.row];
    NSInteger eventType = [[dic objectForKey:@"eventType"] integerValue];
    if (eventType == 3) {
        //帖子
        QIMWorkMomentModel *model = [self getMomentModelWithDic:dic];
        NSString *identifier = model.momentId;
        QIMWorkMomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[QIMWorkMomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
//        cell.delegate = self;
        cell.moment = model;
        cell.tag = indexPath.row;
        return cell;
    } else {
        //评论
        QIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:dic];
        QIMWorkMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:model.uuid];
        if (!cell) {
            cell = [[QIMWorkMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:model.uuid];
            [cell setNoticeMsgModel:model];
            cell.cellType = QIMWorkMomentCellTypeMyMessage;
//            [cell setContentModel:[self getContentModelWithMomentUUId:model.postUUID]];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.searchDataList objectAtIndex:indexPath.row];
    NSLog(@"count : %ld", self.searchDataList.count);
    NSInteger eventType = [[dic objectForKey:@"eventType"] integerValue];
    if (eventType == 3) {
        //帖子
        QIMWorkMomentModel *model = [self getMomentModelWithDic:dic];
        if (model.rowHeight <= 0) {
            return 115;
        } else {
            return model.rowHeight;
        }
    } else {
        //评论或者艾特
        return 115;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.searchDataList removeAllObjects];
    NSMutableString * searchText = [NSMutableString stringWithString:textField.text];
    [searchText replaceCharactersInRange:range withString:string];
    
    UITextRange *selectedRange = textField.markedTextRange;
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (position) {
        
    } else {
        if (textField.text.length + string.length - range.length >= 2) {
            __weak __typeof(self) weakSelf = self;
            [[QIMKit sharedInstance] searchMomentWithKey:[searchText lowercaseString] withSearchTime:0 withStartNum:0 withPageNum:20 withSearchType:0 withCallBack:^(NSArray *result) {
                __typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [strongSelf.searchDataList addObjectsFromArray:result];
                [strongSelf.mainTableView reloadData];
                NSLog(@"result : %@", result);
            }];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //去掉姓名两端空格
    if (textField == self.textField) {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchDataList removeAllObjects];
    __weak __typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] searchMomentWithKey:[textField.text lowercaseString]  withSearchTime:0 withStartNum:0 withPageNum:20 withSearchType:0 withCallBack:^(NSArray *result) {
        NSLog(@"result2 : %@", result);
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf.searchDataList addObjectsFromArray:result];
        [strongSelf.mainTableView reloadData];
        [strongSelf.view endEditing:YES];
        NSLog(@"result : %@", result);
    }];
    return YES;
}

@end

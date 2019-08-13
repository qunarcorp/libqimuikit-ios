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
#import "QIMWorkFeedDetailViewController.h"
#import "YYModel.h"
static const NSInteger searchMinCharacterCount = 2;
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

@interface QIMWorkFeedSearchViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MomentCellDelegate>

@property (nonatomic, strong) UIView *searchBgView;

@property (nonatomic, strong) UIView *searchPlaceHolderView;

@property (nonatomic, strong) UILabel *searchPlaceHolderLabel;

@property (nonatomic, strong) UIView *searchEmptyView;

@property (nonatomic, strong) UILabel *searchEmptyLabel;

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

- (UIView *)searchPlaceHolderView {
    if (!_searchPlaceHolderView) {
        _searchPlaceHolderView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchPlaceHolderView.backgroundColor = [UIColor whiteColor];
    }
    return _searchPlaceHolderView;
}

- (UILabel *)searchPlaceHolderLabel {
    if (!_searchPlaceHolderLabel) {
        _searchPlaceHolderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSString *placeHolderStr = @"支持“姓名”或“关键词”搜索";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        // 设置文字居中
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [placeHolderStr length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor qim_colorWithHex:0x999999] range:NSMakeRange(0, [placeHolderStr length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, [placeHolderStr length])];

        _searchPlaceHolderLabel.attributedText = attributedString;
    }
    return _searchPlaceHolderLabel;
}

- (UIView *)searchEmptyView {
    if (!_searchEmptyView) {
        _searchEmptyView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchEmptyView.backgroundColor = [UIColor whiteColor];
    }
    return _searchEmptyView;
}

- (UILabel *)searchEmptyLabel {
    if (!_searchEmptyLabel) {
        _searchEmptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSString *placeHolderStr = @"暂无搜索结果";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        // 设置文字居中
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [placeHolderStr length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor qim_colorWithHex:0x999999] range:NSMakeRange(0, [placeHolderStr length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, [placeHolderStr length])];
        
        _searchEmptyLabel.attributedText = attributedString;
    }
    return _searchEmptyLabel;
}


- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBgView.bottom + 5, self.view.width, self.view.height) style:UITableViewStyleGrouped];
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
    textField.font = [UIFont systemFontOfSize:17];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNav];
    [self.view addSubview:self.mainTableView];
    [self updateSearchPlaceHolderViewWithHidden:self.textField.text.length];
    // Do any additional setup after loading the view.
}

- (void)updateSearchPlaceHolderViewWithHidden:(BOOL)hidden {
    if (!_searchPlaceHolderView) {
        [self.view addSubview:self.searchPlaceHolderView];
        [self.searchPlaceHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.searchBgView.mas_bottom).mas_offset(130);
            make.left.mas_offset(80);
            make.right.mas_offset(-80);
            make.height.mas_equalTo(50);
        }];
        
        [self.searchPlaceHolderView addSubview:self.searchPlaceHolderLabel];
        [self.searchPlaceHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_offset(0);
            make.top.bottom.mas_offset(0);
        }];
    }
    if (hidden == NO) {
        [self.searchDataList removeAllObjects];
        [self.mainTableView reloadData];
    }
    [self.searchPlaceHolderView setHidden:hidden];
}

- (void)updateSearchEmptyViewWithHidden:(BOOL)hidden {
    if (!_searchEmptyView) {
        [self.view addSubview:self.searchEmptyView];
        [self.searchEmptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.searchBgView.mas_bottom).mas_offset(130);
            make.left.mas_offset(80);
            make.right.mas_offset(-80);
            make.height.mas_equalTo(50);
        }];
        
        [self.searchEmptyView addSubview:self.searchEmptyLabel];
        [self.searchEmptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_offset(0);
            make.top.bottom.mas_offset(0);
        }];
    }
    [self.searchEmptyView setHidden:hidden];
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
    return model;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = [self.searchDataList objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[QIMWorkMomentModel class]]) {
        QIMWorkMomentModel *momentModel = (QIMWorkMomentModel *)model;
        NSString *identifier = [NSString stringWithFormat:@"search-%@", momentModel.momentId];
        QIMWorkMomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[QIMWorkMomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.notShowControl = YES;
        cell.notShowAttachCommentList = YES;
        cell.isSearch = YES;
        cell.delegate = self;
        cell.moment = momentModel;
        cell.tag = indexPath.row;
        return cell;
    } else if ([model isKindOfClass:[QIMWorkNoticeMessageModel class]]) {
        //评论
        QIMWorkNoticeMessageModel *msgModel = (QIMWorkNoticeMessageModel *)model;
        QIMWorkMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:msgModel.uuid];
        NSString *identifier = [NSString stringWithFormat:@"search-%@", msgModel.uuid];
        if (!cell) {
            cell = [[QIMWorkMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            [cell setNoticeMsgModel:msgModel];
            cell.cellType = QIMWorkMomentCellTypeMyMessage;
            [cell setContentModel:[self getContentModelWithMomentUUId:msgModel.postUUID]];
        }
        return cell;
    } else {
        UITableViewCell *cell = [UITableViewCell new];
        return cell;
    }
}

- (QIMWorkMomentContentModel *)getContentModelWithMomentUUId:(NSString *)momentId {
    NSDictionary *momentDic = [[QIMKit sharedInstance] getWorkMomentWithMomentId:momentId];
    
    NSDictionary *contentModelDic = [[QIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    QIMWorkMomentContentModel *contentModel = [QIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    return contentModel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id model = [self.searchDataList objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[QIMWorkMomentModel class]]) {
        QIMWorkMomentCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self didAddComment:cell];
    } else if ([model isKindOfClass:[QIMWorkNoticeMessageModel class]]) {
        QIMWorkNoticeMessageModel *msgModel = (QIMWorkNoticeMessageModel *)model;
        
        QIMWorkFeedDetailViewController *detailVc = [[QIMWorkFeedDetailViewController alloc] init];
        detailVc.momentId = msgModel.postUUID;
        [self.navigationController pushViewController:detailVc animated:YES];
    } else {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.searchDataList objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[QIMWorkMomentModel class]]) {
        QIMWorkMomentModel *momentModel = (QIMWorkMomentModel *)model;
        if (momentModel.rowHeight <= 0) {
            return 135;
        } else {
            return momentModel.rowHeight;
        }
    } else if ([model isKindOfClass:[QIMWorkNoticeMessageModel class]]) {
        QIMWorkNoticeMessageModel *msgModel = (QIMWorkNoticeMessageModel *)model;
        if (msgModel.rowHeight <= 0) {
            return 115;
        } else {
            return msgModel.rowHeight;
        }
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.000001f;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.searchDataList removeAllObjects];
    NSMutableString * searchText = [NSMutableString stringWithString:textField.text];
    [searchText replaceCharactersInRange:range withString:string];
    [self updateSearchPlaceHolderViewWithHidden:searchText.length];
    [self updateSearchEmptyViewWithHidden:YES];
    UITextRange *selectedRange = textField.markedTextRange;
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (position) {
        
    } else {
        if (textField.text.length + string.length - range.length >= searchMinCharacterCount) {
            __weak __typeof(self) weakSelf = self;
            [[QIMKit sharedInstance] searchMomentWithKey:searchText withSearchTime:0 withStartNum:0 withPageNum:20 withSearchType:0 withCallBack:^(NSArray *result) {
                __typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [strongSelf addModelWithResultList:result];
                [strongSelf.mainTableView reloadData];
                [strongSelf updateSearchEmptyViewWithHidden:result.count];
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
    
    [self updateSearchPlaceHolderViewWithHidden:NO];
    [self updateSearchEmptyViewWithHidden:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchDataList removeAllObjects];
    __weak __typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] searchMomentWithKey:textField.text withSearchTime:0 withStartNum:0 withPageNum:20 withSearchType:0 withCallBack:^(NSArray *result) {
        NSLog(@"result2 : %@", result);
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [self addModelWithResultList:result];
        [strongSelf.mainTableView reloadData];
        [strongSelf updateSearchEmptyViewWithHidden:result.count];
        [strongSelf.view endEditing:YES];
    }];
    return YES;
}

- (void)addModelWithResultList:(NSArray *)result {
    [self.searchDataList removeAllObjects];
    if (![result isKindOfClass:[NSArray class]]) {
        return;
    }
    for (NSDictionary *resultDic in result) {
        if ([resultDic isKindOfClass:[NSDictionary class]]) {
            NSInteger eventType = [[resultDic objectForKey:@"eventType"] integerValue];
            if (eventType == 3) {
                QIMWorkMomentModel *model = [self getMomentModelWithDic:resultDic];
                [self.searchDataList addObject:model];
            } else  {
                QIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:resultDic];
                [self.searchDataList addObject:model];
            }
        }
    }
}

#pragma mark - MomentCellDelegate

- (void)didClickSmallImage:(QIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag {
    //初始化图片浏览控件
    NSMutableArray *imageList = [NSMutableArray arrayWithCapacity:3];
    for (QIMWorkMomentPicture *picture in imageList) {
        NSString *imageUrl = picture.imageUrl;
        if (imageUrl.length > 0) {
            [imageList addObject:imageUrl];
        }
    }
    
    [[QIMFastEntrance sharedInstance] browseBigHeader:@{@"imageUrlList": imageList}];
}

- (void)didOpenWorkMomentDetailVc:(NSNotification *)notify {
    NSString *momentId = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMWorkFeedDetailViewController *detailVc = [[QIMWorkFeedDetailViewController alloc] init];
        detailVc.momentId = momentId;;
        [self.navigationController pushViewController:detailVc animated:YES];
    });
}

// 评论
- (void)didAddComment:(QIMWorkMomentCell *)cell {
    QIMWorkFeedDetailViewController *detailVc = [[QIMWorkFeedDetailViewController alloc] init];
    detailVc.momentId = cell.moment.momentId;
    [self.navigationController pushViewController:detailVc animated:YES];
}

// 查看全文/收起
- (void)didSelectFullText:(QIMWorkMomentCell *)cell withFullText:(BOOL)isFullText {
    if (isFullText == YES) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
        [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        //收起
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
            [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    }
}

@end

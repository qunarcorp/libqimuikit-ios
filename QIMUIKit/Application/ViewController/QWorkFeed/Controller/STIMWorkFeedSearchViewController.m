//
//  STIMWorkFeedSearchViewController.m
//  STIMUIKit
//
//  Created by lilu on 2019/7/16.
//

#import "STIMWorkFeedSearchViewController.h"
#import "STIMWorkMomentCell.h"
#import "STIMWorkMomentModel.h"
#import "STIMWorkMomentContentModel.h"
#import "STIMWorkNoticeMessageModel.h"
#import "STIMWorkCommentModel.h"
#import "STIMWorkCommentCell.h"
#import "STIMWorkMessageCell.h"
#import "STIMWorkFeedDetailViewController.h"
#import "YYModel.h"
#import "MBProgressHUD.h"
#import "MJRefreshAutoNormalFooter.h"

static const NSInteger searchMinCharacterCount = 2;
@interface STIMWorkFeedSearchField : UITextField
@end

@implementation STIMWorkFeedSearchField

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

@interface STIMWorkFeedSearchViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MomentCellDelegate>

@property (nonatomic, strong) UIView *searchBgView;

@property (nonatomic, strong) UIView *searchPlaceHolderView;

@property (nonatomic, strong) UILabel *searchPlaceHolderLabel;

@property (nonatomic, strong) UIView *searchIngView;

@property (nonatomic, strong) UILabel *searchIngLabel;

@property (nonatomic, strong) UIView *searchEmptyView;

@property (nonatomic, strong) UILabel *searchEmptyLabel;

@property (nonatomic, strong) STIMWorkFeedSearchField *textField;

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *searchDataList;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation STIMWorkFeedSearchViewController

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
        NSString *placeHolderStr = [NSBundle stimDB_localizedStringForKey:@"Allows Searching by “Names” or “Keywords”"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        // 设置文字居中
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [placeHolderStr length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor stimDB_colorWithHex:0x999999] range:NSMakeRange(0, [placeHolderStr length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, [placeHolderStr length])];

        _searchPlaceHolderLabel.attributedText = attributedString;
    }
    return _searchPlaceHolderLabel;
}

- (UIView *)searchIngView {
    if (!_searchIngView) {
        _searchIngView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchIngView.backgroundColor = [UIColor clearColor];
    }
    return _searchIngView;
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
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor stimDB_colorWithHex:0x999999] range:NSMakeRange(0, [placeHolderStr length])];
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
        _mainTableView.separatorColor = [UIColor stimDB_colorWithHex:0xdddddd];
//        _mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        _mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchMore)];
        _mainTableView.mj_footer.automaticallyHidden = YES;
        _mainTableView.mj_footer.hidden = YES;
    }
    return _mainTableView;
}

- (void)initNav {
    UIView *searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, [[STIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT], self.view.width, 40)];
    searchBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchBgView];
    self.searchBgView = searchBgView;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    [cancelBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor stimDB_colorWithHex:0x666666] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [searchBgView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(17);
        make.top.mas_offset(12);
    }];
    
    STIMWorkFeedSearchField *textField = [[STIMWorkFeedSearchField alloc] initWithFrame:CGRectZero];
    textField.placeholder = [NSBundle stimDB_localizedStringForKey:@"Search"];//@"搜索";
    textField.backgroundColor = [UIColor stimDB_colorWithHex:0xEEEEEE];
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
    iconView.image = [UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e752" size:30 color:[UIColor stimDB_colorWithHex:0xBFBFBF]]];
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
    [self.textField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
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

- (void)updateSearchingViewWithHidden:(BOOL)hidden {
    if (!_searchIngView) {
        [self.view addSubview:self.searchIngView];
        [self.searchIngView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.searchBgView.mas_bottom).mas_offset(130);
            make.left.mas_offset(10);
            make.right.mas_offset(-10);
            make.height.mas_equalTo(100);
        }];
    }
    [self.searchIngView setHidden:hidden];
}

- (MBProgressHUD *)progressHUD {
    [self updateSearchingViewWithHidden:NO];
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.searchIngView];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [self.searchIngView addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.hidden = NO;
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)hideProgressHUD:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hide:animated];
        [self updateSearchingViewWithHidden:YES];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    });
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

- (STIMWorkMomentModel *)getMomentModelWithDic:(NSDictionary *)momentDic {
    
    STIMWorkMomentModel *model = [STIMWorkMomentModel yy_modelWithDictionary:momentDic];
    NSDictionary *contentModelDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    STIMWorkMomentContentModel *conModel = [STIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    model.content = conModel;
    return model;
}

- (STIMWorkCommentModel *)getCommentModelWithDic:(NSDictionary *)momentDic {
    
    STIMWorkCommentModel *model = [STIMWorkCommentModel yy_modelWithDictionary:momentDic];
    return model;
}

- (STIMWorkNoticeMessageModel *)getNoticeMessageModelWithDict:(NSDictionary *)modelDict {
    STIMWorkNoticeMessageModel *model = [STIMWorkNoticeMessageModel yy_modelWithDictionary:modelDict];
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
    if ([model isKindOfClass:[STIMWorkMomentModel class]]) {
        STIMWorkMomentModel *momentModel = (STIMWorkMomentModel *)model;
        NSString *identifier = [NSString stringWithFormat:@"search-%@", momentModel.momentId];
        STIMWorkMomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[STIMWorkMomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    } else if ([model isKindOfClass:[STIMWorkNoticeMessageModel class]]) {
        //评论
        STIMWorkNoticeMessageModel *msgModel = (STIMWorkNoticeMessageModel *)model;
        STIMWorkMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:msgModel.uuid];
        NSString *identifier = [NSString stringWithFormat:@"search-%@", msgModel.uuid];
        if (!cell) {
            cell = [[STIMWorkMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            [cell setNoticeMsgModel:msgModel];
            cell.cellType = STIMWorkMomentCellTypeMyMessage;
            [cell setContentModel:[self getContentModelWithMomentUUId:msgModel.postUUID]];
        }
        return cell;
    } else {
        UITableViewCell *cell = [UITableViewCell new];
        return cell;
    }
}

- (STIMWorkMomentContentModel *)getContentModelWithMomentUUId:(NSString *)momentId {
    NSDictionary *momentDic = [[STIMKit sharedInstance] getWorkMomentWithMomentId:momentId];
    
    NSDictionary *contentModelDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    STIMWorkMomentContentModel *contentModel = [STIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    return contentModel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id model = [self.searchDataList objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[STIMWorkMomentModel class]]) {
        STIMWorkMomentCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self didAddComment:cell];
    } else if ([model isKindOfClass:[STIMWorkNoticeMessageModel class]]) {
        STIMWorkNoticeMessageModel *msgModel = (STIMWorkNoticeMessageModel *)model;
        
        STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
        detailVc.momentId = msgModel.postUUID;
        [self.navigationController pushViewController:detailVc animated:YES];
    } else {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.searchDataList objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[STIMWorkMomentModel class]]) {
        STIMWorkMomentModel *momentModel = (STIMWorkMomentModel *)model;
        if (momentModel.rowHeight <= 0) {
            return 135;
        } else {
            return momentModel.rowHeight;
        }
    } else if ([model isKindOfClass:[STIMWorkNoticeMessageModel class]]) {
        STIMWorkNoticeMessageModel *msgModel = (STIMWorkNoticeMessageModel *)model;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
}

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
        if (textField.text.length + string.length - range.length <= 0) {
            [self addModelWithResultList:nil withReWrite:YES];
            [self updateSearchPlaceHolderViewWithHidden:NO];
            return YES;
        }
        if (textField.text.length + string.length - range.length >= searchMinCharacterCount) {
            __weak __typeof(self) weakSelf = self;
            [self showProgressHUDWithMessage:[NSBundle stimDB_localizedStringForKey:@"moment_searhing"]];
            [[STIMKit sharedInstance] searchMomentWithKey:searchText withSearchTime:0 withStartNum:0 withPageNum:20 withSearchType:0 withCallBack:^(NSArray *result) {
                __typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf hideProgressHUD:YES];
                    [strongSelf addModelWithResultList:result withReWrite:YES];
                });
            }];
        } else {
            [self addModelWithResultList:nil withReWrite:YES];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    [self updateSearchPlaceHolderViewWithHidden:NO];
    [self updateSearchEmptyViewWithHidden:YES];
    _mainTableView.mj_footer.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length < 2) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"请至少输入两个字符开始搜索" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
        return NO;
    }
    [self.searchDataList removeAllObjects];
    __weak __typeof(self) weakSelf = self;
    [self showProgressHUDWithMessage:[NSBundle stimDB_localizedStringForKey:@"moment_searhing"]];
    [[STIMKit sharedInstance] searchMomentWithKey:textField.text withSearchTime:0 withStartNum:0 withPageNum:20 withSearchType:0 withCallBack:^(NSArray *result) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf hideProgressHUD:YES];
        [strongSelf addModelWithResultList:result withReWrite:YES];
    }];
    return YES;
}

- (void)searchMore {
    __weak __typeof(self) weakSelf = self;
    [[STIMKit sharedInstance] searchMomentWithKey:self.textField.text withSearchTime:0 withStartNum:self.searchDataList.count withPageNum:20 withSearchType:0 withCallBack:^(NSArray *result) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (result.count <= 0) {
            [_mainTableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [_mainTableView.mj_footer endRefreshing];
        }
        [self addModelWithResultList:result withReWrite:NO];
    }];
}

- (void)addModelWithResultList:(NSArray *)result withReWrite:(BOOL)rewrite{
    if (self.textField.text.length <= 0) {
        result = nil;
    }
    if (rewrite == YES) {
        [self.searchDataList removeAllObjects];
    }
    if (result == nil) {
        [self.searchDataList removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainTableView.hidden = YES;
            self.mainTableView.mj_footer.hidden = YES;
            [self.mainTableView reloadData];
            [self updateSearchEmptyViewWithHidden:YES];
        });
        return;
    }
    if (![result isKindOfClass:[NSArray class]]) {
        return;
    }
    for (NSDictionary *resultDic in result) {
        if ([resultDic isKindOfClass:[NSDictionary class]]) {
            NSInteger eventType = [[resultDic objectForKey:@"eventType"] integerValue];
            if (eventType == 3) {
                STIMWorkMomentModel *model = [self getMomentModelWithDic:resultDic];
                [self.searchDataList addObject:model];
            } else {
                STIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:resultDic];
                [self.searchDataList addObject:model];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (result.count >= 20) {
            self.mainTableView.mj_footer.hidden = NO;
        } else {
            self.mainTableView.mj_footer.hidden = YES;
        }
        self.mainTableView.hidden = NO;
        [self.mainTableView reloadData];
        [self updateSearchEmptyViewWithHidden:result.count];
    });
}

#pragma mark - MomentCellDelegate

- (void)didClickSmallImage:(STIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag {
    //初始化图片浏览控件
    NSMutableArray *mutablImageList = [NSMutableArray arrayWithCapacity:3];
    NSArray *imageList = model.content.imgList;
    for (STIMWorkMomentPicture *picture in imageList) {
        NSString *imageUrl = picture.imageUrl;
        if (imageUrl.length > 0) {
            [mutablImageList addObject:imageUrl];
        }
    }
    
    [[STIMFastEntrance sharedInstance] browseBigHeader:@{@"imageUrlList": mutablImageList, @"CurrentIndex":@(tag)}];
}

- (void)didOpenWorkMomentDetailVc:(NSNotification *)notify {
    NSString *momentId = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
        detailVc.momentId = momentId;;
        [self.navigationController pushViewController:detailVc animated:YES];
    });
}

// 评论
- (void)didAddComment:(STIMWorkMomentCell *)cell {
    STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
    detailVc.momentId = cell.moment.momentId;
    [self.navigationController pushViewController:detailVc animated:YES];
}

// 查看全文/收起
- (void)didSelectFullText:(STIMWorkMomentCell *)cell withFullText:(BOOL)isFullText {
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

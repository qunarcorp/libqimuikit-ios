//
//  QIMWorkAttachCommentListView.m
//  QIMUIKit
//
//  Created by lilu on 2019/3/11.
//

#import "QIMWorkAttachCommentListView.h"
#import "QIMWorkAttachCommentCell.h"
#import "QIMWorkCommentModel.h"

@interface QIMWorkAttachCommentListView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation QIMWorkAttachCommentListView

- (void)setUnReadCount:(NSInteger)unReadCount {
    _unReadCount = unReadCount;
    [self reloadSectionIndexTitles];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        self.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)setAttachCommentList:(NSArray *)attachCommentList {
    _attachCommentList = attachCommentList;
    [self reloadData];
}

- (CGFloat)getWorkAttachCommentListViewHeight {
    [self layoutIfNeeded];
    return self.contentSize.height;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.attachCommentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = [self.attachCommentList objectAtIndex:indexPath.row];
    QIMWorkAttachCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attachCommentListCellId"];
    if (!cell) {
        cell = [[QIMWorkAttachCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"attachCommentListCellId"];
    }
    [cell setLeftMargin:self.left];
    [cell setCommentModel:commentModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = [self.attachCommentList objectAtIndex:indexPath.row];
    return commentModel.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openWorkMomentDetailNotify" object:self.momentId];
    });
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 30)];
    bgView.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
    UILabel *showMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, self.width - 24, 15)];
    showMoreLabel.textColor = [UIColor qim_colorWithHex:0x00CABE];
    showMoreLabel.font = [UIFont systemFontOfSize:14];
    showMoreLabel.text = [NSString stringWithFormat:@"查看全部%ld条评论 >", self.unReadCount];
    [bgView addSubview:showMoreLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWorkMomentDetailNotify:)];
    showMoreLabel.userInteractionEnabled = YES;
    [showMoreLabel addGestureRecognizer:tap];
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.unReadCount > 5) {
        return 30;
    } else {
        return 0.000001f;
    }
}

- (void)openWorkMomentDetailNotify:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openWorkMomentDetailNotify" object:self.momentId];
    });
}

@end

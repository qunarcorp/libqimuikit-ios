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

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
//        self.userInteractionEnabled = NO;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        self.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        self.tableFooterView = [UIView new];
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
//        cell.userInteractionEnabled = NO;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenQIMWorkFeedDetail" object:self.momentId];
    });
}

@end

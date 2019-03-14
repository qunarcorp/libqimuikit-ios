//
//  QIMWorkChildCommentListView.m
//  QIMUIKit
//
//  Created by lilu on 2019/3/12.
//

#import "QIMWorkChildCommentListView.h"
#import "QIMWorkCommentCell.h"
#import "QIMWorkCommentModel.h"

@interface QIMWorkChildCommentListView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation QIMWorkChildCommentListView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        self.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        self.tableFooterView = [UIView new];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)setChildCommentList:(NSArray *)childCommentList {
    _childCommentList = childCommentList;
    [self reloadData];
}

- (CGFloat)getWorkChildCommentListViewHeight {
    [self layoutIfNeeded];
    return self.contentSize.height;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.childCommentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = [self.childCommentList objectAtIndex:indexPath.row];
    QIMWorkCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"childCommentListCell"];
    if (!cell) {
        cell = [[QIMWorkCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"childCommentListCell"];
        [cell setLeftMagin:self.leftMargin];
        cell.isChildComment = YES;
    }
    [cell setCommentModel:commentModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = [self.childCommentList objectAtIndex:indexPath.row];
    return commentModel.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QIMWorkCommentModel *commentModel = [self.childCommentList objectAtIndex:indexPath.row];
    NSDictionary *postDic = @{@"ChildModel": commentModel, @"ParentIndexPath" : self.parentCommentIndexPath};
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"beginControlChildCommentWithComment" object:postDic];
    });
    QIMVerboseLog(@"子ChildComment点击");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

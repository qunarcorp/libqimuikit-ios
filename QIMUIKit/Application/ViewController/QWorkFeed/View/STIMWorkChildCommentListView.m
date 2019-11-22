//
//  STIMWorkChildCommentListView.m
//  STIMUIKit
//
//  Created by lilu on 2019/3/12.
//

#import "STIMWorkChildCommentListView.h"
#import "STIMWorkCommentCell.h"
#import "STIMWorkCommentModel.h"

@interface STIMWorkChildCommentListView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation STIMWorkChildCommentListView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        self.estimatedRowHeight = 0;
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
    int height = self.contentSize.height;
    int tempHeight = 0;
    for (STIMWorkCommentModel *commentModel in self.childCommentList) {
        int commentHeight = commentModel.rowHeight;
        tempHeight += commentHeight;
    }
    if (tempHeight < height) {
        return height;
    } else {
        return tempHeight;
    }    
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.childCommentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkCommentModel *commentModel = [self.childCommentList objectAtIndex:indexPath.row];
    STIMWorkCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentModel.commentUUID];
    if (!cell) {
        cell = [[STIMWorkCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentModel.commentUUID];
        [cell setLeftMagin:self.leftMargin];
        cell.isChildComment = YES;
    }
    [cell setCommentModel:commentModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkCommentModel *commentModel = [self.childCommentList objectAtIndex:indexPath.row];
    return commentModel.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STIMWorkCommentModel *commentModel = [self.childCommentList objectAtIndex:indexPath.row];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [postDic setSTIMSafeObject:commentModel forKey:@"ChildModel"];
    [postDic setSTIMSafeObject:self.parentCommentIndexPath forKey:@"ParentIndexPath"];
//    NSDictionary *postDic = @{@"ChildModel": commentModel, @"ParentIndexPath" : self.parentCommentIndexPath};
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"beginControlChildCommentWithComment" object:postDic];
    });
    STIMVerboseLog(@"子ChildComment点击");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

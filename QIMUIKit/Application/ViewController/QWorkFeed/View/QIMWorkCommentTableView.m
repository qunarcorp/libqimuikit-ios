//
//  QIMWorkCommentTableView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkCommentTableView.h"
#import "QIMWorkCommentCell.h"
#import "QIMWorkCommentModel.h"
#import "QIMMessageRefreshHeader.h"
#import <MJRefresh/MJRefresh.h>

@interface QIMWorkCommentTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *commentTableView;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) UIEdgeInsets originContentInset;

@property (nonatomic, assign) UIEdgeInsets originScrollIndicatorInsets;

@end

static CGPoint tableOffsetPoint;

@implementation QIMWorkCommentTableView

- (NSMutableArray *)commentModels {
    if (!_commentModels) {
        _commentModels = [NSMutableArray arrayWithCapacity:3];
    }
    return _commentModels;
}

- (NSMutableArray *)hotCommentModels {
    if (!_hotCommentModels) {
        _hotCommentModels = [NSMutableArray arrayWithCapacity:3];
    }
    return _hotCommentModels;
}

- (UITableView *)commentTableView {
    if (!_commentTableView) {
        _commentTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.estimatedRowHeight = 0;
        _commentTableView.estimatedSectionHeaderHeight = 0;
        _commentTableView.estimatedSectionFooterHeight = 0;
        _commentTableView.backgroundColor = [UIColor qim_colorWithHex:0xf8f8f8 alpha:1.0];
        _commentTableView.tableFooterView = [UIView new];
        _commentTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _commentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewComments)];
        _commentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreComments)];
        _commentTableView.mj_footer.automaticallyHidden = YES;
    }
    return _commentTableView;
}

- (void)scrollTheTableViewForCommentWithKeyboardHeight:(CGFloat)keyboardHeight {
    
    if (keyboardHeight == 0) {
        self.commentTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.commentTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [UIView animateWithDuration:0.2 animations:^{
            [self.commentTableView setContentOffset:tableOffsetPoint animated:YES];
        } completion:nil];
    } else {
        tableOffsetPoint = self.commentTableView.contentOffset;
        self.commentTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        self.commentTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        [UIView animateWithDuration:0.2 animations:^{
            if (self.selectedIndexPath) {
                [self.commentTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } completion:nil];
    }
}

- (void)loadNewComments {
    if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(loadNewComments)]) {
        [self.commentDelegate loadNewComments];
    }
}

- (void)loadMoreComments {
    if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(loadMoreComments)]) {
        [self.commentDelegate loadMoreComments];
    }
}

- (void)setCommentHeaderView:(UIView *)commentHeaderView {
    _commentHeaderView = commentHeaderView;
    [self.commentTableView setTableHeaderView:_commentHeaderView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor qim_colorWithHex:0xF8F8F8];
        [self addSubview:self.commentTableView];
    }
    return self;
}

- (void)setCommentNum:(NSInteger)commentNum {
    _commentNum = commentNum;
}

- (void)reloadUploadCommentWithModel:(QIMWorkCommentModel *)commentModel {
    if (!commentModel) {
        return;
    }
    NSIndexPath *indexPath = nil;
    BOOL isHotCommentModel = NO;
    BOOL isNormalCommentModel = NO;
    for (NSInteger i = 0; i < self.hotCommentModels.count; i++) {
        QIMWorkCommentModel *hotCommentModel = [self.hotCommentModels objectAtIndex:i];
        if ([hotCommentModel.commentUUID isEqualToString:commentModel.commentUUID]/* || [hotCommentModel.commentUUID isEqualToString:commentModel.parentCommentUUID] || [hotCommentModel.commentUUID isEqualToString:commentModel.superParentUUID]*/) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            isHotCommentModel = YES;
        }
    }
    for (NSInteger i = 0; i < self.commentModels.count; i++) {
        QIMWorkCommentModel *normalCommentModel = [self.commentModels objectAtIndex:i];
        if ([normalCommentModel.commentUUID isEqualToString:commentModel.commentUUID]/* || [hotCommentModel.commentUUID isEqualToString:commentModel.parentCommentUUID] || [hotCommentModel.commentUUID isEqualToString:commentModel.superParentUUID]*/) {
            if (self.hotCommentModels.count > 0) {
                indexPath = [NSIndexPath indexPathForRow:i inSection:1];
            } else {
                indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            }
            isNormalCommentModel = YES;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isHotCommentModel == NO) {
            //评论的不是热门评论
            if (isNormalCommentModel == YES) {
                //评论的是普通评论
                QIMVerboseLog(@"评论的是普通评论 : %@", commentModel);
                [self.commentModels replaceObjectAtIndex:indexPath.row withObject:commentModel];
                [self reloadCommentsData];
                //            [self reloadCommentWithIndexPath:indexPath withIsHotComment:NO];
            } else {
                //新评论，加的普通评论第一条
                [self.commentModels insertObject:commentModel atIndex:0];
                [self reloadCommentsData];
            }
        } else {
            //评论的是热门评论，重新reload
            [self.hotCommentModels replaceObjectAtIndex:indexPath.row withObject:commentModel];
            [self reloadCommentsData];
        }
    });
}

- (void)reloadCommentsData {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.commentTableView reloadData];
    });
}

- (void)endRefreshingHeader {
    [self.commentTableView.mj_header endRefreshing];
}

- (void)endRefreshingFooter {
    [self.commentTableView.mj_footer endRefreshing];
}

- (void)endRefreshingFooterWithNoMoreData {
    [self.commentTableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)scrollCommentModelToTopIndex {
    NSIndexPath *indexpath = nil;
    if (self.hotCommentModels.count > 0) {
        indexpath = [NSIndexPath indexPathForRow:0 inSection:1];
    } else {
        indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self.commentTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)reloadCommentWithIndexPath:(NSIndexPath *)indexPath withIsHotComment:(BOOL)isHotComment {
    [UIView animateWithDuration:0.3 animations:^{
       [self.commentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)removeCommentWithIndexPath:(NSIndexPath *)indexPath withIsHotComment:(BOOL)isHotComment withSuperStatus:(NSInteger)superParentStatus {
    
    if (superParentStatus == 2) {
        //2标识主评论已删除且没有了子评论在客户端可直接删除掉
        if (isHotComment) {
            [self.hotCommentModels removeObjectAtIndex:indexPath.row];
            [self.commentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            _commentHeaderView.hidden = NO;
            [self.commentTableView setTableHeaderView:_commentHeaderView];
        } else {
            [self.commentModels removeObjectAtIndex:indexPath.row];
            [self.commentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            _commentHeaderView.hidden = NO;
            [self.commentTableView setTableHeaderView:_commentHeaderView];
        }
    } else if (superParentStatus == 1) {
        //1标识主评论已被删除但是还有子评论在客户端需标识该评论已被删除
        //更新主评论为“该评论已被删除”
        if (isHotComment) {
            QIMWorkCommentModel *commentModel = [self.hotCommentModels objectAtIndex:indexPath.row];
            commentModel.isDelete = YES;
            [self.hotCommentModels replaceObjectAtIndex:indexPath.row withObject:commentModel];
            [self.commentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            QIMWorkCommentModel *commentModel = [self.commentModels objectAtIndex:indexPath.row];
            commentModel.isDelete = YES;
            [self.commentModels replaceObjectAtIndex:indexPath.row withObject:commentModel];
            [self.commentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if (superParentStatus == 0) {
        //0主评论没有被删除,正常只删这一条评论
        if (isHotComment) {
            [self.hotCommentModels removeObjectAtIndex:indexPath.row];
            [self.commentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            _commentHeaderView.hidden = NO;
            [self.commentTableView setTableHeaderView:_commentHeaderView];
        } else {
            [self.commentModels removeObjectAtIndex:indexPath.row];
            [self.commentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            _commentHeaderView.hidden = NO;
            [self.commentTableView setTableHeaderView:_commentHeaderView];
        }
    } else {
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hotCommentModels.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.hotCommentModels.count > 0) {
        if (section == 0) {
            return self.hotCommentModels.count;
        } else {
            return self.commentModels.count;
        }
    } else {
        return self.commentModels.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = nil;
    if (self.hotCommentModels.count > 0) {
        if (indexPath.section == 0) {
            commentModel = [self.hotCommentModels objectAtIndex:indexPath.row];
        } else {
            commentModel = [self.commentModels objectAtIndex:indexPath.row];
        }
    } else {
        commentModel = [self.commentModels objectAtIndex:indexPath.row];
    }

    NSString *cellId = [NSString stringWithFormat:@"%@-", commentModel.commentUUID];
    QIMWorkCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[QIMWorkCommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.commentModel = commentModel;
    cell.commentIndexPath = indexPath;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    QIMVerboseLog(@"self.selectedIndexPath : %d", self.selectedIndexPath);
    QIMWorkCommentModel *commentModel = nil;
    BOOL isHotComment = NO;
    if (self.hotCommentModels.count > 0) {
        if (indexPath.section == 0) {
            commentModel = [self.hotCommentModels objectAtIndex:indexPath.row];
            isHotComment = YES;
        } else {
            commentModel = [self.commentModels objectAtIndex:indexPath.row];
            isHotComment = NO;
        }
    } else {
        commentModel = [self.commentModels objectAtIndex:indexPath.row];
        isHotComment = NO;
    }
    if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(beginControlCommentWithComment:withIsHotComment:withIndexPath:)]) {
        [self.commentDelegate beginControlCommentWithComment:commentModel withIsHotComment:isHotComment withIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = nil;
    if (self.hotCommentModels.count > 0) {
        if (indexPath.section == 0) {
            commentModel = [self.hotCommentModels objectAtIndex:indexPath.row];
        } else {
            commentModel = [self.commentModels objectAtIndex:indexPath.row];
        }
        return commentModel.rowHeight;
    } else {
        commentModel = [self.commentModels objectAtIndex:indexPath.row];
        return commentModel.rowHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 0.25f)];
    lineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    [view addSubview:lineView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 21, SCREEN_WIDTH - 30, 19)];
    titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    
    if (self.hotCommentModels.count > 0) {
        if (section == 0) {
            [titleLabel setText:[NSBundle qim_localizedStringForKey:@"moment_Hot_Comments"]];
        } else {
            if (self.commentNum > 0 && self.commentModels.count) {
                NSString *commentNumStr = [NSString stringWithFormat:@"（%ld）", self.commentNum];
                NSString *titleText = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"moment_comment"]];
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:titleText];
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x999999], NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                        range:[titleText rangeOfString:commentNumStr]];
                [titleLabel setAttributedText:attributedText];
            } else {
                
            }
        }
    } else {
        if (self.commentNum > 0 && self.commentModels.count) {
            NSString *commentNumStr = [NSString stringWithFormat:@"（%ld）", self.commentNum];
            NSString *titleText = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"moment_comment"]];
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:titleText];
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x999999], NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                    range:[titleText rangeOfString:commentNumStr]];
            [titleLabel setAttributedText:attributedText];
        } else {

        }
    }

    [view addSubview:titleLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    QIMWorkCommentModel *commentModel = nil;
    if (self.hotCommentModels.count > 0) {
        if (section == 0) {
            return 60;
        } else {
            if (self.commentModels.count <= 0) {
                return 0.00001f;
            }
            return 60;
        }
        return commentModel.rowHeight;
    } else {
        if (self.commentModels.count <= 0) {
            return 0.00001f;
        }
        return 60;
    }
}

@end

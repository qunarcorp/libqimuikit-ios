//
//  STIMWorkCommentTableView.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@class STIMWorkCommentModel;

@protocol STIMWorkCommentTableViewDelegate <NSObject>

- (void)loadNewComments;

- (void)loadMoreComments;

- (void)endAddComment;

- (void)beginControlCommentWithComment:(STIMWorkCommentModel *)commentModel withIsHotComment:(BOOL)isHotComment withIndexPath:(NSIndexPath *)indexPath;

- (void)beginAddCommentWithComment:(STIMWorkCommentModel *)commentModel;

@end

@interface STIMWorkCommentTableView : UIView

@property (nonatomic, strong) NSMutableArray *hotCommentModels;

@property (nonatomic, strong) NSMutableArray *commentModels;

@property (nonatomic, weak) id <STIMWorkCommentTableViewDelegate> commentDelegate;

@property (nonatomic, strong) UIView *commentHeaderView;

@property (nonatomic, assign) NSInteger commentNum;

- (void)scrollTheTableViewForCommentWithKeyboardHeight:(CGFloat)keyboardHeight;

- (void)reloadUploadCommentWithModel:(STIMWorkCommentModel *)commentModel;

- (void)reloadCommentsData;

- (void)endRefreshingHeader;

- (void)endRefreshingFooter;

- (void)endRefreshingFooterWithNoMoreData;

- (void)scrollCommentModelToTopIndex;

- (void)reloadCommentWithIndexPath:(NSIndexPath *)indexPath withIsHotComment:(BOOL)isHotComment;

- (void)removeCommentWithIndexPath:(NSIndexPath *)indexPath withIsHotComment:(BOOL)isHotComment withSuperStatus:(NSInteger)superParentStatus;

@end

NS_ASSUME_NONNULL_END

//
//  STIMWorkChildCommentListView.h
//  STIMUIKit
//
//  Created by lilu on 2019/3/12.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkChildCommentListView : UITableView

@property (nonatomic, strong) NSIndexPath *parentCommentIndexPath;

@property (nonatomic, strong) NSArray *childCommentList;

@property (nonatomic, assign) CGFloat leftMargin;

@property (nonatomic, copy) NSString *commentId;

- (CGFloat)getWorkChildCommentListViewHeight;


@end

NS_ASSUME_NONNULL_END

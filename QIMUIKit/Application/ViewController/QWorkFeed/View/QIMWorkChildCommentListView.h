//
//  QIMWorkChildCommentListView.h
//  QIMUIKit
//
//  Created by lilu on 2019/3/12.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkChildCommentListView : UITableView

@property (nonatomic, strong) NSIndexPath *parentCommentIndexPath;

@property (nonatomic, strong) NSArray *childCommentList;

@property (nonatomic, assign) CGFloat leftMargin;

@property (nonatomic, copy) NSString *commentId;

- (CGFloat)getWorkChildCommentListViewHeight;


@end

NS_ASSUME_NONNULL_END

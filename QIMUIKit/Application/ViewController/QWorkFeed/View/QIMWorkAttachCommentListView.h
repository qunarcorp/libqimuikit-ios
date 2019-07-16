//
//  QIMWorkAttachCommentListView.h
//  QIMUIKit
//
//  Created by lilu on 2019/3/11.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkAttachCommentListView : UITableView

@property (nonatomic, strong) NSArray *attachCommentList;

@property (nonatomic, assign) CGFloat leftMargin;

@property (nonatomic, copy) NSString *momentId;

@property (nonatomic, assign) NSInteger unReadCount;

- (CGFloat)getWorkAttachCommentListViewHeight;

@end

NS_ASSUME_NONNULL_END

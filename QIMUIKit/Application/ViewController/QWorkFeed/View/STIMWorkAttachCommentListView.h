//
//  STIMWorkAttachCommentListView.h
//  STIMUIKit
//
//  Created by lilu on 2019/3/11.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkAttachCommentListView : UITableView

@property (nonatomic, strong) NSArray *attachCommentList;

@property (nonatomic, assign) CGFloat leftMargin;

@property (nonatomic, copy) NSString *momentId;

@property (nonatomic, assign) NSInteger unReadCount;

- (CGFloat)getWorkAttachCommentListViewHeight;

@end

NS_ASSUME_NONNULL_END

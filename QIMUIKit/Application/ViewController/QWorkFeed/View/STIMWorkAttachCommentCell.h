//
//  STIMWorkAttachCommentCell.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/3/11.
//

#import "STIMCommonUIFramework.h"
@class STIMWorkCommentModel;
@class STIMWorkMomentLabel;

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkAttachCommentCell : UITableViewCell

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, assign) CGFloat leftMargin;

@property (nonatomic, strong) STIMWorkMomentLabel *contentLabel;

@property (nonatomic, strong) STIMWorkCommentModel *commentModel;

@end

NS_ASSUME_NONNULL_END

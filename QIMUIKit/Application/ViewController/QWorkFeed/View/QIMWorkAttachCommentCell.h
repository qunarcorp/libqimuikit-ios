//
//  QIMWorkAttachCommentCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/3/11.
//

#import "QIMCommonUIFramework.h"
@class QIMWorkCommentModel;
@class QIMWorkMomentLabel;

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkAttachCommentCell : UITableViewCell

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, assign) CGFloat leftMargin;

@property (nonatomic, strong) QIMWorkMomentLabel *contentLabel;

@property (nonatomic, strong) QIMWorkCommentModel *commentModel;

@end

NS_ASSUME_NONNULL_END

//
//  QIMWorkCommentCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
@class QIMWorkMomentLabel;
@class QIMWorkCommentModel;
@class QIMWorkChildCommentListView;

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkCommentCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *commentIndexPath;

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UILabel *nameLab;

@property (nonatomic, strong) UILabel *organLab;

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, strong) UILabel *replyNameLabel;

@property (nonatomic, assign) BOOL isChildComment;

@property (nonatomic, assign) CGFloat leftMagin;

@property (nonatomic, strong) QIMWorkMomentLabel *contentLabel;

@property (nonatomic, strong) QIMWorkCommentModel *commentModel;

@property (nonatomic, strong) QIMWorkChildCommentListView *childCommentListView;

@end

NS_ASSUME_NONNULL_END

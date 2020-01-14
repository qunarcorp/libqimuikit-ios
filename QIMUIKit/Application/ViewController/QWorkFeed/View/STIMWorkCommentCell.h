//
//  STIMWorkCommentCell.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
@class STIMWorkMomentLabel;
@class STIMWorkCommentModel;
@class STIMWorkChildCommentListView;

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkCommentCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *commentIndexPath;

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UILabel *nameLab;

@property (nonatomic, strong) UILabel *organLab;

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, strong) UILabel *replyNameLabel;

@property (nonatomic, assign) BOOL isChildComment;

@property (nonatomic, assign) CGFloat leftMagin;

@property (nonatomic, strong) STIMWorkMomentLabel *contentLabel;

@property (nonatomic, strong) STIMWorkCommentModel *commentModel;

@property (nonatomic, strong) STIMWorkChildCommentListView *childCommentListView;

@end

NS_ASSUME_NONNULL_END

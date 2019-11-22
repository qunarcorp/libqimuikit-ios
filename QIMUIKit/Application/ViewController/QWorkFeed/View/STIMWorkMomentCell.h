//
//  STIMWorkMomentCell.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMarginLabel.h"

NS_ASSUME_NONNULL_BEGIN

@class STIMWorkMomentCell;
@class STIMWorkMomentModel;
@class STIMWorkMomentLabel;
@class STIMWorkMomentImageListView;
@class STIMWorkMomentLinkView;
@class STIMWorkMomentVideoView;
@class STIMWorkAttachCommentListView;

@protocol MomentCellDelegate <NSObject>

@optional

//操作Moment
- (void)didControlPanelMoment:(STIMWorkMomentCell *)cell;
//操作Moment
- (void)didControlDebugPanelMoment:(STIMWorkMomentCell *)cell;
// 评论
- (void)didAddComment:(STIMWorkMomentCell *)cell;
// 查看全文/收起
- (void)didSelectFullText:(STIMWorkMomentCell *)cell withFullText:(BOOL)isFullText;

- (void)didClickSmallImage:(STIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag;
// 点击高亮文字
//- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText;

@end

@interface STIMWorkMomentCell : UITableViewCell

// 头像
@property (nonatomic, strong) UIImageView *headImageView;
// 名称
@property (nonatomic, strong) UILabel *nameLab;
//组织架构Label
@property (nonatomic, strong) STIMMarginLabel *organLab;
//服务器IdLabel
@property (nonatomic, strong) UILabel *rIdLabe;
// 时间
@property (nonatomic, strong) UILabel *timeLab;
// 操作按钮
@property (nonatomic, strong) UIButton *controlBtn;
// 查看全文按钮
@property (nonatomic, strong) UIButton *showAllBtn;
// 内容
@property (nonatomic, strong) STIMWorkMomentLabel *contentLabel;

// 图片
@property (nonatomic, strong) STIMWorkMomentImageListView *imageListView;

//Link
@property (nonatomic, strong) STIMWorkMomentLinkView *linkView;

//Video
@property (nonatomic, strong) STIMWorkMomentVideoView *videoView;

//附带评论listView
@property (nonatomic, strong) STIMWorkAttachCommentListView *attachCommentListView;

//点赞按钮
@property (nonatomic, strong) UIButton *likeBtn;

//评论按钮
@property (nonatomic, strong) UIButton *commentBtn;

@property (nonatomic, strong) UIView *lineView;

// 动态
@property (nonatomic, strong) STIMWorkMomentModel *moment;
// 代理
@property (nonatomic, assign) id<MomentCellDelegate> delegate;

//点赞按钮开关
@property (nonatomic, assign) BOOL likeActionHidden;

//评论按钮开关
@property (nonatomic, assign) BOOL commentActionHidden;

@property (nonatomic, assign) BOOL alwaysFullText;

@property (nonatomic, assign) BOOL isFullText;

@property (nonatomic, assign) BOOL notShowControl;              //不展示操作按钮

@property (nonatomic, assign) BOOL notShowAttachCommentList;    //不展示评论列表

@property (nonatomic, assign) BOOL isSearch;                    //是否为搜索

@end

NS_ASSUME_NONNULL_END

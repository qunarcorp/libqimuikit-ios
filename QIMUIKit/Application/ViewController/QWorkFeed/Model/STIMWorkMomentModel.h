//
//  STIMWorkMomentModel.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/2.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@class STIMWorkMomentContentModel;
@class STIMWorkCommentModel;
NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkMomentModel : NSObject

@property (nonatomic, assign) NSInteger rId;              //服务器Id

@property (nonatomic, copy) NSString *momentId;         //MomentId

@property (nonatomic, copy) NSString *ownerId;          //用户Id

@property (nonatomic, copy) NSString *ownerHost;        //用户Host

@property (nonatomic, assign) BOOL isAnonymous;         //是否匿名发布

@property (nonatomic, copy) NSString *anonymousName;    //匿名名称

@property (nonatomic, copy) NSString *anonymousPhoto;   //匿名图片

@property (nonatomic, assign) NSNumber *createTime;     //创建时间

@property (nonatomic, assign) NSNumber *updateTime;     //更新时间

@property (nonatomic, strong) STIMWorkMomentContentModel *content;  //Moment内容

@property (nonatomic, strong) NSArray <STIMWorkCommentModel *> *attachCommentList;   //附带的评论List

@property (nonatomic, strong) NSString *atList;         //艾特列表

@property (nonatomic, assign) BOOL isDelete;            //是否已删除

@property (nonatomic, assign) BOOL isLike;              //是否已点赞

@property (nonatomic, assign) NSInteger likeNum;        //点赞数

@property (nonatomic, assign) NSInteger commentsNum;    //评论数

@property (nonatomic, assign) CGFloat rowHeight;        //Moment高度

@property (nonatomic, assign) BOOL isFullText;          //是否展开全文

@property (nonatomic, strong) NSNumber *postType;       //帖子状态，1：正常，2：置顶，4：置热

@property (nonatomic, strong) NSNumber *reviewStatus;   //审核状态

@end

NS_ASSUME_NONNULL_END

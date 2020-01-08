//
//  QIMWorkMomentHotTopicModel.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentHotTopicModel : NSObject

@property (nonatomic, copy) NSNumber * headerNub;
@property (nonatomic, copy) NSNumber * hotPostId;

@property (nonatomic, copy) NSNumber * weight;
@property (nonatomic, copy) NSNumber *likeNum;
@property (nonatomic, copy) NSNumber *deleteFlag;
@property (nonatomic, copy) NSNumber *commentNum;
@property (nonatomic, copy) NSNumber *createTime;
@property (nonatomic, copy) NSNumber *updateTime;

@property (nonatomic, copy) NSString * originTitle;

@property (nonatomic, copy) NSString *showTitle;

@property (nonatomic, copy) NSString *headImg;

@property (nonatomic, copy) NSString *postCreateTime;

@property (nonatomic, copy) NSString *postUid;
@property (nonatomic, copy) NSString *postTotal;

@property (nonatomic, assign) CGFloat  height;
@property (nonatomic, assign) BOOL showNumber;
@property (nonatomic, assign) BOOL showImg;
@end

NS_ASSUME_NONNULL_END

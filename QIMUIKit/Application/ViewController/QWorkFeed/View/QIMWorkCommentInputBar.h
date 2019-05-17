//
//  QIMWorkCommentInputBar.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/10.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QIMWorkCommentInputBarDelegate <NSObject>

- (void)didOpenUserIdentifierVC;

- (void)didiOpenUserSelectVCWithVC:(UIViewController *)qNoticeVC;

- (void)didaddCommentWithStr:(NSString *)str withAtList:(NSArray *)atList;

@end

@interface QIMWorkCommentInputBar : UIView

- (BOOL)isInputBarFirstResponder;

@property (nonatomic, weak) id <QIMWorkCommentInputBarDelegate> delegate;

@property (nonatomic, assign) BOOL firstResponder;

@property (nonatomic, copy) NSString *momentId;

- (void)setLikeNum:(NSInteger)likeNum withISLike:(BOOL)isLike;

- (void)beginCommentToUserId:(NSString *)userId;

- (void)resignFirstInputBar:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END

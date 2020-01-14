//
//  STIMWorkCommentInputBar.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/10.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STIMWorkCommentInputBarDelegate <NSObject>

- (void)didOpenUserIdentifierVC;

- (void)didiOpenUserSelectVCWithVC:(UIViewController *)qNoticeVC;

- (void)didaddCommentWithStr:(NSString *)str withAtList:(NSArray *)atList;

@end

@interface STIMWorkCommentInputBar : UIView

- (BOOL)isInputBarFirstResponder;

@property (nonatomic, weak) id <STIMWorkCommentInputBarDelegate> delegate;

@property (nonatomic, assign) BOOL firstResponder;

@property (nonatomic, copy) NSString *momentId;

- (void)setLikeNum:(NSInteger)likeNum withISLike:(BOOL)isLike;

- (void)beginCommentToUserId:(NSString *)userId;

- (void)resignFirstInputBar:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END

//
//  STIMWorkNoticeMessageModel.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/17.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkNoticeMessageModel : NSObject
@property (nonatomic, copy) NSString *fromUser;
@property (nonatomic, copy) NSString *userFrom;
@property (nonatomic, copy) NSString *userFromHost;

@property (nonatomic, copy) NSString *userTo;
@property (nonatomic, copy) NSString *userToHost;

@property (nonatomic, assign) NSInteger readState;
@property (nonatomic, copy) NSString *postUUID;
@property (nonatomic, assign) NSInteger eventType;

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) long long createTime;

@property (nonatomic, assign) NSInteger toIsAnonymous;
@property (nonatomic, copy) NSString *toAnonymousName;
@property (nonatomic, copy) NSString *toAnonymousPhoto;

@property (nonatomic, assign) BOOL fromIsAnonymous;
@property (nonatomic, copy) NSString *fromAnonymousName;
@property (nonatomic, copy) NSString *fromAnonymousPhoto;

@property (nonatomic, assign) CGFloat rowHeight;

@end

NS_ASSUME_NONNULL_END

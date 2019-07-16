//
//  QIMWorkFeedAtNotifyViewController.h
//  QIMUIKit
//
//  Created by lilu on 2019/2/27.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^onQIMWorkFeedSelectUserBlock)(NSArray *selectUsers);

@interface QIMWorkFeedAtNotifyViewController : QTalkViewController

@property (nonatomic, strong) NSMutableArray *selectUsers;

- (void)onQIMWorkFeedSelectUser:(onQIMWorkFeedSelectUserBlock)block;

@end

NS_ASSUME_NONNULL_END

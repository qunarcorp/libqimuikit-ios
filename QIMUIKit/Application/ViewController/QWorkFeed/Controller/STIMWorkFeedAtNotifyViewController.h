//
//  STIMWorkFeedAtNotifyViewController.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/2/27.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^onSTIMWorkFeedSelectUserBlock)(NSArray *selectUsers);

@interface STIMWorkFeedAtNotifyViewController : QTalkViewController

@property (nonatomic, strong) NSMutableArray *selectUsers;

- (void)onSTIMWorkFeedSelectUser:(onSTIMWorkFeedSelectUserBlock)block;

@end

NS_ASSUME_NONNULL_END

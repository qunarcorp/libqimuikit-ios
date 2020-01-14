//
//  STIMWorkMomentNotifyView.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STIMWorkMomentNotifyViewDelegtae <NSObject>

- (void)didClickNotifyView;

@end

@interface STIMWorkMomentNotifyView : UIView

@property (nonatomic, weak) id <STIMWorkMomentNotifyViewDelegtae> delegate;

@property (nonatomic, assign) NSInteger msgCount;

- (instancetype)initWithNewMsgCount:(NSInteger)msgCount;

@end

NS_ASSUME_NONNULL_END

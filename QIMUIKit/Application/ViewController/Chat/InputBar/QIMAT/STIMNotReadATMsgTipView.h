//
//  STIMNotReadATMsgTipView.h
//  STIMUIKit
//
//  Created by lilu on 2019/5/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STIMNotReadAtMsgTipViewsDelegate <NSObject>
@optional
- (void)moveToLastNotReadAtMsg;
@end

@interface STIMNotReadATMsgTipView : UIView

@property (nonatomic, weak) id <STIMNotReadAtMsgTipViewsDelegate> notReadAtMsgDelegate;
- (instancetype)initWithNotReadAtMsgCount:(int)notReadAtMsgCount;
- (void)updateNotReadAtMsgCount:(int)notReadAtMsgCount;

@end

NS_ASSUME_NONNULL_END

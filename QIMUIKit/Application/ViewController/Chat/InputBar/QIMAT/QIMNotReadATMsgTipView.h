//
//  QIMNotReadATMsgTipView.h
//  QIMUIKit
//
//  Created by lilu on 2019/5/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QIMNotReadAtMsgTipViewsDelegate <NSObject>
@optional
- (void)moveToLastNotReadAtMsg;
@end

@interface QIMNotReadATMsgTipView : UIView

@property (nonatomic, weak) id <QIMNotReadAtMsgTipViewsDelegate> notReadAtMsgDelegate;
- (instancetype)initWithNotReadAtMsgCount:(int)notReadAtMsgCount;
- (void)updateNotReadAtMsgCount:(int)notReadAtMsgCount;

@end

NS_ASSUME_NONNULL_END

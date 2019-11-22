//
//  STIMNotReadMsgTipViews.h
//  qunarChatIphone
//
//  Created by admin on 16/5/6.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMNotReadMsgTipViewsDelegate <NSObject>
@optional
- (void)moveToFirstNotReadMsg;
@end

@interface STIMNotReadMsgTipViews : UIView
@property (nonatomic, weak) id<STIMNotReadMsgTipViewsDelegate> notReadMsgDelegate;
- (instancetype)initWithNotReadCount:(int)notReadCount;
@end

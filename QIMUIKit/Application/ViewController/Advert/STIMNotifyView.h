//
//  STIMNotifyView.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/24.
//

#import "STIMCommonUIFramework.h"

#define kNotifyViewCloseNotification @"kNotifyViewCloseNotification"

@interface STIMNotifyView : UIView

- (instancetype)initWithNotifyMessage:(NSDictionary *)message;

+ (instancetype)sharedNotifyViewWithMessage:(NSDictionary *)message;

@property (nonatomic, strong) NSDictionary *message;

@end

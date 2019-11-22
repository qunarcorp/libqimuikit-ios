//
//  STIMSearchRemindView.h
//  STIMUIKit
//
//  Created by lilu on 2018/12/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STIMSearchRemindView : UIView

- (instancetype)initWithChatId:(NSString *)chatId withRealJid:(NSString *)realjid withChatType:(NSInteger)chatType;

@end

NS_ASSUME_NONNULL_END

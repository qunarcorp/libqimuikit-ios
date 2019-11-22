//
//  STIMFriendQNSettingVC.h
//  qunarChatIphone
//
//  Created by admin on 15/11/23.
//
//

#import "STIMCommonUIFramework.h"

@class STIMFriendSettingItem;
@protocol STIMFriendQNSettingVCDelegate <NSObject>
@optional
- (void)setQuestion:(NSString *)question Answer:(NSString *)answer;
@end
@interface STIMFriendQNSettingVC : QTalkViewController
@property (nonatomic, weak) STIMFriendSettingItem *settingItem;
@property (nonatomic, weak) id<STIMFriendQNSettingVCDelegate> delegate;
@end

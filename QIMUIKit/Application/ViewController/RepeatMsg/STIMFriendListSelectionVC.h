//
//  STIMFriendListSelectionVC.h
//  STChatIphone
//
//  Created by admin on 16/3/18.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMFriendListSelectionVCDelegate <NSObject>
@optional
- (void)selectContactWithJid:(NSString *)jid;
@end

@interface STIMFriendListSelectionVC : QTalkViewController
@property (nonatomic, weak) id<STIMFriendListSelectionVCDelegate> delegate;
@end

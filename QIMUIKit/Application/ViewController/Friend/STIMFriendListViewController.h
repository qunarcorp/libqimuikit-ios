//
//  STIMFriendListViewController.h
//  STChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMContactShareVCDelegate <NSObject>

- (void)selectShareContactWithXmppJid:(NSString *)jid;

@end

@interface STIMFriendListViewController : QTalkViewController

@property (nonatomic, weak) id <STIMContactShareVCDelegate> shareDelegate;

//用来分享名片
@property (nonatomic, assign) BOOL useShare;

//只展示好友列表
@property (nonatomic, assign) BOOL onlyShowFriend;

//只展示组织架构
@property (nonatomic, assign) BOOL onlyShowOrgan;

//共同展示组织架构和好友列表
@property (nonatomic, assign) BOOL commonFriendAndOrgan;

@end

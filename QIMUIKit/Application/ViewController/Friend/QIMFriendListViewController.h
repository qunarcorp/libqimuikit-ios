//
//  QIMFriendListViewController.h
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMContactShareVCDelegate <NSObject>

- (void)selectShareContactWithXmppJid:(NSString *)jid;

@end

@interface QIMFriendListViewController : QTalkViewController

@property (nonatomic, weak) id <QIMContactShareVCDelegate> shareDelegate;

//用来分享名片
@property (nonatomic, assign) BOOL useShare;

//只展示好友列表
@property (nonatomic, assign) BOOL onlyShowFriend;

//只展示组织架构
@property (nonatomic, assign) BOOL onlyShowOrgan;

//共同展示组织架构和好友列表
@property (nonatomic, assign) BOOL commonFriendAndOrgan;

@end

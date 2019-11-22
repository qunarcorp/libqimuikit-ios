//
//  STIMOrganizationalVC.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "STIMCommonUIFramework.h"

@protocol STIMOrganizationalVCDelegate <NSObject>

- (void)selectShareContactWithJid:(NSString *)jid;

@end

@interface STIMOrganizationalVC : QTalkViewController

@property (nonatomic, assign) BOOL shareCard;

@property (nonatomic, weak) id <STIMOrganizationalVCDelegate> shareCardDelegate;

@end

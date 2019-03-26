//
//  QIMOrganizationalVC.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "QIMCommonUIFramework.h"

@protocol QIMOrganizationalVCDelegate <NSObject>

- (void)selectShareContactWithJid:(NSString *)jid;

@end

@interface QIMOrganizationalVC : QTalkViewController

@property (nonatomic, assign) BOOL shareCard;

@property (nonatomic, weak) id <QIMOrganizationalVCDelegate> shareCardDelegate;

@end

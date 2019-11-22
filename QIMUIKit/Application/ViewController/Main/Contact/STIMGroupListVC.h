//
//  STIMGroupListVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/3.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMGroupListVCDelegate <NSObject>
@optional
- (void)selectGroupWithJid:(NSString *)jid;
@end
@interface STIMGroupListVC : QTalkViewController
@property (nonatomic, weak) id<STIMGroupListVCDelegate> delegate;
@end

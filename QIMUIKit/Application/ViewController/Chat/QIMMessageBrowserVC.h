//
//  QIMMessageBrowserVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/2.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMMessageBrowserVC : UIViewController
@property (nonatomic, strong)QIMMessageModel *message; 
@property (nonatomic, assign) UIViewController *parentVC;
@end

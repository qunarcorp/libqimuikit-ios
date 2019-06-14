//
//  PasswordHistoryViewController.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/20.
//
//

#import "QIMCommonUIFramework.h"
#if __has_include("QIMNoteManager.h")
@interface PasswordHistoryViewController : UIViewController

- (void)setHistoryModels:(NSArray *)models;

@property (nonatomic, copy) NSString *pk;

@end
#endif

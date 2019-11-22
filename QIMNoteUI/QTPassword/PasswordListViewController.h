//
//  PasswordListViewController.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import "STIMCommonUIFramework.h"
#if __has_include("STIMNoteManager.h")
@class STIMNoteModel;
@interface PasswordListViewController : UIViewController

- (void)setSTIMNoteModel:(STIMNoteModel *)model;

@end
#endif

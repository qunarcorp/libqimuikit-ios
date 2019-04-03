//
//  PasswordListViewController.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import <UIKit/UIKit.h>
#if __has_include("QIMNoteManager.h")
@class QIMNoteModel;
@interface PasswordListViewController : UIViewController

- (void)setQIMNoteModel:(QIMNoteModel *)model;

@end
#endif

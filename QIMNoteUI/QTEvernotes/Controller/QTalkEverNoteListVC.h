//
//  QTalkEverNoteListVC.h
//  qunarChatIphone
//
//  Created by lihuaqi on 2017/9/20.
//
//

#import <UIKit/UIKit.h>
#if __has_include("QIMNoteManager.h")
@class QIMNoteModel;
@interface QTalkEverNoteListVC : UIViewController
@property(nonatomic, strong) QIMNoteModel *evernoteModel;
@end
#endif

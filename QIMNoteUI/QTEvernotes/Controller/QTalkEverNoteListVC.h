//
//  QTalkEverNoteListVC.h
//  STChatIphone
//
//  Created by lihuaqi on 2017/9/20.
//
//

#import <UIKit/UIKit.h>
#if __has_include("STIMNoteManager.h")
@class STIMNoteModel;
@interface QTalkEverNoteListVC : UIViewController
@property(nonatomic, strong) STIMNoteModel *evernoteModel;
@end
#endif

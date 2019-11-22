//
//  NewAddTodoListVc.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/27.
//
//

#import <UIKit/UIKit.h>
#if __has_include("STIMNoteManager.h")
#import "STIMNoteModel.h"

@interface NewAddTodoListVc : UIViewController

- (void)setEdited:(BOOL)edited;

- (void)setTodoListModel:(STIMNoteModel *)model;

@end
#endif

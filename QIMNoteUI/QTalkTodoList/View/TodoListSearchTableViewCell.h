//
//  TodoListSearchTableViewCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/8/1.
//
//

#import <UIKit/UIKit.h>
#if __has_include("QIMNoteManager.h")

@class QIMNoteModel;
@interface TodoListSearchTableViewCell : UITableViewCell

- (void)setTodoListModel:(QIMNoteModel *)model;

@end
#endif

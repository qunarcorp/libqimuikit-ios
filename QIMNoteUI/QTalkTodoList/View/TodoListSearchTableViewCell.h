//
//  TodoListSearchTableViewCell.h
//  STChatIphone
//
//  Created by 李海彬 on 2017/8/1.
//
//

#import <UIKit/UIKit.h>
#if __has_include("STIMNoteManager.h")

@class STIMNoteModel;
@interface TodoListSearchTableViewCell : UITableViewCell

- (void)setTodoListModel:(STIMNoteModel *)model;

@end
#endif

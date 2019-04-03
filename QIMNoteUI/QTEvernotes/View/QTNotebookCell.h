//
//  QTNotebookCell.h
//  qunarChatIphone
//
//  Created by lihuaqi on 2017/9/21.
//
//

#import <UIKit/UIKit.h>
#if __has_include("QIMNoteManager.h")
@class QIMNoteModel;
@interface QTNotebookCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
-(void)refreshCellWithModel:(QIMNoteModel *)model;
@end
#endif

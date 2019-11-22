//
//  QTNotebookCell.h
//  qunarChatIphone
//
//  Created by lihuaqi on 2017/9/21.
//
//

#import <UIKit/UIKit.h>
#if __has_include("STIMNoteManager.h")
@class STIMNoteModel;
@interface QTNotebookCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
-(void)refreshCellWithModel:(STIMNoteModel *)model;
@end
#endif

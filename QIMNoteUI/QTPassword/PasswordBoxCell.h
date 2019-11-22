//
//  PasswordBoxCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/19.
//
//

#import "STIMCommonUIFramework.h"
#if __has_include("STIMNoteManager.h")
@class STIMNoteModel;

@interface PasswordBoxCell : UITableViewCell

- (void)setSTIMNoteModel:(STIMNoteModel *)model;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;

@end
#endif

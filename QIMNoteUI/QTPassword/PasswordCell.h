//
//  PasswordCell.h
//  STChatIphone
//
//  Created by 李海彬 on 2017/7/11.
//
//

#import "STIMCommonUIFramework.h"
#if __has_include("STIMNoteManager.h")
#import "STIMBaseSelectedTableViewCell.h"

@class STIMNoteModel;
@interface PasswordCell : UITableViewCell

- (void)setSTIMNoteModel:(STIMNoteModel *)model;

+ (CGFloat)getCellHeight;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;

@end
#endif

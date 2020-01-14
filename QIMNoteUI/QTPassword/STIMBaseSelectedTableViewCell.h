//
//  STIMBaseSelectedTableViewCell.h
//  STChatIphone
//
//  Created by 李海彬 on 2017/7/20.
//
//

#import "STIMCommonUIFramework.h"
#if __has_include("STIMNoteManager.h")
@interface STIMBaseSelectedTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *selectBtn;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;

@end
#endif

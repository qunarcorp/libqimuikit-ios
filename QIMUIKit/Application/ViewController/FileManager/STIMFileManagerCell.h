//
//  STIMFileManagerCell.h
//  STChatIphone
//
//  Created by haibin.li on 15/7/24.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMFileManagerCell : UITableViewCell

- (void)setCellMessage:(STIMMessageModel *)message;

@property (nonatomic,assign) BOOL isSelect;//是否是可选的

- (void)setCellSelected : (BOOL)selected;
- (BOOL)isCellSelected;

@end

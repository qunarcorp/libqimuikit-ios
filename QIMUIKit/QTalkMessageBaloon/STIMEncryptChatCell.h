//
//  STIMEncryptChatCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/7.
//
//

@class STIMMsgBaloonBaseCell;

@interface STIMEncryptChatCell : STIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;
@end

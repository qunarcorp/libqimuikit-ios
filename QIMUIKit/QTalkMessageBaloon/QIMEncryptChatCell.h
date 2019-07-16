//
//  QIMEncryptChatCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/7.
//
//

@class QIMMsgBaloonBaseCell;

@interface QIMEncryptChatCell : QIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;
@end

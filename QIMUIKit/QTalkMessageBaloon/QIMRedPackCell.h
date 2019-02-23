//
//  QIMRedPackCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/12/24.
//
//

#import "QIMCommonUIFramework.h"
@class QIMMsgBaloonBaseCell;
@interface QIMRedPackCell : QIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(Message *)message  chatType:(ChatType)chatType;

@end

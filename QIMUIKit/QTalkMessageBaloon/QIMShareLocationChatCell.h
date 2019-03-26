//
//  LocationShareMsgCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;
@interface QIMShareLocationChatCell : QIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end

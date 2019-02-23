//
//  QIMCardShareMsgCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;

@interface QIMCardShareMsgCell : QIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(Message *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end

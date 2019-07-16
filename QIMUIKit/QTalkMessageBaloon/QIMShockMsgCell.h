
#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;
@interface QIMShockMsgCell : QIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end

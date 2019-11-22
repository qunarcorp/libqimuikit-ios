
#import "STIMCommonUIFramework.h"

@class STIMMsgBaloonBaseCell;
@interface STIMShockMsgCell : STIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end

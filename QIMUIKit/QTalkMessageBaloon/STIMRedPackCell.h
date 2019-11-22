//
//  STIMRedPackCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/12/24.
//
//

#import "STIMCommonUIFramework.h"
@class STIMMsgBaloonBaseCell;
@interface STIMRedPackCell : STIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message  chatType:(ChatType)chatType;

@end

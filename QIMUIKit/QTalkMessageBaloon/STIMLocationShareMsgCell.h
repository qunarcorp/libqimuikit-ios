//
//  STIMLocationShareMsgCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "STIMCommonUIFramework.h"

@class STIMMsgBaloonBaseCell;

@interface STIMLocationShareMsgCell : STIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end

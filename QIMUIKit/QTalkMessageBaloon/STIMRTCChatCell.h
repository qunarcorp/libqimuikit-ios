//
//  STIMRTCChatCell.h
//  STChatIphone
//
//  Created by Qunar-Lu on 2017/3/22.
//
//

@class STIMMsgBaloonBaseCell;
@interface STIMRTCChatCell : STIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end

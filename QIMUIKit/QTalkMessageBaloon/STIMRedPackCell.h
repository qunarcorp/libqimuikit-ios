//
//  STIMRedPackCell.h
//  STChatIphone
//
//  Created by haibin.li on 15/12/24.
//
//

#import "STIMCommonUIFramework.h"
@class STIMMsgBaloonBaseCell;
@interface STIMRedPackCell : STIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message  chatType:(ChatType)chatType;

@end

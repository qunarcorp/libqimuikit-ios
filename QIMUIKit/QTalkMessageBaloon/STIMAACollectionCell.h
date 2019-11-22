//
//  STIMAACollectionCell.h
//  qunarChatIphone
//
//  Created by admin on 16/1/18.
//
//

#import "STIMCommonUIFramework.h"

@class STIMMsgBaloonBaseCell;

@interface STIMAACollectionCell : STIMMsgBaloonBaseCell
+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message  chatType:(ChatType)chatType;
@end

//
//  QIMAACollectionCell.h
//  qunarChatIphone
//
//  Created by admin on 16/1/18.
//
//

#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;

@interface QIMAACollectionCell : QIMMsgBaloonBaseCell
+ (CGFloat)getCellHeightWithMessage:(Message *)message  chatType:(ChatType)chatType;
@end

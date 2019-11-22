//
//  STIMChatNotifyInfoCell.h
//  qunarChatIphone
//
//  Created by admin on 16/2/26.
//
//

#import "STIMCommonUIFramework.h"

@class STIMMsgBaloonBaseCell;
@protocol STIMChatNotifyInfoCellDelegate <NSObject>

@end

@interface STIMChatNotifyInfoCell : STIMMsgBaloonBaseCell

@property (nonatomic, weak) id<STIMChatNotifyInfoCellDelegate,STIMMsgBaloonBaseCellDelegate> delegate;

@end

@interface TransferInfoCell : STIMMsgBaloonBaseCell

@property (nonatomic, weak) id<STIMChatNotifyInfoCellDelegate,STIMMsgBaloonBaseCellDelegate> delegate;

@end

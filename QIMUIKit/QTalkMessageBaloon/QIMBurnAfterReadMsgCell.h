
#import "QIMCommonUIFramework.h"
#import "QIMMsgBaloonBaseCell.h"

@class QIMBurnAfterReadMsgCell;

@protocol QIMBurnAfterReadMsgCellDelegate <NSObject>

- (void)browserMessage:(QIMMessageModel *)message;

@end

@interface QIMBurnAfterReadMsgCell : QIMMsgBaloonBaseCell

@property (nonatomic, assign) id<QIMBurnAfterReadMsgCellDelegate,QIMMsgBaloonBaseCellDelegate> delegate;

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end

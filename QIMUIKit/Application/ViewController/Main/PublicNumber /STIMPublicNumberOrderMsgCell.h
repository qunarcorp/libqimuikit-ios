//
//  STIMPublicNumberOrderMsgCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/4.
//
//

#import "STIMCommonUIFramework.h"

@protocol PNOrderMsgCellDelegate <NSObject>
@optional
- (void)openWebUrl:(NSString *)url;
@end

@interface STIMPublicNumberOrderMsgCell : UITableViewCell

@property (nonatomic, weak)STIMMessageModel *message;

@property (nonatomic, weak) id<PNOrderMsgCellDelegate> delegate;

+ (CGFloat)getCellHeightByContent:(NSString *)content;

- (void)refreshUI;

@end

//
//  STIMPushProductCell.h
//  STChatIphone
//
//  Created by haibin.li on 16/1/26.
//
//

#import "STIMCommonUIFramework.h"

@class STIMPushProductCell;
@protocol STIMPushProductCellDelegate <NSObject>

- (void)sendBtnClickedForCell:(STIMPushProductCell *)cell;

@end

@interface STIMPushProductCell : UITableViewCell

@property (nonatomic,assign) id<STIMPushProductCellDelegate> delegate;

- (void)setCellInfo:(NSDictionary *)infoDic;

+ (CGFloat)getCellHeight;

@end

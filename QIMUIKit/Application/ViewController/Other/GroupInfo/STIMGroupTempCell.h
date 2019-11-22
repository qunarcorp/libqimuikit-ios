//
//  STIMGroupTempCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMGroupTempCellDelegate <NSObject>
@optional
- (BOOL)setGroupTemp:(BOOL)hidden;
@end
@interface STIMGroupTempCell : UITableViewCell
@property (nonatomic, weak) id<STIMGroupTempCellDelegate> delegate;
@property (nonatomic, assign) BOOL groupTemp;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end

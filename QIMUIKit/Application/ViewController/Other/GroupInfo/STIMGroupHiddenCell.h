//
//  STIMGroupHiddenCell.h
//  STChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMGroupHiddenCellDelegate <NSObject>
@optional
- (BOOL)setGroupHidden:(BOOL)hidden;
@end
@interface STIMGroupHiddenCell : UITableViewCell
@property (nonatomic, weak) id<STIMGroupHiddenCellDelegate> delegate;
@property (nonatomic, assign) BOOL groupHidden;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end

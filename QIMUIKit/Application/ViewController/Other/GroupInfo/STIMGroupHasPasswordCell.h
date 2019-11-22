//
//  STIMGroupHasPasswordCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMGroupHasPasswordCellDelegate <NSObject>
@optional
- (BOOL)setGroupHasPassword:(BOOL)hasPassword;
@end
@interface STIMGroupHasPasswordCell : UITableViewCell
@property (nonatomic, weak) id<STIMGroupHasPasswordCellDelegate> delegate;
@property (nonatomic, assign) BOOL hasPassword;
+ (CGFloat)getCellHeight;
- (void)refreshUI; 
@end

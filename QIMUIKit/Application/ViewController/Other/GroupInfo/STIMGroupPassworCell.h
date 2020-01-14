//
//  STIMGroupPassworCell.h
//  STChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMGroupPassworCell : UITableViewCell
@property (nonatomic, assign) NSString *password;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end

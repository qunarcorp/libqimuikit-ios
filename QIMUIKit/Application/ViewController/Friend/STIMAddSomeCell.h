//
//  STIMAddSomeCell.h
//  STChatIphone
//
//  Created by admin on 15/11/24.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMAddSomeCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *userInfoDic;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end

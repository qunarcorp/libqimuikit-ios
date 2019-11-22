//
//  STIMFriendTitleListCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMFriendTitleListCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

+ (CGFloat)getCellHeight;

- (void) refresh;

@end

//
//  STIMGroupPushSettingCell.h
//  STChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMGroupPushSettingCell : UITableViewCell
@property (nonatomic, strong) NSString *groupId;
- (void)refreshUI;
@end

//
//  STIMFriendNotifyCell.h
//  STChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMFriendNotifyCellDelete <NSObject>
@optional
- (void)agreeAddFriendWithUserInfoDic:(NSDictionary *)userInfoDic;
@end

@interface STIMFriendNotifyCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *userDic;
@property (nonatomic, weak) id<STIMFriendNotifyCellDelete> delegate;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end

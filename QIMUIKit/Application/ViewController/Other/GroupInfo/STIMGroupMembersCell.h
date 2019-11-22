//
//  STIMGroupMembersCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/11/17.
//
//

#import "STIMCommonUIFramework.h"

@class STIMGroupCardVC;
@class STIMGroupMembersCell;
@protocol STIMGroupMembersCellDelegate <NSObject>

- (void)groupMembersCell:(STIMGroupMembersCell *)cell handleForGes:(UIGestureRecognizer *)ges;

@end

@interface STIMGroupMembersCell : UITableViewCell

@property (nonatomic ,assign) STIMGroupCardVC * target;
@property (nonatomic, assign) id<STIMGroupMembersCellDelegate> delegate;

- (void)setCount:(NSInteger)count;

- (void)setItems:(NSArray *)items;

- (NSInteger)getOnlineMenmbersCount;


@end

//
//  STIMGroupMemberCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/11/19.
//
//

#import "STIMCommonUIFramework.h"

typedef enum {
    GroupMemberIDTypeNone,  //成员
    GroupMemberIDTypeAdmin, //管理员
    GroupMemberIDTypeOwner, //群主
} GroupMemberIDType;

@interface STIMGroupMemberCell : UITableViewCell

- (void)setMemberIDType:(GroupMemberIDType)idType;
@property (nonatomic, assign) BOOL isOnLine;

@end

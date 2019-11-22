//
//  STIMGroupMemberListVC.h
//  qunarChatIphone
//
//  Created by chenjie on 15/11/19.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMGroupMemberListVC : QTalkViewController

@property (nonatomic,copy) NSString                    * groupID;
@property (nonatomic,strong) NSMutableArray            * items;

@end

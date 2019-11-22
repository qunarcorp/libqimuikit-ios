//
//  STIMFriendNodeItem.h
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//
#import "STIMCommonUIFramework.h"

@interface STIMFriendNodeItem : NSObject

@property (nonatomic, assign) BOOL isParentNode;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *descInfo;

@property (nonatomic, strong) id contentValue;
@property (nonatomic, assign) BOOL isLast;

@property (nonatomic, assign) BOOL isFriend;

@end

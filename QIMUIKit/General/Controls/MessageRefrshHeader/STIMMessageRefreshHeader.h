//
//  STIMMessageRefreshHeader.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/21.
//

#import "STIMCommonUIFramework.h"
#import "MJRefresh.h"

@interface STIMMessageRefreshHeader : NSObject

+ (MJRefreshNormalHeader *)messsageHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end

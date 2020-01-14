//
//  STIMMessageRefreshHeader.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/3/21.
//

#import "STIMCommonUIFramework.h"
#import "MJRefresh.h"

@interface STIMMessageRefreshHeader : NSObject

+ (MJRefreshNormalHeader *)messsageHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end

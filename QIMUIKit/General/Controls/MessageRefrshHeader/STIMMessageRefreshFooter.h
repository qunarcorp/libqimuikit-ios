//
//  STIMMessageRefreshFooter.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/7/2.
//

#import "STIMCommonUIFramework.h"
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMMessageRefreshFooter : NSObject

+ (MJRefreshAutoNormalFooter *)messsageFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end

NS_ASSUME_NONNULL_END

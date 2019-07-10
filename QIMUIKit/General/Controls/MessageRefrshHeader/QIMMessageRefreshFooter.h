//
//  QIMMessageRefreshFooter.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/2.
//

#import "QIMCommonUIFramework.h"
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMMessageRefreshFooter : NSObject

+ (MJRefreshAutoNormalFooter *)messsageFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end

NS_ASSUME_NONNULL_END

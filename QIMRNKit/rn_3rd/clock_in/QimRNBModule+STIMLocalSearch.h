//
//  QimRNBModule+STIMLocalSearch.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2018/12/4.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "QimRNBModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface QimRNBModule (STIMLocalSearch)

+ (NSDictionary *)qimrn_searchLocalMsgWithUserParam:(NSDictionary *)param;

+ (NSDictionary *)qimrn_searchLocalFileWithUserParam:(NSDictionary *)param;

+ (NSDictionary *)qimrn_searchLocalLinkWithUserParam:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END

//
//  STIMChatBgManager.h
//  STIMUIKit
//
//  Created by admin on 2019/4/25.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMChatBgManager : NSObject

+ (void)getChatBgById:(NSString *)userId ByName:(NSString *)name WithReset:(BOOL)reset Complete:(void(^)(UIImage *bgImage)) complete;

@end

NS_ASSUME_NONNULL_END

//
//  STIMFlutterModule.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STIMFlutterModule : NSObject

+ (instancetype)sharedInstance;
- (void)openUserMedalFlutterWithUserId:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END

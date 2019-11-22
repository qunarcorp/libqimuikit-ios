//
//  STIMDaysmatterManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/19.
//

#import "STIMCommonUIFramework.h"

@interface STIMDaysmatterManager : NSObject

+ (instancetype)sharedInstance;

- (void)getDaysmatterFromRemote;

@end

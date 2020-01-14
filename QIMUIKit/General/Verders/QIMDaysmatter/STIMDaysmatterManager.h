//
//  STIMDaysmatterManager.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/3/19.
//

#import "STIMCommonUIFramework.h"

@interface STIMDaysmatterManager : NSObject

+ (instancetype)sharedInstance;

- (void)getDaysmatterFromRemote;

@end

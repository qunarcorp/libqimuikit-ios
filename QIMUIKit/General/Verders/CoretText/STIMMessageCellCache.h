//
//  STIMMessageCellCache.h
//  qunarChatIphone
//
//  Created by chenjie on 16/7/6.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMMessageCellCache : NSObject

+ (instancetype) sharedInstance;

- (BOOL)isExistForKey:(NSString *)key;

- (void)setObject:(id)value forKey:(NSString *)key;

- (id)getObjectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeObjectsForKeys:(NSArray *)keys;

- (void)clearUp;

@end

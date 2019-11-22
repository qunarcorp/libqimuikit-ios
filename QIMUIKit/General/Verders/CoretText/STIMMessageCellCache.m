//
//  STIMMessageCellCache.m
//  qunarChatIphone
//
//  Created by chenjie on 16/7/6.
//
//

#import "STIMMessageCellCache.h"

@interface STIMMessageCellCache () {
    NSMutableDictionary * _cacheDic;
}

@end

@implementation STIMMessageCellCache

static STIMMessageCellCache *_cellCache = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cellCache = [[STIMMessageCellCache alloc] init];
    });
    return _cellCache;
}

- (NSMutableDictionary *)cacheDic {
    if (!_cacheDic) {
        _cacheDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _cacheDic;
}

- (BOOL)isExistForKey:(NSString *)key {
    if (key.length) {
        return [[self cacheDic].allKeys containsObject:key];
    }
    return NO;
}

- (void)setObject:(id)value forKey:(NSString *)key {
    if (key.length) {
        [[self cacheDic] setSTIMSafeObject:value forKey:key];
    }
}

- (id)getObjectForKey:(NSString *)key {
    if (key.length) {
        return [[self cacheDic] valueForKey:key];
    }
    return nil;
}

- (void)removeObjectForKey:(NSString *)key {
    if (key.length) {
        [[self cacheDic] removeObjectForKey:key];
    }
}

- (void)removeObjectsForKeys:(NSArray *)keys {
    for (NSString * key in keys) {
        [self removeObjectForKey:key];
    }
}

- (void)clearUp {
    [[self cacheDic] removeAllObjects];
}

@end

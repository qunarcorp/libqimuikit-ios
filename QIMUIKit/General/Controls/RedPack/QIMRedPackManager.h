//
// Created by lilu on 2019/10/30.
//

#import <Foundation/Foundation.h>

typedef void(^QIMKitOpenRedPackCallManagerBack)(BOOL successed);

@interface QIMRedPackManager : NSObject

+ (instancetype)sharedInstance;

- (void)showRedPackWithChatId:(NSString *)chatId withRedPackFromId:(NSString *)userId withRedId:(NSString *)redId withISRoom:(BOOL)isRoom withRedPackInfoDic:(NSDictionary *)redPackInfoDic withCallManagerBack:(QIMKitOpenRedPackCallManagerBack)callback;

@end

//
//  QTalkProjectType.m
//  STChatIphone
//
//  Created by wangyu.wang on 16/9/12.
//
//

#import "QTalkProjectType.h"
//#import "Login.h"

@implementation QTalkProjectType

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getProjectType:(RCTResponseSenderBlock)success:(RCTResponseSenderBlock)error) {
    
    NSString *getProjectType = @"getProjectType";
    NSLog(getProjectType);
    
    NSDictionary *responseData = nil;
    
    NSString *key = [[STIMKit sharedInstance] thirdpartKeywithValue];
    NSString *lastJid = [[STIMKit sharedInstance] getLastJid];
    NSString *myNickName = [[STIMKit sharedInstance] getMyNickName];
    NSString *realKey = key.length ? key : @"";
    NSString *realLastJid = lastJid.length ? lastJid : @"";
    NSString *realMyNickName = myNickName.length ? myNickName : @"";
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
        // qtalk
        NSNumber *WorkFeedEntrance = [[STIMKit sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"];
        if (WorkFeedEntrance == nil) {
            WorkFeedEntrance = @(NO);
        }
        NSLog(@"WorkFeedEntrance : %@", WorkFeedEntrance);
        responseData = @{@"isQTalk": @YES, @"domain": realLastJid, @"fullname": realMyNickName, @"c_key": realKey, @"checkUserKeyHost":[[STIMKit sharedInstance] qimNav_HttpHost], @"showOA":@([[STIMKit sharedInstance] qimNav_ShowOA]), @"isShowWorkWorld":WorkFeedEntrance};
    } else {
        // qchat
        BOOL is = [[STIMKit sharedInstance] isMerchant];
        NSNumber *isSupplier = is == YES ? @YES : @NO;
        
        responseData = @{@"isQTalk": @NO, @"domain": realLastJid, @"fullname": realMyNickName, @"c_key": realKey, @"isSupplier": isSupplier};
    }
    STIMVerboseLog(@"getProjectType : %@", responseData);
    success(@[responseData]);
}

@end

//
//  QTalkLoaclSearch.m
//  STChatIphone
//
//  Created by wangyu.wang on 2016/12/6.
//
//

#import "QTalkLoaclSearch.h"
#import "QTalkSearchRNView.h"
#import "QTalkRNSearchManager.h"

@implementation QTalkLoaclSearch

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(exportRNLog:(NSString *)message) {
    STIMVerboseLog(@"日志 : \n<   %@   > \n", message);
}

RCT_EXPORT_METHOD(search:(NSString *)key
                  limit:(NSInteger)limit
                  offset:(NSInteger)offset
                  groupId:(NSString *)groupId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSString *search = @"search";
    NSLog(search);

    NSMutableArray *data = [QTalkRNSearchManager localSearch:key limit:limit offset:offset groupId:groupId];
    NSDictionary *resp1 = @{@"is_ok" : @YES, @"data" : data ? data : @[], @"errorMsg" : @""};
    STIMVerboseLog(@"本地搜索记录结果 : %@", resp1);
    resolve(resp1);
}

RCT_EXPORT_METHOD(searchUrl:(NSString *)MSG
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *search1 = @"search1";
    NSLog(search1);
    
    NSString *searchUrl = [[STIMKit sharedInstance] qimNav_SearchUrl];
    NSDictionary *resp1 = @{@"is_ok" : @YES, @"data" : searchUrl ? searchUrl : @"", @"Msg" : MSG};
    STIMVerboseLog(@"本地搜索获取搜索URL : %@", resp1);
    resolve(resp1);
}

RCT_EXPORT_METHOD(getVersion:(NSString *)MSG
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *getVersion = @"getVersion";
    NSLog(getVersion);
    NSString *appBuildVersion = [[STIMKit sharedInstance] AppBuildVersion];
    NSDictionary *resp1 = @{@"is_ok" : @YES, @"data" : appBuildVersion ? appBuildVersion : @"", @"Msg" : MSG};
    STIMVerboseLog(@"本地搜索获取版本号 : %@", resp1);
    resolve(resp1);
}
@end

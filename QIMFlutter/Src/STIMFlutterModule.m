//
//  STIMFlutterModule.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/9/20.
//

#import "STIMFlutterModule.h"
#import "STIMJSONSerializer.h"
#import "STIMFlutterViewController.h"
#import "STIMFastEntrance.h"
#import "UIApplication+STIMApplication.h"
#import <Flutter/Flutter.h>
#if __has_include("STIMAutoTracker.h")
#import "STIMAutoTracker.h"
#endif

@interface STIMFlutterModule ()

@property (nonatomic, strong) FlutterMethodChannel *medalChannel;

@property (nonatomic, strong) STIMFlutterViewController *flutterVc;

@end

@implementation STIMFlutterModule

static STIMFlutterModule *_flutterModule = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _flutterModule = [[STIMFlutterModule alloc] init];
    });
    return _flutterModule;
}

- (STIMFlutterViewController *)flutterVc {
    if (!_flutterVc) {
        _flutterVc = [STIMFlutterViewController new];
        //取消闪App启动图
        _flutterVc.splashScreenView = nil;
    }
    return _flutterVc;
}

- (FlutterMethodChannel *)medalChannel {
    if (!_flutterVc) {
        _medalChannel = nil;
    }
    if (!_medalChannel) {
        _medalChannel = [FlutterMethodChannel methodChannelWithName:@"data.flutter.io/medal" binaryMessenger:self.flutterVc];
        __weak typeof(self) weakSelf = self;
        [_medalChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            if ([@"getMedalList" isEqualToString:call.method]) {
                NSLog(@"getMedalList Channel");
                //获取我的勋章列表
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSDictionary *userId = [callArguments objectForKey:@"userId"];
                NSArray *array = [[STIMKit sharedInstance] getUserWearMedalStatusByUserid:userId];
                NSString *jsonStr2 = [[STIMJSONSerializer sharedInstance] serializeObject:array];
                result(jsonStr2);

            } else if ([@"getNickInfo" isEqualToString:call.method]) {
                //获取用户信息，需要把updatetime从long long替换成String类型
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSString *userId = [callArguments objectForKey:@"userId"];
                NSString *userNickInfo = [self getNickInfoWithUserXmppId:userId];
                result(userNickInfo);
            } else if ([@"getUsersInMedal" isEqualToString:call.method]) {
                
                //获取这个勋章下的所有用户
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSInteger medalId = [[callArguments objectForKey:@"medalId"] integerValue];
                NSInteger limit = [[callArguments objectForKey:@"limit"] integerValue];
                NSInteger offset = [[callArguments objectForKey:@"offset"] integerValue];
                NSArray *userInfoList = [[STIMKit sharedInstance] getUsersInMedal:medalId withLimit:limit withOffset:offset];
                NSString *jsonStr2 = [[STIMJSONSerializer sharedInstance] serializeObject:userInfoList];
                result(jsonStr2);
            } else if ([@"updateUserMedalStatus" isEqualToString:call.method]) {
                //设置勋章状态
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSInteger medalId = [[callArguments objectForKey:@"medalId"] integerValue];
                NSInteger status = [[callArguments objectForKey:@"status"] integerValue];
                [[STIMKit sharedInstance] userMedalStatusModifyWithStatus:status withMedalId:medalId withCallBack:^(BOOL success, NSString *errmsg) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyUpdateMedalStatus" object:@{@"status":@(status), @"success": @(success)}];
                    });
                    if (success == YES) {
                        NSLog(@"medaiId : %ld, status : %ld", medalId, status);
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                        [dic setObject:@(YES) forKey:@"isOK"];
                        NSDictionary *medalDic = [[STIMKit sharedInstance] getUserMedalWithMedalId:medalId withUserId:[[STIMKit sharedInstance] getLastJid]];
                        [dic setObject:medalDic forKey:@"medal"];
                        NSString *jsonStr2 = [[STIMJSONSerializer sharedInstance] serializeObject:dic];
                        result(jsonStr2);
                    } else {
                        NSLog(@"medaiId : %ld, status : %ld", medalId, status);
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                        [dic setObject:@(NO) forKey:@"isOK"];
                        NSString *jsonStr2 = [[STIMJSONSerializer sharedInstance] serializeObject:dic];
                        result(jsonStr2);
                    }
                }];
            } else if ([@"nativeLocalLog" isEqualToString:call.method]) {
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSString *logCode = [callArguments objectForKey:@"logCode"];
                NSString *logDes = [callArguments objectForKey:@"logDes"];
#if __has_include("STIMAutoTracker.h")
                [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:logCode withDescription:logDes];
#endif
                
            } else if ([@"quitFlutterApp" isEqualToString:call.method]) {
                self.flutterVc = nil;
            } else {
              result(FlutterMethodNotImplemented);
            }
        }];
    }
    return _medalChannel;
}

- (NSString *)getNickInfoWithUserXmppId:(NSString *)userId {
    NSDictionary *dic = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [userInfoDic setObject:@"" forKey:@"UserInfo"];
    long long updateTime = [[dic objectForKey:@"LastUpdateTime"] longLongValue];
    [userInfoDic setObject:[NSString stringWithFormat:@"%lld", updateTime] forKey:@"LastUpdateTime"];
    
    NSString *str = [[STIMJSONSerializer sharedInstance] serializeObject:userInfoDic];
    return str;
}

- (void)openUserMedalFlutterWithUserId:(NSString *)userId {
    self.flutterVc = nil;
    self.medalChannel;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *routeDic = @{@"selfUserId": [[STIMKit sharedInstance] getLastJid], @"targetUserId": userId};
        NSString *routeStr = [[STIMJSONSerializer sharedInstance] serializeObject:routeDic];
        [self.flutterVc setInitialRoute:routeStr];
  
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:self.flutterVc animated:YES];
    });
}

@end

//
//  QIMFlutterModule.m
//  QIMUIKit
//
//  Created by lilu on 2019/9/20.
//

#import "QIMFlutterModule.h"
#import "QIMJSONSerializer.h"
#import "QIMFlutterViewController.h"
#import "QIMFastEntrance.h"
#import "UIApplication+QIMApplication.h"
#import <Flutter/Flutter.h>

@implementation QIMFlutterModule

+ (void)openUserMedalFlutter {
    /*
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
         methodChannelWithName:@"samples.flutter.io/battery"
               binaryMessenger:controller];
     __weak typeof(self) weakSelf = self;
     [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                            FlutterResult result) {
       if ([@"getBatteryLevel" isEqualToString:call.method]) {
         int batteryLevel = [weakSelf getBatteryLevel];
         if (batteryLevel == -1) {
           result([FlutterError errorWithCode:@"UNAVAILABLE"
                                      message:@"Battery info unavailable"
                                      details:nil]);
         } else {
           result(@(batteryLevel));
         }
       } else {
         result(FlutterMethodNotImplemented);
       }
    */
    dispatch_async(dispatch_get_main_queue(), ^{
        
        FlutterViewController *flutterVc = [FlutterViewController new];
        NSDictionary *dic = @{
        @"DescInfo":@"/QUNAR/基础研发部/短信及Push",
        @"ExtendedFlag":@"",
        @"GroupId":@"",
        @"HeaderSrc":@"https://qim.qunar.com/file/v2/download/avatar/new/99ae30fe52c58254be484496.png",
        @"IncrementVersion":@"",
        @"Introduce":@"",
        @"LastUpdateTime":@"4152",
        @"Name":@"胡滨hubin",
        @"SearchIndex":@"hubinhubin|hbhubin",
        @"Topic":@"",
        @"UserId":@"lilulucas.li@ejabhost1",
        @"UserInfo":@"",
        @"XmppId":@"lilulucas.li@ejabhost1",
        @"collectionBind": @0,
        @"collectionUnReadCount": @0,
        @"id": @0,
        @"isInGroup": @(NO),
        @"mark":@"",
        @"mood":@"11222",
        @"root": @(NO)
        };
        NSString *str = [[QIMJSONSerializer sharedInstance] serializeObject:dic];
        [flutterVc setInitialRoute:str];
        FlutterMethodChannel *medalChannel = [FlutterMethodChannel methodChannelWithName:@"data.flutter.io/medal" binaryMessenger:flutterVc];
        __weak typeof(self) weakSelf = self;
        [medalChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            if ([@"getMedalList" isEqualToString:call.method]) {
                NSLog(@"getMedalList Channel");
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSDictionary *userId = [callArguments objectForKey:@"userId"];
                userId = @"lilulucas.li";
                NSArray *array = [[QIMKit sharedInstance] getUserWearMedalStatusByUserid:userId];
                NSString *jsonStr2 = [[QIMJSONSerializer sharedInstance] serializeObject:array];
                result(jsonStr2);

            } else {
              result(FlutterMethodNotImplemented);
            }
        }];
  
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:flutterVc animated:YES];
    });
}

@end

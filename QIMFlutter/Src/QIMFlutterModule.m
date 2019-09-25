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

@interface QIMFlutterModule ()

@property (nonatomic, strong) FlutterMethodChannel *medalChannel;

@property (nonatomic, strong) QIMFlutterViewController *flutterVc;

@end

@implementation QIMFlutterModule

static QIMFlutterModule *_flutterModule = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _flutterModule = [[QIMFlutterModule alloc] init];
    });
    return _flutterModule;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.medalChannel;
        
    }
    return self;
}

- (QIMFlutterViewController *)flutterVc {
    if (!_flutterVc) {
        _flutterVc = [QIMFlutterViewController new];
        //取消闪App启动图
        _flutterVc.splashScreenView = nil;
    }
    return _flutterVc;
}

- (FlutterMethodChannel *)medalChannel {
    if (!_medalChannel) {
        _medalChannel = [FlutterMethodChannel methodChannelWithName:@"data.flutter.io/medal" binaryMessenger:self.flutterVc];
        __weak typeof(self) weakSelf = self;
        [_medalChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            if ([@"getMedalList" isEqualToString:call.method]) {
                NSLog(@"getMedalList Channel");
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSDictionary *userId = [callArguments objectForKey:@"userId"];
                userId = @"lilulucas.li";
                NSArray *array = [[QIMKit sharedInstance] getUserWearMedalStatusByUserid:userId];
                NSString *jsonStr2 = [[QIMJSONSerializer sharedInstance] serializeObject:array];
                result(jsonStr2);

            } else if ([@"getUsersInMedal" isEqualToString:call.method]) {
                
                NSDictionary *callArguments = (NSDictionary *)call.arguments;
                NSInteger medalId = [callArguments objectForKey:@"medalId"];
                
                
            } else {
              result(FlutterMethodNotImplemented);
            }
        }];
    }
    return _medalChannel;
}

- (void)openUserMedalFlutter {
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        FlutterViewController *flutterVc = [FlutterViewController new];
        NSDictionary *dic = @{
        @"DescInfo":@"/QUNAR/基础研发部/短信及Push",
        @"ExtendedFlag":@"",
        @"GroupId":@"",
    @"HeaderSrc":@"https://ss1.bdstatic.com/5eN1bjq8AAUYm2zgoY3K/r/www/cache/static/protocol/https/home/img/qrcode/zbios_x2_5869f49.png",
        @"IncrementVersion":@"",
        @"Introduce":@"",
        @"LastUpdateTime":@"4152",
        @"Name":@"李露lucas",
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
        [self.flutterVc setInitialRoute:str];
  
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:self.flutterVc animated:YES];
    });
}

@end

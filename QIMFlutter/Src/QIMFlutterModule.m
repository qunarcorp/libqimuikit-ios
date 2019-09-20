//
//  QIMFlutterModule.m
//  QIMUIKit
//
//  Created by lilu on 2019/9/20.
//

#import "QIMFlutterModule.h"
#import "QIMFlutterViewController.h"
#import "QIMFastEntrance.h"
#import "UIApplication+QIMApplication.h"

@implementation QIMFlutterModule



+ (void)openUserMedalFlutter {
    dispatch_async(dispatch_get_main_queue(), ^{
        Class RunC = NSClassFromString(@"FlutterViewController");
        SEL sel = NSSelectorFromString(@"new");
        id old = [RunC performSelector:sel withObject:nil];
        SEL sel2 = NSSelectorFromString(@"setInitialRoute:");
        if ([old respondsToSelector:sel2]) {
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
                                  @"UserId":@"hubin.hu",
                                  @"UserInfo":@"",
                                  @"XmppId":@"hin.hu@ejabhost1",
                                  @"collectionBind": @0,
                                  @"collectionUnReadCount": @0,
                                  @"id": @0,
                                  @"isInGroup": @(NO),
                                  @"mark":@"",
                                  @"mood":@"11222",
                                  @"root": @(NO)
                                  };
            NSError *parseError = nil;
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
            
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [old performSelector:sel2 withObject:str];
        }
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC presentViewController:old animated:YES completion:nil];
    });
}

@end

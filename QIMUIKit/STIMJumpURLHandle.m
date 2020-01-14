//
//  STIMJumpURLHandle.m
//  STChatIphone
//
//  Created by admin on 15/8/13.
//
//

#import "STIMJumpURLHandle.h"
#import "STIMCommonUIFramework.h"
#import "UIApplication+STIMApplication.h"
#import "STIMGroupCardVC.h"
#import "STIMWebView.h"
#import "STIMPublicNumberRobotVC.h"
#import "STIMPublicNumberCardVC.h"
#import "STIMQRCodeLoginVC.h"
#import "STIMQRCodeLoginManager.h"

@implementation STIMJumpURLHandle

+ (BOOL)parseURL:(NSURL *)url {
    if ([url.scheme.lowercaseString isEqualToString:@"qtalk"]) {
        NSString *host = [url host];
        NSDictionary *dictionaryQuery = [[url query] stimDB_dictionaryFromQueryComponents];
        if ([host.lowercaseString isEqualToString:@"group"]) {
            NSString *groupId = [dictionaryQuery objectForKey:@"id"];
            id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ([nav isKindOfClass:[STIMNavController class]]) {
                if (groupId.length > 0) {
                    STIMGroupCardVC *GVC = [[STIMGroupCardVC alloc] init];
                    GVC.groupId = groupId;
                    [nav popToRootVCThenPush:GVC animated:YES];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"无法识别该信息。" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                    [alertView show];
                }
            }
        } else if ([host.lowercaseString isEqualToString:@"user"]) {
            id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ([nav isKindOfClass:[STIMNavController class]]) {
                NSString *userId = [dictionaryQuery objectForKey:@"id"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [STIMFastEntrance openUserCardVCByUserId:userId];
                });
            }
        } else if ([host.lowercaseString isEqualToString:@"robot"]) {
            id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ([nav isKindOfClass:[STIMNavController class]]) {
                NSString *publicNumberId = [dictionaryQuery objectForKey:@"id"];
                NSString *publicNumberType = [dictionaryQuery objectForKey:@"type"];
                NSString *content = [dictionaryQuery objectForKey:@"content"];
                NSString *msgType = [dictionaryQuery objectForKey:@"msgType"];
                if ([publicNumberType.lowercaseString isEqualToString:@"robot"]) {
                    NSDictionary *cardDic =
                            [[STIMKit sharedInstance] getPublicNumberCardByJId:[NSString stringWithFormat:@"%@@%@", publicNumberId, [[STIMKit sharedInstance] getDomain]]];
                    if (cardDic.count > 0) {
                        STIMPublicNumberRobotVC *robotVC = [[STIMPublicNumberRobotVC alloc] init];
                        [robotVC setRobotJId:[cardDic objectForKey:@"XmppId"]];
                        [robotVC setPublicNumberId:publicNumberId];
                        [robotVC setName:[cardDic objectForKey:@"Name"]];
                        [robotVC setTitle:robotVC.name];
                        [nav popToRootVCThenPush:robotVC animated:YES];
                        if (content.length > 0) {
                            if ([msgType isEqualToString:@"action"]) {
                                [robotVC sendMessage:content WithInfo:nil ForMsgType:PublicNumberMsgType_Action];
                            } else {
                                [robotVC sendMessage:content WithInfo:nil ForMsgType:PublicNumberMsgType_Text];
                            }
                        }
                    } else {
                        STIMPublicNumberCardVC *cardVC = [[STIMPublicNumberCardVC alloc] init];
                        [cardVC setJid:[NSString stringWithFormat:@"%@@%@", publicNumberId, [[STIMKit sharedInstance] getDomain]]];
                        [cardVC setPublicNumberId:publicNumberId];
                        [cardVC setNotConcern:YES];
                        [nav popToRootVCThenPush:cardVC animated:YES];
                    }
                }
            }
        }
    } else if ([url.scheme.lowercaseString isEqualToString:@"qimlogin"]) {
//        qimlogin://qrcodelogin?k=55D5492202ABEE3D491D9B43254146CF&v=1.0&p=wiki&type=wiki
        NSString *qdrcodeLoginHost = [url host];
        NSDictionary *qdrcodeLoginQuery = [[url query] stimDB_dictionaryFromQueryComponents];
        if ([qdrcodeLoginHost.lowercaseString isEqualToString:@"qrcodelogin"]) {
            NSString *loginKey = [qdrcodeLoginQuery objectForKey:@"k"]; //登录验证的key
            NSString *loginVersion = [qdrcodeLoginQuery objectForKey:@"v"]; //登录的版本号
            NSString *loginplatForm = [qdrcodeLoginQuery objectForKey:@"p"]; //登录的平台
            NSString *loginType = [qdrcodeLoginQuery objectForKey:@"type"];     //登录平台的类型
            NSString *loginPlatIcon = [qdrcodeLoginQuery objectForKey:@"iconurl"];  //登录平台的icon
            if (loginKey && loginVersion && loginplatForm) {
                id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                STIMQRCodeLoginVC *qrcodeLoginVc = [[STIMQRCodeLoginVC alloc] init];
                if (loginType.length > 0) {
                    qrcodeLoginVc.platForm = [NSString stringWithFormat:@"%@ ", loginType];
                } else {
                    qrcodeLoginVc.platForm = [NSString stringWithFormat:@"%@ ", [STIMKit getSTIMProjectTitleName]];
                }
                if (loginType.length > 0) {
                    qrcodeLoginVc.type = loginType;
                }
                if (loginPlatIcon.length > 0) {
                    qrcodeLoginVc.iconUrl = loginPlatIcon;
                }
                STIMNavController *qrcodeLoginNav = [[STIMNavController alloc] initWithRootViewController:qrcodeLoginVc];
                [nav presentViewController:qrcodeLoginNav animated:YES completion:nil];
                [[STIMQRCodeLoginManager shareSTIMQRCodeLoginManagerWithKey:loginKey WithType:loginType] confirmQRCodeAction];
            }
        }
    } else if ([url.scheme.lowercaseString isEqualToString:@"qpr"]) {
#if __has_include("RNSchemaParse.h")
        UIViewController *reactVC = nil;
        Class RunC = NSClassFromString(@"RNSchemaParse");
        SEL sel = NSSelectorFromString(@"handleOpsasppSchema:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            reactVC = [RunC performSelector:sel withObject:url];
        }
        if (reactVC != nil) {
            id nav = [[UIApplication sharedApplication] visibleNavigationController];
            [nav pushViewController:reactVC animated:YES];
        }
#endif
    }
    return YES;
}

+ (void)decodeQCodeStr:(NSString *)str {
    id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ([str stimDB_hasPrefixHttpHeader]) {
        STIMWebView *webVC = [[STIMWebView alloc] init];
        [webVC setUrl:str];
        [nav popToRootVCThenPush:webVC animated:YES];
    } else {
        NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if (url) {
            if ([url.scheme.lowercaseString isEqualToString:@"qtalk"] || [url.scheme.lowercaseString isEqualToString:@"qimlogin"] || [url.scheme.lowercaseString isEqualToString:@"qpr"]) {
                [STIMJumpURLHandle parseURL:url];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        } else {
            NSString *subString = [str substringWithRange:NSMakeRange(0, 7)];
            if ([subString isEqualToString:@"GroupId"]) {
                NSString *sub = [str substringFromIndex:8];
                NSDictionary *groupCardDic = [[STIMKit sharedInstance] getGroupCardByGroupId:sub];
                if (groupCardDic) {
                    STIMGroupCardVC *GVC = [[STIMGroupCardVC alloc] init];
                    GVC.groupId = sub;
                    [nav popToRootVCThenPush:GVC animated:YES];
                }
            } else if ([subString isEqualToString:@"MuserId"]) {
                NSString *sub = [str substringFromIndex:8];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [STIMFastEntrance openUserCardVCByUserId:sub];
                });
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSString stringWithFormat:@"结果：%@", str] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    STIMVerboseLog(@"扫描后的结果~%@", str);
}

@end

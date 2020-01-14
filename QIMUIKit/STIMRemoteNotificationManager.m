//
//  STIMRemoteNotificationManager.m
//  STChatIphone
//
//  Created by haibin.li on 2016/09/14.
//
//

#import "STIMRemoteNotificationManager.h"
#import "STIMCommonUIFramework.h"
#import "UIApplication+STIMApplication.h"
#import "STIMGroupChatVC.h"
#import "STIMChatVC.h"

@implementation STIMRemoteNotificationManager

+ (void)checkUpNotifacationHandle {
    
    NSDictionary * infoDic = [[STIMKit sharedInstance] userObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
    if (infoDic) {
        [self openChatSessionWithInfoDic:infoDic];
        [[STIMKit sharedInstance] removeUserObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
    }
}

//前往回话列表
+ (void)openChatSessionWithInfoDic:(NSDictionary *)userInfo
{
    UIViewController *rootViewController = [[UIApplication sharedApplication] visibleViewController];
    NSLog(@"rootViewController : %@", rootViewController);
    Class STIMMainVCClass = NSClassFromString(@"STIMMainVC");
    if (userInfo.count && [rootViewController isKindOfClass:STIMMainVCClass]) {
        NSString * userId = userInfo[@"userid"];
        if (userId.length) {
            if ([[[STIMKit sharedInstance] getCurrentSessionUserId] isEqualToString:userId]) {
                return;
            }
            NSInteger chatType = [[userInfo objectForKey:@"chattype"] integerValue];
            switch (chatType) {
                case 6: {
                    [STIMFastEntrance openSingleChatVCByUserId:userId];
                }
                    break;
                case 7: {
                    [STIMFastEntrance openGroupChatVCByGroupId:userId];
                }
                    break;
                case 132: {
                    NSInteger qchatId = [[userInfo objectForKey:@"chatid"] integerValue];
                    NSString *realJid = [userInfo objectForKey:@"realjid"];
                    if (qchatId == 4) {
                        [STIMFastEntrance openConsultServerChatByChatType:ChatType_ConsultServer WithVirtualId:userId WithRealJid:realJid];
                    } else {
                        [STIMFastEntrance openConsultChatByChatType:ChatType_Consult UserId:realJid WithVirtualId:userId];
                    }
                }
                    break;
                default:
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        }
    }
}


@end

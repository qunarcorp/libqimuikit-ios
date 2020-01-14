//
//  STIMNotificationManager.m
//  STChatIphone
//
//  Created by 李海彬 on 2018/5/17.
//

#import "STIMNotificationManager.h"
#import "STIMCommonUIFramework.h"
#import "STIMUUIDTools.h"
#import "STIMJSONSerializer.h"
#import "STIMCollectionFaceManager.h"
#if __has_include("STIMWebRTCClient.h")
    #import "STIMWebRTCClient.h"
    #import "STIMWebRTCMeetingClient.h"
#endif

#if __has_include("STIMNotifyManager.h")
    #import "STIMNotifyManager.h"
#endif

#if __has_include("STIMLocalLog.h")
    #import "STIMLocalLog.h"
#endif

#if __has_include("RNSchemaParse.h")
    #import "QTalkSuggestRNJumpManager.h"
#endif

#import "STIMZBarViewController.h"
#import "STIMJumpURLHandle.h"
#import <UserNotifications/UserNotifications.h>

@interface STIMNotificationManager()
@property (nonatomic,assign) BOOL isEnterBackGround;
@end

@implementation STIMNotificationManager

static STIMNotificationManager *_notificationManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _notificationManager = [[STIMNotificationManager alloc] init];
        [_notificationManager addNotification];
    });
    return _notificationManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isEnterBackGround = NO;
    }
    return self;
}

- (void)addNotification {
    //单人音视频
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callVideoAudio:) name:kWebRTCCallVideoAudio object:nil];
    //群组音视频
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(meetingAudioVideoConference:) name:kWbeRTCCallMeetingAudioVideoConference object:nil];
    //提交日志
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitLog:) name:kPBPresenceCategoryNotifySubmitLog object:nil];
    //全局通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGlobalNotify:) name:kPBPresenceCategoryNotifyGlobalChat object:nil];
    //指定会话通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSpecifiedNotify:) name:kPBPresenceCategoryNotifySpecifiedChat object:nil];
    //Reset 自定义表情
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetCollectionItems:) name:kNotifyResetFaceCollectionManager object:nil];
    //打开群会话
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openGroupChatVCByGroupId:) name:kNotifyOpenGroupChatVc object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hhhh:) name:@"STIMSchemaNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)applicationEnterBackground:(NSNotification *)noti{
    self.isEnterBackGround = YES;
}

- (void)applicationEnterForeground:(NSNotification *)noti{
    self.isEnterBackGround = NO;
}

- (void)showNotificationWithName:(NSString *)name{
    
    if (@available(iOS 10.0, *)) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        content.title = @"视频通话邀请";
        content.subtitle = [NSString stringWithFormat:@"您有一个来自%@视频通话，点击查看",name];
        // 内容
//        content.userInfo = msgInfo;
        // 声音
        // 默认声音
        //    content.sound = [UNNotificationSound defaultSound];
        // 添加自定义声
        // 角标 （我这里测试的角标无效，暂时没找到原因）
        // 多少秒后发送,可以将固定的日期转化为时间
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:2] timeIntervalSinceNow];
        //        NSTimeInterval time = 10;
        // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        
        /*
         //如果想重复可以使用这个,按日期
         // 周一早上 8：00 上班
         NSDateComponents *components = [[NSDateComponents alloc] init];
         // 注意，weekday默认是从周日开始
         components.weekday = 2;
         components.hour = 8;
         UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
         */
        // 添加通知的标识符，可以用于移除，更新等操作
        NSString *identifier = @"MypushNoticeId";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"成功添加推送");
        }];
    }else {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        // 发出推送的日期
        notif.alertTitle = @"音视频通话";
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
        // 推送的内容
        notif.alertBody =  @"您有一个音视频通话";
        // 可以添加特定信息
//        notif.userInfo = msgInfo;
        // 角标
        notif.applicationIconBadgeNumber = 1;
        // 提示音
        notif.soundName = UILocalNotificationDefaultSoundName;
        // 每周循环提醒
        notif.repeatInterval = NSCalendarUnitWeekOfYear;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
}

//单人音视频
- (void)callVideoAudio:(NSNotification *)notify {
    
#if __has_include("STIMWebRTCClient.h")
    
    NSDictionary *infoDic = notify.object;
    int msgType = [[infoDic objectForKey:@"type"] intValue];
    NSString *jid = [infoDic objectForKey:@"from"];
    NSString *resource = [infoDic objectForKey:@"resource"];
    if ([[STIMWebRTCClient sharedInstance] calling] == NO) {
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:jid];
        NSString *name = [userInfo objectForKey:@"Name"];
        if (self.isEnterBackGround == YES) {
            [self showNotificationWithName:name];
        }
        [[STIMWebRTCClient sharedInstance] setRemoteJID:jid];
        [[STIMWebRTCClient sharedInstance] setRemoteResource:resource];
        [[STIMWebRTCClient sharedInstance] showRTCViewByXmppId:jid isVideo:msgType == STIMMessageType_WebRTC_Vedio isCaller:NO];
        
    } else {
//        [[STIMKit sharedInstance] sendAudioVideoWithType:STIMMessageType_WebRTC_Vedio WithBody:@"busy" WithExtentInfo:[[STIMJSONSerializer sharedInstance] serializeObject:@{@"type":@"busy"}] WithMsgId:[STIMUUIDTools UUID] ToJid:[NSString stringWithFormat:@"%@%@",jid,resource.length > 0?[NSString stringWithFormat:@"/%@",resource]:@""]];
        [[STIMWebRTCClient sharedInstance] callBusy];
    }
#endif
}

//群组音视频
- (void)meetingAudioVideoConference:(NSNotification *)notify {
    
#if __has_include("STIMWebRTCMeetingClient.h")
    NSDictionary *infoDic = notify.object;
    
    if (![[STIMWebRTCMeetingClient sharedInstance] hasOpenRoom]) {
        NSString *extendInfo = [infoDic objectForKey:@"extendInfo"];
        NSDictionary *roomDic = [[STIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
        if (roomDic) {
            NSString *groupId = [[infoDic objectForKey:@"fromId"] stringByAppendingString:[infoDic objectForKey:@"domain"]];
            [[STIMWebRTCMeetingClient sharedInstance] setGroupId:groupId];
            [[STIMWebRTCMeetingClient sharedInstance] joinRoomByMessage:roomDic];
        }
    }
#endif
}

- (void)submitLog:(NSNotification *)notify {
#if __has_include("STIMLocalLog.h")
    NSString *conent = notify.object;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [[STIMLocalLog sharedInstance] submitFeedBackWithContent:conent withUserInitiative:NO];
    });
#endif
}

- (void)showGlobalNotify:(NSNotification *)notify {
#if __has_include("STIMNotifyManager.h")
    NSDictionary *notifyMsg = notify.object;
    [[STIMNotifyManager shareNotifyManager] showGlobalNotifyWithMessage:notifyMsg];
#endif
}

- (void)showSpecifiedNotify:(NSNotification *)notify {
#if __has_include("STIMNotifyManager.h")
    NSDictionary *notifyMsg = notify.object;
    [[STIMNotifyManager shareNotifyManager] showChatNotifyWithMessage:notifyMsg];
#endif
}

- (void)resetCollectionItems:(NSNotification *)notify {
    NSArray *items = notify.object;
    [[STIMCollectionFaceManager sharedInstance] resetCollectionItems:items WithUpdate:NO];
}

- (void)openGroupChatVCByGroupId:(NSNotification *)notify {
    NSString *groupId = notify.object;
    if (groupId.length > 0) {
        [STIMFastEntrance openGroupChatVCByGroupId:groupId];
    }
}

- (void)hhhh:(NSNotification *)notify {
    NSURL *schemaUrl = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (schemaUrl.absoluteString.length > 0 && [schemaUrl.scheme isEqualToString:@"qtalkaphone"]) {
            NSArray *components = [schemaUrl.absoluteString componentsSeparatedByString:@":"];
            NSString *host = [schemaUrl host];
            if ([host isEqualToString:@"qunarchat"]) {
                NSString *path = [schemaUrl path];
                if ([path isEqualToString:@"/openGroupChat"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *groupId = [tempDic objectForKey:@"jid"];

                    [STIMFastEntrance openGroupChatVCByGroupId:groupId];
                    
                } else if ([path isEqualToString:@"/openSingleChat"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *userId = [tempDic objectForKey:@"jid"];
                    NSString *realJid = [tempDic objectForKey:@"realJid"];
                    [STIMFastEntrance openSingleChatVCByUserId:userId];
                    
                } else if ([path isEqualToString:@"/headLine"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *jid = [tempDic objectForKey:@"jid"];

                    [STIMFastEntrance openHeaderLineVCByJid:jid];
                } else if ([path isEqualToString:@"/openGroupChatInfo"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *groupId = [tempDic objectForKey:@"groupId"];
                    [STIMFastEntrance openSTIMGroupCardVCByGroupId:groupId];
                    
                } else if ([path isEqualToString:@"/openSingleChatInfo"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *jid = [tempDic objectForKey:@"userId"];
                    NSString *realJid = [tempDic objectForKey:@"realJid"];
                    [STIMFastEntrance openUserChatInfoByUserId:jid];
                    
                } else if ([path isEqualToString:@"/openUserCard"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *jid = [tempDic objectForKey:@"jid"];
                    if (jid.length > 0) {
                        [STIMFastEntrance openUserCardVCByUserId:jid];
                    }
                } else if ([path isEqualToString:@"/hongbao"]) {
                    //我的红包
                    NSString *myRedpackageUrl = [[STIMKit sharedInstance] myRedpackageUrl];
                    if (myRedpackageUrl.length > 0) {
                        [STIMFastEntrance openWebViewForUrl:myRedpackageUrl showNavBar:YES];
                    }
                } else if ([path isEqualToString:@"/hongbao_balance"]) {
                    
                    //余额查询
                    NSString *balacnceUrl = [[STIMKit sharedInstance] redPackageBalanceUrl];
                    if (balacnceUrl.length > 0) {
                        [STIMFastEntrance openWebViewForUrl:balacnceUrl showNavBar:YES];
                    }
                } else if ([path isEqualToString:@"/account_info"]) {
                    
                    [STIMFastEntrance openMyAccountInfo];
                } else if ([path isEqualToString:@"/unreadList"]) {
                    
                    [STIMFastEntrance openNotReadMessageVC];
                } else if ([path isEqualToString:@"/publicNumber"]) {
                    
                    [STIMFastEntrance openSTIMPublicNumberVC];
                } else if ([path isEqualToString:@"/openOrganizational"]) {
                    
                    [STIMFastEntrance openOrganizationalVC];
                } else if ([path isEqualToString:@"/myfile"]) {
                    
                    [STIMFastEntrance openMyFileVC];
                } else {
                    
                }
            } else if ([host isEqualToString:@"rnsearch"]) {
                
                [STIMFastEntrance openRNSearchVC];
            } else if ([host isEqualToString:@"router"]) {
                
                NSString *path = [schemaUrl path];
                if ([path isEqualToString:@"/openHome"]) {
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSInteger selectIndex = [[tempDic objectForKey:@"tab"] integerValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(selectIndex)];
                }
            } else if ([host isEqualToString:@"rnservice"]) {
                
                NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                STIMVerboseLog(@"打印Schema参数列表生成的字典：\n%@", tempDic);
                NSString *module = [tempDic objectForKey:@"module"];
                NSString *Screen = [tempDic objectForKey:@"Screen"];
                
                [STIMFastEntrance openSTIMRNVCWithModuleName:module WithProperties:@{@"Screen":Screen}];
                
                STIMVerboseLog(@"schemaUrl : %@", schemaUrl);
            } else if ([host isEqualToString:@"qrcode"]) {
                
                [STIMFastEntrance openQRCodeVC];
            } else if ([host isEqualToString:@"logout"]) {
                
                [STIMFastEntrance signOut];
            } else if ([host isEqualToString:@"accountSwitch"]) {
                
                
            } else {
                STIMVerboseLog(@"遇到了解析不成功认识的schema : %@", schemaUrl);
            }
        }
    });
}

- (NSDictionary *)parseURLQuery:(NSURL *)url {
    NSString *query = url.query;
    NSArray *subArray = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
    
    for (int j = 0 ; j < subArray.count; j++)
    {
        
        //在通过=拆分键和值
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
        //给字典加入元素
        NSString *value = [[dicArray objectAtIndex:1] stimDB_URLDecodedString];
        NSString *key = [[dicArray objectAtIndex:0] stimDB_URLDecodedString];
        if (key && value) {
            [tempDic setObject:value forKey:key];
        }
    }
    return tempDic;
}

@end

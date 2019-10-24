//
//  QIMNotificationManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/5/17.
//

#import "QIMNotificationManager.h"
#import "QIMCommonUIFramework.h"
#import "QIMUUIDTools.h"
#import "QIMJSONSerializer.h"
#import "QIMCollectionFaceManager.h"
#if __has_include("QIMWebRTCClient.h")
    #import "QIMWebRTCClient.h"
    #import "QIMWebRTCMeetingClient.h"
#endif

#if __has_include("QIMNotifyManager.h")
    #import "QIMNotifyManager.h"
#endif

#if __has_include("QIMLocalLog.h")
    #import "QIMLocalLog.h"
#endif

#if __has_include("RNSchemaParse.h")
    #import "QTalkSuggestRNJumpManager.h"
#endif

#import "QIMZBarViewController.h"
#import "QIMJumpURLHandle.h"
#import <UserNotifications/UserNotifications.h>

@interface QIMNotificationManager()
@property (nonatomic,assign) BOOL isEnterBackGround;
@end

@implementation QIMNotificationManager

static QIMNotificationManager *_notificationManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _notificationManager = [[QIMNotificationManager alloc] init];
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hhhh:) name:@"QIMSchemaNotification" object:nil];
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
    
#if __has_include("QIMWebRTCClient.h")
    
    NSDictionary *infoDic = notify.object;
    int msgType = [[infoDic objectForKey:@"type"] intValue];
    NSString *jid = [infoDic objectForKey:@"from"];
    NSString *resource = [infoDic objectForKey:@"resource"];
    if ([[QIMWebRTCClient sharedInstance] calling] == NO) {
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
        NSString *name = [userInfo objectForKey:@"Name"];
        if (self.isEnterBackGround == YES) {
            [self showNotificationWithName:name];
        }
        [[QIMWebRTCClient sharedInstance] setRemoteJID:jid];
        [[QIMWebRTCClient sharedInstance] setRemoteResource:resource];
        [[QIMWebRTCClient sharedInstance] showRTCViewByXmppId:jid isVideo:msgType == QIMMessageType_WebRTC_Vedio isCaller:NO];
        
    } else {
//        [[QIMKit sharedInstance] sendAudioVideoWithType:QIMMessageType_WebRTC_Vedio WithBody:@"busy" WithExtentInfo:[[QIMJSONSerializer sharedInstance] serializeObject:@{@"type":@"busy"}] WithMsgId:[QIMUUIDTools UUID] ToJid:[NSString stringWithFormat:@"%@%@",jid,resource.length > 0?[NSString stringWithFormat:@"/%@",resource]:@""]];
        [[QIMWebRTCClient sharedInstance] callBusy];
    }
#endif
}

//群组音视频
- (void)meetingAudioVideoConference:(NSNotification *)notify {
    
#if __has_include("QIMWebRTCMeetingClient.h")
    NSDictionary *infoDic = notify.object;
    
    if (![[QIMWebRTCMeetingClient sharedInstance] hasOpenRoom]) {
        NSString *extendInfo = [infoDic objectForKey:@"extendInfo"];
        NSDictionary *roomDic = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
        if (roomDic) {
            NSString *groupId = [[infoDic objectForKey:@"fromId"] stringByAppendingString:[infoDic objectForKey:@"domain"]];
            [[QIMWebRTCMeetingClient sharedInstance] setGroupId:groupId];
            [[QIMWebRTCMeetingClient sharedInstance] joinRoomByMessage:roomDic];
        }
    }
#endif
}

- (void)submitLog:(NSNotification *)notify {
#if __has_include("QIMLocalLog.h")
    NSString *conent = notify.object;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [[QIMLocalLog sharedInstance] submitFeedBackWithContent:conent withUserInitiative:NO];
    });
#endif
}

- (void)showGlobalNotify:(NSNotification *)notify {
#if __has_include("QIMNotifyManager.h")
    NSDictionary *notifyMsg = notify.object;
    [[QIMNotifyManager shareNotifyManager] showGlobalNotifyWithMessage:notifyMsg];
#endif
}

- (void)showSpecifiedNotify:(NSNotification *)notify {
#if __has_include("QIMNotifyManager.h")
    NSDictionary *notifyMsg = notify.object;
    [[QIMNotifyManager shareNotifyManager] showChatNotifyWithMessage:notifyMsg];
#endif
}

- (void)resetCollectionItems:(NSNotification *)notify {
    NSArray *items = notify.object;
    [[QIMCollectionFaceManager sharedInstance] resetCollectionItems:items WithUpdate:NO];
}

- (void)openGroupChatVCByGroupId:(NSNotification *)notify {
    NSString *groupId = notify.object;
    if (groupId.length > 0) {
        [QIMFastEntrance openGroupChatVCByGroupId:groupId];
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

                    [QIMFastEntrance openGroupChatVCByGroupId:groupId];
                    
                } else if ([path isEqualToString:@"/openSingleChat"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *userId = [tempDic objectForKey:@"jid"];
                    NSString *realJid = [tempDic objectForKey:@"realJid"];
                    [QIMFastEntrance openSingleChatVCByUserId:userId];
                    
                } else if ([path isEqualToString:@"/headLine"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *jid = [tempDic objectForKey:@"jid"];

                    [QIMFastEntrance openHeaderLineVCByJid:jid];
                } else if ([path isEqualToString:@"/openGroupChatInfo"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *groupId = [tempDic objectForKey:@"groupId"];
                    [QIMFastEntrance openQIMGroupCardVCByGroupId:groupId];
                    
                } else if ([path isEqualToString:@"/openSingleChatInfo"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *jid = [tempDic objectForKey:@"userId"];
                    NSString *realJid = [tempDic objectForKey:@"realJid"];
                    [QIMFastEntrance openUserChatInfoByUserId:jid];
                    
                } else if ([path isEqualToString:@"/openUserCard"]) {
                    
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSString *jid = [tempDic objectForKey:@"jid"];
                    if (jid.length > 0) {
                        [QIMFastEntrance openUserCardVCByUserId:jid];
                    }
                } else if ([path isEqualToString:@"/hongbao"]) {
                    //我的红包
                    NSString *myRedpackageUrl = [[QIMKit sharedInstance] myRedpackageUrl];
                    if (myRedpackageUrl.length > 0) {
                        [QIMFastEntrance openWebViewForUrl:myRedpackageUrl showNavBar:YES];
                    }
                } else if ([path isEqualToString:@"/hongbao_balance"]) {
                    
                    //余额查询
                    NSString *balacnceUrl = [[QIMKit sharedInstance] redPackageBalanceUrl];
                    if (balacnceUrl.length > 0) {
                        [QIMFastEntrance openWebViewForUrl:balacnceUrl showNavBar:YES];
                    }
                } else if ([path isEqualToString:@"/account_info"]) {
                    
                    [QIMFastEntrance openMyAccountInfo];
                } else if ([path isEqualToString:@"/unreadList"]) {
                    
                    [QIMFastEntrance openNotReadMessageVC];
                } else if ([path isEqualToString:@"/publicNumber"]) {
                    
                    [QIMFastEntrance openQIMPublicNumberVC];
                } else if ([path isEqualToString:@"/openOrganizational"]) {
                    
                    [QIMFastEntrance openOrganizationalVC];
                } else if ([path isEqualToString:@"/myfile"]) {
                    
                    [QIMFastEntrance openMyFileVC];
                } else {
                    
                }
            } else if ([host isEqualToString:@"rnsearch"]) {
                
                [QIMFastEntrance openRNSearchVC];
            } else if ([host isEqualToString:@"router"]) {
                
                NSString *path = [schemaUrl path];
                if ([path isEqualToString:@"/openHome"]) {
                    NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                    NSInteger selectIndex = [[tempDic objectForKey:@"tab"] integerValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(selectIndex)];
                }
            } else if ([host isEqualToString:@"rnservice"]) {
                
                NSDictionary *tempDic = [self parseURLQuery:schemaUrl];
                QIMVerboseLog(@"打印Schema参数列表生成的字典：\n%@", tempDic);
                NSString *module = [tempDic objectForKey:@"module"];
                NSString *Screen = [tempDic objectForKey:@"Screen"];
                
                [QIMFastEntrance openQIMRNVCWithModuleName:module WithProperties:@{@"Screen":Screen}];
                
                QIMVerboseLog(@"schemaUrl : %@", schemaUrl);
            } else if ([host isEqualToString:@"qrcode"]) {
                
                [QIMFastEntrance openQRCodeVC];
            } else if ([host isEqualToString:@"logout"]) {
                
                [QIMFastEntrance signOut];
            } else if ([host isEqualToString:@"accountSwitch"]) {
                
                
            } else {
                QIMVerboseLog(@"遇到了解析不成功认识的schema : %@", schemaUrl);
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
        NSString *value = [[dicArray objectAtIndex:1] qim_URLDecodedString];
        NSString *key = [[dicArray objectAtIndex:0] qim_URLDecodedString];
        if (key && value) {
            [tempDic setObject:value forKey:key];
        }
    }
    return tempDic;
}

@end

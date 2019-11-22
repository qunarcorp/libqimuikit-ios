//
//  QTalk.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QTalk.h"
#import "STIMKitPublicHeader.h"
#import "STIMIconFont.h"
#import "STIMImageManager.h"
#import "STIMEmotionManager.h"
#if __has_include("STIMNoteManager.h")
#import "STIMNoteManager.h"
#endif

static QTalk *__global_qtalk = nil;

@implementation QTalk

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didfinishNSNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_qtalk = [[QTalk alloc] init];
    });
    return __global_qtalk;
}

+ (void)didfinishNSNotification:(NSNotification *)notify {
    [[QTalk sharedInstance] initConfiguration];
}

- (void)initConfiguration {
    //初始化字体集
    [STIMIconFont setFontName:@"QTalk-QChat"];
    
    //初始化图片缓存地址
    [[STIMImageManager sharedInstance] initWithSTIMImageCacheNamespace:@"STIMImageCache"];

    // 初始化表情
    [STIMEmotionManager sharedInstance];
    // 初始化管理类
    [STIMKit sharedInstance];
#if __has_include("STIMNoteManager.h")
    //初始化STIMNote
    [STIMNoteManager sharedInstance];
#endif
    
    // 注册支持的消息类型
    // 文本消息
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMDefalutMessageCell" ForMessageType:STIMMessageType_Text];
    [[STIMKit sharedInstance] setMsgShowText:@"[文本]" ForMessageType:STIMMessageType_Text];
    // 图片
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMSingleChatImageCell" ForMessageType:STIMMessageType_Image];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"[Photo]"] ForMessageType:STIMMessageType_Image];
    [[STIMKit sharedInstance] setMsgShowText:@"[表情]" ForMessageType:STIMMessageType_ImageNew];

    // 语音
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMSingleChatVoiceCell" ForMessageType:STIMMessageType_Voice];
    [[STIMKit sharedInstance] setMsgShowText:@"[语音]" ForMessageType:STIMMessageType_Voice];
    // 文件
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMFileCell" ForMessageType:STIMMessageType_File];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"[File]"] ForMessageType:STIMMessageType_File];
    // 时间戳
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMSingleChatTimestampCell" ForMessageType:STIMMessageType_Time];
    // Topic
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMGroupTopicCell" ForMessageType:STIMMessageType_Topic];
    [[STIMKit sharedInstance] setMsgShowText:@"[群公告]" ForMessageType:STIMMessageType_Topic];
    // Location Share 
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMLocationShareMsgCell" ForMessageType:STIMMessageType_LocalShare];
    // card Share
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMCardShareMsgCell" ForMessageType:STIMMessageType_CardShare];
    [[STIMKit sharedInstance] setMsgShowText:@"[位置分享]" ForMessageType:STIMMessageType_LocalShare];
    
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMShareLocationChatCell" ForMessageType:STIMMessageType_shareLocation];
    [[STIMKit sharedInstance] setMsgShowText:@"[位置共享]" ForMessageType:STIMMessageType_shareLocation];
    
    // Video
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMVideoMsgCell" ForMessageType:STIMMessageType_SmallVideo];
    [[STIMKit sharedInstance] setMsgShowText:@"[视频]" ForMessageType:STIMMessageType_SmallVideo];
    // Source Code
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMSourceCodeCell" ForMessageType:STIMMessageType_SourceCode];
    [[STIMKit sharedInstance] setMsgShowText:@"[代码段]" ForMessageType:STIMMessageType_SourceCode];
//    STIMMessageType_Markdown
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMSourceCodeCell" ForMessageType:STIMMessageType_Markdown];
    [[STIMKit sharedInstance] setMsgShowText:@"[Markdown]" ForMessageType:STIMMessageType_Markdown];
    
    // red pack
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRedPackCell" ForMessageType:STIMMessageType_RedPack];
    [[STIMKit sharedInstance] setMsgShowText:@"[红包]" ForMessageType:STIMMessageType_RedPack];
    
    // red pack desc
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRedPackDescCell" ForMessageType:STIMMessageType_RedPackInfo];
    [[STIMKit sharedInstance] setMsgShowText:@"[红包]" ForMessageType:STIMMessageType_RedPackInfo];
    
    //预测对赌
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMForecastCell" ForMessageType:STIMMessageType_Forecast];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Prediction_tip"] ForMessageType:STIMMessageType_Forecast];
    
    //抢单消息
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Order_Taking_tip"] ForMessageType:MessageType_C2BGrabSingle];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Order_Taking_tip"] ForMessageType:MessageType_QCZhongbao];

    
    // red pack desc
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRedPackDescCell" ForMessageType:STIMMessageType_RedPackInfo];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"redpack_tip"] ForMessageType:STIMMessageType_RedPackInfo];
    
    // AA收款
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMAACollectionCell" ForMessageType:STIMMessageType_AA];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Split_Bill_tip"] ForMessageType:STIMMessageType_AA];
    
    // AA收款 desc
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMAACollectionDescCell" ForMessageType:STIMMessageType_AAInfo];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Split_Bill_tip"] ForMessageType:STIMMessageType_AAInfo];
    
    // 产品信息
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMProductInfoCell" ForMessageType:STIMMessageType_product];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Product_Information_tip"] ForMessageType:STIMMessageType_product];
    
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMExtensibleProductCell" ForMessageType:STIMMessageType_ExProduct];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Product_Information_tip"] ForMessageType:STIMMessageType_ExProduct];
    
    // 活动
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMActivityCell" ForMessageType:STIMMessageType_activity];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Event_tip"] ForMessageType:STIMMessageType_activity];
    
    // 撤回消息
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMSingleChatTimestampCell" ForMessageType:STIMMessageType_Revoke];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"recalled_message"] ForMessageType:STIMMessageType_Revoke];
    
#if __has_include("STIMWebRTCClient.h")
    //语音聊天
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRTCChatCell" ForMessageType:STIMMessageType_WebRTC_Audio];
    //视频聊天
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRTCChatCell" ForMessageType:STIMMessageType_WebRTC_Vedio];
    
    [[STIMKit sharedInstance] setMsgShowText:@"[语音聊天]" ForMessageType:STIMMessageType_WebRTC_Audio];
    
    [[STIMKit sharedInstance] setMsgShowText:@"[视频聊天]" ForMessageType:STIMMessageType_WebRTC_Vedio];
    
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Voice_Call_tip"] ForMessageType:STIMWebRTC_MsgType_Audio];
    
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Video_Call_tip"] ForMessageType:STIMWebRTC_MsgType_Video];
#endif
#if __has_include("STIMWebRTCClient.h")
    //视频会议
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRTCChatCell" ForMessageType:STIMMessageTypeWebRtcMsgTypeVideoMeeting];


    [[STIMKit sharedInstance] setMsgShowText:@"[视频会议]" ForMessageType:STIMMessageTypeWebRtcMsgTypeVideoMeeting];
    
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRTCChatCell" ForMessageType:STIMMessageTypeWebRtcMsgTypeVideoGroup];
    [[STIMKit sharedInstance] setMsgShowText:@"[视频会议]" ForMessageType:STIMMessageTypeWebRtcMsgTypeVideoGroup];
    
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Video_Conference_tip"] ForMessageType:STIMMessageTypeWebRtcMsgTypeVideoMeeting];
    
#endif
    // 窗口抖动
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMShockMsgCell" ForMessageType:STIMMessageType_Shock];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Shake_Screen_tip"] ForMessageType:STIMMessageType_Shock];

    //问题列表
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRobotQuestionCell" ForMessageType:STIMMessageTypeRobotQuestionList];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Problem_List_tip"] ForMessageType:STIMMessageTypeRobotQuestionList];
    
    //机器人答案
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMRobotAnswerCell" ForMessageType:STIMMessageType_RobotAnswer];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Robot_Answer_tip"] ForMessageType:STIMMessageType_RobotAnswer];
    
    // 第三方通用Cell
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMCommonTrdInfoCell" ForMessageType:STIMMessageType_CommonTrdInfo];
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMCommonTrdInfoCell" ForMessageType:STIMMessageType_CommonTrdInfoPer];
    //加密消息Cell
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMEncryptChatCell" ForMessageType:STIMMessageType_Encrypt];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Encrypted_Message_tip"] ForMessageType:STIMMessageType_Encrypt];
    
    //会议室提醒
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMMeetingRemindCell" ForMessageType:STIMMessageTypeMeetingRemind];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Meeting_Room_Notification"] ForMessageType:STIMMessageTypeMeetingRemind];
    
    //驼圈提醒
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMWorkMomentRemindCell" ForMessageType:STIMMessageTypeWorkMomentRemind];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"Moments_Notification"] ForMessageType:STIMMessageTypeWorkMomentRemind];
    
    //勋章提醒
    [[STIMKit sharedInstance] registerMsgCellClassName:@"STIMUserMedalRemindCell" ForMessageType:STIMMessageTypeUserMedalRemind];
    [[STIMKit sharedInstance] setMsgShowText:@"勋章提醒" ForMessageType:STIMMessageTypeUserMedalRemind];

    [[STIMKit sharedInstance] setMsgShowText:@"收到一条消息" ForMessageType:STIMMessageType_GroupNotify];
    [[STIMKit sharedInstance] setMsgShowText:[NSBundle stimDB_localizedStringForKey:@"received_message"] ForMessageType:STIMMessageType_GroupNotify];
}

@end

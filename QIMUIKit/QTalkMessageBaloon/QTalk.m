//
//  QTalk.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QTalk.h"
#import "QIMKitPublicHeader.h"
#import "QIMIconFont.h"
#import "QIMImageManager.h"
#import "QIMEmotionManager.h"
#if __has_include("QIMNoteManager.h")
#import "QIMNoteManager.h"
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
    [QIMIconFont setFontName:@"QTalk-QChat"];
    
    //初始化图片缓存地址
    [[QIMImageManager sharedInstance] initWithQIMImageCacheNamespace:@"QIMImageCache"];

    // 初始化表情
    [QIMEmotionManager sharedInstance];
    // 初始化管理类
    [QIMKit sharedInstance];
#if __has_include("QIMNoteManager.h")
    //初始化QIMNote
    [QIMNoteManager sharedInstance];
#endif
    
    // 注册支持的消息类型
    // 文本消息
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMDefalutMessageCell" ForMessageType:QIMMessageType_Text];
    [[QIMKit sharedInstance] setMsgShowText:@"[文本]" ForMessageType:QIMMessageType_Text];
    // 图片
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatImageCell" ForMessageType:QIMMessageType_Image];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"[Photo]"] ForMessageType:QIMMessageType_Image];
    [[QIMKit sharedInstance] setMsgShowText:@"[表情]" ForMessageType:QIMMessageType_ImageNew];

    // 语音
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatVoiceCell" ForMessageType:QIMMessageType_Voice];
    [[QIMKit sharedInstance] setMsgShowText:@"[语音]" ForMessageType:QIMMessageType_Voice];
    // 文件
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMFileCell" ForMessageType:QIMMessageType_File];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"[File]"] ForMessageType:QIMMessageType_File];
    // 时间戳
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatTimestampCell" ForMessageType:QIMMessageType_Time];
    // Topic
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMGroupTopicCell" ForMessageType:QIMMessageType_Topic];
    [[QIMKit sharedInstance] setMsgShowText:@"[群公告]" ForMessageType:QIMMessageType_Topic];
    // Location Share 
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMLocationShareMsgCell" ForMessageType:QIMMessageType_LocalShare];
    // card Share
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMCardShareMsgCell" ForMessageType:QIMMessageType_CardShare];
    [[QIMKit sharedInstance] setMsgShowText:@"[位置分享]" ForMessageType:QIMMessageType_LocalShare];
    
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMShareLocationChatCell" ForMessageType:QIMMessageType_shareLocation];
    [[QIMKit sharedInstance] setMsgShowText:@"[位置共享]" ForMessageType:QIMMessageType_shareLocation];
    
    // Video
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMVideoMsgCell" ForMessageType:QIMMessageType_SmallVideo];
    [[QIMKit sharedInstance] setMsgShowText:@"[视频]" ForMessageType:QIMMessageType_SmallVideo];
    // Source Code
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSourceCodeCell" ForMessageType:QIMMessageType_SourceCode];
    [[QIMKit sharedInstance] setMsgShowText:@"[代码段]" ForMessageType:QIMMessageType_SourceCode];
//    QIMMessageType_Markdown
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSourceCodeCell" ForMessageType:QIMMessageType_Markdown];
    [[QIMKit sharedInstance] setMsgShowText:@"[Markdown]" ForMessageType:QIMMessageType_Markdown];
    
    // red pack
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRedPackCell" ForMessageType:QIMMessageType_RedPack];
    [[QIMKit sharedInstance] setMsgShowText:@"[红包]" ForMessageType:QIMMessageType_RedPack];
    
    // red pack desc
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRedPackDescCell" ForMessageType:QIMMessageType_RedPackInfo];
    [[QIMKit sharedInstance] setMsgShowText:@"[红包]" ForMessageType:QIMMessageType_RedPackInfo];
    
    //预测对赌
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMForecastCell" ForMessageType:QIMMessageType_Forecast];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Prediction_tip"] ForMessageType:QIMMessageType_Forecast];
    
    //抢单消息
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Order_Taking_tip"] ForMessageType:MessageType_C2BGrabSingle];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Order_Taking_tip"] ForMessageType:MessageType_QCZhongbao];

    
    // red pack desc
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRedPackDescCell" ForMessageType:QIMMessageType_RedPackInfo];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"redpack_tip"] ForMessageType:QIMMessageType_RedPackInfo];
    
    // AA收款
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMAACollectionCell" ForMessageType:QIMMessageType_AA];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Split_Bill_tip"] ForMessageType:QIMMessageType_AA];
    
    // AA收款 desc
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMAACollectionDescCell" ForMessageType:QIMMessageType_AAInfo];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Split_Bill_tip"] ForMessageType:QIMMessageType_AAInfo];
    
    // 产品信息
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMProductInfoCell" ForMessageType:QIMMessageType_product];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Product_Information_tip"] ForMessageType:QIMMessageType_product];
    
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMExtensibleProductCell" ForMessageType:QIMMessageType_ExProduct];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Product_Information_tip"] ForMessageType:QIMMessageType_ExProduct];
    
    // 活动
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMActivityCell" ForMessageType:QIMMessageType_activity];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Event_tip"] ForMessageType:QIMMessageType_activity];
    
    // 撤回消息
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatTimestampCell" ForMessageType:QIMMessageType_Revoke];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"recalled_message"] ForMessageType:QIMMessageType_Revoke];
    
#if __has_include("QIMWebRTCClient.h")
    //语音聊天
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRTCChatCell" ForMessageType:QIMMessageType_WebRTC_Audio];
    //视频聊天
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRTCChatCell" ForMessageType:QIMMessageType_WebRTC_Vedio];
    
    [[QIMKit sharedInstance] setMsgShowText:@"[语音聊天]" ForMessageType:QIMMessageType_WebRTC_Audio];
    
    [[QIMKit sharedInstance] setMsgShowText:@"[视频聊天]" ForMessageType:QIMMessageType_WebRTC_Vedio];
    
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Voice_Call_tip"] ForMessageType:QIMWebRTC_MsgType_Audio];
    
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Video_Call_tip"] ForMessageType:QIMWebRTC_MsgType_Video];
#endif
#if __has_include("QIMWebRTCClient.h")
    //视频会议
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRTCChatCell" ForMessageType:QIMMessageTypeWebRtcMsgTypeVideoMeeting];


    [[QIMKit sharedInstance] setMsgShowText:@"[视频会议]" ForMessageType:QIMMessageTypeWebRtcMsgTypeVideoMeeting];
    
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRTCChatCell" ForMessageType:QIMMessageTypeWebRtcMsgTypeVideoGroup];
    [[QIMKit sharedInstance] setMsgShowText:@"[视频会议]" ForMessageType:QIMMessageTypeWebRtcMsgTypeVideoGroup];
    
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Video_Conference_tip"] ForMessageType:QIMMessageTypeWebRtcMsgTypeVideoMeeting];
    
#endif
    // 窗口抖动
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMShockMsgCell" ForMessageType:QIMMessageType_Shock];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Shake_Screen_tip"] ForMessageType:QIMMessageType_Shock];

    //问题列表
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRobotQuestionCell" ForMessageType:QIMMessageTypeRobotQuestionList];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Problem_List_tip"] ForMessageType:QIMMessageTypeRobotQuestionList];
    
    //机器人答案
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRobotAnswerCell" ForMessageType:QIMMessageType_RobotAnswer];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Robot_Answer_tip"] ForMessageType:QIMMessageType_RobotAnswer];
    
    // 第三方通用Cell
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMCommonTrdInfoCell" ForMessageType:QIMMessageType_CommonTrdInfo];
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMCommonTrdInfoCell" ForMessageType:QIMMessageType_CommonTrdInfoPer];
    //加密消息Cell
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMEncryptChatCell" ForMessageType:QIMMessageType_Encrypt];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Encrypted_Message_tip"] ForMessageType:QIMMessageType_Encrypt];
    
    //会议室提醒
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMMeetingRemindCell" ForMessageType:QIMMessageTypeMeetingRemind];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Meeting_Room_Notification"] ForMessageType:QIMMessageTypeMeetingRemind];
    
    //驼圈提醒
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMWorkMomentRemindCell" ForMessageType:QIMMessageTypeWorkMomentRemind];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"Moments_Notification"] ForMessageType:QIMMessageTypeWorkMomentRemind];
    
    //勋章提醒
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMUserMedalRemindCell" ForMessageType:QIMMessageTypeUserMedalRemind];
    [[QIMKit sharedInstance] setMsgShowText:@"勋章提醒" ForMessageType:QIMMessageTypeUserMedalRemind];

    [[QIMKit sharedInstance] setMsgShowText:@"收到一条消息" ForMessageType:QIMMessageType_GroupNotify];
    [[QIMKit sharedInstance] setMsgShowText:[NSBundle qim_localizedStringForKey:@"received_message"] ForMessageType:QIMMessageType_GroupNotify];
}

@end

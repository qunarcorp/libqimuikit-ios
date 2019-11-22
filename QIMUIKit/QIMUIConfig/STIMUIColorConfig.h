//
//  STIMUIColorConfig.h
//  STIMUIKit
//
//  Created by lilu on 2019/4/25.
//  Copyright © 2019 STIM. All rights reserved.
//

#ifndef STIMUIColorConfig_h
#define STIMUIColorConfig_h

#import "UIColor+STIMUtility.h"

#define stimDB_tabImageNormalColor [UIColor stimDB_colorWithHex:0xC8D5DD alpha:1.0]        //tab正常图标按钮颜色
#define stimDB_tabImageSelectedColor [UIColor stimDB_colorWithHex:0x00CABE alpha:1.0]      //tab选中图标按钮颜色

#define stimDB_tabTitleNormalColor [UIColor stimDB_colorWithHex:0x333333 alpha:1.0]        //tab正常图标按钮颜色
#define stimDB_tabTitleSelectedColor [UIColor stimDB_colorWithHex:0x00CABE alpha:1.0]      //tab选中图标按钮颜色

#define stimDB_mainViewBadgeNumberLabelBgColor      [UIColor stimDB_colorWithHex:0xEB524A alpha:1.0]  //tab上BadgeNumber TextColor

#define stimDB_texbar_button_normalColor [UIColor stimDB_colorWithHex:0xA5A5A5 alpha:1.0] //输入框按钮normal颜色
#define stimDB_texbar_button_highColor [UIColor stimDB_colorWithHex:0xA5A5A5 alpha:0.7] //输入框按钮high颜色
#define stimDB_texbar_button_selectedColor [UIColor stimDB_colorWithHex:0xA5A5A5 alpha:0.5] //输入框按钮selected颜色

#define stimDB_rightMoreBtnColor     [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]     //右上角More按钮颜色
#define stimDB_rightArrowImageColor  [UIColor stimDB_colorWithHex:0x00CABE alpha:1.0]      //右上角arrow按钮颜色
#define stimDB_rightArrowTitleColor  [UIColor stimDB_colorWithHex:0x333333 alpha:1.0]      //右上角arrow按钮颜色

#define stimDB_listSearchBgViewColor  [UIColor stimDB_colorWithHex:0xEEEEEE alpha:1.0]    //搜索框Bg颜色
#define stimDB_listSearchIconViewColor  [UIColor stimDB_colorWithHex:0xBFBFBF alpha:1.0]    //搜索框IconView颜色

#define stimDB_otherPlatformViewBgColor [UIColor whiteColor]               //其他平台已登录BgColor
#define stimDB_otherPlatformViewIconColor [UIColor stimDB_colorWithHex:0xB5B5B5 alpha:1.0]    //其他平台已登录IconColor

#define stimDB_otherPlatformViewTextColor [UIColor stimDB_colorWithHex:0x888888 alpha:1.0]    //其他平台已登录TextColor
#define stimDB_otherPlatformViewRightArrowColor [UIColor stimDB_colorWithHex:0xC4C4C5 alpha:1.0]  //其他平台已登录ArrowColor

#define stimDB_mainRootViewBgColor   [UIColor whiteColor] //主界面bg颜色

#define stimDB_sessionViewBgColor [UIColor whiteColor] //会话列表页Bg颜色
#define stimDB_sessionViewConnectionErrorViewBgColor    [UIColor stimDB_colorWithHex:0xFAE4E3 alpha:1.0]  //网络连接错误BgColor
#define stimDB_sessionViewConnectionErrorTextColor    [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]  //网络连接错误TextColor
#define stimDB_sessionViewNotReadNumButtonColor       [UIColor stimDB_colorWithHex:0xEB524A alpha:1.0]  //未读消息提醒气泡Color
#define stimDB_sessionViewMuteColor                   [UIColor stimDB_colorWithHex:0xDBDBDB alpha:1.0]  //接收不提醒Color

#define stimDB_sessionCellNameTextColor               [UIColor stimDB_colorWithHex:0x333333 alpha:1.0]  //会话列表页Name TextColor
#define stimDB_sessionCellTimeTextColor               [UIColor stimDB_colorWithHex:0xBFBFBF alpha:1.0]  //会话列表页时间戳TextColor
#define stimDB_sessionCellContentTextColor            [UIColor stimDB_colorWithHex:0x999999 alpha:1.0]  //会话列表页Content TextColor


#define stimDB_groupchat_rightCard_Color    [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]       //群右上角
#define stimDB_singlechat_rightCard_Color   [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]       //单人右上角

#define stimDB_nav_moment_color   [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]    //驼圈右上角
#define stimDB_nav_myself_color   [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]    //驼圈右上角

#define stimDB_backButtonTextBgColor [UIColor stimDB_colorWithHex:0xF2F2F2 alpha:1.0]     //返回按钮字体bg
#define stimDB_backButtonColor [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]     //返回按钮Color
#define stimDB_backButtonTextColor [UIColor stimDB_colorWithHex:0xA1A1A1 alpha:1.0]     //返回按钮字体Color

//会话内
#define stimDB_chatBgColor [UIColor stimDB_colorWithHex:0xF0F3F5 alpha:1.0]   //会话背景色

#define stimDB_chatWaterMaskBgColor    [UIColor stimDB_colorWithHex:0xF0F3F5 alpha:1.0]   //会话水印背景色
#define stimDB_chatWaterMaskTextColor  [UIColor stimDB_colorWithHex:0xD4D4D4 alpha:1.0]   //会话水印Text色

#define stimDB_messageLeftBubbleBorderColor [UIColor stimDB_colorWithHex:0xE1E1E1 alpha:1.0]    //左侧气泡边框颜色
#define stimDB_messageRightBubbleBorderColor [UIColor stimDB_colorWithHex:0xA9D2DA alpha:1.0]    //右侧气泡边框颜色

#define stimDB_messageLeftBubbleBgColor [UIColor stimDB_colorWithHex:0xFEFFFE alpha:1.0] //左侧气泡颜色
#define stimDB_messageRightBubbleBgColor [UIColor stimDB_colorWithHex:0xC5EAEE alpha:1.0] //右侧气泡颜色

#define stimDB_messageLeftBubbleTextColor [UIColor stimDB_colorWithHex:0x333333 alpha:1.0] //左侧气泡字体颜色
#define stimDB_messageRightBubbleTextColor [UIColor stimDB_colorWithHex:0x555555 alpha:1.0] //右侧气泡字体颜色

#define stimDB_ChatTimestampCellBgColor   [UIColor stimDB_colorWithHex:0xD3D3D3 alpha:1.0] //时间戳气泡背景颜色

#define stimDB_messageText_color  [UIColor stimDB_colorWithHex:0x333333 alpha:1.0]    //文本消息颜色
#define stimDB_messageLinkurl_color [UIColor stimDB_colorWithHex:0x48A3FF alpha:1.0]         //link颜色back
#define stimDB_messageUnReadState_color [UIColor stimDB_colorWithHex:0x00C1BA alpha:1.0]      //消息未读提示Color
#define stimDB_messageReadState_color [UIColor stimDB_colorWithHex:0xBFBFBF alpha:1.0]      //消息未读提示Color

#define stimDB_newmessageUpArrowBgColor  [UIColor stimDB_colorWithHex:0xFFFFFF alpha:1.0] //会话内新消息UpArrow textColor
#define stimDB_newmessageUpArrowBorderColor  [UIColor stimDB_colorWithHex:0xE4E4E4 alpha:1.0] //会话内新消息UpArrow BorderColor
#define stimDB_newmessageUpArrowTextColor  [UIColor stimDB_colorWithHex:0x666666 alpha:1.0] //会话内新消息UpArrow textColor
#define stimDB_notReadAtMessageUpArrowTextColor [UIColor stimDB_colorWithHex:0xEB524A alpha:1.0] //会话内艾特消息提醒UpArrow textColor

#define stimDB_singlechat_title_color  [UIColor stimDB_colorWithHex:0x333333 alpha:1.0]    //单人聊天titleColor
#define stimDB_singlechat_desc_color   [UIColor stimDB_colorWithHex:0x999999 alpha:1.0]    //单人聊天descColor

#define stimDB_groupchat_title_color   [UIColor stimDB_colorWithHex:0x333333 alpha:1.0]    //群聊天titleColor

#define stimDB_chatsearchRemindViewTextColor    [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]  //聊天会话内快捷搜索提示条TextColor
#define stimDB_chatsearchRemindViewIconColor [UIColor stimDB_colorWithHex:0x0BCCC0 alpha:1.0] //聊天会话内快捷搜索提示条IconColor

//MainVc导航item
#define stimDB_nav_scan_btnColor       [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]   //扫码二维码按钮Color
#define stimDB_nav_addfriend_btnColor  [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]   //添加好友按钮Color
#define stimDB_nav_mymoment_btnColor   [UIColor stimDB_colorWithHex:0x666666 alpha:1.0]       //我的驼圈

//驼圈
#define stimDB_nav_addnewmoment_btnColor   [UIColor stimDB_colorWithHex:0x00CABE]      //新建驼圈按钮Color

#define stimDB_moment_alum_btnColor                 [UIColor stimDB_colorWithHex:0x5EBA9E]      //驼圈相册按钮
#define stimDB_moment_video_btnColor                  [UIColor stimDB_colorWithHex:0x7F91FD]       //驼圈视频按钮
#define stimDB_moment_at_btnColor                     [UIColor stimDB_colorWithHex:0xF8C43D]       //驼圈艾特按钮

#endif /* STIMUIColorConfig_h */

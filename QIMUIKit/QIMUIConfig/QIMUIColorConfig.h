//
//  QIMUIColorConfig.h
//  QIMUIKit
//
//  Created by lilu on 2019/4/25.
//  Copyright © 2019 QIM. All rights reserved.
//

#ifndef QIMUIColorConfig_h
#define QIMUIColorConfig_h

#import "UIColor+QIMUtility.h"

#define qim_tabImageNormalColor [UIColor qim_colorWithHex:0xC8D5DD alpha:1.0]        //tab正常图标按钮颜色
#define qim_tabImageSelectedColor [UIColor qim_colorWithHex:0x00CABE alpha:1.0]      //tab选中图标按钮颜色

#define qim_tabTitleNormalColor [UIColor qim_colorWithHex:0x333333 alpha:1.0]        //tab正常图标按钮颜色
#define qim_tabTitleSelectedColor [UIColor qim_colorWithHex:0x00CABE alpha:1.0]      //tab选中图标按钮颜色

#define qim_mainViewBadgeNumberLabelBgColor      [UIColor qim_colorWithHex:0xEB524A alpha:1.0]  //tab上BadgeNumber TextColor

#define qim_texbar_button_normalColor [UIColor qim_colorWithHex:0xA5A5A5 alpha:1.0] //输入框按钮normal颜色
#define qim_texbar_button_highColor [UIColor qim_colorWithHex:0xA5A5A5 alpha:0.7] //输入框按钮high颜色
#define qim_texbar_button_selectedColor [UIColor qim_colorWithHex:0xA5A5A5 alpha:0.5] //输入框按钮selected颜色

#define qim_rightMoreBtnColor     [UIColor qim_colorWithHex:0x666666 alpha:1.0]     //右上角More按钮颜色
#define qim_rightArrowImageColor  [UIColor qim_colorWithHex:0x00CABE alpha:1.0]      //右上角arrow按钮颜色
#define qim_rightArrowTitleColor  [UIColor qim_colorWithHex:0x333333 alpha:1.0]      //右上角arrow按钮颜色

#define qim_listSearchBgViewColor  [UIColor qim_colorWithHex:0xEEEEEE alpha:1.0]    //搜索框Bg颜色
#define qim_listSearchIconViewColor  [UIColor qim_colorWithHex:0xBFBFBF alpha:1.0]    //搜索框IconView颜色

#define qim_otherPlatformViewBgColor [UIColor whiteColor]               //其他平台已登录BgColor
#define qim_otherPlatformViewIconColor [UIColor qim_colorWithHex:0xB5B5B5 alpha:1.0]    //其他平台已登录IconColor

#define qim_otherPlatformViewTextColor [UIColor qim_colorWithHex:0x888888 alpha:1.0]    //其他平台已登录TextColor
#define qim_otherPlatformViewRightArrowColor [UIColor qim_colorWithHex:0xC4C4C5 alpha:1.0]  //其他平台已登录ArrowColor

#define qim_mainRootViewBgColor   [UIColor whiteColor] //主界面bg颜色

#define qim_sessionViewBgColor [UIColor whiteColor] //会话列表页Bg颜色
#define qim_sessionViewConnectionErrorViewBgColor    [UIColor qim_colorWithHex:0xFAE4E3 alpha:1.0]  //网络连接错误BgColor
#define qim_sessionViewConnectionErrorTextColor    [UIColor qim_colorWithHex:0x666666 alpha:1.0]  //网络连接错误TextColor
#define qim_sessionViewNotReadNumButtonColor       [UIColor qim_colorWithHex:0xEB524A alpha:1.0]  //未读消息提醒气泡Color
#define qim_sessionViewMuteColor                   [UIColor qim_colorWithHex:0xDBDBDB alpha:1.0]  //接收不提醒Color

#define qim_sessionCellNameTextColor               [UIColor qim_colorWithHex:0x333333 alpha:1.0]  //会话列表页Name TextColor
#define qim_sessionCellTimeTextColor               [UIColor qim_colorWithHex:0xBFBFBF alpha:1.0]  //会话列表页时间戳TextColor
#define qim_sessionCellContentTextColor            [UIColor qim_colorWithHex:0x999999 alpha:1.0]  //会话列表页Content TextColor


#define qim_groupchat_rightCard_Color    [UIColor qim_colorWithHex:0x666666 alpha:1.0]       //群右上角
#define qim_singlechat_rightCard_Color   [UIColor qim_colorWithHex:0x666666 alpha:1.0]       //单人右上角

#define qim_nav_moment_color   [UIColor qim_colorWithHex:0x666666 alpha:1.0]    //驼圈右上角
#define qim_nav_myself_color   [UIColor qim_colorWithHex:0x666666 alpha:1.0]    //驼圈右上角

#define qim_backButtonTextBgColor [UIColor qim_colorWithHex:0xF2F2F2 alpha:1.0]     //返回按钮字体bg
#define qim_backButtonColor [UIColor qim_colorWithHex:0x666666 alpha:1.0]     //返回按钮Color
#define qim_backButtonTextColor [UIColor qim_colorWithHex:0xA1A1A1 alpha:1.0]     //返回按钮字体Color

//会话内
#define qim_chatBgColor [UIColor qim_colorWithHex:0xF0F3F5 alpha:1.0]   //会话背景色

#define qim_chatWaterMaskBgColor    [UIColor qim_colorWithHex:0xF0F3F5 alpha:1.0]   //会话水印背景色
#define qim_chatWaterMaskTextColor  [UIColor qim_colorWithHex:0xD4D4D4 alpha:1.0]   //会话水印Text色

#define qim_messageLeftBubbleBorderColor [UIColor qim_colorWithHex:0xE1E1E1 alpha:1.0]    //左侧气泡边框颜色
#define qim_messageRightBubbleBorderColor [UIColor qim_colorWithHex:0xA9D2DA alpha:1.0]    //右侧气泡边框颜色

#define qim_messageLeftBubbleBgColor [UIColor qim_colorWithHex:0xFEFFFE alpha:1.0] //左侧气泡颜色
#define qim_messageRightBubbleBgColor [UIColor qim_colorWithHex:0xC5EAEE alpha:1.0] //右侧气泡颜色

#define qim_messageLeftBubbleTextColor [UIColor qim_colorWithHex:0x333333 alpha:1.0] //左侧气泡字体颜色
#define qim_messageRightBubbleTextColor [UIColor qim_colorWithHex:0x555555 alpha:1.0] //右侧气泡字体颜色

#define qim_ChatTimestampCellBgColor   [UIColor qim_colorWithHex:0xD3D3D3 alpha:1.0] //时间戳气泡背景颜色

#define qim_messageText_color  [UIColor qim_colorWithHex:0x333333 alpha:1.0]    //文本消息颜色
#define qim_messageLinkurl_color [UIColor qim_colorWithHex:0x48A3FF alpha:1.0]         //link颜色back
#define qim_messageUnReadState_color [UIColor qim_colorWithHex:0x00C1BA alpha:1.0]      //消息未读提示Color
#define qim_messageReadState_color [UIColor qim_colorWithHex:0xBFBFBF alpha:1.0]      //消息未读提示Color

#define qim_newmessageUpArrowBgColor  [UIColor qim_colorWithHex:0xFFFFFF alpha:1.0] //会话内新消息UpArrow textColor
#define qim_newmessageUpArrowBorderColor  [UIColor qim_colorWithHex:0xE4E4E4 alpha:1.0] //会话内新消息UpArrow BorderColor
#define qim_newmessageUpArrowTextColor  [UIColor qim_colorWithHex:0x666666 alpha:1.0] //会话内新消息UpArrow textColor
#define qim_notReadAtMessageUpArrowTextColor [UIColor qim_colorWithHex:0xEB524A alpha:1.0] //会话内艾特消息提醒UpArrow textColor

#define qim_singlechat_title_color  [UIColor qim_colorWithHex:0x333333 alpha:1.0]    //单人聊天titleColor
#define qim_singlechat_desc_color   [UIColor qim_colorWithHex:0x999999 alpha:1.0]    //单人聊天descColor

#define qim_groupchat_title_color   [UIColor qim_colorWithHex:0x333333 alpha:1.0]    //群聊天titleColor

#define qim_chatsearchRemindViewTextColor    [UIColor qim_colorWithHex:0x666666 alpha:1.0]  //聊天会话内快捷搜索提示条TextColor
#define qim_chatsearchRemindViewIconColor [UIColor qim_colorWithHex:0x0BCCC0 alpha:1.0] //聊天会话内快捷搜索提示条IconColor

//MainVc导航item
#define qim_nav_scan_btnColor       [UIColor qim_colorWithHex:0x666666 alpha:1.0]   //扫码二维码按钮Color
#define qim_nav_addfriend_btnColor  [UIColor qim_colorWithHex:0x666666 alpha:1.0]   //添加好友按钮Color
#define qim_nav_mymoment_btnColor   [UIColor qim_colorWithHex:0x666666 alpha:1.0]       //我的驼圈

//驼圈
#define qim_nav_addnewmoment_btnColor   [UIColor qim_colorWithHex:0x00CABE]      //新建驼圈按钮Color

#define qim_moment_alum_btnColor                 [UIColor qim_colorWithHex:0x5EBA9E]      //驼圈相册按钮
#define qim_moment_video_btnColor                  [UIColor qim_colorWithHex:0x7F91FD]       //驼圈视频按钮
#define qim_moment_at_btnColor                     [UIColor qim_colorWithHex:0xF8C43D]       //驼圈艾特按钮

#endif /* QIMUIColorConfig_h */

//
//  STIMSingleChatVoiceCell.h
//  DangDiRen
//
//  Created by ping.xue on 14-3-27.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//
//  为了完成groupChat中识别音频发起人，将voiceCell的refreshUI分为doChatVCRefresh和doGroupChatVCRefresh两部分。在ChatVC中直接使用doChatVCRefresh，在groupChatVC中使用doGroupChatVCRefresh。

#import "STIMCommonUIFramework.h"
#import "STIMMsgBaloonBaseCell.h"

@class STIMMessageModel;

@protocol STIMSingleChatVoiceCellDelegate;

#define kNotifyPlayVoiceTime                @"kNotifyPlayProcess"
#define kNotifyPlayVoiceTimeMsgId           @"kNotifyPlayVoiceTimeMsgId"
#define kNotifyPlayVoiceTimeTime            @"kNotifyPlayVoiceTimeTime"

#define kNotifyDownloadProgress             @"kNotifyDownloadProgress"
#define kNotifyDownloadProgressMsgId        @"kNotifyDownloadProgressMsgId"
#define kNotifyDownloadProgressProgress     @"kNotifyDownloadProgressProgress"


@interface STIMSingleChatVoiceCell : STIMMsgBaloonBaseCell<STIMMenuImageViewDelegate>

@property (nonatomic, weak) id<STIMSingleChatVoiceCellDelegate,STIMMsgBaloonBaseCellDelegate> delegate;
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, copy) NSString *messageDate;
@property (nonatomic, assign) BOOL isGroupVoice;

- (void)refreshUI;
- (void)onClick ;
@end

@protocol STIMSingleChatVoiceCellDelegate <NSObject>
@required

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId;
- (int)playCurrentTime;
- (double)getCurrentDownloadProgress;

@end

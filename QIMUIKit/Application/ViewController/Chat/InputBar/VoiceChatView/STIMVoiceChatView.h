//
//  STIMVoiceChatView.h
//  STChatIphone
//
//  Created by haibin.li on 15/7/13.
//
//

typedef enum {
    VoiceChatRecordingStatusStart,
    VoiceChatRecordingStatusRecording,
    VoiceChatRecordingStatusEnd,
    VoiceChatRecordingStatusCancel,
    VoiceChatRecordingStatusAudition,
    VoiceChatRecordingStatusSend,
} VoiceChatRecordingStatus;

typedef enum {
    VoiceBtnStatusNomal,
    VoiceBtnStatusRecording,
    VoiceBtnStatusAuditionStart,
    VoiceBtnStatusAuditionStop,
} VoiceBtnStatus;

#import "STIMCommonUIFramework.h"

@class STIMVoiceChatView;

@protocol STIMVoiceChatViewDelegate <NSObject>

- (void)voiceChatView:(STIMVoiceChatView *)voiceChatView RecordingAtStatus:(VoiceChatRecordingStatus)status;

@end

@interface STIMVoiceChatView : UIView
@property (nonatomic,assign)id<STIMVoiceChatViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame;

- (void)stopPlayVoice;

@end

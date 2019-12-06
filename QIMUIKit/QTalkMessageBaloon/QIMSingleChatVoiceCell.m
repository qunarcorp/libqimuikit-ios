//
//  QIMSingleChatVoiceCell.m
//  DangDiRen
//
//  Created by ping.xue on 14-3-27.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QIMSingleChatVoiceCell.h"
#import "QIMVoiceNoReadStateManager.h"
#import "QIMPlayVoiceManager.h"
#import "QIMCommonFont.h"

#define kBackViewWidth      200
#define kBackViewHeight     35
#define kCellHeightCap      5
#define kBackViewCap        15

#define kVoiceImageLeft     15
#define KVoiceImageRight    5
#define kVoiceImageTop      7
#define kVoiceImageWidth    18
#define kVoiceImageHeight   18
#define kMyBackViewCap      55
#define KTimeLabelWeight    35


static NSArray *_receiveImageArray = nil;
static NSArray *_sentImageArray = nil;
@interface QIMSingleChatVoiceCell ()
{
    dispatch_queue_t       _playVoiceQueue;
    void                  *_playVoiceQueueTag;
}

@end

@implementation QIMSingleChatVoiceCell
{
    UIImageView *_voiceImageView;
    UILabel *_timeLabel;
    NSInteger _minute;
    UIView * _unreadView;
    UILabel *_dateLabel;
}

@synthesize delegate = _delegate;

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message chatType:(ChatType)chatType{
    return kBackViewHeight + kCellHeightCap + 20;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization cod
        _playVoiceQueueTag = &_playVoiceQueueTag;
        _playVoiceQueue = dispatch_queue_create("xmppRunningQueue", 0);
        dispatch_queue_set_specific(_playVoiceQueue, _playVoiceQueueTag, _playVoiceQueueTag, NULL);
        
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView* view = [[UIView alloc]initWithFrame:self.contentView.frame];
        view.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView = view;
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        if (_receiveImageArray == nil) {
            _receiveImageArray = [[NSArray alloc] initWithObjects:[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Friend_Icon1"],[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Friend_Icon2"],[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Friend_Icon3"],[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Friend_Icon4"], nil];
        }
        
        if (_sentImageArray == nil) {
            _sentImageArray = [[NSArray alloc] initWithObjects:[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Myself_Icon1"],[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Myself_Icon2"],[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Myself_Icon3"],[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Myself_Icon4"], nil];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [self.backView addGestureRecognizer:tap];
        
        _voiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kVoiceImageLeft, kVoiceImageTop, kVoiceImageWidth, kVoiceImageHeight)];
        [self.backView addSubview:_voiceImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kVoiceImageLeft + kVoiceImageWidth + kVoiceImageLeft, kVoiceImageTop, kBackViewWidth - (kVoiceImageLeft + kVoiceImageWidth + kVoiceImageLeft) - kVoiceImageLeft, kVoiceImageHeight)];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextColor:[UIColor blackColor]];
        [_timeLabel setText:@"01:55"];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [_timeLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:_timeLabel];
        
        _unreadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _unreadView.backgroundColor = [UIColor redColor];
        _unreadView.layer.cornerRadius = 4.0f;
        _unreadView.layer.masksToBounds = YES;
        _unreadView.centerY = _timeLabel.centerY;
        _unreadView.hidden = YES;
        [self.contentView addSubview:_unreadView];

        _dateLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_dateLabel];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginToPlayNotification:) name:kNotifyBeginToPlay object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noReadViewUpdateNotification:) name:kNotifyEndPlay object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayVoiceTime:) name:kNotifyPlayVoiceTime object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:kNotifyDownloadProgress object:nil];
        //自动播放下一条未读语音
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClick) name:kAutoPlayNextVoiceMsgHandleNotification object:nil];
    }
    return self;
}

- (void)resendMessage{
    
}

- (void)updatePlayVoiceTime:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    NSString *msgId = [userInfo objectForKey:kNotifyPlayVoiceTimeMsgId];
    long long time = [[userInfo objectForKey:kNotifyPlayVoiceTimeTime] longLongValue];
    if ([msgId isEqualToString:self.message.messageId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int sec = time % 60;
            if (!_minute) {
                
                [_timeLabel setText:[NSString stringWithFormat:@"%02d''", (sec + 1) % 60]];
            } else {
                
                if (sec + 1 == 60) {
                    sec = -1;
                }
                [_timeLabel setText:[NSString stringWithFormat:@"%ld'%02d''", (long)_minute, (sec + 1) % 60]];
            }
            if (sec == 58) {
                _minute += 1;
            }
        });
    }
}

- (void)updateDownloadProgress:(NSNotification *)notify{
}

- (void)beginToPlayNotification:(NSNotification *)notifi {
    
    NSString *msgId = notifi.object;
    if ([msgId isEqual:self.message.messageId]) {
        [self refreshUI];
    }
}

- (void)noReadViewUpdateNotification:(NSNotification *) notification {
    
    NSString *msgId = notification.object;
    if ([msgId isEqual:self.message.messageId]) {
        [self refreshUI];
        [_voiceImageView stopAnimating];
    }
}

- (void)onClick {
    
    if ([self.delegate playingVoiceWithMsgId:self.message.messageId]) {
        
        [[QIMPlayVoiceManager defaultPlayVoiceManager] playVoiceWithMsgId:nil];
        [_voiceImageView stopAnimating];
    } else {
        
        [[QIMPlayVoiceManager defaultPlayVoiceManager] playVoiceWithMsgId:self.message.messageId];
        [_timeLabel setText:@"00''"];
        [_voiceImageView startAnimating];
        if (self.message.messageDirection == QIMMessageDirection_Received) {
            //如果语音未读，mssageID落地
            [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:self.message.messageId ChatId:self.chatId withState:YES];
            [self refreshUI];
        }
    }
}

- (CGRect)getCellBackViewFrame{
    CGRect backFrame = [self convertRect:self.backView.frame fromView:self.contentView];
    return CGRectMake(self.left + backFrame.origin.x, self.top + backFrame.origin.y/2.0, backFrame.size.width, backFrame.size.height);
}

//更改self.backView的长度，大于2s小于10s时，等比增长长度；大于10s时，显示最大长度；小于等于2s时显示最小长度
- (void)refreshUI{
    self.selectedBackgroundView.frame = self.contentView.frame;
    [self.backView setMenuActionTypeList:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete)/*, @(MA_Favorite)*/]];
    [self.backView setMessage:self.message];
    if(_isGroupVoice)
    {
        [self doGroupChatVCRefresh];
    } else {
        [self doChatVCRefresh];
    }
    [super refreshUI];
}

- (void)doChatVCRefresh {
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    int voiceLength = [[infoDic objectForKey:@"Seconds"] intValue];
    int minute = voiceLength / 60 ;
    int sec = voiceLength % 60;
    sec = sec > 0 ? sec : 1;
    
    if (self.message.messageType == QIMMessageType_Voice) {
        CGFloat frameWeight = 0;
        if (voiceLength <= 3) {
            frameWeight = kBackViewWidth*0.3;
        } else if (voiceLength < 10 && voiceLength > 3) {
            frameWeight = kBackViewWidth*(0.3+(voiceLength-2)*0.1);
        }
        else {
            frameWeight = kBackViewWidth;
        }
        
        if (self.message.messageDirection == QIMMessageDirection_Received) {
            
            CGRect frame = {{kBackViewCap+45,kCellHeightCap / 2.0},{frameWeight,kBackViewHeight}};
            [self.backView setFrame:frame];
            UIImage *imageFriend = [UIImage qim_imageNamedFromQIMUIKitBundle:@"chat_Avoice_bg"];
            
            [self.backView setImage:[imageFriend stretchableImageWithLeftCapWidth:20 topCapHeight:17]];
            
            [_voiceImageView setFrame:CGRectMake(kVoiceImageLeft, kVoiceImageTop, kVoiceImageWidth, kVoiceImageHeight)];
            [_voiceImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Friend_Icon1"]];
            [_voiceImageView setAnimationImages:_receiveImageArray];
            [_voiceImageView setAnimationDuration:1];
            
            CGRect timeFrame = CGRectMake(kBackViewCap+frameWeight+4+45, kCellHeightCap / 2.0, KTimeLabelWeight, kBackViewHeight);
            [_timeLabel setFrame:timeFrame];

            _unreadView.frame = CGRectMake(CGRectGetMinX(_timeLabel.frame), kCellHeightCap / 2.0, 8, 8);
            _unreadView.centerY = _timeLabel.centerY;
            
            //如果未读， 小红点显示
            BOOL unreadHidden = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] isReadWithMsgId:self.message.messageId ChatId:self.chatId];
            
            _unreadView.hidden = unreadHidden;
        } else {
            
            CGRect frame = {{self.frameWidth - kBackViewCap - frameWeight - 45,kBackViewCap},{frameWeight,kBackViewHeight}};
            [self.backView setFrame:frame];
            UIImage *imageMyself = [UIImage qim_imageNamedFromQIMUIKitBundle:@"chat_Bvoice_bg"];
            
            [self.backView setImage:[imageMyself stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
            
            
            CGRect voiceImageFrame = CGRectMake(self.backView.frame.size.width-kVoiceImageWidth-KVoiceImageRight-8, kVoiceImageTop, kVoiceImageWidth, kVoiceImageHeight);
            [_voiceImageView setFrame:voiceImageFrame];
            [_voiceImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Myself_Icon1"]];
            [_voiceImageView setAnimationImages:_sentImageArray];
            [_voiceImageView setAnimationDuration:1];
            
            CGRect timeFrame = CGRectMake(self.backView.frame.origin.x-4-KTimeLabelWeight, kBackViewCap, KTimeLabelWeight, kBackViewHeight);
            [_timeLabel setFrame:timeFrame];
        }
    }
    int duration = 0;
    if ([self.delegate playingVoiceWithMsgId:self.message.messageId]) {
        [_voiceImageView startAnimating];
        duration = [self.delegate playCurrentTime];
    } else {
        [_voiceImageView stopAnimating];
    }
    if (minute) {
        
        [_timeLabel setText:[NSString stringWithFormat:@"%d'%02d''", minute, sec]];
    } else {
        
        [_timeLabel setText:[NSString stringWithFormat:@"%02d''", sec]];
    }
}

- (void)doGroupChatVCRefresh {
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    int voiceLength = [[infoDic objectForKey:@"Seconds"] intValue];
    int minute = voiceLength / 60;
    int sec = voiceLength % 60;
    sec = sec > 0 ? sec : 1;

    if (self.message.messageType == QIMMessageType_Voice) {
        CGFloat frameWeight = 0;
        if (voiceLength <= 3) {
            frameWeight = kBackViewWidth*0.3;
        } else if (voiceLength < 10 && voiceLength > 3) {
            frameWeight = kBackViewWidth*(0.3+(voiceLength-2)*0.1);
        }
        else {
            frameWeight = kBackViewWidth;
        }
        if (self.message.messageDirection == QIMMessageDirection_Received) {
            
            [_dateLabel setText:self.messageDate];
            [_dateLabel setTextColor:[UIColor darkGrayColor]];
            
            [_dateLabel setFont:[UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 6]];
            _dateLabel.textAlignment = NSTextAlignmentRight;

            CGRect frame = {{kBackViewCap+45,kCellHeightCap / 2.0+20},{frameWeight,kBackViewHeight}};
            [self.backView setFrame:frame];
            UIImage *imageFriend = [UIImage qim_imageNamedFromQIMUIKitBundle:@"chat_Avoice_bg"];
            
            [self.backView setImage:[imageFriend stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
            
            [_voiceImageView setFrame:CGRectMake(kVoiceImageLeft, kVoiceImageTop, kVoiceImageWidth, kVoiceImageHeight)];
            [_voiceImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Friend_Icon1"]];
            [_voiceImageView setAnimationImages:_receiveImageArray];
            [_voiceImageView setAnimationDuration:1];
            
            CGRect timeFrame = CGRectMake(kBackViewCap+frameWeight+4+45, kCellHeightCap / 2.0+20, KTimeLabelWeight, kBackViewHeight);
            [_timeLabel setFrame:timeFrame];
            [_timeLabel setTextColor:[UIColor qtalkTextBlackColor]];
            _unreadView.frame = CGRectMake(CGRectGetMinX(_timeLabel.frame), kCellHeightCap / 2.0, 8, 8);
            _unreadView.centerY = _timeLabel.centerY;
            //如果未读， 小红点显示
            BOOL unreadHidden = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] isReadWithMsgId:self.message.messageId ChatId:self.chatId];
            _unreadView.hidden = unreadHidden;
        } else {
            
            CGRect frame = {{self.frameWidth - kBackViewCap - frameWeight - 45,kBackViewCap},{frameWeight,kBackViewHeight}};
            [self.backView setFrame:frame];
            UIImage *imageMyself = [UIImage qim_imageNamedFromQIMUIKitBundle:@"chat_Bvoice_bg"];
            
            [self.backView setImage:[imageMyself stretchableImageWithLeftCapWidth:20 topCapHeight:15]];
            
            CGRect voiceImageFrame = CGRectMake(self.backView.frame.size.width-kVoiceImageWidth-KVoiceImageRight-8, kVoiceImageTop, kVoiceImageWidth, kVoiceImageHeight);
            [_voiceImageView setFrame:voiceImageFrame];
            [_voiceImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"Chat_VoiceBubble_Myself_Icon1"]];
            [_voiceImageView setAnimationImages:_sentImageArray];
            [_voiceImageView setAnimationDuration:1];
            
            CGRect timeFrame = CGRectMake(self.backView.frame.origin.x-4-KTimeLabelWeight, kBackViewCap, KTimeLabelWeight, kBackViewHeight);
            [_timeLabel setFrame:timeFrame];
            [_timeLabel setTextColor:[UIColor qtalkTextBlackColor]];
        }
    }
    int duration = 0;
    if ([self.delegate playingVoiceWithMsgId:self.message.messageId]) {
        
        [_voiceImageView startAnimating];
        duration = [self.delegate playCurrentTime];
    } else {
        [_voiceImageView stopAnimating];
    }
    if (minute) {
        
        [_timeLabel setText:[NSString stringWithFormat:@"%d'%02d''", minute, sec]];
    } else {
        
        [_timeLabel setText:[NSString stringWithFormat:@"%02d''", sec]];
    }
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case QIMMessageDirection_Sent: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        default:
            break;
    }
    if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
        [menuList addObject:@(MA_CopyOriginMsg)];
    }
    if ([[QIMKit sharedInstance] getIsIpad]) {
//        [menuList removeObject:@(MA_Refer)];
//        [menuList removeObject:@(MA_Repeater)];
//        [menuList removeObject:@(MA_Delete)];
        [menuList removeObject:@(MA_Forward)];
//        [menuList removeObject:@(MA_Repeater)];
    }
    return menuList;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

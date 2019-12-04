//
//  QIMRTCChatCell.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/22.
//
//

#define kRTCCellWidth       170
#define kRTCCellHeight      40
#define kTextLabelTop       10
#define kTextLableLeft      12
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "QIMMsgBaloonBaseCell.h"
//#import "UIImageView+QIMWebCache.h"
#import "QIMRTCChatCell.h"
#import "RTLabel.h"
@interface QIMRTCChatCell () <QIMMenuImageViewDelegate>
{
    UIImageView     * _imageView;
    UILabel     *   titleLabel;
}

@end

@implementation QIMRTCChatCell

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message chatType:(ChatType)chatType
{
    return kRTCCellHeight + ((chatType == ChatType_GroupChat) && (message.messageDirection == QIMMessageDirection_Received) ? 40 : 20);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"QIMRTCChatCell_Call"]];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
    }
    return self;
}

- (void)tapGesHandle:(UITapGestureRecognizer *)tap{
    if (self.message.messageSendState == QIMMessageSendState_Faild) {
        if (self.message.extendInformation.length > 0) {
            self.message.message = self.message.extendInformation;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamReSendMessage object:self.message];
    }
}

- (void)refreshUI
{
    [super refreshUI];
    if (titleLabel) {
        [titleLabel removeFromSuperview];
        titleLabel = nil;
    }
//    _titleLabel = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, kRTCCellWidth, 20)];
//    _titleLabel.font = [UIFont systemFontOfSize:15];
//    _titleLabel.backgroundColor = [UIColor clearColor];
//    _titleLabel.textAlignment = kCTTextAlignmentLeft;
//
    titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:titleLabel];
    self.backView.message = self.message;
    if (self.message.messageType == QIMMessageType_WebRTC_Audio || self.message.messageType == QIMMessageType_WebRTC_Vedio) {
//        _titleLabel.text = self.message.message;
        NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
        if (infoDic) {
            NSString * type = infoDic[@"type"];
            NSNumber * number = infoDic[@"time"];
            
           if (self.message.messageDirection == QIMMessageDirection_Sent) {
                if ([type isEqualToString:@"cancel"]) {
                    titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_canceled"];//@"已取消";
                }
                else if ([type isEqualToString:@"deny"]) {
                    titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_deny_other"];//@"对方已拒绝";
                }
                else if ([type isEqualToString:@"timeout"]){
                    titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_video_no_answer"];//@"对方无人接听";
                }
                else if (number && number.integerValue>0) {
                    titleLabel.text = self.message.message;
                }
            }
            else if(self.message.messageDirection == QIMMessageDirection_Received){
                if ([type isEqualToString:@"cancel"]) {
                    titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_canceled_by_caller"];//@"对方已取消";
                }
                else if ([type isEqualToString:@"deny"]) {
                    titleLabel.text = [NSBundle qim_localizedStringForKey:@"Declined"];
                }
                else if ([type isEqualToString:@"timeout"]) {
                    titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_avcall"];//@"音视频通话";
                }
                else if (number && number.integerValue>0) {
                    titleLabel.text = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"atom_rtc_duration"],[self getTimestamp:number.integerValue]];
                }
            }
            else{
                titleLabel.text = self.message.message;
            }
        }
        else{
            if (self.message.messageType == QIMMessageType_WebRTC_Audio) {
                titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_acall"];
            }
            else{
                titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_avcall"];// @"音视频通话";
            }
        }
        
        if (self.message.messageType == QIMMessageType_WebRTC_Audio) {
            _imageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"QTalkRTCChatCell_Call"];
        }
        else{
            _imageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"rtc_video_left"];
        }
    } else if (self.message.messageType == QIMMessageTypeWebRtcMsgTypeVideoMeeting) {
        titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_video_conference"];//@"视频会议";
        _imageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"QTalkRTCChatCell_Meeting"];
    }
    else if(self.message.messageType == QIMMessageTypeWebRtcMsgTypeVideoGroup) {
        titleLabel.text = [NSBundle qim_localizedStringForKey:@"atom_rtc_video_conference"];//@"视频会议";
        _imageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"QTalkRTCChatCell_Meeting"];
    }
    [titleLabel sizeToFit];
    float backWidth = titleLabel.width + 60;//[_titleLabel optimumSize].width + 60;
    float backHeight = kRTCCellHeight;
    [self setBackViewWithWidth:backWidth WithHeight:backHeight];
    
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received: {
            titleLabel.textColor = [UIColor blackColor];
            _imageView.frame = CGRectMake(self.backView.left + 16, self.backView.top + 5, 24, 24);
//            _imageView.backgroundColor = [UIColor whiteColor];
            titleLabel.frame = CGRectMake(_imageView.right + 5, self.backView.top + (self.backView.height - 20)/2, titleLabel.width, 20);
//            _titleLabel.centerY = self.backView.centerY;
            titleLabel.textColor = [UIColor qim_leftBallocFontColor];
        }
            break;
        case QIMMessageDirection_Sent: {
            titleLabel.textColor = [UIColor whiteColor];
            _imageView.frame = CGRectMake(self.backView.left + 10, self.backView.top + 5, 24, 24);
            titleLabel.frame = CGRectMake(_imageView.right + 5, self.backView.top + (self.backView.height - 20)/2, titleLabel.width, 20);
//            _titleLabel.centerY = self.backView.centerY;
            titleLabel.textColor = [UIColor qim_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
    
}

- (NSString *)getTimestamp:(NSInteger )interval{
    
    NSString *str_minute = @"";
    if (interval/60 < 10) {
        str_minute = [NSString stringWithFormat:@"0%ld",interval/60];
    }
    else{
        str_minute = [NSString stringWithFormat:@"%ld",interval/60];
    }
    
    //format of second
    NSString *str_second = @"";
    if (interval%60 < 10) {
        str_second = [NSString stringWithFormat:@"0%ld",interval%60];
    }
    else
    {
        str_second = [NSString stringWithFormat:@"%ld",interval%60];
    }
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    
    NSLog(@"format_time : %@",format_time);
    
    return format_time;
    
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end

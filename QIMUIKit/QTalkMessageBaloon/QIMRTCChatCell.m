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
    RTLabel         * _titleLabel;
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
    if (_titleLabel) {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
    _titleLabel = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, kRTCCellWidth, 24)];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_titleLabel];
    self.backView.message = self.message;
    _titleLabel.textAlignment = kCTRightTextAlignment;
    if (self.message.messageType == QIMMessageType_WebRTC_Audio) {
        _titleLabel.text = @"发起了语音聊天";
        _imageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"QTalkRTCChatCell_Call"];
    } else if (self.message.messageType == QIMMessageType_WebRTC_Vedio) {
        _titleLabel.text = self.message.message;
        _imageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"QTalkRTCChatCell_Video"];
    } else if (self.message.messageType == QIMMessageTypeWebRtcMsgTypeVideoMeeting) {
        _titleLabel.text = @"发起了视频会议";
        _imageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"QTalkRTCChatCell_Meeting"];
    }
    float backWidth = [_titleLabel optimumSize].width + 50;
    float backHeight = kRTCCellHeight;
    [self setBackViewWithWidth:backWidth WithHeight:backHeight];
    
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received: {
            _titleLabel.textColor = [UIColor blackColor];
            _imageView.frame = CGRectMake(self.backView.left + 16, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, self.backView.top + 7, self.backView.width - 40 - 10, self.backView.height);
//            _titleLabel.centerY = self.backView.centerY;
            _titleLabel.textColor = [UIColor qim_leftBallocFontColor];
        }
            break;
        case QIMMessageDirection_Sent: {
            _titleLabel.textColor = [UIColor whiteColor];
            _imageView.frame = CGRectMake(self.backView.left + 10, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, 5 + 7, self.backView.width - 40 - 10, self.backView.height);
//            _titleLabel.centerY = self.backView.centerY;
            _titleLabel.textColor = [UIColor qim_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
    
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end

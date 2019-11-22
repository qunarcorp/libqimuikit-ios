
#define kSTIMShockMsgCellHeight    40
#define kTextLabelTop       10
#define kTextLableLeft      12
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "STIMMsgBaloonBaseCell.h"
#import "STIMShockMsgCell.h"

@interface STIMShockMsgCell()
{
    UILabel         * _titleLabel;
    UIImageView     * _flagView;
}
@end

@implementation STIMShockMsgCell


+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType {
    return kSTIMShockMsgCellHeight + 20 + (chatType == ChatType_GroupChat ? 20 : 0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
        
        _flagView = [[UIImageView alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"chat_receive_shake"]];
        [self.contentView addSubview:_flagView];
    }
    return self;
}

- (void)refreshUI
{
    _titleLabel.text = @"窗口抖动";
    
    float backWidth = 120;
    float backHeight = 40;
    self.backView.message = self.message;
    [self setBackViewWithWidth:backWidth WithHeight:backHeight];
    switch (self.message.messageDirection) {
        case STIMMessageDirection_Received:
        {   
            _flagView.frame = CGRectMake(self.backView.left + 20, self.backView.top + (self.backView.height - 24) / 2, 24, 24);
            _titleLabel.frame = CGRectMake(_flagView.right + 5, self.backView.top + (self.backView.height - 40) / 2, self.backView.width - _flagView.width - 20, 40);
            _titleLabel.textColor = [UIColor stimDB_leftBallocFontColor];
        }
            break;
        case STIMMessageDirection_Sent:
        {
            _flagView.frame = CGRectMake(self.backView.left + 10, self.backView.top + (self.backView.height - 24) / 2, 24, 24);
            _titleLabel.frame = CGRectMake(_flagView.right + 5, self.backView.top + (self.backView.height - 40) / 2, self.backView.width - _flagView.width - 20, 40);
            _titleLabel.textColor = [UIColor stimDB_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
    [super refreshUI];
}

@end

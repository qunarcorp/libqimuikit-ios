//
//  STIMEncryptChatCell.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/9/7.
//
//
#define kEncryptChatCellWidth 135
#define kEncryptChatCellHeight 40
#define kTextLabelTop       10
#define kTextLableLeft      12
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "STIMMsgBaloonBaseCell.h"
//#import "UIImageView+STIMWebCache.h"
#import "STIMEncryptChatCell.h"
#if __has_include("STIMNoteManager.h")
    #import "STIMEncryptChat.h"
#endif

@interface STIMEncryptChatCell () <STIMMenuImageViewDelegate>
{
    UIImageView     * _imageView;
    UILabel         * _titleLabel;
}

@end

@implementation STIMEncryptChatCell


+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType
{
    return kEncryptChatCellHeight + ((message.messageDirection == STIMMessageDirection_Received) ? 40 : 20);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"explore_tab_password"]];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)refreshUI {
    self.backView.message = self.message;
    
    float backWidth = kEncryptChatCellWidth;
    float backHeight = kEncryptChatCellHeight;
    [self setBackViewWithWidth:backWidth WithHeight:backHeight];
    [super refreshUI];
    switch (self.message.messageDirection) {
        case STIMMessageDirection_Received:
        {
            _titleLabel.textColor = [UIColor blackColor];
            _imageView.frame = CGRectMake(self.backView.left + 16, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, self.backView.top, self.backView.width - 10, self.backView.height);
            _titleLabel.textColor = [UIColor stimDB_leftBallocFontColor];
        }
            break;
        case STIMMessageDirection_Sent:
        {
            _titleLabel.textColor = [UIColor whiteColor];
            _imageView.frame = CGRectMake(self.backView.left + 10, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, self.backView.top, self.backView.width - 10, self.backView.height);
            _titleLabel.textColor = [UIColor stimDB_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
#if __has_include("STIMNoteManager.h")

    STIMEncryptChatState state = [[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.message.from];
    STIMEncryptChatState state2 = [[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.message.to];
    if (state == STIMEncryptChatStateDecrypted || state == STIMEncryptChatStateEncrypting || state2 == STIMEncryptChatStateDecrypted || state2 == STIMEncryptChatStateEncrypting) {
        if (self.message.extendInformation.length > 0) {
            _titleLabel.text = self.message.extendInformation;
        } else {
            _titleLabel.text = @"[加密消息]";
        }
    } else {
        _titleLabel.text = @"[加密消息]";
    }
#else
    _titleLabel.text = @"[加密消息]";
#endif
    _imageView.image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"explore_tab_password"];
    _imageView.centerY = self.backView.centerY;
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end

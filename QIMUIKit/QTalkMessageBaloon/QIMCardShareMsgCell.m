//
//  QIMCardShareMsgCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#define kCardCellWidth      215
#define kCardCellHeight     100
#define kTitleHeight        20
#define kCapToSide          10
#define kIconWidth          60
#define kNameHeight         20
#define kDescHeight         35

#import "QIMMsgBaloonBaseCell.h"
#import "QIMJSONSerializer.h"
#import "QIMCardShareMsgCell.h"

@interface QIMCardShareMsgCell()<QIMMenuImageViewDelegate>
{
    UIImageView     * _imageView;
    UILabel         * _titleLabel;
    UIView          * _sepLine;
    UILabel         * _userNameLabel;
    UILabel         * _userDescLabel;
}
@end

@implementation QIMCardShareMsgCell

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message chatType:(ChatType)chatType
{
    return kCardCellHeight + ((chatType == ChatType_GroupChat) && (message.messageDirection == QIMMessageDirection_Received) ? 40 : 20);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = [UIColor qtalkTextLightColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = @"推荐联系人";
        [self.contentView addSubview:_titleLabel];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLine.backgroundColor = [UIColor qtalkSplitLineColor];
        [self.contentView addSubview:_sepLine];
        
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNameLabel.numberOfLines = 1;
        _userNameLabel.font = [UIFont systemFontOfSize:15];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_userNameLabel];
        
        _userDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userDescLabel.numberOfLines = 0;
        _userDescLabel.font = [UIFont systemFontOfSize:12];
        _userDescLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_userDescLabel];
    
        _imageView = [[UIImageView alloc] initWithImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"lbsshare_icon"]];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)tapGesHandle:(UITapGestureRecognizer *)tap{
    if (self.message.messageSendState == QIMMessageSendState_Faild) {
        if (self.message.extendInformation.length > 0) {
            self.message.message = self.message.extendInformation;
        }
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
        NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:self.message.from];
        self.message.extendInformation = self.message.message;
        self.message.message = [NSString stringWithFormat:@"分享名片：\n昵称：%@\n部门：%@",[userInfoDic objectForKey:@"Name"],[userInfoDic objectForKey:@"DescInfo"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamReSendMessage object:self.message];
    }
}

- (void)refreshUI {
    
    self.backView.message = self.message;
    if (self.message.extendInformation.length > 0) {
        self.message.message = self.message.extendInformation;
    }
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    NSString *userId = [infoDic objectForKey:@"userId"];
    NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    
    _userNameLabel.text = [userInfoDic objectForKey:@"Name"];
    _userDescLabel.text = [userInfoDic objectForKey:@"DescInfo"];
    
    _imageView.layer.masksToBounds = YES;
    _imageView.layer.cornerRadius = kIconWidth / 2.0;
    [_imageView qim_setImageWithJid:[userInfoDic objectForKey:@"xmppId"]];
    float backWidth = kCardCellWidth;
    float backHeight = kCardCellHeight;
    
    [self setBackViewWithWidth:backWidth WithHeight:backHeight];
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received:
        {
            
            _titleLabel.textColor = [UIColor qtalkTextLightColor];
            _sepLine.backgroundColor = [UIColor qtalkSplitLineColor];
            _userNameLabel.textColor = [UIColor blackColor];
            _userDescLabel.textColor = [UIColor blackColor];
            
            _titleLabel.frame = CGRectMake(kBackViewCap + self.backView.left + kCapToSide, self.backView.top + 5, self.backView.width - 20, kTitleHeight);
            _sepLine.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom, _titleLabel.width, 0.5);
            _imageView.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, kIconWidth, kIconWidth);
            _userNameLabel.frame = CGRectMake(_imageView.right + 10, _imageView.top, self.backView.width - kCapToSide - _imageView.right, kNameHeight);
            _userDescLabel.frame = CGRectMake(_userNameLabel.left, _userNameLabel.bottom + 5, _userNameLabel.width, kDescHeight);
            _titleLabel.textColor = [UIColor qim_leftBallocFontColor];
            _sepLine.backgroundColor = [UIColor qim_leftBallocFontColor];
            _userNameLabel.textColor = [UIColor qim_leftBallocFontColor];
            _userDescLabel.textColor = [UIColor qim_leftBallocFontColor];
        }
            break;
        case QIMMessageDirection_Sent:
        {
            _titleLabel.textColor = [UIColor whiteColor];
            _sepLine.backgroundColor = [UIColor whiteColor];
            _userNameLabel.textColor = [UIColor whiteColor];
            _userDescLabel.textColor = [UIColor whiteColor];
            
            _titleLabel.frame = CGRectMake(self.backView.left + kCapToSide, self.backView.top + 5, self.backView.width - 20, kTitleHeight);
            _sepLine.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom, _titleLabel.width, 0.5);
            _imageView.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, kIconWidth, kIconWidth);
            _userNameLabel.frame = CGRectMake(self.backView.left + kCapToSide + kIconWidth + 10, _imageView.top, self.backView.width - kCapToSide * 2 - 20 - kIconWidth, kNameHeight);
            _userDescLabel.frame = CGRectMake(_userNameLabel.left, _userNameLabel.bottom + 5, _userNameLabel.width, kDescHeight);
            _titleLabel.textColor = [UIColor qim_rightBallocFontColor];
            _sepLine.backgroundColor = [UIColor qim_rightBallocFontColor];
            _userNameLabel.textColor = [UIColor qim_rightBallocFontColor];
            _userDescLabel.textColor = [UIColor qim_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
    [super refreshUI];
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_Delete)]];
        }
            break;
        case QIMMessageDirection_Sent: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete)]];
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

@end

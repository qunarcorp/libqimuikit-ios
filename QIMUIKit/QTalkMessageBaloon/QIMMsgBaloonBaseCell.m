//
//  QIMMsgBaloonBaseCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMTextStorage.h"
#import "QIMImageStorage.h"
#import "QIMTextContainer.h"
#import "QIMMessageParser.h"
#import "QIMCollectionFaceManager.h"

static UIImage *__leftBallocImage = nil;
static UIImage *__rightBallocImage = nil;

@interface QIMMsgBaloonBaseCell() <QIMMenuImageViewDelegate>

@property (nonatomic, strong) QIMTextContainer *textContainer;

@end

@implementation QIMMsgBaloonBaseCell

+ (UIImage *)leftBallocImage {
    //return nil时，自动用贝塞尔曲线画气泡
    return nil;
    if (__leftBallocImage == nil) {
        NSData *data = UIImagePNGRepresentation([UIImage qim_imageNamedFromQIMUIKitBundle:@"leftBalloon"]);
        UIImage *image = [[UIImage alloc] initWithData:data scale:[[UIScreen mainScreen] scale]];
        CGFloat width = image.size.width / 2.0;
        CGFloat height = image.size.height / 2.0;
        __leftBallocImage = [image stretchableImageWithLeftCapWidth:width topCapHeight: height];
    }
    return __leftBallocImage;
}

+ (UIImage *)rightBallcoImage{
    return nil;
    if (__rightBallocImage == nil) {
        NSData *data = UIImagePNGRepresentation([UIImage qim_imageNamedFromQIMUIKitBundle:@"rightBalloon"]);
        UIImage *image = [[UIImage alloc] initWithData:data scale:[[UIScreen mainScreen] scale]];
        CGFloat width = image.size.width / 2.0;
        CGFloat height = image.size.height / 2.0;
        __rightBallocImage = [image stretchableImageWithLeftCapWidth:width topCapHeight: height];
    }
    return __rightBallocImage;
}

#pragma mark - setter and getter

- (void)setMessage:(QIMMessageModel *)message {
   QIMMessageModel *tempMsg = _message;
    _message = message;
    [self updateNameLabel];
    [self refreshHeaderView];
    [self updateMedalListView];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        UIView* view = [[UIView alloc]initWithFrame:self.contentView.frame];
        view.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView = view;
        [self setBackgroundColor:[UIColor clearColor]];
        [self initBackViewAndHeaderName];
        [self setupGestureRecognizer];
        //消息发送成功
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgDidSendNotificationHandle:) name:kXmppStreamDidSendMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeaderView) name:kUserHeaderImgUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageStateByNotification:) name:kNotificationMessageStateUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserCard:) name:kUserVCardUpdate object:nil];
        */
        
        //刷新用户头像
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeaderView) name:kUserHeaderImgUpdate object:nil];
        //消息发送状态变更
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageSendStateByNotification:) name:kNotificationMessageSendStateUpdate object:nil];
        //消息阅读状态变更
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageReadStateByNotification:) name:kNotificationMessageReadStateUpdate object:nil];
        //用户名片更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserCard:) name:kUserVCardUpdate object:nil];
    }
    return self;
}

- (void)updateMessageReadStateByNotification:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notifyDic = notify.object;
        NSArray *msgIds = [notifyDic objectForKey:@"MsgIds"];
        for (NSDictionary *msgDict in msgIds) {
            NSString *msgId = [msgDict objectForKey:@"id"];
            QIMMessageRemoteReadState state = (QIMMessageRemoteReadState)[[notifyDic objectForKey:@"State"] unsignedIntegerValue];
            if ([msgId isEqualToString:self.message.messageId]) {
                self.message.messageReadState = state;
                [self updateMessageReadState];
            }
        }
    });
}

- (void)updateMessageSendStateByNotification:(NSNotification *)notify {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notifyDic = notify.object;
        QIMMessageSendState sendState = [[notifyDic objectForKey:@"MsgSendState"] unsignedIntegerValue];
        NSString *msgId = [notifyDic objectForKey:@"messageId"];
        if ([msgId isEqualToString:self.message.messageId]) {
            self.message.messageSendState = sendState;
            [self updateMessageSendState];
            [self updateMessageReadState];
        }
    });
}

- (void)refreshUserCard:(NSNotification *)notify {
    
    NSArray *updateUserIds = notify.object;
    if ([updateUserIds containsObject:self.message.from]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateNameLabel];
            [self refreshHeaderView];
            [self updateMedalListView];
        });
    }
}

- (void)initBackViewAndHeaderName{
    
    self.backView = [[QIMMenuImageView alloc] initWithFrame:CGRectZero];
    [self.backView setDelegate:self];
    [self.backView setUserInteractionEnabled:YES];
    [self.backView setAccessibilityIdentifier:@"MessageBackView"];
    
    [self.contentView addSubview:self.backView];
    
    [self.contentView addSubview:self.HeadView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.medalListView];
    [self.medalListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).mas_offset(MEDAL_SUPER_LEFT);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(MEDAL_SUPER_WIDTH);
        make.height.mas_equalTo(MEDAL_SUPER_HEIGHT);
    }];
}

- (UIImageView *)HeadView {
    if (!_HeadView) {
        _HeadView = [[UIImageView alloc] initWithFrame:CGRectMake(AVATAR_SUPER_LEFT, 0, AVATAR_WIDTH, AVATAR_HEIGHT)];
        _HeadView.layer.cornerRadius = AVATAR_WIDTH / 2.0f;
        _HeadView.layer.masksToBounds = YES;
        _HeadView.contentMode = UIViewContentModeScaleAspectFit;
        _HeadView.userInteractionEnabled = YES;
        _HeadView.backgroundColor = [UIColor qim_colorWithHex:0x9e9e9e alpha:1.0];
        _HeadView.image = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
    }
    return _HeadView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.HeadView.right + NAME_SUPER_LEFT, 0, NAME_SUPER_WIDTH, NAME_SUPER_HEIGHT)];
        _nameLabel.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0];
    }
    return _nameLabel;
}

- (UIView *)medalListView {
    if (!_medalListView) {
        _medalListView = [[UIView alloc] init];
    }
    return _medalListView;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"MessageSendFail"] forState:UIControlStateNormal];
        _statusButton.contentMode = UIViewContentModeScaleAspectFit;
        _statusButton.frame = CGRectMake(self.backView.left - 30, 0, 24, 24);
        _statusButton.hidden = YES;
        [_statusButton addTarget:self action:@selector(resendMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusButton;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.hidden = NO;
    }
    return _indicatorView;
}

- (UILabel *)messgaeStateLabel {
    if (!_messgaeStateLabel) {
        _messgaeStateLabel = [[UILabel alloc] init];
        _messgaeStateLabel.adjustsFontSizeToFitWidth = YES;
        _messgaeStateLabel.textAlignment = NSTextAlignmentRight;
        _messgaeStateLabel.font = [UIFont systemFontOfSize:10];
        _messgaeStateLabel.text = @"未读";
        _messgaeStateLabel.hidden = YES;
        _messgaeStateLabel.frame = CGRectMake(self.backView.left - 40, self.backView.bottom - 12, 35, 12);
        _messgaeStateLabel.textColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
    }
    return _messgaeStateLabel;
}

- (UIImageView *)messgaeStateIcon {
    if (!_messgaeStateIcon) {
        _messgaeStateIcon = [[UIImageView alloc] init];
        _messgaeStateIcon.hidden = YES;
        _messgaeStateIcon.frame = CGRectMake(self.backView.left - 22, self.backView.bottom - 22, 20, 20);
    }
    return _messgaeStateIcon;
}

- (UILabel *)messgaeRealStateLabel {
    if (!_messgaeRealStateLabel) {
        _messgaeRealStateLabel = [[UILabel alloc] init];
        _messgaeRealStateLabel.adjustsFontSizeToFitWidth = YES;
        _messgaeRealStateLabel.textAlignment = NSTextAlignmentRight;
        _messgaeRealStateLabel.frame = CGRectMake(self.backView.left - 80, self.backView.top, 70, 24);
        _messgaeRealStateLabel.numberOfLines = 0;
        _messgaeRealStateLabel.font = [UIFont systemFontOfSize:10];
        _messgaeRealStateLabel.textColor = [UIColor redColor];
    }
    return _messgaeRealStateLabel;
}

- (void)setupGestureRecognizer {
    
    UITapGestureRecognizer *tapHead = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHeaderViewClick:)];
    tapHead.numberOfTapsRequired = 1;
    tapHead.numberOfTouchesRequired = 1;
    [self.HeadView addGestureRecognizer:tapHead];
    
    UITapGestureRecognizer *medalTapHead = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMedalViewClick:)];
    medalTapHead.numberOfTapsRequired = 1;
    medalTapHead.numberOfTouchesRequired = 1;
    [self.medalListView addGestureRecognizer:medalTapHead];
    
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(atSomeOne:)];
    longGes.minimumPressDuration = 0.6;
    longGes.allowableMovement = 1000;
    [self.HeadView addGestureRecognizer:longGes];
}

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)message  chatType:(ChatType)chatType{
    @throw  [NSException exceptionWithName:@"QIMMsgBaloonBaseCell Exception" reason:[NSString stringWithFormat:@"Class %@ \"getCellHeightWithMessage\" method has not realized ",[self class]] userInfo:nil];
}

- (void)refreshUI {
    self.backView.menuActionTypeList = [self showMenuActionTypeList];
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received: {
            self.HeadView.frame = CGRectMake(AVATAR_SUPER_LEFT, AVATAR_SUPER_TOP, AVATAR_WIDTH, AVATAR_HEIGHT);
            
            self.nameLabel.font = [UIFont systemFontOfSize:13];
            if (self.chatType == ChatType_System) {
                self.HeadView.hidden = YES;
                self.nameLabel.hidden = YES;
                self.medalListView.hidden = YES;
            } else if (self.chatType == ChatType_SingleChat) {
                self.nameLabel.hidden = YES;
                self.medalListView.hidden = YES;
            } else if (self.chatType == ChatType_Consult) {
                self.nameLabel.hidden = YES;
                self.medalListView.hidden = YES;
            } else if (self.chatType == ChatType_ConsultServer) {
                self.nameLabel.hidden = YES;
                self.medalListView.hidden = YES;
            }  else {
            }
        }
            break;
        case QIMMessageDirection_Sent: {
            CGFloat selectOffset = self.editing ? (CELL_EDIT_OFFSET + AVATAR_SUPER_LEFT) : AVATAR_SUPER_LEFT;
            CGRect headViewFrame = {{self.frameWidth - AVATAR_WIDTH - selectOffset, AVATAR_SUPER_TOP},{AVATAR_WIDTH,AVATAR_HEIGHT}};
            self.HeadView.frame = headViewFrame;
            self.medalListView.hidden = YES;
        }
            break;
        default:
            break;
    }
    [self updateMessageSendState];
    [self updateMessageReadState];
    float moveSpace = 38;
    CGRect rect = self.backView.frame;
    if (self.editing) {
        if (self.message.messageDirection == QIMMessageDirection_Sent) {
            rect.origin.x = rect.origin.x - moveSpace;
            _backView.frame = rect;
        }
    }
    [self.backView setAccessibilityIdentifier:self.message.messageId];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (self.editing == editing) {
        return;
    }
    [super setEditing:editing animated:animated];
    
    float moveSpace = 38;
    CGRect rect = self.backView.frame;
    CGRect headerRect = self.HeadView.frame;
    if (self.editing) {
        self.HeadView.userInteractionEnabled = NO;
        if (self.message.messageDirection == QIMMessageDirection_Sent) {
            headerRect.origin.x = headerRect.origin.x - moveSpace;
            rect.origin.x = rect.origin.x - moveSpace;
            self.HeadView.frame = headerRect;
            if (self.message.messageType == QIMMessageType_SmallVideo) {
                [self.backView setFrame:rect withNeedAddBubble:NO];
            } else {
                self.backView.frame = rect;
            }
            self.messgaeStateIcon.hidden = NO;
        }
    } else {
        self.HeadView.userInteractionEnabled = YES;
        if (self.message.messageDirection == QIMMessageDirection_Sent) {
            headerRect.origin.x = headerRect.origin.x + moveSpace;
            rect.origin.x = rect.origin.x + moveSpace;
            self.HeadView.frame = headerRect;
            if (self.message.messageType == QIMMessageType_SmallVideo) {
                [self.backView setFrame:rect withNeedAddBubble:NO];
            } else {
                self.backView.frame = rect;
            }
            self.messgaeStateIcon.hidden = NO;
        }
    }
}

- (void)updateNameLabel {
    if (self.message.messageDirection == QIMMessageDirection_Received) {
        __block NSString *nickName = self.message.from;
        dispatch_async([[QIMKit sharedInstance] getLoadMsgNickNameQueue], ^{
            if (self.chatType != ChatType_CollectionChat) {
                //备注
                NSString * remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.message.from];
                if (remarkName.length > 0) {
                    nickName = remarkName;
                }
            } else {
                NSDictionary *userInfo = [[QIMKit sharedInstance] getCollectionUserInfoByUserId:nickName];
                NSString *userName = [[[userInfo objectForKey:@"Name"] componentsSeparatedByString:@"@"] firstObject];
                if (userName.length > 0) {
                    nickName = userName;
                } else {
                    
                }
            }
            nickName = [[nickName componentsSeparatedByString:@"@"] firstObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIFont *userNameFont = [UIFont systemFontOfSize:13];
                // 根据字体得到NSString的尺寸
                CGSize userNameSize = [nickName sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:userNameFont,NSFontAttributeName,nil]];
                self.nameLabel.text = nickName;
                self.nameLabel.width = userNameSize.width + 5;
                self.nameLabel.textColor = [UIColor qim_colorWithHex:0x888888];
            });
        });
    }
}

- (void)updateMedalListView {
    if (self.message.messageDirection == QIMMessageDirection_Received) {
        dispatch_async([[QIMKit sharedInstance] getLoadMsgMedalListQueue], ^{
           
            NSArray *medals = [[QIMKit sharedInstance] getUserWearMedalSmallIconListByUserid:self.message.from];
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat marginLeft = 0;
                for (NSInteger i = 0; i < medals.count; i++) {
                    UIImageView *medalIconView = [[UIImageView alloc] initWithFrame:CGRectMake(marginLeft, 0, 18, 18)];
                    [medalIconView qim_setImageWithURL:[NSURL URLWithString:medals[i]] placeholderImage:[UIImage new]];
                    marginLeft += (18+5);
                    [self.medalListView addSubview:medalIconView];
                }
                if (![self.contentView.subviews containsObject:self.medalListView]) {
                    [self.contentView addSubview:self.medalListView];
                }
                [self.medalListView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.nameLabel.mas_right).mas_offset(MEDAL_SUPER_LEFT);
                    make.top.mas_equalTo(0);
                    make.height.mas_equalTo(MEDAL_SUPER_HEIGHT);
                    make.width.mas_equalTo(marginLeft);
                }];
            });
        });
    }
}

//更新消息阅读状态
- (void)updateMessageReadState {
    if (self.message.messageDirection == QIMMessageDirection_Sent && self.message.messageSendState == QIMMessageSendState_Success) {
        if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
            self.messgaeRealStateLabel.frame = CGRectMake(self.backView.left - 80, self.backView.top, 70, 24);
            [self.contentView addSubview:self.messgaeRealStateLabel];
        }
        BOOL readFlag = (self.message.messageReadState & QIMMessageRemoteReadStateDidReaded) == QIMMessageRemoteReadStateDidReaded;
        if (readFlag) {
            [self.indicatorView stopAnimating];
            self.indicatorView.hidden = YES;
//            self.messgaeStateLabel.hidden = NO;
//            self.messgaeStateLabel.text = @"已读";
//            self.messgaeStateLabel.textColor = [UIColor lightGrayColor];
            
            
            self.messgaeStateIcon.hidden = NO;
            self.messgaeStateIcon.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_messageReadState_font size:20 color:qim_messageReadState_color]];
            
            self.statusButton.hidden = YES;
        } else {
            
            BOOL sentFlag = (self.message.messageReadState & QIMMessageRemoteReadStateDidSent) == QIMMessageRemoteReadStateDidSent;
            if (sentFlag) {
                [self.indicatorView stopAnimating];
                self.indicatorView.hidden = YES;
//                self.messgaeStateLabel.hidden = NO;
                self.messgaeStateIcon.hidden = NO;
                self.messgaeStateIcon.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_messageUnReadState_font size:20 color:qim_messageUnReadState_color]];
                self.statusButton.hidden = YES;
//                [_sessionButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f3" size:32 color:[UIColor qim_colorWithHex:0x616161 alpha:1.0]]] forState:UIControlStateNormal];

//                self.messgaeStateLabel.text = @"未读";
//                self.messgaeStateLabel.textColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
            } else {
                [self.indicatorView stopAnimating];
                self.indicatorView.hidden = YES;
//                self.messgaeStateLabel.hidden = NO;
                self.statusButton.hidden = YES;
//                self.messgaeStateLabel.text = @"未读";
//                self.messgaeStateLabel.textColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
                self.messgaeStateIcon.hidden = NO;
                self.messgaeStateIcon.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_messageUnReadState_font size:20 color:qim_messageUnReadState_color]];
            }
        }
    }
}

//更新消息发送状态
- (void)updateMessageSendState {
    if (self.chatType == ChatType_PublicNumber) {
        return;
    }
    if (self.message.messageDirection == QIMMessageDirection_Sent) {
        //这里只有单聊，Consult（单人会话）显示消息状态
        if (![[QIMKit sharedInstance] isMiddleVirtualAccountWithJid:self.message.to] && self.message.chatType != ChatType_GroupChat && self.message.chatType != ChatType_System && self.chatType != ChatType_GroupChat && self.chatType != ChatType_System && self.chatType != ChatType_CollectionChat) {
            if ([[QIMKit sharedInstance] qimNav_Showmsgstat]) {
//                [self.contentView addSubview:self.messgaeStateLabel];
                [self.contentView addSubview:self.messgaeStateIcon];
            }
        }
        if (self.message.messageSendState == QIMMessageSendState_Waiting || self.message.messageSendState == QIMMessageSendState_Faild) {
            self.message.messageSendState = [[QIMKit sharedInstance] getMessageStateWithMsgId:self.message.messageId];
        }
        if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
            self.messgaeRealStateLabel.frame = CGRectMake(self.backView.left - 80, self.backView.top, 70, 24);
            [self.contentView addSubview:self.messgaeRealStateLabel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (self.message.messageSendState) {
                case QIMMessageSendState_Waiting: {
                    self.indicatorView.center = CGPointMake(self.backView.left - 24, self.backView.centerY);
                    [self.contentView addSubview:self.indicatorView];
                    [self.indicatorView startAnimating];
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@" %@-%@", [NSBundle qim_localizedStringForKey:@"Sending"], self.message.messageId];
                }
                    break;
                case QIMMessageSendState_Faild: {
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@"%@-%@", @"消息发送失败", self.message.messageId];
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                    self.statusButton.center = CGPointMake(self.backView.left - 24, self.backView.centerY);
                    self.statusButton.hidden = NO;
                    [self.contentView addSubview:self.statusButton];
                }
                    break;
                case QIMMessageSendState_Success: {
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@"%@-%@", @"发送成功", self.message.messageId];
                    self.statusButton.hidden = YES;
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                }
                    break;
                default: {
                    self.statusButton.hidden = YES;
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                }
                    break;
            }
        });
    } else {

    }
}

- (void)setBackViewWithWidth:(CGFloat)backWidth WithHeight:(CGFloat)backHeight{
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received: {
            CGRect frame = {{kBackViewCap + AVATAR_WIDTH,kCellHeightCap / 2.0 + _nameLabel.bottom},{backWidth,backHeight}};
            if (self.chatType != ChatType_PublicNumber && self.chatType != ChatType_System && self.chatType != ChatType_SingleChat && self.chatType != ChatType_Consult) {
                frame = CGRectMake(kBackViewCap + AVATAR_WIDTH, kCellHeightCap / 2.0 + _nameLabel.bottom, backWidth, backHeight);
            } else if (self.chatType == ChatType_SingleChat || self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                frame = CGRectMake(kBackViewCap + AVATAR_WIDTH, kCellHeightCap / 2.0, backWidth, backHeight);
            } else {
                frame = CGRectMake(kBackViewCap, kCellHeightCap / 2.0, backWidth, backHeight);
            }
            [self.backView setFrame:frame];
            [self.backView setImage:[QIMMsgBaloonBaseCell leftBallocImage]];
        }
            break;
        case QIMMessageDirection_Sent: {
            CGRect frame = {{self.frameWidth - kBackViewCap - backWidth - AVATAR_WIDTH, kCellHeightCap / 2.0 + kBackViewCap},{backWidth,backHeight}};
           if (self.chatType == ChatType_SingleChat) {
               frame = CGRectMake(self.frameWidth - kBackViewCap - backWidth - AVATAR_WIDTH, kCellHeightCap / 2.0, backWidth, backHeight);
            } else {
            }
            [self.backView setFrame:frame];
            [self.backView setImage:[QIMMsgBaloonBaseCell rightBallcoImage]];
            _messgaeStateLabel.frame = CGRectMake(self.backView.left - 40, self.backView.bottom - 12, 35, 12);
            _statusButton.frame = CGRectMake(self.backView.left - 30, 0, 24, 24);
            _statusButton.center = CGPointMake(self.backView.left - 24, self.backView.centerY);
        }
            break;
        default:
            break;
    }
}

- (CGRect)getCellBackViewFrame{
    CGRect backFrame = [self convertRect:_backView.frame fromView:self.contentView];
    return CGRectMake(self.left + backFrame.origin.x, self.top + backFrame.origin.y, backFrame.size.width, backFrame.size.height);
}

#pragma mark - action

- (void)onHeaderViewClick:(UITapGestureRecognizer *)tapGesture {
    if (self.message.from.length > 0 && self.chatType != ChatType_CollectionChat && self.chatType != ChatType_Consult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:self.message.from];
        });
    } else if (self.message.xmppId.length > 0 && self.chatType == ChatType_Consult && self.message.messageDirection == QIMMessageDirection_Received) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:self.message.xmppId];
        });
    } else {
        
    }
}

- (void)onMedalViewClick:(UITapGestureRecognizer *)tap {
    if (self.message.from.length > 0 && self.chatType != ChatType_CollectionChat && self.chatType != ChatType_Consult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserMedalFlutterWithUserId:self.message.from];
        });
    } else if (self.message.xmppId.length > 0 && self.chatType == ChatType_Consult && self.message.messageDirection == QIMMessageDirection_Received) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserMedalFlutterWithUserId:self.message.xmppId];
        });
    } else {
        
    }
}

- (void)resendMessage:(id)sender {
    if (self.message.messageSendState == QIMMessageSendState_Faild) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamReSendMessage object:self.message];
    }
}

- (void)atSomeOne:(UILongPressGestureRecognizer *)logGes {
    if (logGes.state == UIGestureRecognizerStateBegan && self.chatType == ChatType_GroupChat) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ATSomeOneNotifacation object:self.message.from];
    }
}

- (void)onMenuActionWithType:(MenuActionType)actionType {
    switch (actionType) {
        case MA_Copy: {
            NSMutableString *str = [[NSMutableString alloc] initWithCapacity:3];
            for (QIMTextStorage *textStorage in self.textContainer.textStorages) {
                if (![textStorage isKindOfClass:[QIMTextStorage class]]) {
                    continue;
                } else {
                    [str appendString:textStorage.text];
                }
            }
            [_backView setClipboardWitxthText:str];
        }
            break;
        case MA_Collection: {
            self.textContainer = [QIMMessageParser textContainerForMessage:self.message fromCache:NO];
            for (QIMImageStorage * imageStorage in self.textContainer.textStorages) {
                
                if (![imageStorage isKindOfClass:[QIMImageStorage class]]) {
                    
                    return;
                } else {
                    NSString *imageUrl = imageStorage.imageURL.absoluteString;
                    QIMVerboseLog(@"收藏表情后的地址为 : %@", imageUrl);
                    if (![imageUrl containsString:@"null"] && imageUrl.length > 0) {
                        if (![imageUrl qim_hasPrefixHttpHeader]) {
                            imageUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], imageUrl];
                        }
                        [[QIMCollectionFaceManager sharedInstance] insertCollectionEmojiWithEmojiUrl:imageUrl];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleFailedNotification object:nil];
                        });
                    }
                }
            }
        }
        default:
            [self.delegate processEvent:actionType withMessage:self.message];
            break;
    }
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case QIMMessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Refer),@(MA_Repeater), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case QIMMessageDirection_Sent: {
                [menuList addObjectsFromArray:@[@(MA_Refer), @(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
            }
            break;
        default:
            break;
    }
    if (self.chatType == ChatType_System) {
        [menuList removeObject:@(MA_Refer)];
        [menuList removeObject:@(MA_Delete)];
        [menuList removeObject:@(MA_Forward)];
    } else if (self.chatType == ChatType_CollectionChat) {
        menuList = [NSMutableArray array];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.chatType == ChatType_CollectionChat) {
        self.backView.menuActionTypeList = @[];
    }
}

- (void)refreshHeaderView {
    if (self.message.messageType == QIMMessageType_GroupNotify || self.message.messageType == QIMMessageType_Time || self.message.messageType == QIMMessageType_Revoke || self.message.messageType == QIMMessageTypeRobotQuestionList) {
        self.HeadView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.medalListView.hidden = YES;
        return;
    }
    dispatch_async([[QIMKit sharedInstance] getLoad_msgHeaderImageQueue], ^{
        if (self.chatType != ChatType_GroupChat) {
            switch (self.message.messageDirection) {
                    case QIMMessageDirection_Sent: {
                        self.message.from = [[QIMKit sharedInstance] getLastJid];
                    }
                    break;
                    case QIMMessageDirection_Received: {
                        self.message.from = self.message.from;
                    }
                default:
                    break;
            }
        }
        if (self.chatType == ChatType_CollectionChat) {
            NSString *collectionUserUrl = [[QIMKit sharedInstance] getCollectionUserHeaderUrlWithXmppId:self.message.from];
            if (![collectionUserUrl qim_hasPrefixHttpHeader]) {
                collectionUserUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], collectionUserUrl];
            }
            [self.HeadView qim_setImageWithURL:collectionUserUrl placeholderImage:[UIImage imageWithData:[QIMKit defaultUserHeaderImage]]];
        } else if (self.chatType == ChatType_Consult) {
            if (self.message.messageDirection == QIMMessageDirection_Sent) {
                [self.HeadView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid] WithChatType:ChatType_SingleChat];
            } else {
                [self.HeadView qim_setImageWithJid:self.message.xmppId];
            }
        } else {
            if (self.message.messageDirection == QIMMessageDirection_Sent) {
                [self.HeadView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid] WithChatType:ChatType_SingleChat];
            } else {
                [self.HeadView qim_setImageWithJid:self.message.from];
            }
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

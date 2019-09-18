//
//  QTalkNewSessionTableViewCell.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/6/10.
//

#import "QTalkNewSessionTableViewCell.h"
#import "UILabel+AttributedTextWithItems.h"
#import "QIMBadgeButton.h"
#import "QIMJSONSerializer.h"
#import "QIMCommonFont.h"
#import "NSBundle+QIMLibrary.h"

static NSDateFormatter  *__global_dateformatter;
#define NAME_LABEL_FONT     ([[QIMCommonFont sharedInstance] currentFontSize] )  //名字字体
#define CONTENT_LABEL_FONT  ([[QIMCommonFont sharedInstance] currentFontSize] - 4)  //新消息字体,时间字体
#define COLOR_TIME_LABEL [UIColor blueColor] //时间颜色;

#define kUtilityButtonsWidthMax 260
#define kUtilityButtonWidthDefault 90

static NSString * const kTableViewCellContentView = @"UITableViewCellContentView";

@interface QTalkNewSessionTableViewCell() <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isStick;

@property (nonatomic, assign) BOOL isReminded;              //是否为免打扰

@property (nonatomic, strong) UIImageView *headerView;      //头像

@property (nonatomic, strong) UIImageView *stickView;       //置顶标示View

@property (nonatomic, strong) UILabel *nameLabel;           //Name

@property (nonatomic, strong) UILabel *contentLabel;        //消息Content

@property (nonatomic, strong) UILabel *timeLabel;           //消息时间戳

@property (nonatomic, strong) QIMBadgeButton *notReadNumButton;   //未读数拖拽按钮

@property (nonatomic, strong) UIImageView *muteView;            //消息免打扰

@property (nonatomic, strong) UIImageView *muteNotReadView;     //接收不提醒小红点提醒

@property (nonatomic, strong) UIImageView *prefrenceImageView;  //热线咨询标识

#pragma mark - infoDic

@property (nonatomic, assign) QIMMessageType msgType;

@property (nonatomic, assign) QIMMessageSendState msgState;

@property (nonatomic, assign) QIMMessageDirection msgDirection;

@property (nonatomic, assign) long long msgDateTime;

@property (nonatomic, copy) NSString *showName;             //展示的Name

@property (nonatomic, copy) NSString *jid;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *msgFrom;

@property (nonatomic, copy) NSString *markUpName;

@property (nonatomic, strong)QIMMessageModel *currentMsg;          //当前消息


@end

@implementation QTalkNewSessionTableViewCell

- (void)setInfoDic:(NSDictionary *)infoDic {
    if (infoDic) {
        if (!self.bindId) {
            //这里不能根据MsgId判断，还有消息状态
            _infoDic = infoDic;
            NSString *msgId = [infoDic objectForKey:@"LastMsgId"];
            if ([self.currentMsg.messageId isEqualToString:msgId]) {
                return;
            }
            NSString *xmppId = [infoDic objectForKey:@"XmppId"];
            self.showName = [infoDic objectForKey:@"Name"];
            self.markUpName = [infoDic objectForKey:@"MarkUpName"];
            self.jid = xmppId;
            self.msgType = [[infoDic objectForKey:@"MsgType"] integerValue];
            self.msgState = [[infoDic objectForKey:@"MsgState"] integerValue];
            self.content = [infoDic objectForKey:@"Content"];
            self.chatType = [[infoDic objectForKey:@"ChatType"] integerValue];
            self.msgDateTime = [[infoDic objectForKey:@"MsgDateTime"] longLongValue];
            self.msgDirection = [[infoDic objectForKey:@"MsgDirection"] integerValue];
            self.isStick = [[infoDic objectForKey:@"StickState"] boolValue];
            self.isReminded = [[infoDic objectForKey:@"Reminded"] boolValue];
            self.msgFrom = [infoDic objectForKey:@"MsgFrom"];
            /*
             NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.nickName];
             NSString *userName = [userInfo objectForKey:@"Name"];
             if (!userName || userName.length <= 0) {
             userName = [[self.nickName componentsSeparatedByString:@"@"] firstObject];
             }
             //备注
             NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userInfo[@"XmppId"]];
             self.nickName = (remarkName.length > 0) ? remarkName : userName;
             */
            [self generateCombineJidWithChatType:self.chatType];
        } else {
            _infoDic = infoDic;
            self.jid = [infoDic objectForKey:@"XmppId"];
            ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
            self.msgType = [[infoDic objectForKey:@"MsgType"] intValue];
            self.msgState = [[infoDic objectForKey:@"MsgState"] intValue];
            self.content = [infoDic objectForKey:@"Content"];
            [self generateCombineJidWithChatType:chatType];
        }
    }
}

- (void)generateCombineJidWithChatType:(ChatType)chatType {
    switch (chatType) {
        case ChatType_ConsultServer: {
            NSString *realJid = [self.infoDic objectForKey:@"RealJid"];
            self.combineJid = [NSString stringWithFormat:@"%@<>%@", self.jid, realJid];
        }
            break;
        default: {
            self.combineJid = [NSString stringWithFormat:@"%@<>%@", self.jid, self.jid];
        }
            break;
    }
}

- (void)reloadPlaceHolderName {
    self.showName = [self.infoDic objectForKey:@"UserId"];
    if (!self.showName.length) {
        self.showName = [[self.jid componentsSeparatedByString:@"@"] firstObject];
    }
}

+ (CGFloat)getCellHeight{
    
    return 71;
}

#pragma mark - setter and getter

- (UIImageView *)headerView {
    
    if (!_headerView) {
        
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(12, [self.class getCellHeight] / 2 - 24, 48, 48)];
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.layer.cornerRadius = 24.0f;
        _headerView.layer.masksToBounds = YES;
    }
    return _headerView;
}

- (UIImageView *)stickView {
    if (!_stickView) {
        _stickView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 11, 11)];
        _stickView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"qim_sessionlist_sticky"];
    }
    return _stickView;
}

- (UIImageView *)muteNotReadView {
    if (!_muteNotReadView) {
        
        _muteNotReadView = [[UIImageView alloc] initWithFrame:CGRectMake([[QIMWindowManager shareInstance] getPrimaryWidth] - 20, self.timeLabel.bottom + 15, 8, 8)];
        _muteNotReadView.backgroundColor = [UIColor qim_colorWithHex:0xEB524A];
        _muteNotReadView.layer.cornerRadius  = _muteNotReadView.width / 2.0;
        _muteNotReadView.clipsToBounds = YES;
        _muteNotReadView.centerY = self.muteView.centerY;
    }
    return _muteNotReadView;
}

- (UIImageView *)prefrenceImageView {
    
    if (!_prefrenceImageView) {
        
        _prefrenceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headerView.right - 18, self.headerView.bottom - 15, 15, 15)];
        [_prefrenceImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"hotline"]];
        [_prefrenceImageView setBackgroundColor:[UIColor whiteColor]];
        _prefrenceImageView.layer.masksToBounds = YES;
    }
    return _prefrenceImageView;
}

- (UILabel *)nameLabel {
    
    if (!_nameLabel) {
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 17, [[QIMWindowManager shareInstance] getPrimaryWidth] - 145, qim_sessionViewNameLabelSize)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:qim_sessionViewNameLabelSize];
        _nameLabel.textColor = qim_sessionCellNameTextColor;
        _nameLabel.backgroundColor = [UIColor clearColor];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    
    if (!_contentLabel) {
        
        CGFloat timeLabelMaxX = CGRectGetMaxX(self.timeLabel.frame);
        CGFloat contentLabelWidth = timeLabelMaxX - self.nameLabel.left - 35;
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 7, contentLabelWidth, qim_sessionViewContentLabelSize)];
        _contentLabel.font = [UIFont systemFontOfSize:qim_sessionViewContentLabelSize];
        _contentLabel.textColor = qim_sessionCellContentTextColor;
        _contentLabel.backgroundColor = [UIColor clearColor];
    }
    return _contentLabel;
}

- (UILabel *)timeLabel {
    
    if (!_timeLabel) {
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([[QIMWindowManager shareInstance] getPrimaryWidth] - 85, self.nameLabel.bottom - 16, 75, 12)];
        _timeLabel.font = [UIFont systemFontOfSize:qim_sessionViewTimeLabelSize];
        _timeLabel.textColor = qim_sessionCellTimeTextColor;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _timeLabel;
}

- (UIImageView *)muteView {
    
    if (!_muteView) {
        
        _muteView = [[UIImageView alloc] initWithFrame:CGRectMake([[QIMWindowManager shareInstance] getPrimaryWidth] - 40, self.timeLabel.bottom + 15, 15, 15)];
        _muteView.layer.cornerRadius = _muteView.width / 2.0;
        _muteView.clipsToBounds = YES;
        _muteView.backgroundColor = self.backgroundColor;
        _muteView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_sessionViewMute_font size:15 color:qim_sessionViewMuteColor]];
        _muteView.centerY = self.contentLabel.centerY;
    }
    return _muteView;
}

- (void)setUpNotReadNumButtonWithFrame:(CGRect)frame withBadgeString:(NSString *)badgeString {
    if (!CGRectEqualToRect(frame, self.notReadNumButton.frame) && !CGRectEqualToRect(frame, CGRectZero)) {
        [self.notReadNumButton removeFromSuperview];
        self.notReadNumButton = nil;
        _notReadNumButton = [[QIMBadgeButton alloc] initWithFrame:frame];
        [_notReadNumButton setBadgeFont:[UIFont systemFontOfSize:14]];
        _notReadNumButton.isShowSpringAnimation = YES;
        _notReadNumButton.isShowBomAnimation = YES;
        _notReadNumButton.right = self.timeLabel.right;
        _notReadNumButton.centerY = self.contentLabel.centerY;
        [self.contentView insertSubview:_notReadNumButton atIndex:0];
    } else {
        if (!_notReadNumButton) {
            _notReadNumButton = [[QIMBadgeButton alloc] initWithFrame:CGRectMake(self.timeLabel.right - 35, 11, 35, 20)];
            [_notReadNumButton setBadgeFont:[UIFont systemFontOfSize:14]];
            _notReadNumButton.isShowSpringAnimation = YES;
            _notReadNumButton.isShowBomAnimation = YES;
            _notReadNumButton.right = self.timeLabel.right;
            _notReadNumButton.centerY = self.contentLabel.centerY;
            [self.contentView insertSubview:_notReadNumButton atIndex:0];
        }
    }
    self.chatType = [[self.infoDic objectForKey:@"ChatType"] integerValue];
    [self.notReadNumButton setBadgeColor:qim_sessionViewNotReadNumButtonColor];
    [self.notReadNumButton setBadgeString:badgeString];
    __weak typeof(self) weakSelf = self;
    [self.notReadNumButton setDidClickBlock:^(QIMBadgeButton * badgeButton) {
        [weakSelf clearNotRead];
    }];
    [self.notReadNumButton setDidDisappearBlock:^(QIMBadgeButton * badgeButton) {
        [weakSelf clearNotRead];
    }];
    __block BOOL groupState = NO;
    if (self.isReminded == NO) {
        [self.notReadNumButton setBadgeColor:qim_sessionViewNotReadNumButtonColor];
    } else {
        [self.notReadNumButton hiddenBadgeButton:YES];
        [self.contentView addSubview:self.muteNotReadView];
    }
}

- (UITableViewRowAction *)deleteBtn {
    
    if (!_deleteBtn) {
        
        _deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[NSBundle qim_localizedStringForKey:@"Remove"] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            if (self.sessionScrollDelegate && [self.sessionScrollDelegate respondsToSelector:@selector(qimDeleteSession:)]) {
                
                [self.sessionScrollDelegate qimDeleteSession:indexPath];
            }
            [self.containingTableView setEditing:NO animated:YES];
        }];
    }
    _deleteBtn.backgroundColor = [UIColor redColor];
    return _deleteBtn;
}

- (UITableViewRowAction *)stickyBtn {
    
    NSString *title = self.isStick ? [NSBundle qim_localizedStringForKey:@"chat_remove_sticky"] : [NSBundle qim_localizedStringForKey:@"chat_Sticky_Top"];
    
    _stickyBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (self.sessionScrollDelegate && [self.sessionScrollDelegate respondsToSelector:@selector(qimStickySession:)]) {
            
            [self.sessionScrollDelegate qimStickySession:indexPath];
        }
        [self.containingTableView setEditing:NO animated:YES];
    }];
    _stickyBtn.backgroundColor = [UIColor qim_colorWithHex:0xC8C9CB];
    
    return _stickyBtn;
}

#pragma mark - life ctyle

- (void)initUI {
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE];
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.muteView];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.bindId = nil;
    }
    return self;
}

#pragma mark - Overriden methods

- (void)clearNotRead {
    if (!self.bindId) {
        if (self.chatType == ChatType_GroupChat) {
            
            [[QIMKit sharedInstance] clearNotReadMsgByGroupId:self.jid];
        } else if (self.chatType == ChatType_SingleChat) {
            
            [[QIMKit sharedInstance] clearNotReadMsgByJid:self.jid];
        } else if (self.chatType == ChatType_System) {
            
            [[QIMKit sharedInstance] clearSystemMsgNotReadWithJid:self.jid];
        } else if (self.chatType == ChatType_PublicNumber) {
            [[QIMKit sharedInstance] clearNotReadMsgByPublicNumberId:self.jid];
        } else if (self.chatType == ChatType_ConsultServer) {
            NSString *realJid = [self.infoDic objectForKey:@"RealJid"];
            NSString *xmppId = [self.infoDic objectForKey:@"XmppId"];
            [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:realJid];
        } else if (self.chatType == ChatType_Consult) {
            NSString *xmppId = [self.infoDic objectForKey:@"XmppId"];
            [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:xmppId];
        } else if (self.chatType == ChatType_CollectionChat) {
            NSString *xmppId = [self.infoDic objectForKey:@"XmppId"];
            [[QIMKit sharedInstance] clearNotReadCollectionMsgByJid:xmppId];
        } else {
            
            return;
        }
    } else {
        [[QIMKit sharedInstance] clearNotReadCollectionMsgByBindId:self.bindId WithUserId:self.jid];
    }
}

#pragma mark - RefreshUI

- (NSString *)refreshContentWithMessage:(NSString *)message {
    NSString *content = nil;
    if (!self) {
        QIMVerboseLog(@"sessionCell为nil了");
        return nil;
    }
    self.nickName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.msgFrom];
    switch (self.msgType) {
        case QIMMessageType_Text:
        case QIMMessageType_NewAt:
        case QIMMessageType_Shock: {
            if (self.msgDirection == QIMMessageDirection_Received && self.chatType != ChatType_SingleChat && self.chatType != ChatType_System && self.chatType != ChatType_ConsultServer && self.chatType != ChatType_Consult && self.nickName.length > 0) {
                content = [NSString stringWithFormat:@"%@:%@", self.nickName, message];
            } else {
                content = message;
            }
        }
            break;
        case QIMMessageType_Revoke: {
            content = [[QIMKit sharedInstance] getMsgShowTextForMessageType:self.msgType];
            if (self.msgDirection == QIMMessageDirection_Received && self.nickName.length > 0) {
                content = [NSString stringWithFormat:@"\"%@\"%@", self.nickName, content];
            } else {
                content = [NSString stringWithFormat:@"你%@", content];
            }
        }
            break;
        case PublicNumberMsgType_Notice:
        case PublicNumberMsgType_OrderNotify: {
            NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:message error:nil];
            NSString *title = [dic objectForKey:@"title"];
            if (title.length > 0) {
                
                content = title;
            } else {
                
                content = @"你收到了一条消息。";
            }
        }
            break;
        case QIMMessageType_Consult: {
            
            NSDictionary *msgDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message error:nil];
            NSString *tagStr = [msgDic objectForKey:@"source"];
            NSString *msgStr = [msgDic objectForKey:@"detail"];
            content = [NSString stringWithFormat:@"%@:%@",tagStr?tagStr:@"",msgStr];
        }
            break;
        case QIMMessageType_CNote: {
            if (message.length > 0) {
                
                content = [[QIMKit sharedInstance] getMsgShowTextForMessageType:self.msgType];
                if (content.length <= 0) {
                    
                    content = @"发送了一条消息。";
                }
                if (self.msgDirection == QIMMessageDirection_Received) {
                    content = @"接收到一条消息。";
                } else {
                    content = @"发送了一条消息。";
                }
            }
        }
            break;
        default: {
            if (message.length > 0) {
                
                content = [[QIMKit sharedInstance] getMsgShowTextForMessageType:self.msgType];
                if (content.length <= 0) {
                    
                    content = @"发送了一条消息。";
                }
                if (self.msgDirection == QIMMessageDirection_Received && (self.chatType == ChatType_GroupChat || self.chatType == ChatType_CollectionChat) && self.nickName.length > 0) {
                    content = [NSString stringWithFormat:@"%@:%@", self.nickName, content];
                } else {
                    
                }
            }
        }
            break;
    }
    if (self.msgDirection == QIMMessageDirection_Sent) {
        if (self.msgState == QIMMessageSendState_Faild) {
            content = [NSString stringWithFormat:@"[obj type=\"faild\" value=\"\"]%@", content];
        } else if (self.msgState == QIMMessageSendState_Waiting) {
            content = [NSString stringWithFormat:@"[obj type=\"waiting\" value=\"\"]%@", content];
        }
    }
    
    NSDictionary *notSendDic = [[QIMKit sharedInstance] getNotSendTextByJid:self.jid];
    NSString *draftStr = notSendDic[@"text"];
    if (draftStr.length > 0) {
        content = [NSString stringWithFormat:@"[obj type=\"draft\" value=\"\"]%@", draftStr];
    }
    if (content.length <= 0) {
        
        content = @"收到了一条消息。";
    }
    if (self.isReminded == YES && self.notReadCount > 0) {
        content = [NSString stringWithFormat:@"[%ld条]%@", self.notReadCount, content];
    }
    return content;
}

- (void)refreshHeaderImage {
    
    if (self.bindId) {
        
        self.chatType = [[self.infoDic objectForKey:@"ChatType"] integerValue];
        [self.headerView qim_setCollectionImageWithJid:self.jid WithChatType:self.chatType];
    } else {
        NSString *headerUrl = [self.infoDic objectForKey:@"HeaderSrc"];
        self.chatType = [[self.infoDic objectForKey:@"ChatType"] integerValue];
        if (headerUrl.length > 0) {
            if (![headerUrl qim_hasPrefixHttpHeader]) {
                headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
            }
            [self.headerView qim_setImageWithURL:[NSURL URLWithString:headerUrl] WithChatType:self.chatType];
        } else {
            self.chatType = [[self.infoDic objectForKey:@"ChatType"] integerValue];
            NSString *realJid = [self.infoDic objectForKey:@"RealJid"];
            [self.headerView qim_setImageWithJid:self.jid WithRealJid:realJid WithChatType:self.chatType];
        }
    }
}

//刷新消息未读数
- (void)refreshNotReadCount {
    
    CGFloat timeLabelMaxX = CGRectGetMaxX(self.timeLabel.frame);
    CGFloat contentLabelWidth = timeLabelMaxX - self.nameLabel.left - 35;
    if (self.bindId) {
        self.notReadCount = [[QIMKit sharedInstance] getNotReadCollectionMsgCountByBindId:self.bindId WithUserId:self.jid];
    }
    __block NSString *countStr = nil;
    if (self.notReadCount > 0) {
        if (self.notReadCount > 99) {
            countStr = @"99+";
        }
        else {
            countStr = [NSString stringWithFormat:@"%ld", self.notReadCount];
        }
    } else {
        countStr = @"";
    }
    
    if (countStr.length > 0 && countStr != nil) {
        
        [self.notReadNumButton hiddenBadgeButton:NO];
        CGFloat width = (countStr.length * 7) + 13;
        [self setUpNotReadNumButtonWithFrame:CGRectMake(self.timeLabel.right - width, 11, width, 16) withBadgeString:countStr];
        if (self.isReminded == YES) {
            self.muteNotReadView.hidden = NO;
            self.muteNotReadView.centerY = self.muteView.centerY;
        } else {
            self.muteNotReadView.hidden = YES;
        }
        [self.contentLabel setFrame:CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 7, contentLabelWidth, 15)];
    } else {
        
        [self.notReadNumButton hiddenBadgeButton:YES];
        [_muteNotReadView setHidden:YES];
        self.contentLabel.width = contentLabelWidth;
        [self.contentLabel setFrame:CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 7, contentLabelWidth, 15)];
    }
    if (self.isReminded == YES && countStr.length > 0) {//接收不提醒
        self.muteView.hidden = NO;
        [self refeshContent];
        self.muteView.frame = CGRectMake([[QIMWindowManager shareInstance] getPrimaryWidth] - 40, self.timeLabel.bottom + 15, 15, 15);
        self.muteView.centerY = self.contentLabel.centerY;
    } else if (self.isReminded == YES && countStr.length <= 0) {//接收不提醒
        self.muteView.hidden = NO;
        [self refeshContent];
        self.muteView.frame = CGRectMake([[QIMWindowManager shareInstance] getPrimaryWidth] - 25, self.timeLabel.bottom + 15, 15, 15);
        self.muteView.centerY = self.contentLabel.centerY;
    } else {
        self.muteView.hidden = YES;
        
    }
}

- (void)refreshName {
    if (self.showName) {
        if (self.markUpName.length > 0) {
            self.showName = self.markUpName;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nameLabel setText:self.showName];
        });
    } else {
        self.chatType = [[self.infoDic objectForKey:@"ChatType"] integerValue];
        switch (self.chatType) {
            case ChatType_GroupChat: {
                if (!self.bindId) {
                    NSDictionary *groupVcard = [[QIMKit sharedInstance] getGroupCardByGroupId:self.jid];
                    if (groupVcard.count > 0) {
                        NSString *groupName = [groupVcard objectForKey:@"Name"];
                        NSInteger groupUpdateTime = [[groupVcard objectForKey:@"LastUpdateTime"] integerValue];
                        if (groupName.length > 0 && groupUpdateTime > 0) {
                            self.showName = groupName;
                        } else {
                            [self reloadPlaceHolderName];
                            [[QIMKit sharedInstance] updateGroupCardByGroupId:self.jid withCache:YES];
                        }
                    } else {
                        [[QIMKit sharedInstance] updateGroupCardByGroupId:self.jid withCache:YES];
                    }
                } else {
                    NSDictionary *cardDic = [[QIMKit sharedInstance] getCollectionGroupCardByGroupId:self.jid];
                    NSString *collectionGroupName = [cardDic objectForKey:@"Name"];
                    if (collectionGroupName.length > 0) {
                        self.showName = collectionGroupName;
                    } else {
                        [self reloadPlaceHolderName];
                    }
                }
            }
                break;
            case ChatType_System: {
                if ([self.jid hasPrefix:@"FriendNotify"]) {
                    self.showName = @"新朋友";
                } else {
                    
                    if ([self.jid hasPrefix:@"rbt-notice"]) {
                        
                        self.showName = @"公告通知";
                    } else if ([self.jid hasPrefix:@"rbt-qiangdan"]) {
                        self.showName = @"抢单通知";
                    } else if ([self.jid hasPrefix:@"rbt-zhongbao"]) {
                        self.showName = @"抢单";
                    } else {
                        
                        self.showName = [NSBundle qim_localizedStringForKey:@"System Messages"];//@"系统消息";
                    }
                }
            }
                break;
            case ChatType_CollectionChat: {
                self.showName = @"我的其他绑定账号";
            }
                break;
            case ChatType_SingleChat: {
                if (!self.bindId) {
                    //备注
                    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.jid];
                    if (remarkName.length > 0) {
                        
                        self.showName = remarkName;
                    } else {
                        
                    }
                } else {
                    NSDictionary *userInfo = [[QIMKit sharedInstance] getCollectionUserInfoByUserId:self.jid];
                    NSString *userName = [userInfo objectForKey:@"Name"];
                    if (userName.length > 0) {
                        self.showName = userName;
                    } else {
                        [self reloadPlaceHolderName];
                    }
                }
            }
                break;
            case ChatType_PublicNumber: {
                self.showName = [NSBundle qim_localizedStringForKey:@"contact_tab_public_number"];
            }
                break;
            case ChatType_ConsultServer: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.contentView addSubview:self.prefrenceImageView];
                });
                NSString *xmppId = [self.infoDic objectForKey:@"XmppId"];
                NSString *realJid = [self.infoDic objectForKey:@"RealJid"];
                
                NSDictionary *virtualInfo = [[QIMKit sharedInstance] getUserInfoByUserId:xmppId];
                NSString *virtualName = [virtualInfo objectForKey:@"Name"];
                if (virtualName.length <= 0) {
                    virtualName = [xmppId componentsSeparatedByString:@"@"].firstObject;
                }
                
                NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:realJid];
                NSString *realName = [userInfo objectForKey:@"Name"];
                if (realName.length <= 0) {
                    realName = [realJid componentsSeparatedByString:@"@"].firstObject;
                }
                self.showName = [NSString stringWithFormat:@"%@-%@",virtualName,realName];
            }
                break;
            case ChatType_Consult: {
                NSString *xmppId = [self.infoDic objectForKey:@"XmppId"];
                NSDictionary * virtualInfo = [[QIMKit sharedInstance] getUserInfoByUserId:xmppId];
                NSString *virtualName = [virtualInfo objectForKey:@"Name"];
                if (virtualName.length <= 0) {
                    virtualName = [xmppId componentsSeparatedByString:@"@"].firstObject;
                }
                self.showName = virtualName;
            }
                break;
            default:
                break;
        }
        if (self.showName.length) {
            
            [self.nameLabel setText:self.showName];
        } else {
            [self reloadPlaceHolderName];
            [self.nameLabel setText:self.showName];
        }
        
    }
}

- (void)refreshTimeLabelWithTime:(long long)time {
    long long msgDate = 0;
    if (time <= 0) {
        msgDate = [[self.infoDic objectForKey:@"MsgDateTime"] longLongValue];
    } else {
        msgDate = time;
    }
    __block NSString *timeStr = nil;
        if (msgDate > 0) {
            
            NSDate *senddate = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
            
            if (__global_dateformatter == nil) {
                
                __global_dateformatter = [[NSDateFormatter alloc] init];
                [__global_dateformatter setDateFormat:@"MM-dd HH:mm"];
            }
            
            BOOL isToday = [senddate qim_isToday];
            if (isToday) {
                
                NSString *locationString = [__global_dateformatter stringFromDate:senddate];
                locationString = [locationString substringFromIndex:6];
                NSInteger hour = [[locationString substringToIndex:2] integerValue];
                if (hour < 12) {
                    
                    timeStr = [NSString stringWithFormat:@"%@ %@",/*@"上午"*/@"", locationString];
                } else {
                    
                    timeStr = [NSString stringWithFormat:@"%@ %@",/*@"下午"*/@"", locationString];
                }
                
            } else {
                
                [__global_dateformatter setDateFormat:@"MM-dd HH:mm"];
                
                NSString *locationString = [__global_dateformatter stringFromDate:senddate];
                timeStr = [[locationString componentsSeparatedByString:@" "] objectAtIndex:0];
            }
        } else {
            timeStr = @"";
        }
        [self.timeLabel setText:timeStr];
}


- (void)refreshUI {
    self.chatType = [[self.infoDic objectForKey:@"ChatType"] integerValue];
    if (self.chatType == ChatType_ConsultServer) {
        [self.contentView addSubview:self.prefrenceImageView];
        _prefrenceImageView.hidden = NO;
    } else {
        _prefrenceImageView.hidden = YES;
    }
    [self refreshName];
    [self refreshHeaderImage];
    [self refreshTimeLabelWithTime:self.msgDateTime];
    [self refeshContent];
    self.notReadCount = [[self.infoDic objectForKey:@"UnreadCount"] integerValue];
//    NSLog(@"thisNotReadCount is ???");
    [self refreshNotReadCount];
    
    if (self.isStick) {
        _stickView.hidden = NO;
        [self addSubview:self.stickView];
    } else {
        _stickView.hidden = YES;
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)refeshContent {
    __block NSString *message = self.content;
    __block NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    [ps setAlignment:NSTextAlignmentLeft];
    
    __block NSString *content = @"";
    __weak __typeof(self) weakSelf = self;
    if (message.length > 0) {
        dispatch_async([[QIMKit sharedInstance] getLoadSessionContentQueue], ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSArray *atMeMessages = [[QIMKit sharedInstance] getHasAtMeByJid:strongSelf.jid];
            if (atMeMessages.count > 0) {
                NSDictionary * titleDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor qim_colorWithHex:0xEB524A alpha:1], NSForegroundColorAttributeName, ps, NSParagraphStyleAttributeName, nil];
                NSAttributedString *atStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[有人@我]"] attributes:titleDic];
                [str appendAttributedString:atStr];
            }
            content = [strongSelf refreshContentWithMessage:[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (content.length > 0) {
                    
                    [str appendAttributedString:[strongSelf decodeMsg:content]];
                }
                [strongSelf.contentLabel setAttributedText:str];
            });
        });
    } else {
        [self.contentLabel setText:@"收到了一条消息"];
    }
}

- (NSAttributedString *)decodeMsg:(NSString *)msg {
    NSMutableAttributedString *attStr = nil;
    if (msg) {
        
        NSUInteger startLoc = 0;
        int index = 0;
        NSString * lastStr = @"";
        attStr = [[NSMutableAttributedString alloc] init];
        
        NSString *regulaStr = @"\\[obj type=\"(.*?)\" value=\"(.*?)\"( width=(.*?) height=(.*?))?\\]";
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:msg options:0 range:NSMakeRange(0, [msg length])];
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            
            NSRange firstRange  =  [match rangeAtIndex:1];
            NSString *type = [msg substringWithRange:firstRange];
            NSRange secondRange =  [match rangeAtIndex:2];
            NSString *value = [msg substringWithRange:secondRange];
            NSUInteger len = match.range.location - startLoc;
            NSString *tStr = [msg substringWithRange:NSMakeRange(startLoc, len)];
            [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:tStr]];
            if ([type isEqualToString:@"image"]) {
                
                [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSBundle qim_localizedStringForKey:@"[Photo]"]]];
            } else if ([type isEqualToString:@"emoticon"]) {
                
                [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"[表情]"]];
            } else if ([type isEqualToString:@"url"]){
                
                NSAttributedString *attStr1 = [[NSAttributedString alloc] initWithString:value attributes:@{NSForegroundColorAttributeName:qim_sessionCellContentTextColor}];
                [attStr appendAttributedString:attStr1];
            } else if ([type isEqualToString:@"draft"]) {
                NSAttributedString *attStr1 = [[NSAttributedString alloc] initWithString:@"[草稿]" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
                [attStr appendAttributedString:attStr1];
            } else if ([type isEqualToString:@"faild"]) {
                
                UIFont *font = [UIFont systemFontOfSize:15];
                NSMutableDictionary *attributed = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor redColor]}];
                NSAttributedString *attStr1 = [[NSAttributedString alloc] initWithString:@"\U0000f0fc " attributes:attributed];
                [attStr appendAttributedString:attStr1];
            } else if ([type isEqualToString:@"waiting"]) {
                UIFont *font = [UIFont systemFontOfSize:15];
                NSMutableDictionary *attributed = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
                NSAttributedString *attStr1 = [[NSAttributedString alloc] initWithString:@"\U0000e3d9 " attributes:attributed];
                [attStr appendAttributedString:attStr1];
            }
            startLoc = match.range.location + match.range.length;
            if (index == arrayOfAllMatches.count - 1) {
                
                lastStr = [[msg substringFromIndex:(match.range.location + match.range.length)] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                if ([lastStr length] > 0) {
                    UIFont *font = [UIFont systemFontOfSize:15];
                    NSMutableDictionary *attributed = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x999999]}];
                    [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:lastStr attributes:attributed]];
                }
            }
            index++;
        }
        if (arrayOfAllMatches.count <= 0) {
            
            [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:msg]];
        }
    }
    return attStr;
}
@end

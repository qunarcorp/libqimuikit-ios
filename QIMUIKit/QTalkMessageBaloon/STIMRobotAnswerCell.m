//
//  STIMRobotAnswerCell.m
//  STIMUIKit
//
//  Created by 李露 on 11/9/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMRobotAnswerCell.h"
#import "STIMTextContainer.h"
#import "STIMMessageParser.h"
#import "STIMAttributedLabel.h"
#import "STIMButton.h"

#define kHintTextFontSize   16
#define kLikeRobotAnswerTag 10001
#define kDislikeRobotAnswerTag 10002
#define kLineWidth             1.0f

@interface STIMRobotAnswerCell ()

@property (nonatomic, strong) STIMAttributedLabel *msgContentLabel;
@property (nonatomic, strong) STIMAttributedLabel *middleContentLabel;
@property (nonatomic, strong) UIView *panelBgView;
@property (nonatomic, strong) UIView *controllPanelBgView;
@property (nonatomic, strong) STIMTextContainer *msgContentContainer;
@property (nonatomic, strong) STIMTextContainer *middleContentContainer;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *dislikeButton;
@property (nonatomic, strong) UIButton *teachButton;

@end

@implementation STIMRobotAnswerCell

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType {
    
    NSDictionary *exTrdDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
    NSString *content = [exTrdDic objectForKey:@"content"];
    CGFloat cellHeight = 0.0f;
    if (content.length) {
        STIMMessageModel *contentMsg = [[STIMMessageModel alloc] init];
        contentMsg.message = content;
        contentMsg.messageId = [NSString stringWithFormat:@"%@_content", message.messageId];
        contentMsg.messageDirection = message.messageDirection;
        STIMTextContainer *textContainer = [STIMMessageParser textContainerForMessage:contentMsg];
        textContainer.font = [UIFont systemFontOfSize:kHintTextFontSize];
        cellHeight += [textContainer getHeightWithFramesetter:nil width:textContainer.textWidth];
    }
    STIMMessageRemoteReadState readState = [[STIMKit sharedInstance] getReadStateWithMsgId:message.messageId];
    STIMVerboseLog(@"readState : %ld", readState);
    if (readState == 4) {
        return cellHeight + 50;
    } else {
        NSString *middleContent = [exTrdDic objectForKey:@"middleContent"];
        if (middleContent.length) {
            STIMMessageModel *middleContentMsg = [[STIMMessageModel alloc] init];
            middleContentMsg.message = middleContent;
            middleContentMsg.messageId = [NSString stringWithFormat:@"%@_middleContent", message.messageId];
            middleContentMsg.messageDirection = message.messageDirection;
            STIMTextContainer *textContainer = [STIMMessageParser textContainerForMessage:middleContentMsg];
            textContainer.font = [UIFont systemFontOfSize:12];
            cellHeight += [textContainer getHeightWithFramesetter:nil width:textContainer.textWidth];
        }
        return cellHeight + 100;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        self.contentView.backgroundColor = [UIColor qtalkChatBgColor];
        
        self.msgContentLabel = [[STIMAttributedLabel alloc] init];
        self.msgContentLabel.backgroundColor = [UIColor clearColor];
        [self.backView addSubview:self.msgContentLabel];
        
        self.panelBgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.panelBgView.backgroundColor = [UIColor whiteColor];
        [self.backView addSubview:self.panelBgView];
        
        self.controllPanelBgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.controllPanelBgView.backgroundColor = [UIColor whiteColor];
        [self.panelBgView addSubview:self.controllPanelBgView];
        
        self.middleContentLabel = [[STIMAttributedLabel alloc] init];
        self.middleContentLabel.backgroundColor = [UIColor clearColor];
        [self.panelBgView addSubview:self.middleContentLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageControlStateByNotification:) name:kNotificationMessageControlStateUpdate object:nil];
    }
    return self;
}

- (void)updateMessageControlStateByNotification:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notifyDic = notify.object;
        NSArray *msgIds = [notifyDic objectForKey:@"MsgIds"];
        for (NSDictionary *msgDict in msgIds) {
            NSString *msgId = [msgDict objectForKey:@"id"];
            STIMMessageRemoteReadState state = (STIMMessageRemoteReadState)[[notifyDic objectForKey:@"State"] unsignedIntegerValue];
            if ([msgId isEqualToString:self.message.messageId]) {
                self.message.messageReadState = state;
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRobotAnswerMessageCell:)]) {
                    [self.delegate refreshRobotAnswerMessageCell:self];
                }
                break;
            } else {
                
            }
        }
    });
}

- (void)refreshUI {
    
    NSDictionary *exTrdDic = [[STIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
    NSString *msgContent = [exTrdDic objectForKey:@"content"];
    STIMMessageModel *contentMsg = [[STIMMessageModel alloc] init];
    contentMsg.message = msgContent;
    contentMsg.messageId = [NSString stringWithFormat:@"%@_content", self.message.messageId];
    contentMsg.messageDirection = self.message.messageDirection;
    _msgContentContainer = [STIMMessageParser textContainerForMessage:contentMsg];
    
    self.msgContentLabel.delegate = self.delegate;
    self.msgContentLabel.textContainer = _msgContentContainer;
    if (_msgContentContainer) {
        [self.msgContentLabel setFrameWithOrign:CGPointMake((STIMMessageDirection_Received == self.message.messageDirection) ? 25 :10, 16) Width:[STIMMessageParser getCellWidth]];
    }else {
        [self.msgContentLabel setFrameWithOrign:CGPointMake(0, 0) Width:[STIMMessageParser getCellWidth]];
    }
    float cellWidth = [STIMMessageParser getCellWidth];
    float height = [STIMRobotAnswerCell getCellHeightWithMessage:self.message chatType:self.message.chatType - 20];
    
    [self.backView setMessage:self.message];
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    [self setBackViewWithWidth:[STIMMessageParser getCellWidth] + 40 WithHeight:height - 30];
    STIMMessageReadFlag readState = [[STIMKit sharedInstance] getMessageStateWithMsgId:self.message.messageId];
    STIMVerboseLog(@"readState2 : %ld", readState);

    if (readState == 4) {
        [self.lineView removeFromSuperview];
        [self.panelBgView removeAllSubviews];
        [self.panelBgView removeFromSuperview];
        [self.middleContentLabel removeFromSuperview];
        [self.controllPanelBgView removeFromSuperview];
    } else {
        self.panelBgView.frame = CGRectMake(10, self.msgContentLabel.bottom, [STIMMessageParser getCellWidth] + 40 - 20, self.backView.bottom - self.msgContentLabel.bottom - 35);
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(12, 5, cellWidth + 20 - 24, 1.0f)];
        self.lineView.backgroundColor = [UIColor stimDB_colorWithHex:0xEEEEEE];
        [self.panelBgView addSubview:self.lineView];
        
        NSString *middleContent = [exTrdDic objectForKey:@"middleContent"];
        STIMMessageModel *middleContentMsg = [[STIMMessageModel alloc] init];
        middleContentMsg.message = middleContent;
        middleContentMsg.messageId = [NSString stringWithFormat:@"%@_middleContent", self.message.messageId];
        middleContentMsg.messageDirection = self.message.messageDirection;
        _middleContentContainer = [STIMMessageParser textContainerForMessage:middleContentMsg];
        
        self.middleContentLabel.delegate = self.delegate;
        self.middleContentLabel.textContainer = _middleContentContainer;
        if (_middleContentContainer) {
            [self.middleContentLabel setFrameWithOrign:CGPointMake((STIMMessageDirection_Received == self.message.messageDirection) ? 20 :5, 16) Width:[STIMMessageParser getCellWidth]];
        } else {
            [self.middleContentLabel setFrameWithOrign:CGPointMake(0,0) Width:[STIMMessageParser getCellWidth]];
        }
        self.middleContentLabel.font = [UIFont systemFontOfSize:12];
        self.middleContentLabel.textColor = [UIColor stimDB_colorWithHex:0x9E9E9E];
        [self.panelBgView addSubview:self.middleContentLabel];
        self.controllPanelBgView.frame = CGRectMake(0, self.middleContentLabel.bottom + 10, self.panelBgView.width, 20);
        [self setupControlButton];
    }
    [super refreshUI];
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
}

- (void)setupControlButton {
    STIMButton *likeButton = [STIMButton buttonWithType:UIButtonTypeCustom];
    likeButton.frame = CGRectMake(15, 0, 50, 20);
    likeButton.imageAlignment = STIMButtonImageAlignmentLeft;
    likeButton.tag = kLikeRobotAnswerTag;
    likeButton.adjustsImageWhenHighlighted = NO;
    [likeButton setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f04f" size:20 color:[UIColor stimDB_colorWithHex:0x9E9E9E]]] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f04f" size:20 color:[UIColor redColor]]] forState:UIControlStateSelected];
    [likeButton setTitle:@"有用" forState:UIControlStateNormal];
    [likeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [likeButton setTitleColor:[UIColor stimDB_colorWithHex:0x5CC57F] forState:UIControlStateNormal];
    [likeButton addTarget:self action:@selector(feedbackAnswer:) forControlEvents:UIControlEventTouchUpInside];
    [self.controllPanelBgView addSubview:likeButton];
    self.likeButton = likeButton;
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(self.controllPanelBgView.width / 3.0, 0, kLineWidth, 20)];
    lineView1.backgroundColor = [UIColor stimDB_colorWithHex:0xEEEEEE];
    [self.controllPanelBgView addSubview:lineView1];

    STIMButton *dislikeButton = [STIMButton buttonWithType:UIButtonTypeCustom];
    dislikeButton.adjustsImageWhenHighlighted = NO;
    dislikeButton.frame = CGRectMake(lineView1.right + 18, 0, 50, 20);
    dislikeButton.tag = kDislikeRobotAnswerTag;
    dislikeButton.imageAlignment = STIMButtonImageAlignmentLeft;
    [dislikeButton setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e5eb" size:20 color:[UIColor stimDB_colorWithHex:0x9E9E9E]]] forState:UIControlStateNormal];
    [dislikeButton setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e5eb" size:20 color:[UIColor redColor]]] forState:UIControlStateSelected];
    [dislikeButton setTitle:@"没用" forState:UIControlStateNormal];
    [dislikeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [dislikeButton setTitleColor:[UIColor stimDB_colorWithHex:0x5CC57F] forState:UIControlStateNormal];
    [dislikeButton addTarget:self action:@selector(feedbackAnswer:) forControlEvents:UIControlEventTouchUpInside];
    [self.controllPanelBgView addSubview:dislikeButton];
    self.dislikeButton = dislikeButton;
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(2 * self.controllPanelBgView.width / 3.0, 0, kLineWidth, 20)];
    lineView2.backgroundColor = [UIColor stimDB_colorWithHex:0xEEEEEE];
    [self.controllPanelBgView addSubview:lineView2];
    
    STIMButton *teachButton = [STIMButton buttonWithType:UIButtonTypeCustom];
    teachButton.adjustsImageWhenHighlighted = NO;
    teachButton.frame = CGRectMake(lineView2.right + 18, 0, 50, 20);
    teachButton.imageAlignment = STIMButtonImageAlignmentLeft;
    [teachButton setTitle:@"教小拿" forState:UIControlStateNormal];
    [teachButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [teachButton setTitleColor:[UIColor stimDB_colorWithHex:0x5CC57F] forState:UIControlStateNormal];
    [teachButton addTarget:self action:@selector(reTeachRobot:) forControlEvents:UIControlEventTouchUpInside];
    [self.controllPanelBgView addSubview:teachButton];
    self.teachButton = teachButton;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)feedbackAnswer:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSDictionary *exTrdDic = [[STIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
    NSString *requestUrl = [exTrdDic objectForKey:@"url"];
    NSDictionary *originPostBody = [exTrdDic objectForKey:@"requestPost"];
    NSMutableDictionary *tempPostBodyDic = [NSMutableDictionary dictionaryWithDictionary:originPostBody];
    if (btn.tag == kLikeRobotAnswerTag) {
        [tempPostBodyDic setObject:@"yes" forKey:@"isOk"];
    } else if (btn.tag == kDislikeRobotAnswerTag) {
        [tempPostBodyDic setObject:@"no" forKey:@"isOk"];
    }
    NSData *bodydata = [[STIMJSONSerializer sharedInstance] serializeObject:tempPostBodyDic error:nil];
    __block NSInteger btnTag = btn.tag;
    __weak __typeof(self) weakSelf = self;
    [[STIMKit sharedInstance] sendTPPOSTRequestWithUrl:requestUrl withRequestBodyData:bodydata withSuccessCallBack:^(NSData *responseData) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        UIButton *button = (UIButton *)[self.controllPanelBgView viewWithTag:btnTag];
        [button setSelected:YES];
        [button setEnabled:NO];
        [self.likeButton setEnabled:NO];
        [self.dislikeButton setEnabled:NO];
        [self.teachButton setEnabled:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRobotAnswerMessageCell:)]) {
            [self.delegate refreshRobotAnswerMessageCell:self];
        }
        [[STIMKit sharedInstance] sendReadStateWithMessagesIdArray:@[self.message.messageId] WithMessageReadFlag:STIMMessageReadFlagDidControl WithXmppId:self.message.from];
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)reTeachRobot:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reTeachRobot)]) {
        [self.delegate reTeachRobot];
    }
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end

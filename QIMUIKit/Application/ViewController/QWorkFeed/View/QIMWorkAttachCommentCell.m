//
//  QIMWorkAttachCommentCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/3/11.
//

#import "QIMWorkAttachCommentCell.h"
#import "QIMWorkMomentLabel.h"
#import "QIMWorkCommentModel.h"
#import "QIMEmotionManager.h"
#import "QIMWorkMomentParser.h"

@interface QIMWorkAttachCommentCell () <QIMAttributedLabelDelegate>

@end

@implementation QIMWorkAttachCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    //点赞按钮
    _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateSelected];
    _likeBtn.layer.cornerRadius = 13.5f;
    _likeBtn.layer.masksToBounds = YES;
    [_likeBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    [self.contentView addSubview:_likeBtn];
    
    // 正文视图
    _contentLabel = [[QIMWorkMomentLabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.linesSpacing = 20.0f;
    _contentLabel.delegate = self;
    _contentLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    _contentLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
    [_contentLabel setBackgroundColor:[UIColor qim_colorWithHex:0xF3F3F5]];
    [self.contentView addSubview:_contentLabel];
}

- (void)setCommentModel:(QIMWorkCommentModel *)commentModel {
    if (commentModel.commentUUID.length <= 0) {
        return;
    }
    _commentModel = commentModel;;
    NSString *nameText = @"";
    BOOL isAnonymousComment = commentModel.isAnonymous;
    if (isAnonymousComment == NO) {
        
        //实名评论
        NSString *commentFromUserId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
        nameText = [NSString stringWithFormat:@"%@：", [[QIMKit sharedInstance] getUserMarkupNameWithUserId:commentFromUserId]];
    } else {
        //匿名评论
        NSString *anonymousName = commentModel.anonymousName;
        nameText = [NSString stringWithFormat:@"%@：", anonymousName];
    }
    CGFloat rowHeight = 0;
    
    BOOL isChildComment = (commentModel.parentCommentUUID.length > 0) ? YES : NO;
    BOOL toisAnonymous = commentModel.toisAnonymous;
    NSString *replayNameStr = @"";
    NSString *replayStr = @"";
    if (isChildComment) {
        if (toisAnonymous) {
            NSString *toAnonymousName = commentModel.toAnonymousName;
            replayNameStr = [NSString stringWithFormat:@"%@回复%@", nameText, toAnonymousName];
            replayStr = [NSString stringWithFormat:@"[obj type=\"reply\" value=\"%@\"]",replayNameStr];
        } else {
            NSString *toUser = commentModel.toUser;
            NSString *toUserHost = commentModel.toHost;
            if (toUser.length > 0) {
                
            }
            NSString *toUserId = [NSString stringWithFormat:@"%@@%@", toUser, toUserHost];
            NSString *toUserName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:toUserId];
            replayNameStr = [NSString stringWithFormat:@"%@回复%@", nameText, toUserName];
            replayStr = [NSString stringWithFormat:@"[obj type=\"reply\" value=\"%@\"]",replayNameStr];
        }
    } else {
        replayNameStr = [NSString stringWithFormat:@"%@", nameText];
        replayStr = [NSString stringWithFormat:@"[obj type=\"reply\" value=\"%@\"]",replayNameStr];
    }
    
    _likeBtn.frame = CGRectMake([[QIMWindowManager shareInstance] getPrimaryWidth] - 70 - self.leftMargin, 8, 60, 15);
    NSInteger likeNum = commentModel.likeNum;
    [_likeBtn setTitle:[NSString stringWithFormat:@"%ld 赞", likeNum] forState:UIControlStateNormal];
    QIMMessageModel *msg = [[QIMMessageModel alloc] init];
    msg.message = [NSString stringWithFormat:@"%@ %@", replayStr, [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:commentModel.content]];
    msg.messageId = commentModel.commentUUID;
    self.contentLabel.originContent = commentModel.content;
    self.contentLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
    QIMTextContainer *mainTextContainer = [QIMWorkMomentParser textContainerForMessage:msg fromCache:YES withCellWidth:self.likeBtn.left - 12 withFontSize:14 withFontColor:[UIColor qim_colorWithHex:0x333333] withNumberOfLines:3];
    CGFloat textH = mainTextContainer.textHeight;
    self.contentLabel.textContainer = mainTextContainer;
    [self.contentLabel setFrameWithOrign:CGPointMake(12, 5) Width:(self.likeBtn.left - 12)];
    _commentModel.rowHeight = _contentLabel.bottom + 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

// 点击代理
- (void)attributedLabel:(QIMAttributedLabel *)attributedLabel textStorageClicked:(id<QIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    if ([textStorage isMemberOfClass:[QIMLinkTextStorage class]]) {
        QIMLinkTextStorage *storage = (QIMLinkTextStorage *) textStorage;
        if (![storage.linkData length]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Wrong_Interface"] message:[NSBundle qim_localizedStringForKey:@"Wrong_URL"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] otherButtonTitles:nil];
            [alertView show];
        } else {
            [QIMFastEntrance openWebViewForUrl:storage.linkData showNavBar:YES];
        }
    } else {
        
    }
}

// 长按代理 有多个状态 begin, changes, end 都会调用,所以需要判断状态
- (void)attributedLabel:(QIMAttributedLabel *)attributedLabel textStorageLongPressed:(id<QIMTextStorageProtocol>)textStorage onState:(UIGestureRecognizerState)state atPoint:(CGPoint)point {
    
}

@end

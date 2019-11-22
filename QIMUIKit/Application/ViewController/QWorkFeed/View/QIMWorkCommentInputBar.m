//
//  QIMWorkCommentInputBar.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/10.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkCommentInputBar.h"
#import "QIMWorkCommentTextView.h"
#import "QIMWorkMomentUserIdentityModel.h"
#import "QIMWorkFeedAtNotifyViewController.h"
#import "QIMATGroupMemberTextAttachment.h"
#import "QIMMessageTextAttachment.h"
#import "QTalkTipsView.h"

@interface QIMWorkCommentInputBar () <UITextViewDelegate>

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) QIMWorkCommentTextView *commentTextView;

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, assign) BOOL isLike;

@property (nonatomic, assign) NSInteger likeNum;

@end

@implementation QIMWorkCommentInputBar

- (BOOL)isInputBarFirstResponder {
    return [self.commentTextView isFirstResponder];
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(_headerImageView.right - 5, _headerImageView.bottom - 5, 5, 5)];
        _iconView.backgroundColor = [UIColor whiteColor];
        _iconView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"q_work_triangle"];
    }
    return _iconView;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 36, 36)];
        _headerImageView.layer.cornerRadius = 18.0f;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.borderColor = [UIColor qim_colorWithHex:0xDFDFDF].CGColor;
        _headerImageView.layer.borderWidth = 1.0f;
//        [self reloadUserIdentifier];
//        [_headerImageView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
        _headerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserIdentifierVC:)];
        [_headerImageView addGestureRecognizer:tap];
    }
    return _headerImageView;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 62, 17, 52, 26);
        [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0e7" size:26 color:[UIColor qim_colorWithHex:0x999999]]] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0cd" size:26 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
        [_likeBtn setTitle:[NSBundle qim_localizedStringForKey:@"moment_like"] forState:UIControlStateNormal];
        [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
        [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateSelected];
        [_likeBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
        [_likeBtn addTarget:self action:@selector(didLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 46, 10, 36, 36);
        [_sendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e644" size:36 color:[UIColor qim_colorWithHex:0xBFBFBF]]] forState:UIControlStateDisabled];
        [_sendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e644" size:36 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateNormal];
        _sendBtn.layer.cornerRadius = 18.0f;
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.hidden = YES;
        _sendBtn.enabled = NO;
        [_sendBtn addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 8, 90, 21)];
        _placeholderLabel.text = @"  快来说几句…(200字以内)";
        _placeholderLabel.numberOfLines = 0;
        _placeholderLabel.font = [UIFont systemFontOfSize:15];
        _placeholderLabel.textColor = [UIColor qim_colorWithHex:0x999999];
    }
    return _placeholderLabel;
}

- (QIMWorkCommentTextView *)commentTextView {
    if (!_commentTextView) {
        _commentTextView = [[QIMWorkCommentTextView alloc] initWithFrame:CGRectMake(self.headerImageView.right + 6, 10, CGRectGetWidth(self.frame) - self.headerImageView.right - 6 - 16 - self.likeBtn.width - 6, 36)];
        _commentTextView.textAlignment = NSTextAlignmentLeft;
        _commentTextView.delegate = self;
        _commentTextView.backgroundColor = [UIColor qim_colorWithHex:0xF0F0F0];
        _commentTextView.font = [UIFont systemFontOfSize:15];
        _commentTextView.textColor = [UIColor qim_colorWithHex:0x333333];
        _commentTextView.contentInset = UIEdgeInsetsMake(0, 10.0f, 0, 10.0f);
        [_commentTextView addSubview:self.placeholderLabel];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.3) {
            [_commentTextView setValue:self.placeholderLabel forKey:@"_placeholderLabel"];
        }
        _commentTextView.layer.cornerRadius = 18.0f;
        _commentTextView.layer.masksToBounds = YES;
        _commentTextView.returnKeyType = UIReturnKeySend;
    }
    return _commentTextView;
}

- (void)resignFirstInputBar:(BOOL)flag {
    if (flag) {
        self.sendBtn.hidden = NO;
        if (self.commentTextView.text.length <= 0) {
            self.sendBtn.enabled = NO;
        } else {
            self.sendBtn.enabled = YES;
        }
        self.likeBtn.hidden = YES;
        self.commentTextView.frame = CGRectMake(self.headerImageView.right + 6, 10, CGRectGetWidth(self.frame) - self.headerImageView.right - 6 - self.likeBtn.width - 6, 36);
        [self bringSubviewToFront:self.sendBtn];
    } else {
        self.sendBtn.hidden = YES;
        self.likeBtn.hidden = NO;
        self.commentTextView.frame = CGRectMake(self.headerImageView.right + 6, 10, CGRectGetWidth(self.frame) - self.headerImageView.right - 6 - 16 - self.likeBtn.width - 15, 36);
        [self sendSubviewToBack:self.sendBtn];
        self.placeholderLabel.text = @"  快来说几句…(200字以内)";
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,-2.5);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 7.5;
        
        [self addSubview:self.headerImageView];
        [self addSubview:self.iconView];
        [self addSubview:self.sendBtn];
        [self addSubview:self.likeBtn];
        [self addSubview:self.commentTextView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUserIdentifier) name:@"kReloadUserIdentifier" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLikeNum:(NSInteger)likeNum withISLike:(BOOL)isLike {
    _likeNum = likeNum;
    _isLike = isLike;
    if (isLike) {
        _likeBtn.selected = YES;
        [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
    } else {
        _likeBtn.selected = NO;
        if (likeNum > 0) {
            [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
        } else {
            [_likeBtn setTitle:[NSBundle qim_localizedStringForKey:@"moment_like"] forState:UIControlStateNormal];
        }
    }
}

- (void)setMomentId:(NSString *)momentId {
    _momentId = momentId;
    [self reloadUserIdentifier];
}

- (void)reloadUserIdentifier {
    QIMWorkMomentUserIdentityModel *userModel  = [[QIMWorkMomentUserIdentityManager sharedInstanceWithPOSTUUID:self.momentId] userIdentityModel];
    BOOL isAnonymous = userModel.isAnonymous;

    if (isAnonymous == NO) {
        [_headerImageView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
    } else {
        NSString *anonymousName = userModel.anonymousName;
        NSString *anonymousPhoto = userModel.anonymousPhoto;
        if (![anonymousPhoto qim_hasPrefixHttpHeader]) {
            anonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], anonymousPhoto];
        } else {
            
        }
        [_headerImageView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
    }
}

- (void)beginCommentToUserId:(NSString *)userId {
    self.placeholderLabel.text = [NSString stringWithFormat:@"%@（200字以内）", userId];
    [self.commentTextView becomeFirstResponder];
}

- (void)didLikeComment:(UIButton *)sender {
    BOOL likeFlag = !sender.selected;
    [[QIMKit sharedInstance] likeRemoteMomentWithMomentId:self.momentId withLikeFlag:likeFlag withCallBack:^(NSDictionary *responseDic) {
        if (responseDic.count > 0) {
            NSLog(@"点赞成功");
            BOOL islike = [[responseDic objectForKey:@"isLike"] boolValue];
            NSInteger likeNum = [[responseDic objectForKey:@"likeNum"] integerValue];
            if (islike) {
                [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
                sender.selected = YES;
            } else {
                if (likeNum > 0) {
                    [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
                } else {
                    [sender setTitle:[NSBundle qim_localizedStringForKey:@"moment_like"] forState:UIControlStateNormal];
                }
                sender.selected = NO;
            }
        } else {
            NSLog(@"点赞失败");
        }
    }];
}

- (void)openUserIdentifierVC:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didOpenUserIdentifierVC)]) {
        [self.delegate didOpenUserIdentifierVC];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        [self.sendBtn setEnabled:YES];
    } else {
        [self.sendBtn setEnabled:NO];
    }
}

//判断内容是否全部为空格  YES 全部为空格
- (BOOL)isEmpty:(NSString *)str {
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.commentTextView && [text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        NSLog(@"text : %@", text);
        if (self.delegate && [self.delegate respondsToSelector:@selector(didaddCommentWithStr:withAtList:)]) {
            [self sendComment];
        }
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    } else if (textView == self.commentTextView && [text isEqualToString:@"@"]) {
        QIMWorkFeedAtNotifyViewController * qNoticeVC = [[QIMWorkFeedAtNotifyViewController alloc] init];
        __weak __typeof(&*self) weakSelf = self;
        
        [qNoticeVC onQIMWorkFeedSelectUser:^(NSArray *selectUsers) {
            NSLog(@"selectUsers : %@", selectUsers);
            for (NSString *userXmppJid in selectUsers) {
                if (userXmppJid.length > 0) {
                    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userXmppJid];
                    if (userInfo.count > 0) {
                        NSString *name = [userInfo objectForKey:@"Name"];
                        NSString *jid = [userInfo objectForKey:@"XmppId"];
                        NSString *memberName = [NSString stringWithFormat:@"@%@ ", name];
                        
                        QIMATGroupMemberTextAttachment *atTextAttachment = [[QIMATGroupMemberTextAttachment alloc] init];
                        CGSize size = [memberName qim_sizeWithFontCompatible:self.commentTextView.font];
                        atTextAttachment.image = [UIImage qim_imageWithColor:[UIColor qim_colorWithHex:0xF0F0F0] size:CGSizeMake(size.width, self.commentTextView.font.lineHeight) text:memberName textAttributes:@{NSFontAttributeName:self.commentTextView.font} circular:NO];
                        atTextAttachment.groupMemberName = memberName;
                        atTextAttachment.groupMemberJid = jid;
                        
                        [self.commentTextView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:atTextAttachment] atIndex:self.commentTextView.selectedRange.location];
                        self.commentTextView.selectedRange = NSMakeRange(MIN(self.commentTextView.selectedRange.location + 1, self.commentTextView.text.length - self.commentTextView.selectedRange.length), self.commentTextView.selectedRange.length);
                        [self resetTextStyle];
                        
                    } else {
                        QIMVerboseLog(@"未选择要艾特的群成员");
                        weakSelf.commentTextView.selectedRange = NSMakeRange(weakSelf.commentTextView.selectedRange.location + self.commentTextView.selectedRange.length + 1, 0);
                        [weakSelf resetTextStyle];
                    }
                }
            }
        }];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didiOpenUserSelectVCWithVC:)]) {
            [self.delegate didiOpenUserSelectVCWithVC:qNoticeVC];
        }
        return NO;
    }
    return YES;
}

- (void)resetTextStyle {
    //After changing text selection, should reset style.
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.firstLineHeadIndent = 0;    /**首行缩进宽度*/
    if (self.commentTextView.textStorage.length <= 0) {

        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        self.commentTextView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
        self.commentTextView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    }else{
        NSRange wholeRange = NSMakeRange(0, self.commentTextView.textStorage.length);
        [self.commentTextView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
        [self.commentTextView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:wholeRange];
        [self.commentTextView.textStorage removeAttribute:NSParagraphStyleAttributeName range:wholeRange];
    }
    [self.commentTextView setFont:[UIFont systemFontOfSize:15]];
}

- (void)sendComment {
    if (self.commentTextView.text.length > 200) {
        [QTalkTipsView showTips:[NSString stringWithFormat:@"评论不可以超过200个字哦～"] InView:[[[[UIApplication sharedApplication] keyWindow] rootViewController] view]];
        return;
    }
    
    if (self.commentTextView.text.length > 0 && ![self isEmpty:self.commentTextView.attributedText.string]) {
        NSMutableArray *outATInfoArray = [NSMutableArray arrayWithCapacity:3];
        NSString *finallyContent = [[QIMMessageTextAttachment sharedInstance] getStringFromAttributedString:self.commentTextView.attributedText WithOutAtInfo:&outATInfoArray];
        [self.delegate didaddCommentWithStr:finallyContent withAtList:outATInfoArray];
        self.commentTextView.text = nil;
        [self.commentTextView resignFirstResponder];
    }
}

@end

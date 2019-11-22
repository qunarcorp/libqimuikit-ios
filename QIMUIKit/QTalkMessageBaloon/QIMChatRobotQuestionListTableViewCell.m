//
//  QIMChatRobotQuestionListTableViewCell.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/8/28.
//

#import "QIMChatRobotQuestionListTableViewCell.h"
#import "QIMMsgBaloonBaseCell.h"
#import "QIMTextContainer.h"
#import "QIMAttributedLabel.h"
#import "QIMMessageParser.h"
#import "QIMJSONSerializer.h"
#import "QIMMessageCellCache.h"
#import "QIMCustomPopManager.h"
#import "QIMCustomPopViewController.h"
#import "UIApplication+QIMApplication.h"

#define kSeplineColor       0xCCCCCC

#define kQCIMMsgCellIconWH 44
#define kQCIMMsgCellBoxMargin 12
#define kQCIMMsgCellCtntMargin 15
#define kQCIMMsgCellCtntFont 10
#define kQCIMMsgCellUsrTitleFont 15

#define kIMChatTimeFont [UIFont systemFontOfSize:11] //时间字体
#define kIMChatHintFont [UIFont systemFontOfSize:13] //提示和系统消息字体
#define kIMChatContentFont [UIFont systemFontOfSize:15]//内容字体

#define kLineHeight1px (1/[[UIScreen mainScreen] scale])

#define kIMChatMargin 12 //间隔
#define kIMChatIconWH 44 //头像宽高height、width
#define kIMChatTimeMarginW 10
#define kIMChatTimeMarginH 5
#define kIMChatContentTop 10
#define kIMChatContentLeft 12
#define kIMChatContentBottom 10
#define kIMChatContentRight 12
#define kIMAudioButtonMinWidth 62 //语音消息按钮宽度
#define kIMRedPointWH 8 //语音消息读取状态视图宽高

#define kActionsBtnTagFrom 1000
#define kHintTextFontSize   16
#define kSpaceToSide    15
#define kHintCelMaxWidth    250//([UIScreen mainScreen].bounds.size.width - kSpaceToSide * 2)
#define kMessageIsUnfold  @"kMessageIsUnfold"


@interface QIMChatRobotQuestionListTableViewCell()<QIMMenuImageViewDelegate,UIActionSheetDelegate,QIMAttributedLabelDelegate>
{
    UIView               * _bgView;
    QIMAttributedLabel   * _textLabel;
    UIView                * _listBGView;
    QIMAttributedLabel   * _hintLabel;
}

@property (nonatomic, strong) QIMTextContainer *textContainer;
@property (nonatomic, strong) QIMTextContainer *hintContainer;
@property (nonatomic, strong) UIButton * resolveBtn;
@property (nonatomic, strong) UIButton * unResolveBtn;
@property (nonatomic, strong) UILabel * bottom_tipsLabel;
@property (nonatomic, strong) UIView * separateLine;
@property (nonatomic, strong) UILabel * resolveLabel;
@property (nonatomic, strong) UILabel * unResolveLabel;
@property (nonatomic, strong) NSString * yesBtnUrl;
@property (nonatomic, strong) NSString * noBtnUrl;
@end

@implementation QIMChatRobotQuestionListTableViewCell
@dynamic delegate;

+ (CGFloat)getCellHeightWithMessage:(QIMMessageModel *)msg chatType:(ChatType)chatType {
    return [self consultRbtCellHeightForMsg:msg];
}

+ (CGFloat)consultRbtCellHeightForMsg:(QIMMessageModel *)msg {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxWidth = screenW - 2*kIMChatMargin;
    float cellHeight = 0;
    float cellWidth = maxWidth;
    NSString * jsonStr = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
    if (infoDic == nil && jsonStr.length) {
        infoDic = @{@"content":jsonStr?jsonStr:@""};
    }
    if (infoDic.count) {
        //消息标题
        NSString * content = [infoDic objectForKey:@"content"];
        if (content.length) {
            QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessageCtnt:content withId:msg.messageId direction:msg.messageDirection];
            textContainer.textAlignment = kCTTextAlignmentLeft;
            textContainer.font = [UIFont systemFontOfSize:kHintTextFontSize];
            cellHeight += [textContainer getHeightWithFramesetter:nil width:kHintCelMaxWidth-28-14] + 10;
            cellWidth = textContainer.textWidth + (kIMChatContentLeft + kIMChatContentRight);
            cellHeight += 10;
        }
        
        NSString * listTips = infoDic[@"listTips"];
        if (listTips.length > 0) {
            cellHeight += 20;
            [listTips qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth- kIMChatContentLeft - kIMChatContentRight, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
            cellHeight += 5;
        }
        
        cellHeight += 15;
        
        NSString * type = [infoDic[@"listArea"] objectForKey:@"type"];
        if ([type.lowercaseString isEqualToString:@"list"]) {
            NSArray * items = [infoDic[@"listArea"] objectForKey:@"items"];
            int initSize = [infoDic[@"listArea"][@"style"][@"defSize"] intValue];
            if (initSize <= 0 || initSize >= 10) {
                initSize = items.count;
            }
            NSUInteger maxIndex = items.count;
            NSDictionary * isUnfoldDic = [[QIMMessageCellCache sharedInstance] getObjectForKey:kMessageIsUnfold];
            BOOL isUnfold = NO;
            if (isUnfoldDic) {
                isUnfold = [isUnfoldDic[msg.messageId] boolValue];
            }
            if (isUnfold == NO) {
                maxIndex = MIN(maxIndex, initSize);
            }
            
            if (items && items.count > 0) {
                cellHeight += 15;
                if (items.count > initSize) {
                    cellHeight += 45;
                }
                else{
                    cellHeight += 25;
                }
                NSUInteger index = 0;
                //                for (NSDictionary * item in items) {
                //                    if ([item objectForKey:@"text"]) {
                //                        cellHeight += [[item objectForKey:@"text"] qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth- kIMChatContentLeft - kIMChatContentRight, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
                //                        if (index > initSize) {
                //                            break;
                //                        }
                //                        index ++;
                //                    }
                //                }
                for (int i = 0; i<items.count; i++) {
                    NSDictionary * item = [items objectAtIndex:i];
                    if ([item objectForKey:@"text"]) {
                        if (i > initSize - 1) {
                            break;
                        }
                        cellHeight += [[item objectForKey:@"text"] qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth- kIMChatContentLeft - kIMChatContentRight, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
                    }
                }
                if (maxIndex >= 1) {
                    cellHeight += (10 * (maxIndex - 1));
                }
                //                cellHeight += 25;
            }
        }
        
        NSString * bottom_tips = [infoDic objectForKey:@"bottom_tips"];
        if (bottom_tips && bottom_tips.length > 0) {
            cellHeight += 40;
        }
        
        NSArray * bottom = [infoDic objectForKey:@"bottom"];
        if (bottom && bottom.count > 0) {
            cellHeight += 35;
        }
        
        //hints
        NSArray * hints = [infoDic objectForKey:@"hints"];
        if (hints && [hints isKindOfClass:[NSArray class]] && hints.count) {
            cellHeight += 10;
            QIMTextContainer * container = [[QIMTextContainer alloc] init];
            container.textAlignment = kCTCenterTextAlignment;
            container.lineBreakMode = kCTLineBreakByCharWrapping;
            container.font = [UIFont systemFontOfSize:kHintTextFontSize];
            container.isWidthToFit = YES;
            for (NSDictionary * hintDic in hints) {
                NSString * type = [hintDic[@"event"][@"type"] lowercaseString];
                BOOL isLink = type && ![type isEqualToString:@"text"];
                NSString * text = hintDic[@"text"];
                if (isLink) {
                    [container appendLinkWithText:text linkFont:[UIFont systemFontOfSize:kHintTextFontSize] linkColor:[UIColor blueColor] underLineStyle:kCTUnderlineStyleNone linkData:hintDic];
                } else{
                    [container appendText:text];
                }
            }
            container = [container createTextContainerWithTextWidth:kHintCelMaxWidth];
            cellHeight += [container getHeightWithFramesetter:nil width:container.textWidth] + 20;
            [[QIMMessageCellCache sharedInstance] setObject:container forKey:[msg.messageId stringByAppendingString:@"_hints"]];
        }
    }
    return cellHeight + kIMChatContentTop + kIMChatContentBottom;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithChatType:(ChatType)chatType{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.chatType = chatType;
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        //        self.contentView.backgroundColor = [UIColor qtalkChatBgColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        
        //        self.backView = nil;
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor clearColor];
        //        _bgView.layer.borderColor = [UIColor grayColor];
        //        _bgView.layer.bo
        [self.backView addSubview:_bgView];
        
        _textLabel = [[QIMAttributedLabel alloc] init];
//        _textLabel.characterSpacing
        _textLabel.backgroundColor = [UIColor whiteColor];
        [_bgView addSubview:_textLabel];
        
        _listBGView = [[UIView alloc] init];
        _listBGView.backgroundColor = [UIColor whiteColor];
        _listBGView.layer.cornerRadius = 8.0;
        _listBGView.layer.masksToBounds = YES;
        [_bgView addSubview:_listBGView];
        
        _hintLabel = [[QIMAttributedLabel alloc] init];
        _hintLabel.backgroundColor = [UIColor qim_colorWithHex:0xc1c1c1];
        [_bgView addSubview:_hintLabel];
        
        _resolveBtn = [[UIButton alloc]init];
        [_resolveBtn setBackgroundImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"robotResovlebtnUnSelected"] forState:UIControlStateNormal];
        [_resolveBtn setBackgroundImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"robotResovlebtnSelected"] forState:UIControlStateSelected];
        [_resolveBtn addTarget:self action:@selector(resolveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bgView addSubview:_resolveBtn];
        
        _unResolveBtn = [[UIButton alloc]init];
        [_unResolveBtn setBackgroundImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"robotunResovlebtnUnSelected"] forState:UIControlStateNormal];
        [_unResolveBtn setBackgroundImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"robotunResovelebtnSelected"] forState:UIControlStateSelected];
        [_unResolveBtn addTarget:self action:@selector(unResolveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bgView addSubview:_unResolveBtn];
        
        
        _bottom_tipsLabel = [[UILabel alloc]init];
        _bottom_tipsLabel.textAlignment = NSTextAlignmentLeft;
        _bottom_tipsLabel.textColor = [UIColor qim_colorWithHex:0x999999];
        _bottom_tipsLabel.font = [UIFont systemFontOfSize:14];
        
        [_bgView addSubview:_bottom_tipsLabel];
        
        
        _separateLine = [[UIView alloc]init];
        _separateLine.backgroundColor = [UIColor qim_colorWithHex:0xEAEAEA];
        
        [_bgView addSubview:_separateLine];
        
        _resolveLabel = [[UILabel alloc]init];
        _resolveLabel.textAlignment = NSTextAlignmentLeft;
        _resolveLabel.textColor = [UIColor qim_colorWithHex:0x999999];
        _resolveLabel.font = [UIFont systemFontOfSize:14];
        //        _resolveLabel.text = @"是";
        [_bgView addSubview:_resolveLabel];
        
        _unResolveLabel = [[UILabel alloc]init];
        _unResolveLabel.textAlignment = NSTextAlignmentLeft;
        _unResolveLabel.textColor = [UIColor qim_colorWithHex:0x999999];
        _unResolveLabel.font = [UIFont systemFontOfSize:14];
        //        _unResolveLabel.text =@"否";
        [_bgView addSubview:_unResolveLabel];
    }
    return self;
}

- (void)setMessage:(QIMMessageModel *)message {
    [super setMessage:message];
    _textContainer = nil;
    _textLabel.textContainer = nil;
    //    _hintContainer = [[QIMMessageCellCache sharedInstance] getObjectForKey:[message.messageId stringByAppendingString:@"_hints"]];
    NSString * jsonStr = self.message.extendInformation.length > 0 ? self.message.extendInformation : self.message.message;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
    if (infoDic && infoDic[@"content"]) {
        if ([infoDic[@"content"] length]) {
        }else{
            _textContainer = nil;
            return;
        }
    }
    _textContainer = [QIMMessageParser textContainerForMessageCtnt:infoDic[@"content"] withId:self.message.messageId direction:self.message.messageDirection];
    _textContainer.textAlignment = kCTTextAlignmentLeft;
}

//- (QIMTextContainer *)getTextContainer{
//
////    return _textContainer;
//}

- (void)refreshUI {
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    _textLabel.delegate = self.delegate;
    _textLabel.textContainer = _textContainer;
//    [_textLabel clearOwnerView];
    if (_textContainer) {
        
        [_textLabel setFrameWithOrign:CGPointMake((QIMMessageDirection_Received == self.message.messageDirection) ? 14 :14,15) Width:kHintCelMaxWidth-14-14];
    } else {
        [_textLabel setFrameWithOrign:CGPointMake(0,0) Width:kHintCelMaxWidth];
    }
    NSString *jsonStr = self.message.extendInformation.length > 0 ? self.message.extendInformation : self.message.message;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
    CGFloat maxWidth = kHintCelMaxWidth;
    float backWidth = _textLabel.textContainer.textWidth;
    float height = 0;
    //    if (backWidth > 0 && _textLabel.textContainer.textHeight == 0) {
    //        height = [_textContainer getHeightWithFramesetter:nil width:_textContainer.textWidth];
    //    }
    //    else{
    height = _textLabel.height;
    //    }
    float backHeight = (height>0)?(height+20):0;
    [_listBGView removeAllSubviews];
    _listBGView.hidden = YES;
    float originY = 0 + backHeight;
    float space = 10;
    NSString * listTips = infoDic[@"listTips"];
    if (listTips.length > 0) {
        _listBGView.hidden = NO;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 42)];
        headerView.backgroundColor = [UIColor whiteColor];
        [_listBGView addSubview:headerView];
        float actionBtnHeight = [listTips qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth - kIMChatContentLeft - kIMChatContentRight, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
        UILabel *listTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        listTipsLabel.text = listTips;
        listTipsLabel.font = [UIFont systemFontOfSize:15];//[UIFont boldSystemFontOfSize:15];
        [listTipsLabel setTextColor:[UIColor qim_colorWithHex:0x999999]];
        listTipsLabel.frame = CGRectMake(14,space + originY, maxWidth-14 - kIMChatContentLeft - kIMChatContentRight, actionBtnHeight);
        [_listBGView addSubview:listTipsLabel];
        listTipsLabel.centerY = headerView.centerY;
        
        NSString *iconUrl = [infoDic[@"listArea"] objectForKey:@"icon_url"];
        if (iconUrl.length > 0 && iconUrl) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(headerView.frame) - 70, 5, 48, 48)];
            [iconView qim_setImageWithURL:iconUrl];
            iconView.backgroundColor = [UIColor clearColor];
            [headerView addSubview:iconView];
        }
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(-1, headerView.bottom - 1, maxWidth + 8, 1)];
        view.backgroundColor = [UIColor qim_colorWithHex:0xEAEAEA];
        [headerView addSubview:view];
        originY += (headerView.height + space);
    }
    
    NSString * type = [infoDic[@"listArea"] objectForKey:@"type"];
    if ([type.lowercaseString isEqualToString:@"list"]) {
        
        NSArray * items = [infoDic[@"listArea"] objectForKey:@"items"];
        int initSize = [infoDic[@"listArea"][@"style"][@"defSize"] intValue];
        if (initSize <= 0 || initSize >= 10) {
            initSize = items.count;
        }
        if (items && items.count > 0) {
            NSUInteger maxIndex = items.count;
            NSDictionary * isUnfoldDic = [[QIMMessageCellCache sharedInstance] getObjectForKey:kMessageIsUnfold];
            BOOL isUnfold = NO;
            if (isUnfoldDic) {
                isUnfold = [isUnfoldDic[self.message.messageId] boolValue];
            }
            if (isUnfold == NO) {
                maxIndex = MIN(maxIndex, initSize+1);
            }
            NSUInteger index = 0;
            _listBGView.hidden = NO;
            
            //            for (NSDictionary * item in items) {
            //                if ([item objectForKey:@"text"] ) {
            //                    float actionBtnHeight = [[item objectForKey:@"text"] qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
            //
            //                    UILabel *itemAction = [[UILabel alloc] initWithFrame:CGRectZero];
            //                    [itemAction setTag:kActionsBtnTagFrom + index];
            //                    itemAction.numberOfLines = 0;
            //                    [itemAction setText:[item objectForKey:@"text"]];
            //                    [itemAction setTextColor:[UIColor qim_colorWithHex:0x5CC57F]];
            //                    [itemAction setFont:[UIFont systemFontOfSize:15]];
            //                    itemAction.frame = CGRectMake(27, space + originY, maxWidth - kIMChatContentLeft - kIMChatContentRight - 27, actionBtnHeight);
            //                    itemAction.userInteractionEnabled = YES;
            //                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionsHandle:)];
            //                    [itemAction addGestureRecognizer:tap];
            //
            //                    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(14, itemAction.centerY - 2.5 , 5, 5)];
            //                    view.layer.masksToBounds = YES;
            //                    view.layer.cornerRadius = 2.5;
            //                    view.backgroundColor = [UIColor qim_colorWithHex:0x00CABE];
            //                    [_listBGView addSubview:itemAction];
            //                    [_listBGView addSubview:view];
            //
            //                    originY += (itemAction.height + space) ;
            ////                    CGFloat lineOriginY = space / 2 + itemAction.height - 1;
            ////                    if (index < maxIndex - 1 ) {
            ////                        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, lineOriginY, itemAction.width, 0.5)];
            ////                        line.backgroundColor = [UIColor qim_colorWithHex:0xe7e7e7];
            ////                        [itemAction addSubview:line];
            ////                    }
            //                }
            //                index ++;
            //                if (index > initSize) {
            //                    break;
            //                }
            //
            //            }
            
            for (int i = 0; i<items.count; i++) {
                NSDictionary * item = [items objectAtIndex:i];
                if ([item objectForKey:@"text"] ) {
                    if (i > initSize - 1) {
                        break;
                    }
                    float actionBtnHeight = [[item objectForKey:@"text"] qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
                    
                    UILabel *itemAction = [[UILabel alloc] initWithFrame:CGRectZero];
                    [itemAction setTag:kActionsBtnTagFrom + i];
                    itemAction.numberOfLines = 0;
                    [itemAction setText:[item objectForKey:@"text"]];
                    [itemAction setTextColor:[UIColor qim_colorWithHex:0x333333]];
                    [itemAction setFont:[UIFont systemFontOfSize:15]];
                    itemAction.frame = CGRectMake(27, space + originY - 5, maxWidth - kIMChatContentLeft - kIMChatContentRight - 27, actionBtnHeight);
                    itemAction.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionsHandle:)];
                    [itemAction addGestureRecognizer:tap];
                    
                    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(14, itemAction.centerY - 2.5 , 5, 5)];
                    view.layer.masksToBounds = YES;
                    view.layer.cornerRadius = 2.5;
                    view.backgroundColor = [UIColor qim_colorWithHex:0x00CABE];
                    [_listBGView addSubview:itemAction];
                    [_listBGView addSubview:view];
                    
                    originY += (itemAction.height + space) ;
                    //                    CGFloat lineOriginY = space / 2 + itemAction.height - 1;
                    //                    if (index < maxIndex - 1 ) {
                    //                        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, lineOriginY, itemAction.width, 0.5)];
                    //                        line.backgroundColor = [UIColor qim_colorWithHex:0xe7e7e7];
                    //                        [itemAction addSubview:line];
                    //                    }
                }
                
            }
            
            if (items.count > initSize) {
                float actionBtnHeight = 30;
                UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, originY - 5, maxWidth, 50)];
                //                bottomView.layer.shadowOffset = CGSizeMake(0, -15);
                //                bottomView.layer.shadowOpacity = 0.9;
                bottomView.backgroundColor = [UIColor whiteColor];
                bottomView.layer.shadowColor = [UIColor whiteColor].CGColor;
                
                [_listBGView addSubview:bottomView];
                
                UILabel *itemAction = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 27, 20)];
                [itemAction setTextColor:[UIColor qim_colorWithHex:0x00CABE]];
                [itemAction setText:@"展开"];
                itemAction.adjustsFontSizeToFitWidth = YES;
                [itemAction setFont:[UIFont systemFontOfSize:13]];
                
                [bottomView addSubview:itemAction];
                
                itemAction.centerX = bottomView.centerX - 10;
                UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(itemAction.right, 10, 20, 20)];
                [itemIcon setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3c7" size:20 color:[UIColor colorWithRGBHex:0x00CABE]]]];
                [bottomView addSubview:itemIcon];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionsHandle:)];
                [bottomView addGestureRecognizer:tap];
                originY += (itemAction.height + space);
            }else{
                originY += 5;
            }
        } else {
            //            backWidth = self.contentView.width - 2 * kQCIMMsgCellBoxMargin;
        }
        originY += 3;
        _listBGView.frame = CGRectMake(-0.5, 0, maxWidth + 8, originY - 2.5);
        _listBGView.backgroundColor = [UIColor whiteColor];
        
        //        if (_textContainer) {
        //            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kIMChatContentLeft - 4.5, 0, backWidth - kIMChatContentLeft - kIMChatContentRight, 0.5)];
        //            line.backgroundColor = [UIColor qim_colorWithHex:0xe7e7e7];
        //            [_listBGView addSubview:line];
        //        }
        //        backHeight = _listBGView.bottom;
    }
    
    NSString * bottom_tips = [infoDic objectForKey:@"bottom_tips"];
    
    self.bottom_tipsLabel.hidden = YES;
    self.separateLine.hidden = YES;
    if (bottom_tips && bottom_tips.length > 0) {
        self.separateLine.hidden = NO;
        [self.separateLine setFrame:CGRectMake(-0.5,originY + 5, maxWidth+7, 1)];
        
        self.bottom_tipsLabel.text = bottom_tips;
        self.bottom_tipsLabel.hidden = NO;
        [self.bottom_tipsLabel setFrame:CGRectMake(kIMChatContentLeft, originY + 15, maxWidth - kIMChatContentLeft - kIMChatContentRight, 20)];
        originY += 40;
    }
    
    NSArray * bottomArray = [infoDic objectForKey:@"bottom"];
    
    self.resolveBtn.hidden = YES;
    self.unResolveBtn.hidden = YES;
    self.resolveLabel.hidden = YES;
    self.unResolveLabel.hidden = YES;
    self.resolveLabel.hidden = YES;
    self.unResolveLabel.hidden = YES;
    self.resolveBtn.selected = NO;
    self.unResolveBtn.selected = NO;
    self.resolveBtn.enabled = YES;
    self.unResolveBtn.enabled = YES;
    if (bottomArray && bottomArray.count > 0) {
        self.resolveBtn.hidden = NO;
        self.unResolveBtn.hidden = NO;
        self.resolveLabel.hidden = NO;
        self.unResolveLabel.hidden = NO;
        
        for (int i =0 ; i<bottomArray.count; i++) {
            NSDictionary * bottomBtnDic = bottomArray[i];
            if ([[NSString stringWithFormat:@"%@",bottomBtnDic[@"id"]] isEqualToString:@"1"]) {
                self.resolveLabel.text = bottomBtnDic[@"text"];
                self.yesBtnUrl = bottomBtnDic[@"url"];
            }
            else{
                self.unResolveLabel.text = bottomBtnDic[@"text"];
                self.noBtnUrl = bottomBtnDic[@"url"];
            }
        }
        NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
        if ([def objectForKey:self.message.messageId]) {
            
            NSString * is_worked = [def objectForKey:self.message.messageId];
            if (is_worked.integerValue == 0) {
                self.unResolveBtn.selected = YES;
                self.resolveBtn.enabled = NO;
            }
            else if(is_worked.integerValue == 1){
                self.resolveBtn.selected = YES;
                self.unResolveBtn.enabled = NO;
                
            }
            else{
                
            }
        }
        
        [self.resolveBtn setFrame:CGRectMake(kIMChatContentLeft, originY + 12, 32, 32)];
        [self.resolveLabel setFrame:CGRectMake(self.resolveBtn.right + 5,(self.resolveBtn.height - 20)/2 + self.resolveBtn.top, 40, 20)];
        [self.unResolveBtn setFrame:CGRectMake(self.resolveLabel.right + 30, originY + 12, 32, 32)];
        [self.unResolveLabel setFrame:CGRectMake(self.unResolveBtn.right + 5,(self.unResolveBtn.height - 20)/2 + self.unResolveBtn.top, 40, 20)];
        
        originY +=  50;
    }
    
    
    _bgView.frame = CGRectMake(12.5, 1, kHintCelMaxWidth+4.5, originY + 4);
    
    [self.backView setMessage:self.message];
    [self setBackViewWithWidth:kHintCelMaxWidth + 25 WithHeight:originY + 5];
    [self.backView setFrame:CGRectMake(50, 27, kHintCelMaxWidth + 25,originY + 5 )];
    //    [self setBackViewWithWidth:backWidth WithHeight:backHeight];
    
    //hints
    //    if (_hintContainer) {
    //
    //        _hintLabel.delegate = self;
    //
    //        _hintLabel.textContainer = _hintContainer;
    //
    //        float spaceToSide = ([UIScreen mainScreen].bounds.size.width - kSpaceToSide - _hintLabel.textContainer.textWidth) / 2;
    //
    //        [_hintLabel setFrameWithOrign:CGPointMake(spaceToSide, _bgView.bottom + 10) Width:_hintLabel.textContainer.textWidth];
    //        _hintLabel.hidden = NO;
    //    } else{
    //        [_hintLabel setHidden:YES];
    //    }
    //    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    //    [super refreshUI];
}

- (void)requestHttpWithRequestUrl:(NSString *)urlStr {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QIMKit sharedInstance] sendTPGetRequestWithUrl:urlStr withSuccessCallBack:^(NSData *responseData) {
            
        } withFailedCallBack:^(NSError *error) {
            
        }];
    });
}

- (void)actionsHandle:(UITapGestureRecognizer *)tap {
    //问题列表点击动作
    NSInteger index = -1;
    index = tap.view.tag - kActionsBtnTagFrom;
    NSArray * items = nil;
    NSString *listTip = nil;
    int initSize = 0;
    NSString * jsonStr = self.message.extendInformation.length > 0 ? self.message.extendInformation : self.message.message;
    if (jsonStr.length) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
        NSString * type = [infoDic[@"listArea"] objectForKey:@"type"];
        listTip = [infoDic objectForKey:@"listTips"];
        if ([type.lowercaseString isEqualToString:@"list"]) {
            
            items = [infoDic[@"listArea"] objectForKey:@"items"];
            initSize = [infoDic[@"listArea"][@"style"][@"defSize"] intValue];
            //            initSize = [infoDic[@"listArea"][@"stype"][@"defSize"] intValue];
        }
    }
    BOOL isUnfold = NO;
    NSDictionary * isUnfoldDic = [[QIMMessageCellCache sharedInstance] getObjectForKey:kMessageIsUnfold];
    if (isUnfoldDic) {
        isUnfold = [isUnfoldDic[self.message.messageId] boolValue];
    }
    NSUInteger maxIndex = items.count;
    if (isUnfold == NO) {
        maxIndex = MIN(maxIndex, initSize);
    }
    if (index >= 0 && index < maxIndex) {
        NSDictionary * itemDic = [items objectAtIndex:index];
        NSString * itemText = [itemDic objectForKey:@"text"];
        NSDictionary * eventDic = itemDic[@"event"];
        NSString * clickType = [eventDic objectForKey:@"type"];
        NSString * url = [eventDic objectForKey:@"url"];
        NSString * afterClickSendMsg = [eventDic objectForKey:@"msgText"];
        if ([[clickType lowercaseString] isEqualToString:@"interface"]) {
            if (url.length > 0) {
                [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:url withSuccessCallBack:^(NSData *responseData) {
                    
                } withFailedCallBack:^(NSError *error) {
                    
                }];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(sendQIMChatRobotQusetionListTextMessageForText:isSendToServer:userType:)]) {
                    if (afterClickSendMsg.length) {
//                        [self.delegate sendTextMessageForText:afterClickSendMsg isSendToServer:YES userType:@"cRbt"];
                        [self.delegate sendQIMChatRobotQusetionListTextMessageForText:afterClickSendMsg isSendToServer:YES userType:@"cRbt"];
                    } else{
                       [self.delegate sendQIMChatRobotQusetionListTextMessageForText:afterClickSendMsg isSendToServer:NO userType:@"cRbt"];
                    }
                }
            }
        } else if ([[clickType lowercaseString] isEqualToString:@"forward"]) {
            if (url.length ) {
                [QIMFastEntrance openWebViewForUrl:url showNavBar:YES];
            }
        }
        else if([[clickType lowercaseString] isEqualToString:@"text"]){
            if (self.delegate && [self.delegate respondsToSelector:@selector(sendQIMChatRobotQusetionListTextMessageForText:isSendToServer:userType:)]) {
                if (afterClickSendMsg.length) {
                    [self.delegate sendQIMChatRobotQusetionListTextMessageForText:afterClickSendMsg isSendToServer:YES userType:@"cRbt"];
                } else{
                   [self.delegate sendQIMChatRobotQusetionListTextMessageForText:afterClickSendMsg isSendToServer:NO userType:@"cRbt"];
                }
            }
        }
    } else {
        QIMCustomPopViewController *popVc = [[QIMCustomPopViewController alloc] init];
        popVc.popHeaderTitle = listTip;
        popVc.items = items;
        [QIMCustomPopManager showPopVC:popVc withRootVC:[[UIApplication sharedApplication] visibleViewController]];
    }
    /*
     else if (index == maxIndex){
     //折叠 展开
     NSMutableDictionary * newIsUnfoldDic = [NSMutableDictionary dictionaryWithDictionary:isUnfoldDic];
     [newIsUnfoldDic setObject:@(!isUnfold) forKey:self.message.messageId];
     [[QIMMessageCellCache sharedInstance] setObject:newIsUnfoldDic forKey:kMessageIsUnfold];
     if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRobotQuestionMessageCell:)]) {
     [self.delegate refreshRobotQuestionMessageCell:self];
     }
     }
     */
}

- (void)resolveBtnClicked:(UIButton *)btn{
    
    //    if (btn.selected == NO) {
    //        btn.selected == YES;
    //    }
    //    else{
    //
    //    }
    if (btn.selected == YES) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:_yesBtnUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary * dictFromData = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if (!(dictFromData && dictFromData.count >0)) {
            return ;
        }
        if ([dictFromData objectForKey:@"data"]) {
            NSDictionary * dic = [dictFromData objectForKey:@"data"];
            NSLog(@"%@",self.message.messageId);
            NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
            if ([dic objectForKey:@"is_worked"] && weakSelf.message.messageId) {
                [def setObject:[dic objectForKey:@"is_worked"] forKey:weakSelf.message.messageId];
                [def synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.resolveBtn.selected = YES;
                    weakSelf.unResolveBtn.selected = NO;
                    weakSelf.unResolveBtn.enabled = NO;
                    if (weakSelf.delegate && [weakSelf respondsToSelector:@selector(refreshQIMChatRobotListQuestionMessageCell:)]) {
                        [weakSelf.delegate refreshQIMChatRobotListQuestionMessageCell:self];
                    }
                });
            }
            else{
                NSLog(@"self.message.messageId 为空");
            }
        }
        
        
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)unResolveBtnClicked:(UIButton *)btn{
    if (btn.selected == YES) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:_noBtnUrl withSuccessCallBack:^(NSData *responseData) {
        
        NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:nil];
        if (!(dictFromData && dictFromData.count >0)) {
            return ;
        }
        if ([dictFromData objectForKey:@"data"]) {
            NSDictionary * dic = [dictFromData objectForKey:@"data"];
            NSLog(@"%@",self.message.messageId);
            NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
            if ([dic objectForKey:@"is_worked"] && weakSelf.message.messageId) {
                [def setObject:[dic objectForKey:@"is_worked"] forKey:weakSelf.message.messageId];
                [def synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.resolveBtn.selected = NO;
                    weakSelf.unResolveBtn.selected = YES;
                    weakSelf.resolveBtn.enabled = NO;
                    if (weakSelf.delegate && [weakSelf respondsToSelector:@selector(refreshQIMChatRobotListQuestionMessageCell:)]) {
                        [weakSelf.delegate refreshQIMChatRobotListQuestionMessageCell:self];
                    }
                });
            }
            else{
                NSLog(@"self.message.messageId 为空");
            }
        }
        
        
        
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (NSArray *)showMenuActionTypeList {
    return nil;
}

@end

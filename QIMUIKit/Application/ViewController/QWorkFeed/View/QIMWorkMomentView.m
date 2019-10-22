//
//  QIMWorkMomentView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/29.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentView.h"
#import "QIMWorkMomentImageListView.h"
#import "QIMWorkMomentLinkView.h"
#import "QIMWorkMomentVideoView.h"
#import "QIMWorkMomentLabel.h"
#import "QIMMarginLabel.h"
#import "QIMWorkMomentParser.h"
#import "QIMEmotionManager.h"

CGFloat maxFullContentHeight = 0;

@interface QIMWorkMomentView () <QIMAttributedLabelDelegate, QIMWorkMomentLinkViewTapDelegate, QIMWorkMomentVideoViewTapDelegate> {
    CGFloat _rowHeight;
}

// 头像
@property (nonatomic, strong) UIImageView *headImageView;
// 名称
@property (nonatomic, strong) UILabel *nameLab;
//组织架构Label
@property (nonatomic, strong) QIMMarginLabel *organLab;
//服务器IdLabel
@property (nonatomic, strong) UILabel *rIdLabe;
// 时间
@property (nonatomic, strong) UILabel *timeLab;
// 图片
@property (nonatomic, strong) QIMWorkMomentImageListView *imageListView;

//Link
@property (nonatomic, strong) QIMWorkMomentLinkView *linkView;

//Video
@property (nonatomic, strong) QIMWorkMomentVideoView *videoView;

//正文ContentLabel
@property (nonatomic, strong) QIMWorkMomentLabel *contentLabel;

@property (nonatomic, strong) QIMWorkMomentModel *moment;

@end

@implementation QIMWorkMomentView

- (instancetype)initWithFrame:(CGRect)frame withMomentModel:(QIMWorkMomentModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        _moment = model;
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setMomentModel:(QIMWorkMomentModel *)momentModel {
    _moment = momentModel;
    [self removeAllSubviews];
    [self setupUI];
}

- (void)setupUI {
    // 头像视图
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 43, 43)];
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headImageView.userInteractionEnabled = YES;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = _headImageView.width / 2.0f;
    _headImageView.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    _headImageView.layer.borderColor = [UIColor qim_colorWithHex:0xDFDFDF].CGColor;
    _headImageView.layer.borderWidth = 0.5f;
    [self addSubview:_headImageView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    [_headImageView addGestureRecognizer:tapGesture];
    
    // 名字视图
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right + 8, _headImageView.top, 50, 20)];
    _nameLab.font = [UIFont boldSystemFontOfSize:15.0];
    _nameLab.textColor = [UIColor qim_colorWithHex:0x00CABE];
    _nameLab.backgroundColor = [UIColor clearColor];
    [self addSubview:_nameLab];
    _nameLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *nameTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickName:)];
    [_nameLab addGestureRecognizer:nameTapGesture];
    
    //组织架构视图
    _organLab = [[QIMMarginLabel alloc] init];
    _organLab.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    _organLab.font = [UIFont systemFontOfSize:11];
    _organLab.textColor = [UIColor qim_colorWithHex:0x999999];
    _organLab.textAlignment = NSTextAlignmentCenter;
    _organLab.layer.cornerRadius = 2.0f;
    _organLab.layer.masksToBounds = YES;
    _organLab.textAlignment = NSTextAlignmentCenter;
    [_organLab sizeToFit];
    [self addSubview:_organLab];
    
    _rIdLabe = [[UILabel alloc] init];
    _rIdLabe.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    _rIdLabe.font = [UIFont systemFontOfSize:11];
    _rIdLabe.textColor = [UIColor qim_colorWithHex:0x999999];
    _rIdLabe.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_rIdLabe];
    _rIdLabe.hidden = YES;
    
    // 正文视图
    _contentLabel = [[QIMWorkMomentLabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.linesSpacing = 1.0f;
    _contentLabel.characterSpacing = 0.0f;
    _contentLabel.delegate = self;
    _contentLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    [self addSubview:_contentLabel];

    // 图片区
    _imageListView = [[QIMWorkMomentImageListView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageListView];
    
    //Link区
    _linkView = [[QIMWorkMomentLinkView alloc] initWithFrame:CGRectZero];
    _linkView.hidden = YES;
    [self addSubview:_linkView];
    
    //Video
    _videoView = [[QIMWorkMomentVideoView alloc] initWithFrame:CGRectZero];
    _videoView.hidden = YES;
    [self addSubview:_videoView];
    
    // 时间视图
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = [UIColor qim_colorWithHex:0xADADAD];
    _timeLab.font = [UIFont systemFontOfSize:13.0f];
    [_timeLab sizeToFit];
    [self addSubview:_timeLab];
    
    
    NSString *userId = [NSString stringWithFormat:@"%@@%@", self.moment.ownerId, self.moment.ownerHost];
    if (self.moment.isAnonymous == NO) {
        
        [_headImageView qim_setImageWithJid:userId];
        _nameLab.text = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
        _nameLab.textColor = [UIColor qim_colorWithHex:0x00CABE];
        [_nameLab sizeToFit];
        
        _organLab.frame = CGRectMake(self.nameLab.right + 5, self.nameLab.top, 66, 20);
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
        NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:[NSBundle qim_localizedStringForKey:@"moment_Unknown"];
        NSString *showDp = [[department componentsSeparatedByString:@"/"] objectAtIndex:2];
        if (showDp.length > 0) {
            _organLab.text = showDp ? [NSString stringWithFormat:@"%@", showDp] : @"";
            [_organLab sizeToFit];
            [_organLab sizeThatFits:CGSizeMake(_organLab.width, _organLab.height)];
            _organLab.height = 20;
        } else {
            _organLab.hidden = YES;
        }
        
        _rIdLabe.frame = CGRectMake(self.organLab.right + 5, self.nameLab.top, 20, 20);
        _rIdLabe.text = [NSString stringWithFormat:@"%ld", self.moment.rId];
    } else {
        
        NSString *anonymousPhoto = self.moment.anonymousPhoto;
        NSString *anonymousName = self.moment.anonymousName;
        if (![anonymousPhoto qim_hasPrefixHttpHeader]) {
            anonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], anonymousPhoto];
        }
        [_headImageView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
        _nameLab.text = anonymousName;
        _nameLab.textColor = [UIColor qim_colorWithHex:0x999999];
        [_nameLab sizeToFit];
        
        _organLab.hidden = YES;
        _rIdLabe.frame = CGRectMake(self.nameLab.right + 5, self.nameLab.top, 20, 20);
        _rIdLabe.text = [NSString stringWithFormat:@"%ld", self.moment.rId];
    }
    _nameLab.centerY = self.headImageView.centerY;
    _organLab.centerY = self.headImageView.centerY;
    _rIdLabe.centerY = self.headImageView.centerY;
    CGFloat bottom = self.headImageView.bottom;
    
    QIMWorkFeedContentType contentType = self.moment.content.type;
    NSString *content = self.moment.content.content;
    switch (contentType) {
        case QIMWorkFeedContentTypeText: {
            NSString *exContent = self.moment.content.exContent;
            if (exContent) {
                content = exContent;
            } else {
                
            }
        }
            break;
        case QIMWorkFeedContentTypeImage: {
            
        }
            break;
        case QIMWorkFeedContentTypeLink: {
            NSString *exContent = self.moment.content.exContent;
            if (exContent) {
                content = exContent;
            } else {
                
            }
        }
            break;
        case QIMWorkFeedContentTypeVideo: {
            NSString *exContent = self.moment.content.exContent;
            if (exContent) {
                content = exContent;
            } else {
                
            }
        }
            break;
        default: {
            content = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:self.moment.content.content];
        }
            break;
    }
    
    NSString *texg = content;
//    [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:content];
    QIMMessageModel *msg = [[QIMMessageModel alloc] init];
    msg.message = texg;
    msg.messageId = [NSString stringWithFormat:@"Full-%@", self.moment.momentId];
    
    QIMTextContainer *textContainer = [QIMWorkMomentParser textContainerForMessage:msg fromCache:YES withCellWidth:[[UIScreen mainScreen] qim_rightWidth] - self.nameLab.left - 20 withFontSize:15 withFontColor:[UIColor qim_colorWithHex:0x333333] withNumberOfLines:0];
    CGFloat textH = textContainer.textHeight;
    self.contentLabel.frame = CGRectMake(self.nameLab.left, bottom + 3, [[UIScreen mainScreen] qim_rightWidth] - self.nameLab.left - 20, textContainer.textHeight);
    _contentLabel.textContainer = textContainer;

    bottom = _contentLabel.bottom + 8;

    [self refreshContentUIWithType:contentType withBottom:bottom];
    
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:([self.moment.createTime longLongValue]/1000)];
    _timeLab.text = [timeDate qim_timeIntervalDescription];
    _timeLab.frame = CGRectMake(self.contentLabel.left, (_rowHeight > 0) ? _rowHeight + 15 : bottom + 15, 60, 12);
    
    self.height = _timeLab.bottom + 15;
}

- (void)refreshContentUIWithType:(QIMWorkFeedContentType)type withBottom:(CGFloat)bottom {
    switch (type) {
        case QIMWorkFeedContentTypeText: {
            if (self.moment.content.imgList.count > 0) {
                _imageListView.momentContentModel = self.moment.content;
                _imageListView.origin = CGPointMake(self.nameLab.left, bottom + 5);
                [_imageListView setTapSmallImageView:^(QIMWorkMomentContentModel * _Nonnull momentContentModel, NSInteger currentTag) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSmallImage:WithCurrentTag:)]) {
                        [self.delegate didClickSmallImage:self.moment WithCurrentTag:currentTag];
                    }
                }];
                _rowHeight = _imageListView.bottom;
            } else {
                
            }
            self.contentLabel.originContent = self.moment.content.content;
        }
            break;
        case QIMWorkFeedContentTypeImage: {
            if (self.moment.content.imgList.count > 0) {
                _imageListView.momentContentModel = self.moment.content;
                _imageListView.origin = CGPointMake(self.nameLab.left, bottom + 5);
                [_imageListView setTapSmallImageView:^(QIMWorkMomentContentModel * _Nonnull momentContentModel, NSInteger currentTag) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSmallImage:WithCurrentTag:)]) {
                        [self.delegate didClickSmallImage:self.moment WithCurrentTag:currentTag];
                    }
                }];
                _rowHeight = _imageListView.bottom;
            } else {
                
            }
            self.contentLabel.originContent = self.moment.content.content;
        }
            break;
        case QIMWorkFeedContentTypeLink: {
            if (self.moment.content.linkContent) {
                _linkView.hidden = NO;
                _linkView.frame = CGRectMake(self.nameLab.left, bottom + 15, [[UIScreen mainScreen] qim_rightWidth] - self.nameLab.left - 15, 66);
                _linkView.delegate = self;
                _linkView.linkModel = self.moment.content.linkContent;
                _rowHeight = _linkView.bottom;
            }
            self.contentLabel.originContent = self.moment.content.exContent;
        }
            break;
        case QIMWorkFeedContentTypeVideo: {
            if (self.moment.content.videoContent) {
                _videoView.hidden = NO;
                _videoView.frame = CGRectMake(self.nameLab.left, bottom + 15, 144, 144);
                _videoView.delegate = self;
                _videoView.videoModel = self.moment.content.videoContent;
                _rowHeight = _videoView.bottom;
            }
            self.contentLabel.originContent = self.moment.content.exContent;
        }
            break;
        default: {
            if (self.moment.content.imgList.count > 0) {
                _imageListView.momentContentModel = self.moment.content;
                _imageListView.origin = CGPointMake(self.nameLab.left, bottom + 5);
                [_imageListView setTapSmallImageView:^(QIMWorkMomentContentModel * _Nonnull momentContentModel, NSInteger currentTag) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSmallImage:WithCurrentTag:)]) {
                        [self.delegate didClickSmallImage:self.moment WithCurrentTag:currentTag];
                    }
                }];
                _rowHeight = _imageListView.bottom;
            } else {
                
            }
            self.contentLabel.originContent = self.moment.content.content;
        }
            break;
    }
}

// 点击头像
- (void)clickHead:(UITapGestureRecognizer *)gesture {
    if (self.moment.isAnonymous == NO) {
        NSString *userId = [NSString stringWithFormat:@"%@@%@", self.moment.ownerId, self.moment.ownerHost];
        [QIMFastEntrance openUserCardVCByUserId:userId];
    }
}

- (void)clickName:(UITapGestureRecognizer *)tapGesture {
    if (self.moment.isAnonymous == NO) {
        NSString *userId = [NSString stringWithFormat:@"%@@%@", self.moment.ownerId, self.moment.ownerHost];
        [QIMFastEntrance openUserCardVCByUserId:userId];
    }
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

#pragma mark - QIMWorkMomentLinkViewTapDelegate

- (void)didTapWorkMomentShareLinkUrl:(QIMWorkMomentContentLinkModel *)linkModel {
    if (linkModel.linkurl.length > 0) {
        [QIMFastEntrance openWebViewForUrl:linkModel.linkurl showNavBar:linkModel.showbar];
    }
}

#pragma mark - QIM

- (void)didTapWorkMomentVideo:(QIMVideoModel *)videoModel {
    if (videoModel) {
        [QIMFastEntrance openVideoPlayerForVideoModel:videoModel];
    }
//    [QIMFastEntrance openVideoPlayerForUrl:videoModel.FileUrl LocalOutPath:videoModel.LocalVideoOutPath CoverImageUrl:videoModel.ThumbUrl];
}

@end

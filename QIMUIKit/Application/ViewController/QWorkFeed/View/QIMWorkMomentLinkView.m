//
//  QIMWorkMomentLinkView.m
//  QIMUIKit
//
//  Created by lilu on 2019/5/19.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentLinkView.h"
#import "QIMWorkMomentContentLinkModel.h"

@interface QIMWorkMomentLinkView ()

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation QIMWorkMomentLinkView

#pragma mark - setter and getter

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 44, 44)];
        _imgView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"workmoment_link_icon"];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imgView.right + 9, 14, self.width - 66, 40)];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (void)setLinkModel:(QIMWorkMomentContentLinkModel *)linkModel {
    _linkModel = linkModel;
    [self.imgView qim_setImageWithURL:[NSURL URLWithString:linkModel.img] placeholderImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"workmoment_link_icon"]];
    self.titleLabel.frame = CGRectMake(self.imgView.right + 9, 14, self.width - 66, 40);
    self.titleLabel.text = linkModel.title;
}

#pragma mark - initUI

- (void)initUI {
    [self addSubview:self.imgView];
    [self addSubview:self.titleLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWorkMomentShareLinkUrl)];
    [self addGestureRecognizer:tap];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
        [self initUI];
    }
    return self;
}

- (void)tapWorkMomentShareLinkUrl {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapWorkMomentShareLinkUrl:)]) {
        [self.delegate didTapWorkMomentShareLinkUrl:self.linkModel];
    }
}

@end

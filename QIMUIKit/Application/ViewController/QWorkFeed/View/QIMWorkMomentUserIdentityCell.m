//
//  QIMWorkMomentUserIdentityCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/11.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentUserIdentityCell.h"
#import "QIMWorkMomentUserIdentityModel.h"

@interface QIMWorkMomentUserIdentityCell ()

@property (nonatomic, strong) UIButton *replaceBtn;

@property (nonatomic, strong) UILabel *canNotReplaceLabel;

@end

@implementation QIMWorkMomentUserIdentityCell

- (UIButton *)replaceBtn {
    if (!_replaceBtn) {
        _replaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replaceBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_replaceBtn setTitleColor:[UIColor qim_colorWithHex:0xBFBFBF] forState:UIControlStateDisabled];
        [_replaceBtn setTitle:@"换一换" forState:UIControlStateNormal];
        [_replaceBtn setTitle:@"换一换" forState:UIControlStateDisabled];
        [_replaceBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_replaceBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3d3" size:13 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateNormal];
        [_replaceBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3d3" size:13 color:[UIColor qim_colorWithHex:0xBFBFBF]]] forState:UIControlStateDisabled];
        [_replaceBtn addTarget:self action:@selector(replaceAnony:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replaceBtn;
}

- (UILabel *)canNotReplaceLabel {
    if (!_canNotReplaceLabel) {
        _canNotReplaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _canNotReplaceLabel.text = @"花名已确定，不可更改";
        _canNotReplaceLabel.font = [UIFont systemFontOfSize:13];
        _canNotReplaceLabel.textAlignment = NSTextAlignmentRight;
        _canNotReplaceLabel.textColor = [UIColor qim_colorWithHex:0xBFBFBF];
    }
    return _canNotReplaceLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.layer.cornerRadius = 10.0f;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setUserIdentitySelected:(BOOL)selected {
    _userIdentitySelected = selected;
    if (selected == YES) {
        [self.imageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0x00CABE]]]];
    } else {
        [self.imageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0xE4E4E4]]]];
    }
}

- (void)setUserIdentityReplaceable:(BOOL)replaceable {
    if (replaceable == YES) {
        self.replaceBtn.frame = CGRectMake(SCREEN_WIDTH - 90, self.contentView.bottom - 40, 90, 40);
        [self.contentView addSubview:self.replaceBtn];
        self.replaceBtn.hidden = NO;
        self.replaceBtn.enabled = YES;
    } else {
        _replaceBtn.hidden = YES;
        self.canNotReplaceLabel.frame = CGRectMake(SCREEN_WIDTH - 175, self.contentView.bottom - 30, 160, 15);
        [self.contentView addSubview:self.canNotReplaceLabel];
    }
}

- (void)replaceAnony:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(replaceWorkMomentUserIdentity)]) {
        [self.delegate replaceWorkMomentUserIdentity];
    }
}

@end

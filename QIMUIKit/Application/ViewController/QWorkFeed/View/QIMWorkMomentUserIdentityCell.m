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

@end

@implementation QIMWorkMomentUserIdentityCell

- (UIButton *)replaceBtn {
    if (!_replaceBtn) {
        _replaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replaceBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_replaceBtn setTitleColor:[UIColor qim_colorWithHex:0xBFBFBF] forState:UIControlStateDisabled];
        [_replaceBtn setTitle:@"换一换" forState:UIControlStateNormal];
        [_replaceBtn setTitle:@"换一换" forState:UIControlStateDisabled];
        [_replaceBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateNormal];
        [_replaceBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0xBFBFBF]]] forState:UIControlStateDisabled];
        [_replaceBtn addTarget:self action:@selector(replaceAnony:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replaceBtn;
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
        self.replaceBtn.frame = CGRectMake(SCREEN_WIDTH - 100, 30, 80, 30);
        [self.contentView addSubview:self.replaceBtn];
        self.replaceBtn.enabled = YES;
        /*
        if (self.userIdentitySelected) {
            self.replaceBtn.enabled = YES;
        } else {
            self.replaceBtn.enabled = NO;
        }*/
    } else {
        
    }
}

- (void)replaceAnony:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(replaceWorkMomentUserIdentity)]) {
        [self.delegate replaceWorkMomentUserIdentity];
    }
}

@end

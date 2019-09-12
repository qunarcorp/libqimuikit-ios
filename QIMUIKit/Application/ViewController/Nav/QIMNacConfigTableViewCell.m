//
//  QIMNacConfigTableViewCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/3/26.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMNacConfigTableViewCell.h"

@interface QIMNacConfigTableViewCell ()

@property (nonatomic, strong) UIView *navBgView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *checkButton;

@property (nonatomic, strong) UILabel *navLabel;

@property (nonatomic, strong) UIButton *qrcodeBtn;

@property (nonatomic, strong) UIButton *modifyBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation QIMNacConfigTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - setter and getter

- (UIView *)navBgView {
    if (!_navBgView) {
        _navBgView = [UIView new];
        _navBgView.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    }
    return _navBgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor qim_colorWithHex:0x9B9B9B];
    }
    return _titleLabel;
}

- (UILabel *)navLabel {
    if (!_navLabel) {
        _navLabel = [UILabel new];
        _navLabel.font = [UIFont systemFontOfSize:12];
        _navLabel.numberOfLines = 0;
        _navLabel.textColor = [UIColor qim_colorWithHex:0x9B9B9B];
    }
    return _navLabel;
}

- (UIButton *)checkButton {
    if (!_checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:28 color:[UIColor qim_colorWithHex:0xE4E4E4]]] forState:UIControlStateNormal];
        [_checkButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:28 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
        [_checkButton addTarget:self action:@selector(selectNav:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (UIButton *)qrcodeBtn {
    if (!_qrcodeBtn) {
        _qrcodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_qrcodeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f10d" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
        [_qrcodeBtn addTarget:self action:@selector(showNavQRCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrcodeBtn;
}

- (UIButton *)modifyBtn {
    if (!_modifyBtn) {
        _modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modifyBtn setTitle:[NSBundle qim_localizedStringForKey:@"nav_change_Navigation"] forState:UIControlStateNormal];
        [_modifyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_modifyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        _modifyBtn.layer.borderWidth = 1.0f;
        _modifyBtn.layer.borderColor = [UIColor qim_colorWithHex:0xD9D9D9].CGColor;
        [_modifyBtn addTarget:self action:@selector(modifyNav:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modifyBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:[NSBundle qim_localizedStringForKey:@"nav_delete_Navigation"] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        _deleteBtn.layer.borderWidth = 1.0f;
        _deleteBtn.layer.borderColor = [UIColor qim_colorWithHex:0xD9D9D9].CGColor;
        [_deleteBtn addTarget:self action:@selector(deleteNav:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI { 
    
    [self.contentView addSubview:self.navBgView];
    [self.navBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(20);
        make.left.mas_offset(16);
        make.right.mas_offset(-16);
        make.height.mas_equalTo(110);
    }];
    
    [self.navBgView addSubview:self.checkButton];
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(12);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(28);
        make.right.mas_equalTo(self.navBgView.mas_right).mas_offset(-12);
    }];
    
    [self.navBgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(12);
        make.left.mas_offset(8);
        make.right.mas_equalTo(self.checkButton.mas_left).mas_offset(-10);
        make.height.mas_equalTo(20);
     }];
    [self.titleLabel sizeToFit];
    
    [self.navBgView addSubview:self.navLabel];
    [self.navLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(8);
        make.left.mas_offset(8);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self.checkButton.mas_left).mas_offset(-10);
    }];
    [self.navLabel sizeToFit];
    
    [self.navBgView addSubview:self.deleteBtn];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.navBgView.mas_bottom).mas_offset(-10);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(28);
        make.right.mas_equalTo(self.navBgView.mas_right).mas_offset(-16);
    }];
    [self.navBgView addSubview:self.modifyBtn];
    [self.modifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.navBgView.mas_bottom).mas_offset(-10);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(28);
        make.right.mas_equalTo(self.deleteBtn.mas_left).mas_offset(-10);
    }];
    [self.navBgView addSubview:self.qrcodeBtn];
    [self.qrcodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(13);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.modifyBtn.mas_centerY);
    }];
}

- (void)setUpUINormal {
    [self.navBgView setBackgroundColor:[UIColor qim_colorWithHex:0xF3F3F3]];
    [self.titleLabel setTextColor:[UIColor qim_colorWithHex:0x9B9B9B]];
    [self.navLabel setTextColor:[UIColor qim_colorWithHex:0x9B9B9B]];
    [self.qrcodeBtn setSelected:YES];
    [self.checkButton setSelected:NO];
    self.modifyBtn.layer.borderColor = [UIColor qim_colorWithHex:0xD9D9D9].CGColor;
    self.deleteBtn.layer.borderColor = [UIColor qim_colorWithHex:0xD9D9D9].CGColor;
}

- (void)setUpUISelected {
    [self.navBgView setBackgroundColor:[UIColor qim_colorWithHex:0xDFF9F4]];
    [self.titleLabel setTextColor:[UIColor qim_colorWithHex:0x333333]];
    [self.navLabel setTextColor:[UIColor qim_colorWithHex:0x333333]];
    [self.qrcodeBtn setSelected:YES];
    [self.checkButton setSelected:YES];
    self.modifyBtn.layer.borderColor = [UIColor qim_colorWithHex:0x939393].CGColor;
    self.deleteBtn.layer.borderColor = [UIColor qim_colorWithHex:0x939393].CGColor;
}

- (void)selectNav:(id)sender {
    UIButton *btn = (UIButton *)sender;
    self.checkButton.selected = !btn.selected;
    BOOL selected = self.checkButton.selected;
    if (selected == YES) {
        [self setUpUISelected];
    } else {
        [self setUpUINormal];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectNavWithNavCell:)]) {
        [self.delegate selectNavWithNavCell:self];
    }
}

- (void)showNavQRCode:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showNavQRWithNavCell:)]) {
        [self.delegate showNavQRWithNavCell:self];
    }
}


- (void)deleteNav:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteNavWithNavCell:)]) {
        [self.delegate deleteNavWithNavCell:self];
    }
}

- (void)modifyNav:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyNavWithNavCell:)]) {
        [self.delegate modifyNavWithNavCell:self];
    }
}

- (void)setNavInfo:(NSDictionary *)navInfo {
    _navInfo = navInfo;
    NSString *navName = [navInfo objectForKey:QIMNavNameKey];
    NSString *navUrl = [navInfo objectForKey:QIMNavUrlKey];
    self.titleLabel.text = navName;
    self.navLabel.text = navUrl;
}

@end

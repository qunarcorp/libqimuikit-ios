//
//  QIMWorkFeedAtUserTableViewCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/4/29.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkFeedAtUserTableViewCell.h"

@interface QIMWorkFeedAtUserTableViewCell ()

@property (nonatomic, strong) UIImageView *headerView;  //用户头像View

@property (nonatomic, strong) UILabel *nameLabel;       //用户昵称Label

@property (nonatomic, strong) UILabel *departmentLabel; //用户组织架构Label

@property (nonatomic, strong) UILabel *promotLabel;     //提醒该用户已经选择

@end

@implementation QIMWorkFeedAtUserTableViewCell

+ (CGFloat)getCellHeight {
    return 51.0f;
}

#pragma mark - setter and getter

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 8, 36, 36)];
        _headerView.layer.cornerRadius = 18;
        _headerView.layer.masksToBounds = YES;
        _headerView.layer.borderWidth = 1.0f;
        _headerView.layer.borderColor = [UIColor qim_colorWithHex:0xE1E1E1].CGColor;
    }
    return _headerView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerView.right + 8, 5, 150, 18)];
        _nameLabel.textColor = [UIColor qim_colorWithHex:0x333333];
        _nameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _nameLabel;
}

- (UILabel *)departmentLabel {
    if (!_departmentLabel) {
        _departmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerView.right + 8, self.nameLabel.bottom + 5, self.width - self.headerView.right, 18)];
        _departmentLabel.textColor = [UIColor qim_colorWithHex:0x333333];
        _departmentLabel.font = [UIFont systemFontOfSize:12];
    }
    return _departmentLabel;
}

- (UILabel *)promotLabel {
    if (!_promotLabel) {
        _promotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _promotLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headerView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.departmentLabel];
    }
    return self;
}

- (void)setUserSelected:(BOOL)selected {
    _userSelected = selected;
    if (selected == YES) {
        [self.imageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0x00CABE]]]];
    } else {
        [self.imageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0xE4E4E4]]]];
    }
}

- (void)refreshUI {
    [self.headerView qim_setImageWithJid:self.userXmppId];
    [self.nameLabel setText:self.userName];
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.userXmppId];
    NSString *userDep = [userInfo objectForKey:@""];
    [self.departmentLabel setText:userDep];
}

@end

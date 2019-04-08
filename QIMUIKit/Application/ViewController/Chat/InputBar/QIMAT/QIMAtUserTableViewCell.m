//
//  QIMAtUserTableViewCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/4/8.
//

#import "QIMAtUserTableViewCell.h"

@interface QIMAtUserTableViewCell ()

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) UILabel *nameLabel;

@end

static NSDateFormatter  *__global_dateformatter;
#define NAME_LABEL_FONT     (FONT_SIZE - 1)  //名字字体
#define CONTENT_LABEL_FONT  (FONT_SIZE - 4)  //新消息字体,时间字体
#define COLOR_TIME_LABEL [UIColor blueColor] //时间颜色;

@implementation QIMAtUserTableViewCell

+ (CGFloat)getCellHeight{
    return 60;
}

#pragma mark - setter and getter

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        _headerView.layer.masksToBounds = YES;
        _headerView.layer.cornerRadius = 5.0f;
    }
    return _headerView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, [[UIScreen mainScreen] qim_rightWidth] - 70, 20)];
        [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:NAME_LABEL_FONT]];
        [_nameLabel setTextColor:[UIColor spectralColorBlueColor]];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
    }
    return _nameLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headerView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)refreshUI {
    [self.headerView qim_setImageWithJid:self.jid];
    [self.nameLabel setText:self.name];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  QIMArrowCellTableViewCell.m
//  QY+
//
//  Created by 吕中威 on 16/9/18.
//  Copyright © 2016年 Rich. All rights reserved.
//

#import "QIMArrowCellTableViewCell.h"

@interface QIMArrowCellTableViewCell ()

@end

@implementation QIMArrowCellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 6, 28, 28)];
        self.iconView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconView.frame) + 8, 10, self.contentView.bounds.size.width - CGRectGetMaxX(self.iconView.frame) - 16, 20)];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

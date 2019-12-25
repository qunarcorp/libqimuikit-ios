//
//  QIMWorkMomentHotTopicTableViewCell.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import "QIMWorkMomentHotTopicTableViewCell.h"
#import "QIMWorkMomentTagModel.h"
#import "QIMImageUtil.h"
#import "UIImage+QIMIconFont.h"
@interface QIMWorkMomentHotTopicTableViewCell()

@property (nonatomic,strong) UILabel * numberLabel;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * commitLabel;
@property (nonatomic,strong) UILabel * likeLabel;
@property (nonatomic,strong) UIImageView * myImageView;
@property (nonatomic, assign) BOOL showImgs;


@end
@implementation QIMWorkMomentHotTopicTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews{
    
    self.backgroundColor = [UIColor whiteColor];
//    self.numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
//    self.numberLabel.textAlignment = NSTextAlignmentCenter;
//    self.numberLabel.font = [UIFont systemFontOfSize:19];
//
//    [self addSubview:self.numberLabel];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 11.5, SCREEN_WIDTH - 20-105, 45)];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.titleLabel];
    
    self.commitLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.x, self.titleLabel.bottom + 14, 50, 14)];
    self.commitLabel.textColor = [UIColor colorWithRGBHex:0x999999];
    self.commitLabel.textAlignment = NSTextAlignmentLeft;
    self.commitLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.commitLabel];
    
    self.likeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.commitLabel.right + 15, self.commitLabel.y, 60, 14)];
    self.likeLabel.textColor = [UIColor colorWithRGBHex:0x999999];
    self.likeLabel.textAlignment = NSTextAlignmentLeft;
    self.likeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.likeLabel];
    
    self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 90, self.titleLabel.y, 75, 75)];
    [self addSubview:self.myImageView];
}

- (void)reLayoutViews{
    [self.commitLabel sizeToFit];
    [self.likeLabel sizeToFit];
    if (self.myImageView.hidden == YES) {
        [self.titleLabel setFrame:CGRectMake(self.titleLabel.x, self.titleLabel.y, SCREEN_WIDTH - 40, 44)];
    }
    else{
         [self.titleLabel setFrame:CGRectMake(self.titleLabel.x, self.titleLabel.y, SCREEN_WIDTH - 20 - 105 , 44)];
    }
    [self.commitLabel setFrame:CGRectMake(self.commitLabel.x, self.commitLabel.y, self.commitLabel.width, self.commitLabel.height)];
    [self.likeLabel setFrame:CGRectMake(self.commitLabel.right + 15, self.commitLabel.y, self.likeLabel.width, self.likeLabel.height)];
}

-(void)setHotTopicModel:(QIMWorkMomentHotTopicModel *)model{
    self.numberLabel.text = [NSString stringWithFormat:@"%zd",model.hotPostId.integerValue];
    self.titleLabel.text = model.showTitle;
    self.commitLabel.text = [NSString stringWithFormat:@"评论%zd",model.commentNum.integerValue];
    self.likeLabel.text = [NSString stringWithFormat:@"点赞%zd",model.likeNum.integerValue];
    if (model.headImg && model.headImg.length > 0) {
        [self.myImageView qim_setImageWithURL:[NSURL URLWithString:model.headImg]];
    }
    else{
        self.myImageView.hidden = YES;
    }
    [self reLayoutViews];
    model.height = self.likeLabel.bottom + 13;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

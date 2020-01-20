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
    self.numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 12.5, 25, 25)];
    self.numberLabel.textAlignment = NSTextAlignmentLeft;
//    originLeft = self.numberLabel.right + 6;
    [self addSubview:self.numberLabel];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 12.5, SCREEN_WIDTH - 20 - 105, 45)];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
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

- (void)reLayoutViewsWithModel:(QIMWorkMomentHotTopicModel *)model{
    
    CGFloat originLeft = 20;
    if (model.showNumber) {
        self.numberLabel.hidden = NO;
        [self.numberLabel setFrame:CGRectMake(10, 12.5, 25, 25)];
        self.numberLabel.textAlignment = NSTextAlignmentLeft;
        self.numberLabel.font = [UIFont systemFontOfSize:19 weight:2];
        originLeft = self.numberLabel.right + 6;
    }
    else{
        self.numberLabel.hidden = YES;
    }
    
    [self.commitLabel sizeToFit];
    [self.likeLabel sizeToFit];
    if (model.showImg == NO) {
        [self.titleLabel setFrame:CGRectMake(originLeft, self.titleLabel.y, SCREEN_WIDTH - 20 - originLeft, self.titleLabel.height)];
        [self.titleLabel sizeToFit];
        if (_titleLabel.height <= 46/2) {
             [self.titleLabel setFrame:CGRectMake(originLeft, self.titleLabel.y, SCREEN_WIDTH - 20 - originLeft, self.titleLabel.height)];
        }
        else{
             [self.titleLabel setFrame:CGRectMake(originLeft, self.titleLabel.y, SCREEN_WIDTH - 20 - originLeft, 44)];
        }
        [self.commitLabel setFrame:CGRectMake(originLeft, self.titleLabel.bottom + 14, self.commitLabel.width, self.commitLabel.height)];
        [self.likeLabel setFrame:CGRectMake(self.commitLabel.right + 15, self.commitLabel.y, self.likeLabel.width, self.likeLabel.height)];
        self.myImageView.hidden = YES;
    }
    else{
        [self.titleLabel sizeToFit];
        [self.titleLabel setFrame:CGRectMake(originLeft, self.titleLabel.y, SCREEN_WIDTH - originLeft - 105 , self.titleLabel.height>44?44:self.titleLabel.height)];
        
        [self.commitLabel setFrame:CGRectMake(originLeft, 95 - 27, self.commitLabel.width, self.commitLabel.height)];
        [self.likeLabel setFrame:CGRectMake(self.commitLabel.right + 15, self.commitLabel.y, self.likeLabel.width, self.likeLabel.height)];
        self.myImageView.hidden = NO;
    }
    
}

-(void)setHotTopicModel:(QIMWorkMomentHotTopicModel *)model{
    
    if (model.showNumber) {
        self.numberLabel.text = [NSString stringWithFormat:@"%zd",model.headerNub.integerValue];
    }
    else{
        self.numberLabel.text = @"";
    }
    NSArray * color = @[@"#D54A45",@"#E98730",@"#F5B64F",@"#B3B3B3",@"#B3B3B3"];
    self.numberLabel.textColor = [UIColor qim_colorWithHexString:[color[model.headerNub.intValue - 1] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    self.titleLabel.text = model.showTitle;
    self.commitLabel.text = [NSString stringWithFormat:@"评论%zd",model.commentNum.integerValue];
    self.likeLabel.text = [NSString stringWithFormat:@"点赞%zd",model.likeNum.integerValue];
    if (model.headImg && model.headImg.length > 0) {
        [self.myImageView qim_setImageWithURL:[NSURL URLWithString:model.headImg]];
    }
    [self reLayoutViewsWithModel:model];
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

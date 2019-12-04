//
//  QIMWorkMomentTagView.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/18.
//

#import "QIMWorkMomentTagView.h"
#import "QIMWorkMomentTagModel.h"
@interface QIMWorkMomentTagView()
@property (nonatomic , strong) UIView * tagBGView;
@property (nonatomic , strong) UIImageView * leftImageView;
@property (nonatomic , strong) UILabel * titleLabel;
@property (nonatomic , strong) UIImageView * closeBtn;
@property (nonatomic , assign) BOOL selected;
@end

@implementation QIMWorkMomentTagView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selected = NO;
        [self initViews];
    }
    return self;
}

- (void)initViews{
    self.tagBGView = [[UIView alloc]init];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagTaped)];
    [self.tagBGView addGestureRecognizer:tap];
    
    self.tagBGView.layer.cornerRadius = 27/2.f;
    self.tagBGView.layer.masksToBounds = YES;
    self.leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5.5, (self.height - 15)/2, 15, 15)];
    
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    
    self.closeBtn = [[UIImageView alloc]init];
    
    
    [self.tagBGView addSubview:self.leftImageView];
    [self.tagBGView addSubview:self.titleLabel];
    [self.tagBGView addSubview:self.closeBtn];
    [self addSubview:self.tagBGView];
}

- (void)tagTaped{
    if (self.selected == NO) {
        self.model.selected = YES;
        self.selected =YES;
        [self selectStatus];
        if (self.addTagBlock) {
            self.addTagBlock(self.model);
        }
        return;
    }
    else
    {
        self.model.selected = NO;
        self.selected =NO;
        [self normalStatus];
        if (self.removeBlock) {
            self.removeBlock(self.model);
        }
        return;
    }
}

-(void)setModel:(QIMWorkMomentTagModel *)model
{
    if (model) {
        _model = model;
    }
    [self normalStatus];
    [self refreshView];
}

- (void)refreshView{
    self.titleLabel.text = self.model.tagTitle;
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(self.leftImageView.right + 8, 0, self.titleLabel.width, 27)];
    [self.tagBGView setFrame:CGRectMake(0, 0,5.5+self.leftImageView.width + 8 + self.titleLabel.width +15, 27)];
    self.frame = self.tagBGView.frame;
}

- (void)normalStatus{
    self.tagBGView.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
    self.titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
}

- (void)selectStatus{
    self.tagBGView.backgroundColor = [UIColor qim_colorWithHex:0x54C993];
    self.titleLabel.textColor = [UIColor qim_colorWithHex:0xFFFFFF];
}

-(void)resetTagViewStatus{
    self.model.selected = NO;
    self.selected = NO;
    [self normalStatus];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

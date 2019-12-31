//
//  QIMWorkMomentTagView.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/18.
//

#import "QIMWorkMomentTagView.h"
#import "QIMWorkMomentTagModel.h"
#import "QIMImageUtil.h"
#import "UIImage+QIMIconFont.h"
@interface QIMWorkMomentTagView()
@property (nonatomic , strong) UIView * tagBGView;
@property (nonatomic , strong) UIImageView * leftImageView;
@property (nonatomic , strong) UILabel * titleLabel;
@property (nonatomic , strong) UIButton * closeBtn;
@property (nonatomic , assign) CGFloat viewHeight;
@end

@implementation QIMWorkMomentTagView

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.selected = NO;
        self.canChangeColor = YES;
        [self initViews];
    }
    return self;
}
-(instancetype)initWitHeight:(CGFloat)height{
    self.viewHeight = height;
    return [self init];
}

- (void)initViews{
    self.tagBGView = [[UIView alloc]init];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagTaped)];
    [self.tagBGView addGestureRecognizer:tap];
    
    self.tagBGView.layer.cornerRadius = self.viewHeight/2.f;
    self.tagBGView.layer.masksToBounds = YES;
    
    self.leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5.5, (self.viewHeight - 15)/2, 15, 15)];
    [self.leftImageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_tag_jinghao size:15 color:[UIColor qim_colorWithHexString:self.model.tagColor.length >0 ? [self.model.tagColor stringByReplacingOccurrencesOfString:@"#" withString:@""]:@""]]]];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.tagBGView addSubview:self.leftImageView];
    [self.tagBGView addSubview:self.titleLabel];
    [self addSubview:self.tagBGView];
}

- (void)addCanDeleteBtnWithWidth:(CGRect)backViewRect{
    UILabel * line = [[UILabel alloc]initWithFrame:CGRectMake(backViewRect.size.width - 28.5, 0, 0.5, self.viewHeight)];
    line.backgroundColor = [UIColor qim_colorWithHex:0xDADADA];
    
    self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(backViewRect.size.width - 29, 0, 29, self.viewHeight)];
    [self.closeBtn addTarget:self action:@selector(deleteTagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * closeBtnView = [[UIImageView alloc]init];
    [closeBtnView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_tag_delete size:8.5 color:[UIColor qim_colorWithHex:0xCE5F5F]]]];
    
    [closeBtnView setFrame:CGRectMake(9, (self.viewHeight - 8.5)/2, 8.5, 8.5)];
    [self.closeBtn addSubview:closeBtnView];
    
    [self.tagBGView addSubview:line];
    [self.tagBGView addSubview:self.closeBtn];
    
    
}

- (void)deleteTagBtnClick:(id)btn{
    if (self.closeBlock) {
        self.closeBlock(self.model);
    }
}

- (void)tagTaped{
    if (!self.canChangeColor || self.closeBtn) {
        if (self.tagDidClickedBlock) {
            self.tagDidClickedBlock(self.model);
        }
        return;
    }
    if (self.model.selected == NO) {
        self.model.selected =YES;
        [self selectStatus];
        if (self.addTagBlock) {
            self.addTagBlock(self.model);
        }
        return;
    }
    else
    {
        self.model.selected =NO;
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
    if (model.selected == YES) {
        [self selectStatus];
    }
    else{
        [self normalStatus];
    }
    [self refreshView];
}


- (void)refreshView{
    if (self.textSize && self.textSize > 0) {
        self.titleLabel.font = [UIFont systemFontOfSize:self.textSize];
    }
    if (self.textBGColor) {
        self.titleLabel.textColor = self.textBGColor;
    }
    [self.leftImageView setFrame:CGRectMake(5.5, (self.viewHeight - 15)/2, 15, 15)];
    self.titleLabel.text = self.model.tagTitle;
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(self.leftImageView.right + 8, 0, self.titleLabel.width, self.viewHeight)];
    if (self.canDelete) {
        [self.tagBGView setFrame:CGRectMake(0, 0,5.5+self.leftImageView.width + 8 + self.titleLabel.width +12 + 29,self.viewHeight)];
        [self addCanDeleteBtnWithWidth:self.tagBGView.frame];
    }
    else{
        [self.tagBGView setFrame:CGRectMake(0, 0,5.5+self.leftImageView.width + 8 + self.titleLabel.width +15, self.viewHeight)];
    }
    self.frame = self.tagBGView.frame;
}

- (void)normalStatus{
//    self.model.selected = NO;
    [self.leftImageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_tag_jinghao size:15 color:[UIColor qim_colorWithHexString:self.model.tagColor.length >0 ? [self.model.tagColor stringByReplacingOccurrencesOfString:@"#" withString:@""]:@""]]]];
    
    self.tagBGView.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
    self.titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
}

- (void)selectStatus{
//    self.model.selected = YES;
    [self.leftImageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_tag_jinghao size:15 color:[UIColor qim_colorWithHex:0xFFFFFF]]]];
    self.tagBGView.backgroundColor = [UIColor qim_colorWithHexString:self.model.tagColor.length >0 ? [self.model.tagColor stringByReplacingOccurrencesOfString:@"#" withString:@""]:@""];
    self.titleLabel.textColor = [UIColor qim_colorWithHex:0xFFFFFF];
}

-(void)resetTagViewStatus{
    self.model.selected = NO;
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

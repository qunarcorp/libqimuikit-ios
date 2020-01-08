//
//  QIMWorkMomentTagHeaderEntrenceView.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import "QIMWorkMomentTagHeaderEntrenceView.h"
#import "QIMWorkMomentTagModel.h"
#import "QIMImageUtil.h"
#import "UIImage+QIMIconFont.h"
@interface QIMWorkMomentTagHeaderEntrenceView()
@property (nonatomic,strong) UIButton * btnHotPageBtn;
@property (nonatomic,strong) UIButton * topicPageBtn;
@end

@implementation QIMWorkMomentTagHeaderEntrenceView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
    self.btnHotPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.topicPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.btnHotPageBtn setFrame:CGRectMake(15, 15, (SCREEN_WIDTH - 30 -11)/2 , 41)];
    [self.btnHotPageBtn addTarget:self action:@selector(hotPageClicked) forControlEvents:UIControlEventTouchUpInside];
       
    
    [self.topicPageBtn setFrame:CGRectMake(self.btnHotPageBtn.right + 11, 15, (SCREEN_WIDTH - 30 -11)/2, 41)];
    [self.topicPageBtn addTarget:self action:@selector(topicPageClicked) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray * tArr = [NSMutableArray array];
    NSMutableArray * iArr = [NSMutableArray array];
    if ([[QIMKit sharedInstance] getHotPostMomentNotifyConfig] && ![[QIMKit sharedInstance] getTopicFlagMomentNotifyConfig]) {
        [self.btnHotPageBtn setFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 41)];
        self.topicPageBtn.hidden = YES;
    }
    else if(![[QIMKit sharedInstance] getHotPostMomentNotifyConfig] && [[QIMKit sharedInstance] getTopicFlagMomentNotifyConfig]){
        [self.topicPageBtn setFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 41)];
        self.btnHotPageBtn.hidden = YES;
    }
    
    if ([[QIMKit sharedInstance] getHotPostMomentNotifyConfig]) {
        [tArr addObject:@"热帖榜"];
        [iArr addObject:@"hottpickpoll"];
        CAGradientLayer *gl = [CAGradientLayer layer];
           gl.frame = CGRectMake(0, 0, self.btnHotPageBtn.width, self.btnHotPageBtn.height) ;
           gl.startPoint = CGPointMake(0, 0.5);
           gl.endPoint = CGPointMake(0.9, 0.5);
           gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:250/255.0 blue:229/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:251/255.0 green:237/255.0 blue:223/255.0 alpha:1.0].CGColor];
           gl.locations = @[@(0), @(1.0f)];
           [self.btnHotPageBtn.layer addSublayer:gl];
           self.btnHotPageBtn.layer.masksToBounds = YES;
           self.btnHotPageBtn.layer.cornerRadius = 5;
       }
    if ([[QIMKit sharedInstance] getTopicFlagMomentNotifyConfig]) {
        [tArr addObject:@"话题池"];
        [iArr addObject:@"topicpoll"];
        CAGradientLayer *tgl = [CAGradientLayer layer];
        tgl.frame = CGRectMake(0, 0, self.topicPageBtn.width, self.topicPageBtn.height);
        tgl.startPoint = CGPointMake(0, 0.5);
        tgl.endPoint = CGPointMake(1, 0.5);
        tgl.colors = @[(__bridge id)[UIColor colorWithRed:233/255.0 green:249/255.0 blue:252/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:211/255.0 green:248/255.0 blue:240/255.0 alpha:1.0].CGColor];
        tgl.locations = @[@(0), @(1.0f)];
        self.topicPageBtn.layer.masksToBounds = YES;
        self.topicPageBtn.layer.cornerRadius = 5;
        [self.topicPageBtn.layer addSublayer:tgl];
    }
    
    
    
    for (int i = 0; i<tArr.count;i++) {
           UILabel *label = [[UILabel alloc] init];
           label.frame = CGRectMake(17,13,60,16);
           label.numberOfLines = 0;
           
           NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:tArr[i] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]}];

           label.attributedText = string;
           label.textAlignment = NSTextAlignmentLeft;
           label.alpha = 1.0;
        label.font = [UIFont systemFontOfSize:15 weight:20];
           
           UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(self.btnHotPageBtn.width - 43, 9, 26, 26)];
            image.image = [UIImage qim_imageNamedFromQIMUIKitBundle:iArr[i]];
        if (i == 0) {
            [self.btnHotPageBtn addSubview:label];
            [self.btnHotPageBtn addSubview:image];
        }
        else{
            [self.topicPageBtn addSubview:label];
            [self.topicPageBtn addSubview:image];
        }
    }
    
    [self addSubview:self.btnHotPageBtn];
    [self addSubview:self.topicPageBtn];
    
    self.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
}

- (void)hotPageClicked{
    if (self.jumpBlock) {
        self.jumpBlock(0);
    }
}

- (void)topicPageClicked{
    if (self.jumpBlock) {
        self.jumpBlock(1);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  QIMWorkMomentHotTagHeaderView.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import "QIMWorkMomentHotTagHeaderView.h"
#import "QIMWorkMomentTagModel.h"
#import "QIMImageUtil.h"
#import "UIImage+QIMIconFont.h"
#import "QIMWorkMomentHeaderListCollectionViewCell.h"
@interface QIMWorkMomentHotTagHeaderView() <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic,strong) CAGradientLayer *gl;
@property (nonatomic,strong) UILabel * headerTitle;
@property (nonatomic,strong) UILabel * tieziLabel;
@property (nonatomic,strong) UILabel * hudongLabel;
@property (nonatomic,strong) UIView * containerView;
@property (nonatomic,strong) UILabel * ctnlabel;
@property (nonatomic,strong) UIButton * moreBtn;
@property (nonatomic,assign) BOOL isExpand;
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) UIView * underLineView;
@property (nonatomic,strong) NSMutableArray * dataArr;
@end
@implementation QIMWorkMomentHotTagHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.isExpand = NO;
        self.dataArr = [NSMutableArray array];
        [self.dataArr addObject:@"darenbang"];
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews{
    
    
    self.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    
    self.backGroundView = [[UIView alloc] init];
    self.backGroundView.frame = CGRectMake(0,0,SCREEN_WIDTH,125);
    self.backGroundView.backgroundColor = [UIColor orangeColor];
    
    
    self.gl = [CAGradientLayer layer];
    self.gl.frame = CGRectMake(0,0,SCREEN_WIDTH,self.backGroundView.height);
    self.gl.startPoint = CGPointMake(0, 0.5);
    self.gl.endPoint = CGPointMake(1, 0.5);
    self.gl.locations = @[@(0), @(1.0f)];
    [self.backGroundView.layer addSublayer:self.gl];
    
    UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 20, 24, 24)];
    [iconView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_tag_jinghao size:24 color:[UIColor whiteColor]]]];
    [self.backGroundView addSubview:iconView];
    
    
    self.headerTitle = [[UILabel alloc]initWithFrame:CGRectMake(iconView.right + 12, 20, 300, 23)];
    self.headerTitle.text = @"产品讨论";
    self.headerTitle.textColor = [UIColor whiteColor];
    self.headerTitle.font = [UIFont systemFontOfSize:22];
    self.headerTitle.textAlignment = NSTextAlignmentLeft;
    [self.backGroundView addSubview:self.headerTitle];
    
    self.tieziLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.headerTitle.left, self.headerTitle.bottom + 12, 100, 13)];
    self.tieziLabel.text = @"200个帖子";
    self.tieziLabel.textColor = [UIColor whiteColor];
    self.tieziLabel.font = [UIFont systemFontOfSize:12];
    self.tieziLabel.textAlignment = NSTextAlignmentLeft;
    [self.backGroundView addSubview:self.tieziLabel];
    
    self.hudongLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tieziLabel.right + 17, self.tieziLabel.y, 100, 13)];
    self.hudongLabel.text = @"80人互动";
    self.hudongLabel.textColor = [UIColor whiteColor];
    self.hudongLabel.font = [UIFont systemFontOfSize:12];
    self.hudongLabel.textAlignment = NSTextAlignmentLeft;
    [self.backGroundView addSubview:self.hudongLabel];
    
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(25, 88, SCREEN_WIDTH - 50, 93)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 8;
    self.containerView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0,2);
    self.containerView.layer.shadowOpacity = 1;
    self.containerView.layer.shadowRadius = 5;
//    [backGroundView addSubview:containerView];
    
    self.ctnlabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 14, self.containerView.width-36, 48)];
    self.ctnlabel.text = @"老何的一千零一夜是一档个人分享节目，里面收录了何伟平的个人笔记，老何的一千零一夜afkeaejfnkanfajefakfa";
    self.ctnlabel.numberOfLines = 0;
    self.ctnlabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    self.ctnlabel.font = [UIFont systemFontOfSize:14];
    self.ctnlabel.textAlignment = NSTextAlignmentLeft;
    [self.containerView addSubview:self.ctnlabel];
    
//    &#xf3cb;
//    UILabel * zhankaiMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(containerView.width/2 - 33, label.bottom + 4, 54, 19)];
//    zhankaiMoreLabel
    self.moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.ctnlabel.bottom + 2, self.containerView.width, 30)];
    [self.moreBtn setTitle:@"展开更多" forState:UIControlStateNormal];
    self.moreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.moreBtn setTitleColor:[UIColor colorWithRGBHex:0xBFBFBF] forState:UIControlStateNormal];
    [self.moreBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_tag_more_down size:15 color:[UIColor colorWithRGBHex:0xBFBFBF]]] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat space = 5;
    
    CGFloat imageWidth = CGRectGetWidth(self.moreBtn.imageView.frame);
    CGFloat imageHeight = CGRectGetHeight(self.moreBtn.imageView.frame);
    CGFloat titleWidth = CGRectGetWidth(self.moreBtn.titleLabel.frame);
    CGFloat titleHeight = CGRectGetHeight(self.moreBtn.titleLabel.frame);
    
    self.moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 + (titleWidth + space / 2), 0, 0 - (titleWidth + space / 2));
   self.moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 - (imageWidth + space / 2), 0, 0 + (imageWidth + space / 2));
    
    [self.containerView addSubview:self.moreBtn];
    
    [self setupCollectionView];
    
    [self addSubview:self.backGroundView];
    [self addSubview:self.containerView];
    [self addSubview:self.collectionView];
    
    self.underLineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.collectionView.bottom, SCREEN_WIDTH, 0.5)];
    self.underLineView.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE];
    [self addSubview:self.underLineView];
    
}

-(void)setHeaderModel:(QIMWorkMomentHeaderTagInfoModel *)model{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.backGroundView.backgroundColor = [UIColor whiteColor];
    NSArray * colors = [model.topicBGColor componentsSeparatedByString:@","];
    if (colors && colors.count >0) {
        NSString * colorOneStr = colors.firstObject;
        NSString * colorTwoStr = colors.lastObject;
        UIColor * colorOne = [UIColor qim_colorWithHexString:colorOneStr.length>0 ? [colorOneStr stringByReplacingOccurrencesOfString:@"#" withString:@""]:@""];
        
        UIColor * colorTwo = [UIColor qim_colorWithHexString:colorOneStr.length>0 ? [colorOneStr stringByReplacingOccurrencesOfString:@"#" withString:@""]:@""];
        
        self.gl.colors = @[(__bridge id)colorOne.CGColor, (__bridge id)colorTwo.CGColor];
        self.gl.locations = @[@(0), @(1.0f)];
    }
    self.headerTitle.text = model.tagTitle;
    self.tieziLabel.text = [NSString stringWithFormat:@"%zd个帖子",model.postTotal.intValue];
    self.hudongLabel.text = [NSString stringWithFormat:@"%zd人互动",model.activeUserTotal.intValue];
    self.ctnlabel.text = model.descriptionString;
    if (model.users && model.users.count >0) {
        [self.dataArr addObjectsFromArray:[model.users mutableCopy]];
    }
    else{
        self.collectionView.hidden = YES;
    }
    [self resizeSubViews];
    [_collectionView reloadData];
}
- (void)resizeSubViews{
    if (self.isExpand == NO) {
        [self.tieziLabel sizeToFit];
        [self.hudongLabel sizeToFit];
        [self.ctnlabel sizeToFit];
        CGRect tempFrame = self.ctnlabel.frame;
        [self.ctnlabel setFrame:CGRectMake(self.ctnlabel.x, self.ctnlabel.y, self.ctnlabel.width,48)];
        self.tieziLabel.frame = CGRectMake(self.tieziLabel.x, self.tieziLabel.y, self.tieziLabel.width, self.tieziLabel.height);
        self.hudongLabel.frame = CGRectMake(self.tieziLabel.right + 17, self.hudongLabel.y, self.hudongLabel.width, self.hudongLabel.height);
        if (tempFrame.size.height <= 48) {
            self.moreBtn.hidden = YES;
            [self.moreBtn setFrame:CGRectMake(0, self.ctnlabel.bottom + 2, self.containerView.width, 0)];
            [self.containerView setFrame:CGRectMake(self.containerView.x, self.containerView.y, self.containerView.width, self.ctnlabel.height + 14 + 14)];
        }
        else{
            self.moreBtn.hidden = NO;
            [self.moreBtn setFrame:CGRectMake(0, self.ctnlabel.bottom + 2, self.containerView.width, 30)];
            [self.containerView setFrame:CGRectMake(self.containerView.x, self.containerView.y, self.containerView.width, self.ctnlabel.height + 14 + 30.5)];
        }
        
    }
    else{
        [self.ctnlabel sizeToFit];
        [self.ctnlabel setFrame:CGRectMake(self.ctnlabel.x, self.ctnlabel.y, self.ctnlabel.width, self.ctnlabel.height)];
        [self.moreBtn setFrame:CGRectMake(0, self.ctnlabel.bottom + 2, self.containerView.width, 30)];
        [self.containerView setFrame:CGRectMake(self.containerView.x, self.containerView.y, self.containerView.width, self.ctnlabel.height + 14 + 30.5)];
       
    }
    if (self.collectionView.hidden == YES) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.collectionView.bottom + 15);
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.containerView.bottom + 30);
    }
    else{
         _collectionView.frame = CGRectMake(0, self.containerView.bottom + 28, SCREEN_WIDTH, 57);
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.collectionView.bottom + 15);
    }
    
    [self.underLineView setFrame:CGRectMake(0, self.frame.size.height - 0.5, SCREEN_WIDTH, 0.5)];
    

    if (self.changeHeightBolck) {
        self.changeHeightBolck(self.collectionView.bottom + 5);
    }
}

- (void)moreBtnClicked:(UIButton *)btn{
    if (self.isExpand == NO) {
        self.isExpand = YES;
        [self resizeSubViews];
        return;
    }
    else{
        self.isExpand =NO;
        [self resizeSubViews];
        return;
    }
    
}


#pragma mark-collectionView
- (void)setupCollectionView
{
 // 使用系统自带的流布局（继承自UICollectionViewLayout）
  UICollectionViewFlowLayout *layout = ({
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  // 每个cell的大小
  layout.itemSize     = CGSizeMake(45, 45);
  // 横向滚动
  layout.scrollDirection    = UICollectionViewScrollDirectionHorizontal;
  // cell间的间距
  layout.minimumLineSpacing   = 14;

      layout.sectionInset = UIEdgeInsetsMake(0, 14, 0, 14);
  layout;
 });
 
 // 使用UICollectionView必须设置UICollectionViewLayout属性
 self.collectionView = ({
  UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
     collectionView.frame = CGRectMake(0, self.containerView.bottom + 28, SCREEN_WIDTH, 57);
  collectionView.backgroundColor = [UIColor clearColor];
  // 这里千万记得在interface哪里写<UICollectionViewDataSource>！！！
  collectionView.dataSource  = self;
     collectionView.delegate = self;
  [collectionView setShowsHorizontalScrollIndicator:NO];
 
  [self addSubview:collectionView];
 
  collectionView;
 });
 
    [self.collectionView registerClass:[QIMWorkMomentHeaderListCollectionViewCell class] forCellWithReuseIdentifier:@"maincell"];
 // 实现注册cell，其中PhotoCell是我自定义的cell，继承自UICollectionViewCell
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * headerStr = self.dataArr[indexPath.row];
    
    QIMWorkMomentHeaderListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"maincell" forIndexPath:indexPath];
    
//    cell.backgroundColor = [UIColor greenColor];
    if (indexPath.row == 0) {
        [cell.imageView setImage: [UIImage qim_imageNamedFromQIMUIKitBundle:@"darenbang"]];
    }
    else{
         [cell.imageView qim_setImageWithJid:headerStr placeholderImage:[UIImage imageWithData:[QIMKit defaultUserHeaderImage]]];
        [cell setClickBlock:^{
            [QIMFastEntrance openUserCardVCByUserId:headerStr];
        }];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return CGSizeMake(57, 57);
        
    }
    else if (indexPath.row == 1){
        return CGSizeMake(45, 45);
    }
    else{
        return CGSizeMake(42, 42);
    }
    
}


#pragma mark-请求接口

@end

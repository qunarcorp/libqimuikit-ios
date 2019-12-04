//
//  QIMWorkMomentTagListTableViewCell.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/18.
//

#import "QIMWorkMomentTagListTableViewCell.h"
#import "QIMWorkMomentTopicListModel.h"
#import "QIMWorkMomentTagView.h"
#import "QIMWorkMomentTagModel.h"
#import "MBProgressHUD.h"
#import "QTalkTipsView.h"


@interface QIMWorkMomentTagListTableViewCell()
@property (nonatomic , strong) UILabel * headerLabel;
@property (nonatomic , strong) UIView * tagBgView;
@end

@implementation QIMWorkMomentTagListTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        [self setupUI];
    }
    return self;
}

-(void)setModel:(QIMWorkMomentTopicListModel *)model{
    if (model) {
        _model = model;
    }
    [self refreshCell];
}

- (void)refreshCell{
    self.headerLabel.text = self.model.topicTitle;
    [self setSubTagViews];
}

- (void)setupUI{
    self.headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 10, self.width - 25, 19)];
    self.headerLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    self.headerLabel.font = [UIFont systemFontOfSize:16];
    self.headerLabel.textAlignment = NSTextAlignmentLeft;
    self.headerLabel.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    
    self.tagBgView = [[UIView alloc]initWithFrame:CGRectMake(25, self.headerLabel.bottom + 15, self.width - 25, 10)];
    self.tagBgView.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    
    [self addSubview:self.headerLabel];
    [self addSubview:self.tagBgView];
}

- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    
    return hud;
}

- (void)setSubTagViews{
    
    CGFloat yFloat = 0;
    CGFloat xFloat = 0;
    for (NSInteger i = 0; i< self.model.tagList.count; i++) {
        
        QIMWorkMomentTagModel * model = self.model.tagList[i];
        QIMWorkMomentTagView * view = [[QIMWorkMomentTagView alloc]init];
        
        __weak typeof(self) weakSelf = self;
        
        __weak typeof(view) weakView = view;
        [view setAddTagBlock:^(QIMWorkMomentTagModel * _Nonnull model) {
            if (weakSelf.model.selectArr.count >= 2) {
                [weakView resetTagViewStatus];
                [weakSelf showSelectedMessage];
            }
            else{
                [weakSelf.model.selectArr addObject:model];
            }
        }];
        
        [view setRemoveBlock:^(QIMWorkMomentTagModel * _Nonnull model) {
            [weakSelf.model.selectArr removeObject:model];
        }];
        
        view.canDelete = NO;
        view.model = model;
        yFloat = i/2 * 37;
        if(i%2==0){
            xFloat = 0;
        }
        else{
            xFloat = view.width + 15;
        }
        
        if (view.width + 25 > SCREEN_WIDTH/2) {
            xFloat = view.width + 15;
        }
        view.frame = CGRectMake(xFloat, yFloat, view.width, 27);
        [self.tagBgView addSubview:view];
    }
    self.tagBgView.frame = CGRectMake(25, self.headerLabel.bottom +15, self.width + 25, 10 + yFloat + 27);
    _model.cellHeight = self.headerLabel.height + self.tagBgView.height + 15 + 10;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)showSelectedMessage{
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 180)/2, SCREEN_HEIGHT - 109, 180, 60)];
//    label.text = @"一个帖子最多可选5个话题";
//    label.font = [UIFont systemFontOfSize:15];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.numberOfLines = 0;
//    label.backgroundColor = [UIColor qim_colorWithHex:0x333333];
//    label.layer.masksToBounds = YES;
//    label.layer.cornerRadius = 4;
//    label.layer.shadowOpacity = 1;
//    label.layer.shadowRadius = 10;
//    label.layer.shadowOffset = CGSizeMake(0,3);
//    label.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2].CGColor;
//    [[UIApplication sharedApplication].keyWindow addSubview:label];
//    [UIView animateWithDuration:0.2 animations:^{
//        label.alpha = 1;
//        [label removeFromSuperview];
//    }];
    [QTalkTipsView showTips:[NSString stringWithFormat:@"评论不可以超过200个字哦～"] InView:[[[[UIApplication sharedApplication] keyWindow] rootViewController] view]];
    return;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

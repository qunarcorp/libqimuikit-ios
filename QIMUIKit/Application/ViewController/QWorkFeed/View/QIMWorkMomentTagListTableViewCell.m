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
        self.canMutiSelected = YES;
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
    NSInteger lastWidth = 0;
    for (NSInteger i = 0; i< self.model.tagList.count; i++) {
        
        QIMWorkMomentTagModel * model = self.model.tagList[i];
        QIMWorkMomentTagView * view = [[QIMWorkMomentTagView alloc]init];
        view.canChangeColor = self.canMutiSelected;
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
        
        [view setTagDidClickedBlock:^(QIMWorkMomentTagModel * _Nonnull model) {
            if (weakSelf.selectBlock) {
                weakSelf.selectBlock(model);
            }
        }];
        
        view.canDelete = NO;
        view.model = model;
        if (i==0) {
            xFloat = 0;
            yFloat = 0;
        }
        else{
            if (SCREEN_WIDTH - (xFloat + lastWidth + view.width +15 + 30)< 0) {
                yFloat = yFloat + 37;
                xFloat = 0;
            }
            else{
                xFloat = xFloat + lastWidth + 15;
            }
        }
        view.frame = CGRectMake(xFloat, yFloat, view.width, 27);
        lastWidth = view.width;
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

    [QTalkTipsView showTips:[NSString stringWithFormat:@"评论不可以超过200个字哦～"] InView:[[[[UIApplication sharedApplication] keyWindow] rootViewController] view]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

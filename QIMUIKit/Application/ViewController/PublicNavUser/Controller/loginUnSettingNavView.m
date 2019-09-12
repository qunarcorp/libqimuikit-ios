//
//  loginUnSettingNavView.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/7/10.
//

#import "loginUnSettingNavView.h"
#import "UIColor+QIMUtility.h"
#import "QIMIconInfo.h"
#import "UIImage+QIMIconFont.h"
#import "Masonry.h"

@interface loginUnSettingNavView()
@property (nonatomic , strong) UIView * grayBgView;
@property (nonatomic , strong) UIView * alertBgView;
@property (nonatomic , strong) UILabel * titleLabel;
@property (nonatomic , strong) UILabel * settingNavByhandLabel;
@property (nonatomic , strong) UIButton * scanSettingNavBtn;
@property (nonatomic , strong) UILabel * cancelLabel;
@end
@implementation loginUnSettingNavView

-(UIView *)grayBgView{
    if (!_grayBgView) {
        _grayBgView = [[UIView alloc]init];
        _grayBgView.backgroundColor = [UIColor qim_colorWithHex:0x242730 alpha:0.5];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenMyGrayView)];
        [_grayBgView addGestureRecognizer:tap];
    }
    return _grayBgView;
}

-(UIView *)alertBgView{
    if (!_alertBgView) {
        _alertBgView = [[UIView alloc]init];
        _alertBgView.backgroundColor = [UIColor whiteColor];
    }
    return _alertBgView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.numberOfLines = 0;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"请先扫码配置您的导航地址"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Semibold" size: 17],NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]}];
        
        _titleLabel.attributedText = string;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.alpha = 1.0;
    }
    return _titleLabel;
}
-(UILabel *)settingNavByhandLabel{
    if (!_settingNavByhandLabel) {
        _settingNavByhandLabel = [[UILabel alloc] init];
        _settingNavByhandLabel.numberOfLines = 0;
        _settingNavByhandLabel.userInteractionEnabled = YES;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSBundle qim_localizedStringForKey:@"Configure_Navigation"] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Regular" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0]}];
        _settingNavByhandLabel.tag = 123112234452;
        _settingNavByhandLabel.attributedText = string;
        _settingNavByhandLabel.textAlignment = NSTextAlignmentLeft;
        _settingNavByhandLabel.alpha = 1.0;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureTapClicked:)];
        [_settingNavByhandLabel addGestureRecognizer:tap];
    }
    return _settingNavByhandLabel;
}

- (UIButton *)scanSettingNavBtn{
    if (!_scanSettingNavBtn) {
        _scanSettingNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scanSettingNavBtn.backgroundColor = [UIColor qim_colorWithHex:0x00CABE];
        [_scanSettingNavBtn setTitle:[NSBundle qim_localizedStringForKey:@"nav_scan_Configure_Navigation"] forState:UIControlStateNormal];
        [_scanSettingNavBtn setTitleColor:[UIColor qim_colorWithHex:0xFFFFFF] forState:UIControlStateNormal];
        _scanSettingNavBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:4];
        [_scanSettingNavBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor qim_colorWithHex:0xFFFFFF]]] forState:UIControlStateNormal];
        [_scanSettingNavBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor qim_colorWithHex:0xFFFFFF]]] forState:UIControlStateSelected];
        [_scanSettingNavBtn addTarget:self action:@selector(scanCodeSettingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _scanSettingNavBtn.layer.masksToBounds = YES;
        _scanSettingNavBtn.layer.cornerRadius = 4;
        _scanSettingNavBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 - 7 / 2, 0, 0 + 7 / 2);
        _scanSettingNavBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 + 7 / 2, 0, 0 - 7 / 2);
    }
    return _scanSettingNavBtn;
}

- (UILabel *)cancelLabel{
    if (!_cancelLabel) {
        _cancelLabel = [[UILabel alloc] init];
        _cancelLabel.frame = CGRectMake(152.5,405,64,16);
        _cancelLabel.numberOfLines = 0;
        _cancelLabel.userInteractionEnabled = YES;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"下次再说"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Regular" size: 16],NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];
        _cancelLabel.tag = 123112234453;
        _cancelLabel.attributedText = string;
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
        _cancelLabel.alpha = 1.0;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenMyGrayView)];
        [_cancelLabel addGestureRecognizer:tap];
    }
    return _cancelLabel;
}


-(instancetype)initWithFrame:(CGRect)frame delegate:(id<loginUnSettingNavViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self initWithUI];
    }
    return self;
}

- (void)initWithUI{
    [self addSubview:self.grayBgView];
    
    [self.grayBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.grayBgView addSubview:self.alertBgView];
    
    [self.alertBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.height.mas_equalTo(@(225));
        make.width.mas_equalTo(@(265));
    }];
    
    
    [self.alertBgView addSubview:self.titleLabel];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.right.mas_equalTo(self.alertBgView);
        make.left.mas_equalTo(self.alertBgView.mas_left).offset(33);
        make.height.mas_equalTo(@(20));
    }];
//
    [self.alertBgView addSubview:self.settingNavByhandLabel];

    [self.settingNavByhandLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(14);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(22);
    }];

    [self.alertBgView addSubview:self.scanSettingNavBtn];

    [self.scanSettingNavBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.settingNavByhandLabel.mas_bottom).offset(41);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.alertBgView).offset(-33);
        make.height.mas_equalTo(42);
    }];

    [self.alertBgView addSubview:self.cancelLabel];
    [self.cancelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scanSettingNavBtn.mas_bottom).offset(17);
        make.left.right.mas_equalTo(self.alertBgView);
        make.height.mas_equalTo(17);
    }];
}

-(void)gestureTapClicked:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(showSettingNavViewController)]) {
        [self.delegate showSettingNavViewController];
    }
    [self hiddenMyGrayView];
}

- (void)scanCodeSettingBtnClick:(UIButton *)btnClick{
    if ([self.delegate respondsToSelector:@selector(showScanViewController)]) {
        [self.delegate showScanViewController];
    }
    [self hiddenMyGrayView];
}

- (void)hiddenMyGrayView{
    [self removeAllSubviews];
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

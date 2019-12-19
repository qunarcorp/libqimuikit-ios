//
// Created by lilu on 2019/10/30.
//

#import "QIMRedPackOpenView.h"
#import "Masonry.h"
#import "QIMUIFontConfig.h"
#import "QIMUIColorConfig.h"
#import "QIMUISizeConfig.h"
#import "QIMIconInfo.h"
#import "QIMKitPublicHeader.h"
#import "UIImage+QIMIconFont.h"
#import "UIApplication+QIMApplication.h"

@interface QIMRedPackOpenView ()

@property (nonatomic, strong) UIView *bgContentView;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIButton *openBtn;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) UILabel *desLabel;

@property (nonatomic, strong) UILabel *gongxiLabel;

@property (nonatomic, copy) NSString *chatId;

@property (nonatomic, copy) NSString *userJid;

@property (nonatomic, copy) NSString *redId;

@property (nonatomic, assign) BOOL isRoom;

@property (nonatomic, copy) NSString *gongxiStr;

@end

@implementation QIMRedPackOpenView {

}

- (instancetype)initWithChatId:(NSString *)chatId withUserId:(NSString *)userId withRedId:(NSString *)redId withISRoom:(BOOL)isRoom withRedPackInfoDic:(NSDictionary *)redPackInfoDic {
    self = [super initWithFrame:[[[UIApplication sharedApplication] visibleViewController] view].bounds];
    if (self) {
        /*
        {
            content = "恭喜发财，大吉大利";
            rid = 52;
            type = "拼手气红包";
            typestr = "恭喜发财，大吉大利";
            url = 52;
        }
         */
        self.chatId = chatId;
        self.userJid = userId;
        self.redId = redId;
        self.isRoom = isRoom;
        NSString *typeStr = [redPackInfoDic objectForKey:@"typestr"];
        self.gongxiStr = (typeStr.length > 0) ? typeStr : @"恭喜发财，大吉大利";
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.bgContentView];
    [self.bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(273);
        make.height.mas_equalTo(410);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    [self.bgContentView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.bgContentView.mas_width);
        make.height.mas_equalTo(267);
        make.left.top.mas_equalTo(0);
    }];
    self.bgImageView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"red_pack_bg"];

    [self.bgImageView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.width.height.mas_equalTo(46);
       make.top.mas_offset(45);
       make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [self.headerView qim_setImageWithJid:self.userJid];

    [self.bgImageView addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(8);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    [self.bgImageView addSubview:self.gongxiLabel];
    [self.gongxiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.desLabel.mas_bottom).mas_offset(16);
       make.left.right.mas_equalTo(0);
       make.height.mas_equalTo(25);
    }];

    [self.bgImageView addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.left.mas_equalTo(12.5);
       make.width.height.mas_equalTo(26.5);
    }];
    [self.closeBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"red_pack_close"] forState:UIControlStateNormal];


    [self.bgContentView addSubview:self.openBtn];
    [self.openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgImageView.mas_bottom).mas_offset(-60);
        make.width.height.mas_equalTo(86);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [self.openBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"red_pack_openbtn"] forState:UIControlStateNormal];
}

- (UIView *)bgContentView {
    if (!_bgContentView) {
        _bgContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 273, 267)];
        _bgContentView.backgroundColor = [UIColor qim_colorWithHex:0xC1453F];
//        _bgContentView.userInteractionEnabled = NO;
    }
    return _bgContentView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.backgroundColor = [UIColor qim_colorWithHex:0xC1453F];
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        _closeBtn.backgroundColor = [UIColor clearColor];
        [_closeBtn addTarget:self action:@selector(closeRedPack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)openBtn {
    if (!_openBtn) {
        _openBtn = [[UIButton alloc] init];
        _openBtn.backgroundColor = [UIColor clearColor];
        [_openBtn addTarget:self action:@selector(openRedPack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openBtn;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] init];
        _headerView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"red_pack_openbtn"];
        _headerView.layer.cornerRadius = 23.0f;
        _headerView.layer.masksToBounds = YES;
    }
    return _headerView;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.font = [UIFont systemFontOfSize:14];
        _desLabel.textAlignment = NSTextAlignmentCenter;
        _desLabel.textColor = [UIColor qim_colorWithHex:0xFFD4D4];
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.userJid];
        _desLabel.text = [NSString stringWithFormat:@"%@的红包", [userInfo objectForKey:@"Name"]];
    }
    return _desLabel;
}

- (UILabel *)gongxiLabel {
    if (!_gongxiLabel) {
        _gongxiLabel = [[UILabel alloc] init];
        _gongxiLabel.font = [UIFont systemFontOfSize:19.5];
        _gongxiLabel.text = @"恭喜发财，大吉大利";
        _gongxiLabel.textAlignment = NSTextAlignmentCenter;
        _gongxiLabel.textColor = [UIColor qim_colorWithHex:0xffffff];
    }
    return _gongxiLabel;
}

- (void)setOpenCallBack:(QIMKitOpenRedPackBlock)openCallBack {
    _openCallBack = [openCallBack copy];
}

- (void)openRedPack:(id)sender {
    __weak __typeof(self)weakSelf = self;
    [[QIMKit sharedInstance] grapRedEnvelop:self.chatId RedRid:self.redId IsChatRoom:self.isRoom withCallBack:^(NSString *rid) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (rid.length > 0 && [rid isEqualToString:strongSelf.redId]) {
            if (strongSelf.openCallBack) {
                strongSelf.openCallBack(YES);
            }
        } else {
            if (strongSelf.openCallBack) {
                strongSelf.openCallBack(NO);
            }
        }
    }];
}

- (void)closeRedPack:(id)sender {
    [self removeFromSuperview];
}

@end

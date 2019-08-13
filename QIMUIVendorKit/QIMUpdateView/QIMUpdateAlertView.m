//
//  QIMUpdateAlertView.m
//  QIMUIKit
//
//  Created by lilu on 2019/6/25.
//

#import <QIMUIKit/UIImage+QIMUIKit.h>
#import <QIMCommonCategories/QIMCommonCategories.h>
#import "QIMUpdateAlertView.h"
#import "QIMUIColorConfig.h"
#import "View+MASAdditions.h"
#import "NSString+QIMUtility.h"
#import "YYModel.h"

#define key_Window [UIApplication sharedApplication].keyWindow
#define key_QIMSelectItem_Title @"key_QIMSelectItem_Title"
#define key_QIMSelectItem_TitleColor @"key_QIMSelectItem_TitleColor"

#define kColorWithHex(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]

#define Screen_QIM_Width [UIScreen mainScreen].bounds.size.width
#define Screen_QIM_Height [UIScreen mainScreen].bounds.size.height
#define kAlertView_offsetX 55   //alertView侧边偏移量
#define kAlertView_MAX_Height 460   //alertView最大高度
#define kAlertView_content_offsetX 20 //内部文字边距
#define kSelect_item_height 45 //选项高度

@interface QIMUpdateAlertView ()

@property(nonatomic, strong) QIMUpdateDataModel *updateModel;

//@property(nonatomic, assign) QIMUpgradeType upgradeType;    //更新状态
//
//@property(nonatomic, copy) NSString *updateUrl;     //更新地址
//
//@property(nonatomic, strong) NSDictionary *updateDic;   //更新Dic

@property(nonatomic, copy) NSString *title;

//@property(nonatomic, copy) NSString *message;

@property(nonatomic, strong) UIImageView *iconView;     //图标

@property(nonatomic, strong) UILabel *titleLabel;       //titleLabel

@property(nonatomic, strong) UILabel *messageLabel;     //更新日志Label

@property (nonatomic, strong) UIButton *nextButton;     //下次再说

@property (nonatomic, strong) UIButton *updateButton;   //立即更新按钮

@property(nonatomic, strong) UIView *alertView;


@end

@implementation QIMUpdateAlertView

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"update_version"];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = @"新版本更新";
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.text = @"更新内容更新内容更新内容更新内容更新内容更新内容";
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.numberOfLines = 5;
        _messageLabel.textColor = [UIColor qim_colorWithHex:0x888888];
        _messageLabel.backgroundColor = [UIColor whiteColor];
        _messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _messageLabel;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.layer.cornerRadius = 4.0f;
        _nextButton.layer.borderWidth = 1.0f;
        _nextButton.layer.borderColor = [UIColor qim_colorWithHex:0xBFBFBF].CGColor;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton setTitle:@"下次再说" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor whiteColor]];
        [_nextButton addTarget:self action:@selector(nextUpdate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIButton *)updateButton {
    if (!_updateButton) {
        _updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateButton.layer.cornerRadius = 4.0f;
        _updateButton.layer.masksToBounds = YES;
        [_updateButton setTitle:@"立即更新" forState:UIControlStateNormal];
        [_updateButton setTitleColor:[UIColor qim_colorWithHex:0xFFFFFF] forState:UIControlStateNormal];
        [_updateButton setBackgroundColor:[UIColor qim_colorWithHex:0x00CABE]];
        [_updateButton addTarget:self action:@selector(gotoUpdate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateButton;
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(kAlertView_offsetX, 0, Screen_QIM_Width - kAlertView_offsetX * 2, kAlertView_MAX_Height / 2)];
        _alertView.center = key_Window.center;
        _alertView.backgroundColor = [UIColor whiteColor];
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.cornerRadius = 3.0f;
    }
    return _alertView;
}

+ (instancetype)qim_showUpdateAlertViewWithUpdateDic:(NSDictionary *)updateDic {
    QIMUpdateAlertView *updateView = [[QIMUpdateAlertView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];

    [updateView showUpdateAlertViewWithUpdateDic:updateDic];
    return updateView;
}

- (void)showUpdateAlertViewWithUpdateDic:(NSDictionary *)updateDic {

    NSString *updateTitle = @"新版本更新";
    QIMUpdateDataModel *updateModel = [QIMUpdateDataModel yy_modelWithDictionary:updateDic];
    self.updateModel = updateModel;
    if (self.updateModel.isUpdated == NO) {
        return;
    }
//    NSString *updateMessage = [updateDic objectForKey:@"message"];
//    self.upgradeType = [[updateDic objectForKey:@"isUpdated"] integerValue];
//    self.updateDic = updateDic;
    self.title = updateTitle;
//    self.message = updateMessage;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];

    [self addSubview:self.alertView];
    [self layoutHCAlertView];
}

/**
 布局AlertView
 */
- (void)layoutHCAlertView {

    [self.alertView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(1);
        make.width.mas_equalTo(133);
        make.height.mas_equalTo(129);
        make.centerX.mas_equalTo(self.alertView.mas_centerX);
    }];

    //titleLabel
    CGFloat normalWidth = self.alertView.frame.size.width - kAlertView_content_offsetX * 2;
    CGSize rectTitleSize = [self.title qim_sizeWithFontCompatible:self.titleLabel.font forWidth:normalWidth lineBreakMode:NSLineBreakByWordWrapping];
    [self.alertView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconView.mas_bottom).mas_offset(15);
        make.width.mas_equalTo(rectTitleSize.width);
        make.height.mas_equalTo(rectTitleSize.height);
        make.centerX.mas_equalTo(self.alertView.mas_centerX);
    }];
    self.titleLabel.text = self.title;

    //messageLabel
    CGFloat normalMessageWidth = self.alertView.frame.size.width - kAlertView_content_offsetX * 2 - 56;
    CGSize rectMessageSize = [self.updateModel.message qim_sizeWithFontCompatible:self.messageLabel.font constrainedToSize:CGSizeMake(normalMessageWidth, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
    self.messageLabel.text = self.updateModel.message;
    [self.alertView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(14);
        make.left.mas_equalTo(28);
        make.right.mas_equalTo(-28);
        make.height.mas_equalTo((rectMessageSize.height > self.messageLabel.font.lineHeight * 6) ? self.messageLabel.font.lineHeight * 6 : rectMessageSize.height);
        make.centerX.mas_equalTo(self.alertView.mas_centerX);
    }];

    if (self.updateModel.isUpdated == YES) {
        if (self.updateModel.forceUpdate == NO) {
            //下次再说按钮
            [self.alertView addSubview:self.nextButton];
            [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(105);
                make.height.mas_equalTo(42);
                make.left.mas_offset(20);
                make.top.mas_equalTo(self.messageLabel.mas_bottom).mas_offset(26);
            }];
            
            //立即更新按钮
            [self.alertView addSubview:self.updateButton];
            [self.updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(105);
                make.height.mas_equalTo(42);
                make.right.mas_equalTo(-20);
                make.top.mas_equalTo(self.messageLabel.mas_bottom).mas_offset(26);
            }];
        } else {
            //立即更新按钮
            [self.alertView addSubview:self.updateButton];
            [self.updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(210);
                make.height.mas_equalTo(42);
                make.right.mas_equalTo(-28);
                make.top.mas_equalTo(self.messageLabel.mas_bottom).mas_offset(26);
                make.centerX.mas_equalTo(self.messageLabel.mas_centerX);
            }];
        }
    }

    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(Screen_QIM_Width - kAlertView_offsetX * 2);
        make.bottom.mas_equalTo(self.updateButton.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(kAlertView_offsetX);
        make.top.mas_equalTo(Screen_QIM_Width - kAlertView_offsetX * 2);
    }];

    [self layoutIfNeeded];
    self.alertView.center = key_Window.center;
}

#pragma mark - Action

- (void)dismiss
{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

- (void)nextUpdate:(id)sender {
    //下次再说
    if (self.upgradeDelegate && [self.upgradeDelegate respondsToSelector:@selector(qim_UpdateAlertViewDidClickWithType:withUpdateDic:)]) {
        [self.upgradeDelegate qim_UpdateAlertViewDidClickWithType:QIMUpgradeAfter withUpdateDic:self.updateModel];
    }
    [self dismiss];
}

- (void)gotoUpdate:(id)sender {
    //现在去更新
    if (self.upgradeDelegate && [self.upgradeDelegate respondsToSelector:@selector(qim_UpdateAlertViewDidClickWithType:withUpdateDic:)]) {
        [self.upgradeDelegate qim_UpdateAlertViewDidClickWithType:QIMUpgradeNow withUpdateDic:self.updateModel];
    }
    [self dismiss];
}

@end

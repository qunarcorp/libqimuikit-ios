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

#define key_Window [UIApplication sharedApplication].keyWindow
#define key_HCSelectItem_Title @"key_HCSelectItem_Title"
#define key_HCSelectItem_TitleColor @"key_HCSelectItem_TitleColor"

#define kColorWithHex(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]

#define Screen_HC_Width [UIScreen mainScreen].bounds.size.width
#define Screen_HC_Height [UIScreen mainScreen].bounds.size.height
#define kAlertView_offsetX 55   //alertView侧边偏移量
#define kAlertView_MAX_Height 460   //alertView最大高度
#define kAlertView_content_offsetX 20 //内部文字边距
#define kSelect_item_height 45 //选项高度

@interface QIMUpdateAlertView ()

@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) NSString *message;

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
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor qim_colorWithHex:0x888888];
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
    }
    return _updateButton;
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(kAlertView_offsetX, 0, Screen_HC_Width - kAlertView_offsetX * 2, kAlertView_MAX_Height / 2)];
        _alertView.center = key_Window.center;
        _alertView.backgroundColor = [UIColor whiteColor];
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.cornerRadius = 5;
    }
    return _alertView;
}

+ (void)qim_showUpdateAlertViewTitle:(NSString *)title message:(NSString *)message selectItemIndex:(NSInteger)index {
    QIMUpdateAlertView *updateView = [[QIMUpdateAlertView alloc] initWithFrame:CGRectZero];
    [updateView showAlertViewTitle:title message:message selectItemIndex:index];
}

- (void)showAlertViewTitle:(NSString *)title message:(NSString *)message selectItemIndex:(NSInteger)index {
//    self.selectedBlock = selectIndex;
//    itemsBlock(self.items);

    self.title = title;
    self.message = message;

    [[[UIApplication sharedApplication] keyWindow] addSubview:self];

    [self addSubview:self.alertView];
    [self layoutHCAlertView];
    self.alertView.center = key_Window.center;
}


/**
 布局AlertView
 */
- (void)layoutHCAlertView {

    self.alertView.backgroundColor = [UIColor yellowColor];
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
    CGFloat normalMessageWidth = self.alertView.frame.size.width - kAlertView_content_offsetX * 2;
    CGSize rectMessageSize = [self.message qim_sizeWithFontCompatible:self.messageLabel.font forWidth:normalMessageWidth lineBreakMode:NSLineBreakByWordWrapping];


    self.messageLabel.text = self.message;
    [self.alertView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(14);
        make.width.mas_equalTo(rectMessageSize.width);
        make.height.mas_equalTo(rectMessageSize.height);
        make.centerX.mas_equalTo(self.alertView.mas_centerX);
    }];

    //Button
    [self.alertView addSubview:self.nextButton];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(105);
        make.height.mas_equalTo(42);
        make.left.mas_offset(20);
        make.top.mas_equalTo(self.messageLabel.mas_bottom).mas_offset(26);
    }];

    [self.alertView addSubview:self.updateButton];
    [self.updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(105);
        make.height.mas_equalTo(42);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.messageLabel.mas_bottom).mas_offset(26);
    }];

    //alertView frame
//    CGFloat alertViewHeight = self.titleLabel.frame.origin.y + rectTitleSize.height + rectMessageSize.height + 100 + kAlertView_content_offsetX * 2;
    self.alertView.frame = CGRectMake(kAlertView_offsetX, 0, Screen_HC_Width - kAlertView_offsetX * 2, self.updateButton.bottom + 60);
//    self.alertView.frame = CGRectMake(kAlertView_offsetX, 0, Screen_HC_Width - kAlertView_offsetX * 2, alertViewHeight > kAlertView_MAX_Height ? kAlertView_MAX_Height : alertViewHeight);
    self.alertView.center = key_Window.center;
//    _alertView = [[UIView alloc] initWithFrame:CGRectMake(kAlertView_offsetX, 0, Screen_HC_Width - kAlertView_offsetX * 2, kAlertView_MAX_Height / 2)];

    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(Screen_HC_Width - kAlertView_offsetX * 2);
        make.bottom.mas_equalTo(self.updateButton.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(kAlertView_offsetX);
        make.top.mas_equalTo(Screen_HC_Width - kAlertView_offsetX * 2);
//        make.center.mas_equalTo([UIApplication sharedApplication].keyWindow.mas_center);
    }];

//    NSMutableArray *arr = self.items.itemsArray;
//    for (NSDictionary *hcItem in arr) {
//        NSLog(@"items: %@", [hcItem objectForKey:key_HCSelectItem_Title]);
//    }
//npm
//    self.selectedBlock(2);
}

- (void)selectActionWhenTwoItem:(UIButton *)sender {
//    self.selectedBlock(sender.tag);
//    [self hiddenSelf];
}

@end

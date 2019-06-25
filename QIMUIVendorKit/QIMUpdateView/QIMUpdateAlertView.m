//
//  QIMUpdateAlertView.m
//  QIMUIKit
//
//  Created by lilu on 2019/6/25.
//

#import "QIMUpdateAlertView.h"

@interface QIMUpdateAlertView ()

@property(nonatomic, copy) UIImageView *iconView;

@property(nonatomic, copy) UIView *alertView;


@end

@implementation QIMUpdateAlertView

+ (void)qim_showUpdateAlertViewTitle:(NSString *)title message:(NSString *)message selectItemIndex:(NSInteger)index {
    QIMUpdateAlertView *updateView = [[QIMUpdateAlertView alloc] initWithFrame:CGRectZero];
    
}

- (void)qim_showUpdateAlertView:(NSString *)title message:(NSString *)message selectItemIndex:(NSInteger)index {
    
    
}

@end

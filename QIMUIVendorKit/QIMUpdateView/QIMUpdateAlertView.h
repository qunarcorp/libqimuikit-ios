//
//  QIMUpdateAlertView.h
//  QIMUIKit
//
//  Created by lilu on 2019/6/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMUpdateAlertView : UIView

+ (void)qim_showUpdateAlertViewTitle:(NSString *)title message:(NSString *)message selectItemIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

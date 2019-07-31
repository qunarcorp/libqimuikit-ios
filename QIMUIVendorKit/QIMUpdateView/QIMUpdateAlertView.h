//
//  QIMUpdateAlertView.h
//  QIMUIKit
//
//  Created by lilu on 2019/6/25.
//

#import <UIKit/UIKit.h>
#import "QIMUpdateDataModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QIMUpgradeNow,    //立即更新
    QIMUpgradeAfter,  //可下次更新
} QIMUpgradeType;

@protocol QIMUpdateAlertViewDelegate <NSObject>

- (void)qim_UpdateAlertViewDidClickWithType:(QIMUpgradeType)type withUpdateDic:(QIMUpdateDataModel *)updateModel;

@end

@interface QIMUpdateAlertView : UIView

@property (nonatomic, weak) id <QIMUpdateAlertViewDelegate> upgradeDelegate;

+ (instancetype)qim_showUpdateAlertViewWithUpdateDic:(NSDictionary *)updateDic;

@end

NS_ASSUME_NONNULL_END

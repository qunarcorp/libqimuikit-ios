//
//  STIMUpdateAlertView.h
//  STIMUIKit
//
//  Created by lilu on 2019/6/25.
//

#import <UIKit/UIKit.h>
#import "STIMUpdateDataModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    STIMUpgradeNow,    //立即更新
    STIMUpgradeAfter,  //可下次更新
} STIMUpgradeType;

@protocol STIMUpdateAlertViewDelegate <NSObject>

- (void)stimDB_UpdateAlertViewDidClickWithType:(STIMUpgradeType)type withUpdateDic:(STIMUpdateDataModel *)updateModel;

@end

@interface STIMUpdateAlertView : UIView

@property (nonatomic, weak) id <STIMUpdateAlertViewDelegate> upgradeDelegate;

+ (instancetype)stimDB_showUpdateAlertViewWithUpdateDic:(NSDictionary *)updateDic;

@end

NS_ASSUME_NONNULL_END

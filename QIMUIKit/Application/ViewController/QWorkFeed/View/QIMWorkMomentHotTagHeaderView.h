//
//  QIMWorkMomentHotTagHeaderView.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import <UIKit/UIKit.h>
#import "QIMCommonUIFramework.h"
#import "QIMWorkMomentHeaderTagInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^tagHeaderChageViewFrameBlock)(CGFloat height);

@interface QIMWorkMomentHotTagHeaderView : UIView
@property (nonatomic,copy) tagHeaderChageViewFrameBlock changeHeightBolck;
- (void)setHeaderModel:(QIMWorkMomentHeaderTagInfoModel *)model;
@end

NS_ASSUME_NONNULL_END

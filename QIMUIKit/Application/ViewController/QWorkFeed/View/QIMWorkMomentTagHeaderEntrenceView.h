//
//  QIMWorkMomentTagHeaderEntrenceView.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^jumpHandlerBlock)(NSInteger tag);
@interface QIMWorkMomentTagHeaderEntrenceView : UIView

@property (nonatomic,copy) jumpHandlerBlock jumpBlock;

@end

NS_ASSUME_NONNULL_END

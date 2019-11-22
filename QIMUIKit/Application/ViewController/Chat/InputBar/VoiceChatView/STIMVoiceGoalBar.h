
#import "STIMCommonUIFramework.h"
#import <QuartzCore/QuartzCore.h>
#import "STIMVoiceGoalBarPercentLayer.h"


@interface STIMVoiceGoalBar : UIView {
    UIImage * thumb;
    STIMVoiceGoalBarPercentLayer *percentLayer;
    CALayer *thumbLayer;
}

@property (nonatomic, strong) UILabel *percentLabel;

- (void)setPercent:(int)percent animated:(BOOL)animated;

@end

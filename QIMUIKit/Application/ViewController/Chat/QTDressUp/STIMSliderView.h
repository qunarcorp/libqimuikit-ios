//
//  STIMSliderView.h
//  STChatIphone
//
//  Created by haibin.li on 16/3/7.
//
//

#import "STIMCommonUIFramework.h"

@class STIMSliderView;
@protocol STIMSliderViewDelegate <NSObject>

- (void)sliderView:(STIMSliderView *)slider didChangeSelectedValue:(NSInteger)index;

@end

@interface STIMSliderView : UIView

@property (nonatomic,assign) id<STIMSliderViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame;

@end

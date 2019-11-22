//
//  STIMInputPopView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/9/22.
//
//

#import "STIMCommonUIFramework.h"

@class STIMInputPopView;

@protocol STIMInputPopViewDelegate <NSObject>

- (void)inputPopView:(STIMInputPopView *)view willBackWithText:(NSString *)text;

- (void)cancelForSTIMInputPopView:(STIMInputPopView *)view;

@end

@interface STIMInputPopView : UIView

@property (nonatomic,assign) id<STIMInputPopViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setTitle:(NSString *)title;

- (void)showInView:(UIView *)superView;

@end

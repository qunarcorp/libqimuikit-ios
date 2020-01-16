//
//  QTImageAssetTipView.h
//  STChatIphone
//
//  Created by admin on 15/8/18.
//
//

//#import "STIMCommonUIFramework.h"
#import "STIMCommonUIFramework.h"

@protocol QTImageAssetTapViewDelegate <NSObject>
@optional
-(void)touchSelect:(BOOL)select;
-(BOOL)shouldTap;
@end
@interface QTImageAssetTapView : UIView
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, weak) id<QTImageAssetTapViewDelegate> delegate;
@end

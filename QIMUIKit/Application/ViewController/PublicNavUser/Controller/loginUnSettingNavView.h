//
//  loginUnSettingNavView.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/7/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol loginUnSettingNavViewDelegate <NSObject>

-(void)showScanViewController;

-(void)showSettingNavViewController;

@end

@interface loginUnSettingNavView : UIView
@property(nonatomic,weak) id<loginUnSettingNavViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<loginUnSettingNavViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END

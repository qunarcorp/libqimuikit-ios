//
//  QIMWorkOwnerCamelTabBar.h
//  QIMUIKit
//
//  Created by Kamil on 2019/5/15.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol QIMWorkOwnerCamelTabBarDelegate <NSObject>

- (void)tabBarBtnClickedIndex:(NSInteger)index;

@end

@interface QIMWorkOwnerCamelTabBar : UIView
@property (nonatomic,weak) id<QIMWorkOwnerCamelTabBarDelegate>delegate;
-(void)viewXOffset:(CGFloat)offset;
@end

NS_ASSUME_NONNULL_END

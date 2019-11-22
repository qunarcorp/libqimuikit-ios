//
//  STIMWorkOwnerCamelTabBar.h
//  STIMUIKit
//
//  Created by Kamil on 2019/5/15.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol STIMWorkOwnerCamelTabBarDelegate <NSObject>

- (void)tabBarBtnClickedIndex:(NSInteger)index;

@end

@interface STIMWorkOwnerCamelTabBar : UIView
@property (nonatomic,weak) id<STIMWorkOwnerCamelTabBarDelegate>delegate;
-(void)viewXOffset:(CGFloat)offset;
@end

NS_ASSUME_NONNULL_END

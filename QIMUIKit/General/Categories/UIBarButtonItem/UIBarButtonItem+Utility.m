//
//  UIBarButtonItem+Utility.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/14.
//
//

#import "UIBarButtonItem+Utility.h"
#import "UIImage+STIMUIKit.h"

@implementation UIBarButtonItem (Utility)


+ (UIBarButtonItem *)createBarButtonItemWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target action:(SEL)action {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
//    NSString *highlightedImageName = [NSString stringWithFormat:@"%@_highted", imageName];
//    [btn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:imageName] forState:UIControlStateNormal];
//    [btn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:highlightedImageName] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end

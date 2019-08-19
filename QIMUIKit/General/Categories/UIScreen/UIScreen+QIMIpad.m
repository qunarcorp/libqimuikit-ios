//
//  UIScreen+QIMIpad.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/6/16.
//
//

#import "UIScreen+QIMIpad.h"
#import "QIMKit.h"
#import "QIMKit+QIMAppInfo.h"

@implementation UIScreen(QIMIpad)

- (CGFloat)qim_dockWidth{
    if ([UIScreen mainScreen].width * 0.06 < 80) {
        return 80;
    }
    return [UIScreen mainScreen].width * 0.06;
}

- (CGFloat)qim_leftWidth {
#if __has_include("QIMIPadWindowManager.h")
    
    if ([[QIMKit sharedInstance] getIsIpad] && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        
        
        
        CGFloat leftWidth = [UIScreen mainScreen].bounds.size.width - [self qim_dockWidth] - [self qim_rightWidth];
        if (leftWidth <= 0) {
            leftWidth = 375;
        }
        return leftWidth;
        //iPad
//        UIView *view = [[[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers firstObject] view];
//        CGFloat width = CGRectGetWidth(view.frame) - [self qim_dockWidth];
//        return width;
        /*
        if ([UIScreen mainScreen].width * 0.21 < 295) {
            return 295;
        }
        return [UIScreen mainScreen].width * 0.21;
        */
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
#else
    return [UIScreen mainScreen].bounds.size.width;
#endif
}

- (CGFloat)qim_rightWidth {
#if __has_include("QIMIPadWindowManager.h")
    if ([[QIMKit sharedInstance] getIsIpad] && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        //iPad
        UIView *view = [[[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers lastObject] view];
        return CGRectGetWidth(view.frame);
    } else {
        return [UIScreen mainScreen].bounds.size.width;
    }
#else
    return [UIScreen mainScreen].bounds.size.width;
#endif
}

- (CGFloat)height{
    return self.bounds.size.height;
}

- (CGFloat)width{
    return self.bounds.size.width;
}
@end

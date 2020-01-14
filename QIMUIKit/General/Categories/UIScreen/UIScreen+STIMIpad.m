//
//  UIScreen+STIMIpad.m
//  STChatIphone
//
//  Created by 平 薛 on 15/6/16.
//
//

#import "UIScreen+STIMIpad.h"
#import "STIMKit.h"
#import "STIMKit+STIMAppInfo.h"

@implementation UIScreen(STIMIpad)

- (CGFloat)stimDB_dockWidth{
    if ([UIScreen mainScreen].width * 0.06 < 80) {
        return 80;
    }
    return [UIScreen mainScreen].width * 0.06;
}

- (CGFloat)stimDB_leftWidth {
#if __has_include("STIMIPadWindowManager.h")
    
    if ([[STIMKit sharedInstance] getIsIpad] && [STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
        
        
        
        CGFloat leftWidth = [UIScreen mainScreen].bounds.size.width - [self stimDB_dockWidth] - [self stimDB_rightWidth];
        if (leftWidth <= 0) {
            leftWidth = 375;
        }
        return leftWidth;
        //iPad
//        UIView *view = [[[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers firstObject] view];
//        CGFloat width = CGRectGetWidth(view.frame) - [self stimDB_dockWidth];
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

- (CGFloat)stimDB_rightWidth {
#if __has_include("STIMIPadWindowManager.h")
    if ([[STIMKit sharedInstance] getIsIpad] && [STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
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

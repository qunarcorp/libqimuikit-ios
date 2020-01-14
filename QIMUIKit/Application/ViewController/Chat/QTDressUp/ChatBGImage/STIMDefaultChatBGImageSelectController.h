//
//  STIMDefaultChatBGImageSelectController.h
//  STChatIphone
//
//  Created by haibin.li on 15/7/17.
//
//
#import "STIMCommonUIFramework.h"

@class STIMDefaultChatBGImageSelectController;
@protocol STIMDefaultChatBGImageSelectControllerDelegate <NSObject>

- (void)defaultSTIMChatBGImageSelectController:(STIMDefaultChatBGImageSelectController *)imagePicker willPopWithImage:(UIImage *)image;

@end

@interface STIMDefaultChatBGImageSelectController : QTalkViewController
@property (nonatomic, assign) id<STIMDefaultChatBGImageSelectControllerDelegate> delegate;
@end

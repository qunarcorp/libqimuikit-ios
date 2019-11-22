//
//  STIMImageEditViewController.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/3.
//
//

#import "STIMCommonUIFramework.h"

@class STIMImageEditViewController;

@protocol STIMImageEditViewControllerDelegate <NSObject>

- (void)imageEditVC:(STIMImageEditViewController *)imageEditVC didEditWithProductImage:(UIImage *)productImage;

@end

@interface STIMImageEditViewController : QTalkViewController

@property (nonatomic, assign) id<STIMImageEditViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL fromAlum;

- (instancetype)initWithImage:(UIImage *)image;

@end

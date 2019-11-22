//
//  STIMChatBGImagePickerController.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@class STIMChatBGImagePickerController;
@protocol STIMChatBGImagePickerControllerDelegate <NSObject>

- (void)imagePicker:(STIMChatBGImagePickerController *)imagePicker willDismissWithImage:(UIImage *)image;

@end

@interface STIMChatBGImagePickerController : QTalkViewController

@property (nonatomic, assign) id<STIMChatBGImagePickerControllerDelegate> delegate;

-(instancetype)initWithImage:(UIImage *)image;

@end

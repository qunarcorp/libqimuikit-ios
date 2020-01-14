//
//  STIMChatBGImageSelectController.h
//  STChatIphone
//
//  Created by haibin.li on 15/7/17.
//
//
#import "STIMCommonUIFramework.h"

@class STIMChatBGImageSelectController;

@protocol STIMChatBGImageSelectControllerDelegate <NSObject>

- (void)ChatBGImageDidSelected:(STIMChatBGImageSelectController *)chatBGImageSelectVC;

@end

@interface STIMChatBGImageSelectController : QTalkViewController

@property (nonatomic ,assign) id<STIMChatBGImageSelectControllerDelegate> delegate;
@property (nonatomic,assign) NSString       * userID;
@property (nonatomic,assign) BOOL             isFromChat;

- (instancetype)initWithCurrentBGImage:(UIImage *)image;

@end

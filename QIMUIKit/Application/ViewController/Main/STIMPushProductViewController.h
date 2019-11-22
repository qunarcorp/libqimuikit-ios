//
//  STIMPushProductViewController.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/26.
//
//

#import "STIMCommonUIFramework.h"

@class STIMPushProductViewController;

@protocol STIMPushProductViewControllerDelegate <NSObject>

- (void)sendProductInfoStr:(NSString *)infoStr productDetailUrl:(NSString *)detlUrl;

@end

@interface STIMPushProductViewController : UIViewController

@property(nonatomic,assign) id<STIMPushProductViewControllerDelegate> delegate;

@end

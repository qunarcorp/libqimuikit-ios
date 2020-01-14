//
//  STIMProgressHUD.h
//  STChatIphone
//
//  Created by Qunar-Lu on 2017/1/14.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMProgressHUD : NSObject

+ (STIMProgressHUD *)sharedInstance;

- (void)showProgressHUDWithTest:(NSString *)text;

- (void)closeHUD;

@end

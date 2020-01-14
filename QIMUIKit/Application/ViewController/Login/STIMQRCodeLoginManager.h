//
//  STIMQRCodeLoginManager.h
//  STChatIphone
//
//  Created by 李海彬 on 2017/10/30.
//

#import "STIMCommonUIFramework.h"

typedef enum {
    STIMQRCodeLoginStateNone = 0,
    STIMQRCodeLoginStateSuccess = 1,
    STIMQRCodeLoginStateFailed,
} STIMQRCodeLoginState;

#define STIMQRCodeLoginStateNotification @"STIMQRCodeLoginStateNotification"

@interface STIMQRCodeLoginManager : NSObject

+ (instancetype)shareSTIMQRCodeLoginManager;

+ (instancetype)shareSTIMQRCodeLoginManagerWithKey:(NSString *)loginKey WithType:(NSString *)type;

+ (instancetype)shareSTIMQRCodeLoginManagerWithKey:(NSString *)loginKey;

/**
 取消登陆
 */
- (void)cancelQRCodeLogin;


/**
 确认登陆
 */
- (void)confirmQRCodeLogin;


/**
 已经确认扫码
 */
- (void)confirmQRCodeAction;

@end

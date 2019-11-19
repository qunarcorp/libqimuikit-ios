//
//  QIMQRCodeLoginManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/10/30.
//

#import "QIMQRCodeLoginManager.h"
#import "QIMJSONSerializer.h"
#import "QIMHTTPRequest.h"
#import "QIMHTTPClient.h"

static QIMQRCodeLoginManager *__qrcodeLoginManager = nil;
@interface QIMQRCodeLoginManager ()

@property (nonatomic, copy) NSString *loginKey;

@property (nonatomic, copy) NSString *type;

@end

@implementation QIMQRCodeLoginManager

+ (instancetype)shareQIMQRCodeLoginManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __qrcodeLoginManager = [[QIMQRCodeLoginManager alloc] init];
    });
    return __qrcodeLoginManager;
}

+ (instancetype)shareQIMQRCodeLoginManagerWithKey:(NSString *)loginKey {
    __qrcodeLoginManager = [QIMQRCodeLoginManager shareQIMQRCodeLoginManager];
    if (loginKey) {
        __qrcodeLoginManager.loginKey = loginKey;
    } else {
        __qrcodeLoginManager.loginKey = @"";
    }
    return __qrcodeLoginManager;
}

+ (instancetype)shareQIMQRCodeLoginManagerWithKey:(NSString *)loginKey WithType:(NSString *)type {
    __qrcodeLoginManager = [QIMQRCodeLoginManager shareQIMQRCodeLoginManager];
    if (loginKey) {
        __qrcodeLoginManager.loginKey = loginKey;
    } else {
        __qrcodeLoginManager.loginKey = @"";
    }
    __qrcodeLoginManager.type = (type.length > 0) ? type : @"";
    return __qrcodeLoginManager;
}

- (void)confirmQRCodeAction {
    
    __weak typeof(self) weakSelf = self;
    NSString *headerUrl = [[QIMKit sharedInstance] getUserBigHeaderImageUrlWithUserId:[[QIMKit sharedInstance] getLastJid]];
    NSString *confirmURL = [NSString stringWithFormat:@"%@/qtapi/common/qrcode/auth.qunar", [[QIMKit sharedInstance] qimNav_Javaurl]];
    NSDictionary *authData = @{@"a" : headerUrl?headerUrl:@"", @"t" : @"1", @"u" : [QIMKit getLastUserName]?[QIMKit getLastUserName]:@""  , @"v" : @"1.0"};
    NSString *authJSON = [[QIMJSONSerializer sharedInstance] serializeObject:authData];
    NSDictionary *param = @{@"qrcodekey" : weakSelf.loginKey ? weakSelf.loginKey : @"", @"phase" : @(1), @"authdata" : authJSON ? authJSON : @""};
    NSMutableData *postData = [NSMutableData dataWithData:[[QIMJSONSerializer sharedInstance] serializeObject:param error:nil]];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMKit sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:confirmURL]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setHTTPBody:postData];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            QIMVerboseLog(@"确认扫码操作");
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)confirmQRCodeLogin {
    NSString *confirmURL = [NSString stringWithFormat:@"%@/qtapi/common/qrcode/auth.qunar", [[QIMKit sharedInstance] qimNav_Javaurl]];
    NSString * qCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
    NSString * vCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
    NSString * tCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
    NSDictionary *authData = @{@"d" : @{@"q" : qCookie ? qCookie : @"", @"v" : vCookie ? vCookie : @"", @"t" : tCookie ? tCookie : @""}, @"p" : @"qchat", @"t" : @"1", @"v" : @"1.0"};
    if (self.type.length > 0) {
        authData = @{@"d" : @{@"q_ckey" : [[QIMKit sharedInstance] thirdpartKeywithValue]}, @"p" : @"qchat", @"t" : @"1", @"v" : @"1.0"};
    }
    NSString *authJSON = [[QIMJSONSerializer sharedInstance] serializeObject:authData];
    NSDictionary *param = @{@"qrcodekey" : self.loginKey, @"phase" : @(2), @"authdata" : authJSON};
    NSMutableData *postData = [NSMutableData dataWithData:[[QIMJSONSerializer sharedInstance] serializeObject:param error:nil]];
    
    [[QIMKit sharedInstance] sendTPPOSTFormUrlEncodedRequestWithUrl:confirmURL withRequestBodyData:postData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDict = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        QIMVerboseLog(@"二维码确认登陆结果 : %@", responseDict);
        BOOL ret = [responseDict objectForKey:@"ret"];
        NSInteger errcode = [[responseDict objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:QIMQRCodeLoginStateNotification object:@(QIMQRCodeLoginStateSuccess)];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:QIMQRCodeLoginStateNotification object:@(QIMQRCodeLoginStateFailed)];
            });
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)cancelQRCodeLogin {
    NSString *headerUrl = [[QIMKit sharedInstance] getUserBigHeaderImageUrlWithUserId:[[QIMKit sharedInstance] getLastJid]];
    NSString *confirmURL = [NSString stringWithFormat:@"%@/qtapi/common/qrcode/auth.qunar", [[QIMKit sharedInstance] qimNav_Javaurl]];
    NSDictionary *authData = @{@"a" : headerUrl?headerUrl:@"", @"t" : @"4", @"u" : [QIMKit getLastUserName], @"v" : @"1.0"};
    NSString *authJSON = [[QIMJSONSerializer sharedInstance] serializeObject:authData];
    NSDictionary *param = @{@"qrcodekey" : self.loginKey ? self.loginKey : @"", @"phase" : @(2), @"authdata" : authJSON ? authJSON : @""};
    NSMutableData *postData = [NSMutableData dataWithData:[[QIMJSONSerializer sharedInstance] serializeObject:param error:nil]];
    [[QIMKit sharedInstance] sendTPPOSTFormUrlEncodedRequestWithUrl:confirmURL withRequestBodyData:postData withSuccessCallBack:^(NSData *responseData) {
        
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

@end

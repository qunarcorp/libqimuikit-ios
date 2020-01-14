//
//  STIMQRCodeLoginManager.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/10/30.
//

#import "STIMQRCodeLoginManager.h"
#import "STIMJSONSerializer.h"
#import "STIMHTTPRequest.h"
#import "STIMHTTPClient.h"

static STIMQRCodeLoginManager *__qrcodeLoginManager = nil;
@interface STIMQRCodeLoginManager ()

@property (nonatomic, copy) NSString *loginKey;

@property (nonatomic, copy) NSString *type;

@end

@implementation STIMQRCodeLoginManager

+ (instancetype)shareSTIMQRCodeLoginManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __qrcodeLoginManager = [[STIMQRCodeLoginManager alloc] init];
    });
    return __qrcodeLoginManager;
}

+ (instancetype)shareSTIMQRCodeLoginManagerWithKey:(NSString *)loginKey {
    __qrcodeLoginManager = [STIMQRCodeLoginManager shareSTIMQRCodeLoginManager];
    if (loginKey) {
        __qrcodeLoginManager.loginKey = loginKey;
    } else {
        __qrcodeLoginManager.loginKey = @"";
    }
    return __qrcodeLoginManager;
}

+ (instancetype)shareSTIMQRCodeLoginManagerWithKey:(NSString *)loginKey WithType:(NSString *)type {
    __qrcodeLoginManager = [STIMQRCodeLoginManager shareSTIMQRCodeLoginManager];
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
    NSString *headerUrl = [[STIMKit sharedInstance] getUserBigHeaderImageUrlWithUserId:[[STIMKit sharedInstance] getLastJid]];
    NSString *confirmURL = [NSString stringWithFormat:@"%@/qtapi/common/qrcode/auth.qunar", [[STIMKit sharedInstance] qimNav_Javaurl]];
    NSDictionary *authData = @{@"a" : headerUrl?headerUrl:@"", @"t" : @"1", @"u" : [STIMKit getLastUserName]?[STIMKit getLastUserName]:@""  , @"v" : @"1.0"};
    NSString *authJSON = [[STIMJSONSerializer sharedInstance] serializeObject:authData];
    NSDictionary *param = @{@"qrcodekey" : weakSelf.loginKey ? weakSelf.loginKey : @"", @"phase" : @(1), @"authdata" : authJSON ? authJSON : @""};
    NSMutableData *postData = [NSMutableData dataWithData:[[STIMJSONSerializer sharedInstance] serializeObject:param error:nil]];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMKit sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:confirmURL]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setHTTPBody:postData];
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            STIMVerboseLog(@"确认扫码操作 : %@", response.responseString);
        }
    } failure:^(NSError *error) {
        
    }];
    
    /*
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:confirmURL]];
    [request setRequestMethod:@"POST"];
    [request setPostBody:postData];
    [request setUseCookiePersistence:NO];

    [request setRequestHeaders:cookieProperties];
    [request startSynchronous];
    if ([request responseStatusCode] == 200 && ![request error]) {
        STIMVerboseLog(@"确认扫码操作 : %@", request.responseString);
    } */
}

- (void)confirmQRCodeLogin {
    NSString *confirmURL = [NSString stringWithFormat:@"%@/qtapi/common/qrcode/auth.qunar", [[STIMKit sharedInstance] qimNav_Javaurl]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:confirmURL]];
    NSString * qCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
    NSString * vCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
    NSString * tCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
    NSDictionary *authData = @{@"d" : @{@"q" : qCookie ? qCookie : @"", @"v" : vCookie ? vCookie : @"", @"t" : tCookie ? tCookie : @""}, @"p" : @"qchat", @"t" : @"1", @"v" : @"1.0"};
    if (self.type.length > 0) {
        authData = @{@"d" : @{@"q_ckey" : [[STIMKit sharedInstance] thirdpartKeywithValue]}, @"p" : @"qchat", @"t" : @"1", @"v" : @"1.0"};
    }
    NSString *authJSON = [[STIMJSONSerializer sharedInstance] serializeObject:authData];
    NSDictionary *param = @{@"qrcodekey" : self.loginKey, @"phase" : @(2), @"authdata" : authJSON};
    NSMutableData *postData = [NSMutableData dataWithData:[[STIMJSONSerializer sharedInstance] serializeObject:param error:nil]];
    [request setRequestMethod:@"POST"];
    [request setPostBody:postData];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMKit sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setRequestHeaders:cookieProperties];
    [request startSynchronous];
    if ([request responseStatusCode] == 200 && ![request error]) {
        STIMVerboseLog(@"二维码确认登陆结果 : %@", request.responseString);
        NSDictionary *responseDict = [[STIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [responseDict objectForKey:@"ret"];
        NSInteger errcode = [[responseDict objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:STIMQRCodeLoginStateNotification object:@(STIMQRCodeLoginStateSuccess)];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:STIMQRCodeLoginStateNotification object:@(STIMQRCodeLoginStateFailed)];
            });
        }
    }
}

- (void)cancelQRCodeLogin {
    NSString *headerUrl = [[STIMKit sharedInstance] getUserBigHeaderImageUrlWithUserId:[[STIMKit sharedInstance] getLastJid]];
    NSString *confirmURL = [NSString stringWithFormat:@"%@/qtapi/common/qrcode/auth.qunar", [[STIMKit sharedInstance] qimNav_Javaurl]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:confirmURL]];
    NSDictionary *authData = @{@"a" : headerUrl?headerUrl:@"", @"t" : @"4", @"u" : [STIMKit getLastUserName], @"v" : @"1.0"};
    NSString *authJSON = [[STIMJSONSerializer sharedInstance] serializeObject:authData];
    NSDictionary *param = @{@"qrcodekey" : self.loginKey ? self.loginKey : @"", @"phase" : @(2), @"authdata" : authJSON ? authJSON : @""};
    NSMutableData *postData = [NSMutableData dataWithData:[[STIMJSONSerializer sharedInstance] serializeObject:param error:nil]];
    [request setRequestMethod:@"POST"];
    [request setPostBody:postData];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMKit sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setRequestHeaders:cookieProperties];
    [request startSynchronous];
    if ([request responseStatusCode] == 200 && ![request error]) {
        STIMVerboseLog(@"%@", request.responseString);
    }
}

@end

//
//  QTalkAuth.m
//  STChatIphone
//
//  Created by wangyu.wang on 16/4/5.
//
//


#import "QimRNBModule.h"
#if __has_include("STIMFlutterModule.h")
#import "STIMFlutterModule.h"
#endif

#import "STIMMainVC.h"
#import "UIApplication+STIMApplication.h"
#import "QimRNBModule+TravelCalendar.h"
#import "QimRNBModule+STIMLocalSearch.h"
#import "QimRNBModule+STIMUser.h"
#import "QimRNBModule+STIMGroup.h"
#import "QimRNBModule+MySetting.h"
#import "NSBundle+STIMLibrary.h"
#import "STIMRNBaseVc.h"
#import "STIMCommonUIFramework.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "TOTPGenerator.h"
#import "QRCodeGenerator.h"
#import "STIMWebView.h"
#import "STIMChatVC.h"
#import "STIMMainVC.h"
#import "STIMPinYinForObjc.h"
#import "STIMMessageHelperVC.h"
#import "STIMGroupListVC.h"
#import "STIMPublicNumberVC.h"
#import "STIMRNExternalAppManager.h"
#import "STIMDressUpController.h"
#import "STIMFileManagerViewController.h"
#import "STIMQNValidationFriendVC.h"
#import "STIMValidationFriendVC.h"
#import "STIMFriendSettingCell.h"
#import "STIMPGroupSelectionView.h"
#import "STIMJumpURLHandle.h"
#import "STIMAboutVC.h"
#import "STIMProgressHUD.h"
#import "STIMPublicNumberSearchVC.h"
#import "STIMMySettingController.h"
#import "STIMServiceStatusViewController.h"
#import "STIMJSONSerializer.h"
#import "STIMDataController.h"
#import "STIMUUIDTools.h"
#import "STIMGroupChatVC.h"
#import "STIMSwitchAccountView.h"
#import "SCLAlertView.h"
#import "NSDate+Extension.h"
#import "UIView+STIMToast.h"
#import "STIMPublicRedefineHeader.h"
#import "STIMAddIndexViewController.h"
#import "STIMUserCacheManager.h"
#if __has_include("STIMIPadWindowManager.h")
#import "STIMIPadWindowManager.h"
#endif

#if __has_include("STIMLocalLog.h")
#import "STIMLocalLog.h"
#endif
#if __has_include("STIMAutoTracker.h")
#import "STIMAutoTracker.h"
#endif

#define MyRedBag @"MyRedBag"
#define BalanceInquiry @"BalanceInquiry"
#define AccountInfo @"AccountInfo"
#define MyFile @"MyFile"
#define MyMedal @"MyMedal"

@interface STIMRCTRootView : RCTRootView
@property (nonatomic, weak) UIViewController *ownerVC;
@property (nonatomic, strong) NSString *title;
@end
@implementation STIMRCTRootView

- (instancetype)initWithBridge:(RCTBridge *)bridge moduleName:(NSString *)moduleName initialProperties:(NSDictionary *)initialProperties {
    if (self = [super initWithBridge:bridge moduleName:moduleName initialProperties:initialProperties]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAccountInfo:) name:kNotifySwichUserSuccess object:nil];
        if ([[STIMKit sharedInstance] getIsIpad]) {
            self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] stimDB_rightWidth], [[UIScreen mainScreen] height]);
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.ownerVC.navigationItem setTitle:self.title];
}

- (void)reloadAccountInfo:(NSNotification *)notify {
    BOOL switchAccountSuccess = [notify.object boolValue];
    if (switchAccountSuccess) {
        STIMVerboseLog(@"刷新一下RN我的页面");
        [self.bridge.eventDispatcher sendAppEventWithName:@"STIM_RN_Will_Show" body:@{@"name": self.moduleName}];
    }
}

@end

@interface QimRNBModule () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) STIMSwitchAccountView *accountCollectionView;
@property (nonatomic, strong) SCLAlertView *swicthAccountAlert;
@property (nonatomic, strong) SCLAlertView *waitingAlert;

@end

@implementation QimRNBModule

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {
    return @{@"greeting": @"Welcome to the DevDactic\n React Native Tutorial!"};
}

RCT_EXPORT_METHOD(getTOTP:(RCTResponseSenderBlock)success) {
    NSString *secret = [NSString stringWithFormat:@"u=%@&k=%@",[[STIMKit sharedInstance] getLastJid],[[STIMKit sharedInstance] myRemotelogginKey]];
    NSData *secretData = [secret dataUsingEncoding:NSASCIIStringEncoding];
    TOTPGenerator *generator = [[TOTPGenerator alloc] initWithSecret:secretData
                                                           algorithm:kOTPGeneratorSHA1Algorithm
                                                              digits:6
                                                              period:30];
    long long time = [[NSDate date] timeIntervalSince1970] - [[STIMKit sharedInstance] getServerTimeDiff];
    NSString *str = [generator generateOTPForTimeInterval:time];
    while (str.length < 6) {
        str = [NSString stringWithFormat:@"0%@",str];
    }
    success(@[@{@"totp":str,@"time":@(time)}]);
}

RCT_EXPORT_METHOD(appConfig:(RCTResponseSenderBlock)success) {

    NSInteger projectType = ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) ? 0 : 1;
    NSString *ckey = [[STIMKit sharedInstance] thirdpartKeywithValue];
    NSString *ip = @"0.0.0.0";
    NSString *userId = [STIMKit getLastUserName];
    NSString *httpHost = [[STIMKit sharedInstance] qimNav_Javaurl];
    BOOL WorkFeedEntrance = [[[STIMKit sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"] boolValue];
    BOOL isShowRedPackage = YES;
    BOOL isEasyTrip = NO;
    BOOL notNeedShowEmailInfo = ([[STIMKit sharedInstance] qimNav_Email].length > 0) ? NO : YES;
    BOOL notNeedShowLeaderInfo = ([[STIMKit sharedInstance] qimNav_LeaderUrl].length > 0) ? NO : YES;
    BOOL notNeedShowMobileInfo = ([[STIMKit sharedInstance] qimNav_Mobileurl].length > 0) ? NO : YES;
    BOOL notNeedShowCamelNotify = NO;
    BOOL isToCManager = NO;
    if([[STIMKit sharedInstance] userObjectForKey:@"isToCManager"]){
        isToCManager = [[[STIMKit sharedInstance] userObjectForKey:@"isToCManager"] boolValue];
    }
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeStartalk) {
        isShowRedPackage = NO;
        isEasyTrip = YES;
        notNeedShowCamelNotify = YES;
    } else {
        isEasyTrip = [[[STIMKit sharedInstance] getDomain] isEqualToString:@"ejabhost1"] ? NO : YES;
        notNeedShowCamelNotify = [[[STIMKit sharedInstance] getDomain] isEqualToString:@"ejabhost1"] ? NO : YES;
    }
    BOOL oldAuthSign = [[[STIMKit sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"] boolValue];
    BOOL checkAuthSignKey = [[STIMKit sharedInstance] containsObjectForKey:@"kUserWorkFeedEntrance"];
    if (checkAuthSignKey == NO) {
        oldAuthSign = YES;
    }
    NSArray *appConfig = @[@{@"projectType" : @(projectType), @"isQtalk" : @(!projectType), @"nativeAppType" : @([STIMKit getSTIMProjectType]), @"ckey" : ckey,@"clientIp" : ip,@"userId" : userId,@"domain" : [[STIMKit sharedInstance] qimNav_Domain]?[[STIMKit sharedInstance] qimNav_Domain]:@"", @"httpHost" : httpHost, @"RNAboutView" : @(0), @"RNMineView": @([[STIMKit sharedInstance] qimNav_RNMineView]), @"RNGroupCardView": @([[STIMKit sharedInstance] qimNav_RNGroupCardView]), @"RNContactView": @([[STIMKit sharedInstance] qimNav_RNContactView]), @"RNSettingView" : @([[STIMKit sharedInstance] qimNav_RNSettingView]), @"RNUserCardView" : @([[STIMKit sharedInstance] qimNav_RNUserCardView]), @"RNGroupListView": @([[STIMKit sharedInstance] qimNav_RNGroupListView]), @"RNPublicNumberListView" : @([[STIMKit sharedInstance] qimNav_RNPublicNumberListView]), @"showOrganizational" : @([[STIMKit sharedInstance] qimNav_ShowOrganizational]), @"showOA" : @([[STIMKit sharedInstance] qimNav_ShowOA]), @"qcAdminHost": [[STIMKit sharedInstance] qimNav_QCHost]?[[STIMKit sharedInstance] qimNav_QCHost]:@"", @"showServiceState": @([[STIMKit sharedInstance] isMerchant]), @"fileUrl":[[STIMKit sharedInstance] qimNav_InnerFileHttpHost]?[[STIMKit sharedInstance] qimNav_InnerFileHttpHost]:@"", @"isShowWorkWorld":@(oldAuthSign), @"isShowGroupQRCode":@(YES), @"isShowLocalQuickSearch":@(YES), @"isShowRedPackage":@(isShowRedPackage), @"isEasyTrip":@(isEasyTrip), @"isiOSIpad":@([[STIMKit sharedInstance] getIsIpad]), @"ScreenWidth":@([[UIScreen mainScreen] stimDB_rightWidth]), @"notNeedShowEmailInfo":@(notNeedShowEmailInfo), @"notNeedShowMobileInfo":@(notNeedShowMobileInfo), @"notNeedShowLeaderInfo":@(notNeedShowLeaderInfo), @"notNeedShowCamelNotify":@(notNeedShowCamelNotify),
                             @"isToCManager":@(isToCManager)}];
    STIMVerboseLog(@"AppConfig : %@", appConfig);
    success(appConfig);
}

RCT_EXPORT_METHOD(updateRemoteKey:(RCTResponseSenderBlock)success) {
    if ([[STIMKit sharedInstance] updateRemoteLoginKey]) {
        success(@[@{@"ok":@(YES)}]);
    } else {
        success(@[@{@"ok":@(NO)}]);
    }
}

RCT_EXPORT_METHOD(updateNavTitle:(NSString *)navTitle) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [navVC.navigationItem setTitle:navTitle];
    });
}

/**
 打开RN页面
 */
RCT_EXPORT_METHOD(openRNPage:(NSDictionary *)params :(RCTResponseSenderBlock)success) {
    NSString *bundleName = [params objectForKey:@"Bundle"];
    NSString *moduleName = [params objectForKey:@"Module"];
    NSString *properties = [params objectForKey:@"Properties"];
    STIMAppType AppType = [[params objectForKey:@"AppType"] integerValue];
    NSString *bundleVersion = [params objectForKey:@"Version"];
    BOOL showNativeNav = [[params objectForKey:@"showNativeNav"] boolValue];
    switch (AppType) {
        case STIMAppExternal: {
            //本地Check
            NSString *bundleUrl = [params objectForKey:@"BundleUrls"];
            if (bundleUrl.length > 0) {
                NSString *bundleMd5Name = [[[STIMKit sharedInstance] stimDB_cachedFileNameForKey:bundleUrl] stringByAppendingFormat:@".jsbundle"];
                BOOL check = [[STIMRNExternalAppManager sharedInstance] checkSTIMRNExternalAppWithBundleUrl:bundleUrl];
                if (check) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                        if (!navVC) {
                            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                        }
                        NSDictionary *rnProperties = [[STIMJSONSerializer sharedInstance] deserializeObject:properties error:nil];
                        @try {
                            [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:showNativeNav WithBundleName:bundleMd5Name WithModule:moduleName WithProperties:rnProperties];
                        } @catch (NSException *exception) {
                            STIMVerboseLog(@"exception1 - %@", exception);
                        } @finally {
                            STIMVerboseLog(@"finally -");
                        }
                        
                    });
                } else {
                    //Download
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[STIMProgressHUD sharedInstance] showProgressHUDWithTest:@"正在下载/更新应用"];
                    });
                    BOOL updateSuccess = [[STIMRNExternalAppManager sharedInstance] downloadSTIMRNExternalAppWithBundleParams:params];
                    if (updateSuccess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[STIMProgressHUD sharedInstance] closeHUD];
                        });
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                            if (!navVC) {
                                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                            }
                            NSDictionary *rnProperties = [[STIMJSONSerializer sharedInstance] deserializeObject:properties error:nil];
                            @try {
                                [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:showNativeNav WithBundleName:bundleMd5Name WithModule:moduleName WithProperties:properties];
                            } @catch (NSException *exception) {
                                STIMVerboseLog(@"exception2 - %@", exception);
                            } @finally {
                                STIMVerboseLog(@"finally");
                            }
                            
                        });
                    } else {
                        STIMVerboseLog(@"更新失败");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[STIMProgressHUD sharedInstance] showProgressHUDWithTest:@"打开应用失败，请移步网络状态良好的地方打开"];
                            [[STIMProgressHUD sharedInstance] closeHUD];
                        });
                    }
                }
            }
        }
            break;
        case STIMAppTypeH5: {
            NSString *webUrl = [params objectForKey:@"memberAction"];
            BOOL shownav = [[params objectForKey:@"showNativeNav"] boolValue];
            if (webUrl.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [STIMFastEntrance openWebViewForUrl:webUrl showNavBar:shownav];
                });
            }
        }
            break;
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                }
                [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:bundleName WithModule:moduleName WithProperties:properties];
            });
        }
            break;
    }
}

/**
 打开Native页面
 */
RCT_EXPORT_METHOD(openNativePage:(NSDictionary *)params){
    NSString *nativeName = [params objectForKey:@"NativeName"];
    if ([nativeName isEqualToString:MyRedBag]) {
        // 我的红包
        [STIMFastEntrance openWebViewForUrl:[[STIMKit sharedInstance] myRedpackageUrl] showNavBar:YES];
    } else if ([nativeName isEqualToString:BalanceInquiry]) {
        // 余额查询
        [STIMFastEntrance openWebViewForUrl:[[STIMKit sharedInstance] redPackageBalanceUrl] showNavBar:YES];
    } else if ([nativeName isEqualToString:AccountInfo]) {
        
        [STIMFastEntrance openMyAccountInfo];
    } else if ([nativeName isEqualToString:MyFile]) {
       
        [STIMFastEntrance openMyFileVC];
    } else if ([nativeName isEqualToString:MyMedal]) {
        //打开我的勋章
        NSString *userId = [params objectForKey:@"userId"];
        [STIMFastEntrance openUserMedalFlutterWithUserId:userId];
    } else if ([nativeName isEqualToString:@"NotReadMsg"]){
        
        [STIMFastEntrance openNotReadMessageVC];
    } else if ([nativeName isEqualToString:@"FriendList"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [STIMFastEntrance openUserFriendsVC];
        });
    } else if ([nativeName isEqualToString:@"GroupList"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [STIMFastEntrance openSTIMGroupListVC];
        });
    } else if ([nativeName isEqualToString:@"PublicNo"]){
        
        [STIMFastEntrance openSTIMPublicNumberVC];
    } else if ([nativeName isEqualToString:@"GroupChat"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *groupId = [params objectForKey:@"GroupId"];
            [STIMFastEntrance openGroupChatVCByGroupId:groupId];
        });
    } else if ([nativeName isEqualToString:@"SearchContact"]){
        
        [STIMFastEntrance openRNSearchVC];
    }else if ([nativeName isEqualToString:@"OpenToCManager"]){
        [STIMFastEntrance openWebViewForUrl:[[STIMKit sharedInstance] qimNav_getManagerAppUrl] showNavBar:YES];
    } else if ([nativeName isEqualToString:@"NavAddress"]) {
        if ([[[STIMKit sharedInstance] qimNav_AppWebHostUrl] length]) {
            NSString *url = [NSString stringWithFormat:@"%@/manage#/nav_code?domain=%@", [[STIMKit sharedInstance] qimNav_AppWebHostUrl], [[STIMKit sharedInstance] getDomain]];
            [STIMFastEntrance openWebViewForUrl:url showNavBar:YES];
        }
    } else if ([nativeName isEqualToString:@"PublicNumberChat"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *publicNumberId = [params objectForKey:@"PublicNumberId"];
            [STIMFastEntrance openRobotChatVC:publicNumberId];
        });
    } else if ([nativeName isEqualToString:@"Organizational"]) {
        
        [STIMFastEntrance openOrganizationalVC];
    } else if ([nativeName isEqualToString:@"NativeSetting"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            STIMMySettingController *settingVc = [[STIMMySettingController alloc] init];
            [navVC pushViewController:settingVc animated:YES];
        });
    } else if ([nativeName isEqualToString:@"searchChatHistory"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *searchMsgUrl = [NSString stringWithFormat:@"%@/lookback/main_controller.php", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost]];
            if (searchMsgUrl.length > 0) {
                [STIMFastEntrance openWebViewForUrl:searchMsgUrl showNavBar:YES];
            }
        });
    } else if ([nativeName isEqualToString:@"DomainSearch"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            STIMAddIndexViewController *indexVC = [[STIMAddIndexViewController alloc] init];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            [navVC pushViewController:indexVC animated:YES];
#if __has_include("STIMAutoTracker.h")
            [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"add a contact" withDescription:@"添加联系人"];
#endif
        });
    }
}

RCT_EXPORT_METHOD(exitApp:(NSString *)rnName) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyVCClose object:rnName];
    });
}

+ (void)reloadBridgeCache {
    [__innerCacheBridge.eventDispatcher sendAppEventWithName:@"STIM_RN_Refresh_Count" body:nil];
}

+ (void)loadBridgeCache{
    if (__innerCacheBridge == nil) {
        [QimRNBModule getBridgeByBundleName:[QimRNBModule getInnerBundleName]];
    }
}

+ (RCTBridge *)getBridgeByBundleName:(NSString*)bundleName{
    if ([[QimRNBModule getInnerBundleName] isEqualToString:bundleName]) {
        if (__innerCacheBridge == nil) {
            __innerCacheBridge = [[RCTBridge alloc] initWithBundleURL:[QimRNBModule getJsCodeLocation] moduleProvider:nil launchOptions:nil];
        }
        return __innerCacheBridge;
    } else {
        return [[RCTBridge alloc] initWithBundleURL:[QimRNBModule getOuterJsLocation:bundleName] moduleProvider:nil launchOptions:nil];
    }
}

+ (RCTBridge *)getStaticCacheBridge {
    return __innerCacheBridge;
}

/**
 外部应用JSLocation
 */
+ (NSURL *)getOuterJsLocation:(NSString *)bundleName {
    NSString *localJSCodeFileStr = [[UserCachesPath stringByAppendingPathComponent: [QimRNBModule getCachePath]] stringByAppendingPathComponent: [NSString stringWithFormat:@"%@", bundleName]];
    if (localJSCodeFileStr && [[NSFileManager defaultManager] fileExistsAtPath:localJSCodeFileStr]) {
        STIMVerboseLog(@"本地缓存的更新包地址 : %@", localJSCodeFileStr);
    } else {
        
    }
    NSURL *jsCodeLocation = [NSURL URLWithString:localJSCodeFileStr];
    return jsCodeLocation;
}

/**
 内嵌应用JSLocation
 */
+ (NSURL *)getJsCodeLocation {
//    return [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];

    NSString *qtalkFoundRNDebugUrlStr = [[STIMKit sharedInstance] userObjectForKey:@"qtalkFoundRNDebugUrl"];
    if (qtalkFoundRNDebugUrlStr.length > 0) {
        NSURL *qtalkFoundRNDebugUrlStrUrl = [NSURL URLWithString:qtalkFoundRNDebugUrlStr];
        return qtalkFoundRNDebugUrlStrUrl;
    } else {
        NSString *innerJsCodeLocation = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"QIMRNKit" BundleName:@"QIMRNKit" pathForResource:[QimRNBModule getInnerBundleName] ofType:@"jsbundle"];
        NSString *localJSCodeFileStr = [[UserCachesPath stringByAppendingPathComponent: [QimRNBModule getCachePath]] stringByAppendingPathComponent: [QimRNBModule getAssetBundleName]];
        if (localJSCodeFileStr && [[NSFileManager defaultManager] fileExistsAtPath:localJSCodeFileStr]) {
            STIMVerboseLog(@"本地缓存的更新包地址 : %@", localJSCodeFileStr);
            innerJsCodeLocation = localJSCodeFileStr;
        } else {
            
        }
        NSURL *jsCodeLocation = [NSURL URLWithString:innerJsCodeLocation];
        return jsCodeLocation;
    }
}

+ (UIViewController *)clockOnVC {
    STIMRNBaseVc *vc = [[STIMRNBaseVc alloc] init];
    vc.rnName = @"ClockIn";
    NSURL *jsCodeLocation = [QimRNBModule getJsCodeLocation];
    
    STIMRCTRootView *rootView = [[STIMRCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                              moduleName:@"ClockIn"
                                                       initialProperties:nil
                                                           launchOptions:nil];
    
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    vc.view = rootView;
    return vc;
}

+ (UIViewController *)TOTPVC {
    [[STIMKit sharedInstance] updateRemoteLoginKey];
    STIMRNBaseVc *vc = [[STIMRNBaseVc alloc] init];
    [vc setHiddenNav:YES];
    vc.rnName = @"TOTP";
    NSURL *jsCodeLocation = [QimRNBModule getJsCodeLocation];
    STIMRCTRootView *rootView = [[STIMRCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                              moduleName:@"TOTP"
                                                       initialProperties:nil
                                                           launchOptions:nil];
    
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    vc.view = rootView;
    return vc;
}

+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module{
    [self openVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:nil];
}

+ (UIViewController *)getVCWithParam:(NSDictionary *)param {
    UINavigationController *navVC = [param objectForKey:@"navVC"];
    BOOL hiddenNav = [[param objectForKey:@"hiddenNav"] boolValue];
    NSString *bundleName = [param objectForKey:@"bundleName"];
    if (bundleName.length < 0 || !bundleName) {
        bundleName = [QimRNBModule getInnerBundleName];
    }
    NSString *module = [param objectForKey:@"module"];
    NSDictionary *properties = [param objectForKey:@"properties"];
    return [self getVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:properties];
}

+ (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                           WithBundleName:(NSString *)bundleName
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties {
    STIMRNBaseVc *vc = [[STIMRNBaseVc alloc] init];
    vc.rnName = module;
    vc.hiddenNav = hiddenNav;
    vc.bridge = [QimRNBModule getBridgeByBundleName:bundleName];
    STIMRCTRootView *rootView = [[STIMRCTRootView alloc] initWithBridge:vc.bridge moduleName:module initialProperties:properties];
    rootView.frame = vc.view.bounds;
    [vc.view addSubview:rootView];
    vc.view.backgroundColor = [UIColor whiteColor];
    return vc;
}

+ (void)openSTIMRNVCWithParam:(NSDictionary *)param {
    UINavigationController *navVC = [param objectForKey:@"navVC"];
    BOOL hiddenNav = [[param objectForKey:@"hiddenNav"] boolValue];
    NSString *bundleName = [param objectForKey:@"bundleName"];
    if (bundleName.length < 0 || !bundleName) {
        bundleName = [QimRNBModule getInnerBundleName];
    }
    NSString *module = [param objectForKey:@"module"];
    NSDictionary *properties = [param objectForKey:@"properties"];
    [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:properties];
}

+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module
              WithProperties:(NSDictionary *)properties{
    UIViewController *vc = [QimRNBModule getVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:properties];
    //Mark by oldiPad
    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
#if __has_include("STIMIPadWindowManager.h")
        [[STIMIPadWindowManager sharedInstance] showDetailViewController:vc];
#endif
    } else {
        [navVC pushViewController:vc animated:YES];
    }
    /* mark by newipad
    [navVC pushViewController:vc animated:YES];
    */
}

+ (void)sendSTIMRNWillShow {
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"STIM_RN_Will_Show" body:@{@"name": @"aaa"}];
}

+ (id)createSTIMRNVCWithParam:(NSDictionary *)param {
    NSString *bundleName = [param objectForKey:@"bundleName"];
    if (bundleName.length < 0 || !bundleName) {
        bundleName = [QimRNBModule getInnerBundleName];
    }
    NSString *module = [param objectForKey:@"module"];
    NSDictionary *properties = [param objectForKey:@"properties"];
    return [QimRNBModule createSTIMRNVCWithBundleName:bundleName WithModule:module WithProperties:properties];
}

+ (id)createSTIMRNVCWithBundleName:(NSString *)bundleName
                       WithModule:(NSString *)module
                   WithProperties:(NSDictionary *)properties{
    STIMRNBaseVc *vc = [[STIMRNBaseVc alloc] init];
    vc.rnName = module;
    //使用initWithBridge 可以实现对同一个RCTBridge实例的复用
    STIMRCTRootView *rootView = [[STIMRCTRootView alloc] initWithBridge:[QimRNBModule getBridgeByBundleName:bundleName] moduleName:module initialProperties:properties];
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    vc.view = rootView;
    return vc;
}

/*
 * 依赖客户端升级 大版本号
 *
 */
+(NSString *)getAssetBundleName{
    if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
        return @"clock_in.ios.jsbundle_QTalk_V54_215";
    } else if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        return @"clock_in.ios.jsbundle_QChat_V54_5";
    } else {
        return @"clock_in.ios.jsbundle_V54_215";
    }
}

/*
 * 离线资源包 压缩文件名
 *
 */
+(NSString *)getAssetZipBundleName{
    return @"clock_in.ios.jsbundle.tar.gz";
}

/*
 * 内置bundle 文件名
 *
 */
+(NSString *)getInnerBundleName{
    return @"clock_in.ios";
}

/*
 * 缓存路径
 *
 */
+(NSString *)getCachePath{
    return @"rnRes/stimDB_rn/";
}

@end

static NSString *showNumberId = nil;

@implementation QimRNBModule(UserCard)

//打开用户名片
RCT_EXPORT_METHOD(openUserCard:(NSDictionary *)param) {
    NSString *userId = [param objectForKey:@"UserId"];
    if (![userId isEqualToString:[[STIMKit sharedInstance] getLastJid]] && userId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [STIMFastEntrance openUserCardVCByUserId:userId];
        });
    }
}

//获取用户基本信息
RCT_EXPORT_METHOD(getUserInfo:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length <= 0 || !userId) {
        return;
    }
    NSDictionary *properties = [QimRNBModule qimrn_getUserInfoByUserId:userId];
    callback(@[@{@"UserInfo":properties?properties:@{}}]);
}

//获取用户基本信息
RCT_EXPORT_METHOD(getUserInfoByUserCard:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length <= 0 || !userId) {
        return;
    }
    NSDictionary *properties = [QimRNBModule qimrn_getUserInfoByUserId:userId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[STIMKit sharedInstance] updateUserCard:userId withCache:NO];
    });
    NSArray *userMedallist = [QimRNBModule qimrn_getNewUserHaveMedalByUserId:userId];
    
    callback(@[@{@"UserInfo" : properties ? properties : @{}, @"medalList": userMedallist ? userMedallist : @[]}]);
}

//获取单人会话置顶状态
RCT_EXPORT_METHOD(syncChatStickyState:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *realJid = [params objectForKey:@"realJid"];
    NSString *userId = [params objectForKey:@"xmppId"];
    NSString *combineId = (realJid.length > 0) ? [NSString stringWithFormat:@"%@<>%@", userId, realJid] : [NSString stringWithFormat:@"%@<>%@", userId, userId];
    BOOL stickyState = [[STIMKit sharedInstance] isStickWithCombineJid:combineId];
    callback(@[@{@"state" : @(stickyState)}]);
}

//置顶单人会话
RCT_EXPORT_METHOD(updateUserChatStickyState:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *realJid = [params objectForKey:@"realJid"];
    NSString *userId = [params objectForKey:@"xmppId"];
    NSString *combineJid = @"";
    if (realJid.length > 0) {
        combineJid = [NSString stringWithFormat:@"%@<>%@", userId, realJid];
    } else {
        combineJid = [NSString stringWithFormat:@"%@<>%@", userId, userId];
    }
    if ([[STIMKit sharedInstance] isStickWithCombineJid:combineJid]) {
        BOOL success = [[STIMKit sharedInstance] removeStickWithCombineJid:combineJid WithChatType:ChatType_SingleChat];
        callback(@[@{@"ok" : @(success)}]);
    } else {
        BOOL success = [[STIMKit sharedInstance] setStickWithCombineJid:combineJid WithChatType:ChatType_SingleChat];
        callback(@[@{@"ok" : @(success)}]);
    }
}

//用户是否为好友
RCT_EXPORT_METHOD(getFriend:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId) {
        NSDictionary *friendDic = [[STIMKit sharedInstance] selectFriendInfoWithUserId:userId];
        BOOL isFriend = friendDic != nil;
        callback(@[@{@"FriendBOOL" : @(isFriend)}]);
    } else {
        callback(@[@{@"FriendBOOL" : @(NO)}]);
    }
}

//获取用户个性签名
RCT_EXPORT_METHOD(getUserMood:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length > 0) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSString *mood = [QimRNBModule qimrn_getUserMoodByUserId:userId];
        [properties setObject:mood ? mood : @"" forKey:@"Mood"];
        callback(@[@{@"UserInfo" : properties ? properties : @""}]);
    }
}

//获取用户勋章列表
RCT_EXPORT_METHOD(getUserMedal:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length > 0) {
        NSArray *userMedal = [QimRNBModule qimrn_getUserMedalByUserId:userId];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[STIMKit sharedInstance] getRemoteUserMedalWithXmppJid:userId];
        });
        callback(@[@{@"UserMedal" : userMedal ? userMedal : @[]}]);
    }
}

//获取Leader信息
RCT_EXPORT_METHOD(getUserLead:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    NSDictionary *userWorkInfo = nil;
    if (userId.length > 0) {
        NSDictionary *properties = [QimRNBModule qimrn_getUserLeaderInfoByUserId:userId];
        callback(@[@{@"UserInfo":properties ? properties : @{}}]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[STIMKit sharedInstance] getRemoteUserWorkInfoWithUserId:userId withCallBack:nil];
        });
    }
}

// 设置备注名
RCT_EXPORT_METHOD(saveRemark:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *userId = [param objectForKey:@"UserId"];
    NSString *remark = [param objectForKey:@"Remark"];
    NSString *nickName = [param objectForKey:@"Name"];
    [[STIMKit sharedInstance] updateUserMarkupNameWithUserId:userId WithMarkupName:remark];
    callback(@[@{@"ok" : @(YES)}]);
}

//查看手机号
RCT_EXPORT_METHOD(showUserPhoneNumber:(NSDictionary *)param) {
    STIMVerboseLog(@"点击查看用户手机号 : %@", param);
    NSString *userId = [[[param objectForKey:@"UserId"] componentsSeparatedByString:@"@"] firstObject];
    if (!showNumberId) {
        showNumberId = userId;
        [[STIMKit sharedInstance] getPhoneNumberWithUserId:userId withCallBack:^(NSString *phoneNumberStr) {
            if (phoneNumberStr.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = [NSString stringWithFormat:@"手机号:%@", phoneNumberStr];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIPasteboard generalPasteboard] setString:phoneNumberStr];
                        showNumberId = nil;
                    }];
                    UIAlertAction *telAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel:%@", phoneNumberStr]];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                            showNumberId = nil;
                        } else {
                            STIMVerboseLog(@"当前设备不支持呼叫");
                            showNumberId = nil;
                        }
                    }];
                    [alert addAction:copyAction];
                    [alert addAction:telAction];
                    //                UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                    UIViewController *rootVc = [[UIApplication sharedApplication] visibleViewController];
                    [rootVc presentViewController:alert animated:YES completion:nil];
                });
            } else {
                showNumberId = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"没有查询到相应记录" delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil, nil];
                    [alert show];
                });
            }
        }];
    }
}

// 发送邮件
RCT_EXPORT_METHOD(sendEmail:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [[STIMFastEntrance sharedInstance] sendMailWithRootVc:navVC ByUserId:userId];
    });
}

// 评论
RCT_EXPORT_METHOD(commentUser:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
        NSData *userInfoData = [userInfo objectForKey:@"UserInfo"];
        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
        NSString *commentUrl = [dic objectForKey:@"commenturl"];
        NSURL *url = [NSURL URLWithString:commentUrl];
        NSString *query = [url query];
        NSString *baseUrl = nil;
        if (query.length > 0) {
            baseUrl =[commentUrl substringToIndex:commentUrl.length - query.length - 1];
            query = [query stringByAppendingString:@"&"];
        } else {
            baseUrl = commentUrl;
            query = @"";
        }
        if (baseUrl.length > 0) {
            commentUrl = [NSString stringWithFormat:@"%@?%@u=%@&k=%@&t=%@",
                          baseUrl,
                          query,
                          [[STIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [[STIMKit sharedInstance] myRemotelogginKey],
                          [userInfo objectForKey:@"UserId"]];
            [STIMFastEntrance openWebViewForUrl:commentUrl showNavBar:YES];
        }
    });
}

// 查看大头像
RCT_EXPORT_METHOD(browseBigHeader:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BrowseBigHeader" object:param];
    });
    callback(@[@{@"ok" : @(YES)}]);
}

// 打开单人会话
RCT_EXPORT_METHOD(openUserChat:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
        [STIMFastEntrance openSingleChatVCByUserId:userId];
    });
}

//添加好友
RCT_EXPORT_METHOD(addUserFriend:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
        NSDictionary *modeDic = [[STIMKit sharedInstance] getVerifyFreindModeWithXmppId:userId];
        int mode = [[modeDic objectForKey:@"mode"] intValue];
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC setNavigationBarHidden:NO animated:YES];
        switch (mode) {
            case VerifyMode_AllRefused:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Your friend request was rejected."] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
                [alertView show];
            }
                break;
            case VerifyMode_AllAgree:
            {
                [[STIMKit sharedInstance] addFriendPresenceWithXmppId:userId WithAnswer:nil];
            }
                break;
            case VerifyMode_Validation:
            {
                STIMValidationFriendVC *valiVC = [[STIMValidationFriendVC alloc] init];
                [valiVC setXmppId:userId];
                [navVC pushViewController:valiVC animated:YES];
            }
                break;
            case VerifyMode_Question_Answer:
            {
                STIMQNValidationFriendVC *validVC = [[STIMQNValidationFriendVC alloc] init];
                [validVC setValidDic:modeDic];
                [validVC setXmppId:userId];
                [navVC pushViewController:validVC animated:YES];
            }
                break;
            default:
                break;
        }
    });
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"add friends" withDescription:[NSBundle stimDB_localizedStringForKey:@"Add friend"]];
#endif
}

RCT_EXPORT_METHOD(deleteUserFriend:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        UIAlertController *delteFriendSheetVC = [UIAlertController alertControllerWithTitle:@"确定要删除该好友吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除好友" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL isSuccess = [[STIMKit sharedInstance] deleteFriendWithXmppId:userId WithMode:2];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                [[self progressHUD] hide:YES];
                    if (isSuccess) {
                        [navVC popToRootViewControllerAnimated:YES];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"删除好友失败。" delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
                        [alertView show];
                    }
                });
            });
        }];
        [delteFriendSheetVC addAction:cancelAction];
        [delteFriendSheetVC addAction:deleteAction];
        [navVC presentViewController:delteFriendSheetVC animated:YES completion:nil];
    });
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"delete friend" withDescription:@"删除好友"];
#endif
}

@end

@implementation QimRNBModule(GroupCard)

RCT_EXPORT_METHOD(clearImessage:(NSDictionary *)params) {
    STIMVerboseLog(@"param : %@", params);
    NSString *xmppId = [params objectForKey:@"xmppId"];
    [[STIMKit sharedInstance] deleteMessageWithXmppId:xmppId];
}

// 获取群二维码图片
RCT_EXPORT_METHOD(getGroupQRCode:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    UIImage *qrCodeImage = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"qtalk://group?id=%@",groupId] imageSize:256];
    NSString *base64Image = [UIImage stimDB_image2DataURL:qrCodeImage];
    callback(@[@{@"qrCode" : base64Image ? base64Image : @""}]);
}

// 获取群成员列表
RCT_EXPORT_METHOD(getGroupMember:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length <= 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *list = [QimRNBModule qimrn_getGroupMembersByGroupId:groupId];
        callback(@[@{@"GroupMembers" : list, @"ok" : @(YES)}]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[STIMKit sharedInstance] syncgroupMember:groupId];
        });
    });
}

RCT_EXPORT_METHOD(selectMemberFromGroup:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSString *searchText = [param objectForKey:@"searchText"];
    NSArray *userList = [[STIMKit sharedInstance] stIMDB_getGroupMember:groupId BySearchStr:searchText];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *userDic in userList) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *xmppId = [userDic objectForKey:@"xmppjid"];
        NSString *name = [userDic objectForKey:@"name"];
        NSString *headerUri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:xmppId];
        if (headerUri.length <= 0) {
            headerUri = [STIMKit defaultUserHeaderImagePath];
        }
        [dic setSTIMSafeObject:xmppId forKey:@"xmppId"];
        [dic setSTIMSafeObject:name forKey:@"name"];
        [dic setSTIMSafeObject:headerUri forKey:@"headerUri"];
        [array addObject:dic];
    }
    
    callback(@[@{@"UserList" : array, @"ok" : @(YES)}]);
}

RCT_EXPORT_METHOD(selectGroupMemberForKick:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSInteger affiliation = [[param objectForKey:@"affiliation"] integerValue];
    
    NSArray *userList = [[STIMKit sharedInstance] stIMDB_getGroupMember:groupId WithGroupIdentity:affiliation];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *userDic in userList) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *xmppId = [userDic objectForKey:@"xmppjid"];
        NSString *name = [userDic objectForKey:@"name"];
        NSString *userName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:xmppId];
        NSString *headerUri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:xmppId];
        if (headerUri.length <= 0) {
            headerUri = [STIMKit defaultUserHeaderImagePath];
        }
        [dic setSTIMSafeObject:xmppId forKey:@"xmppId"];
        [dic setSTIMSafeObject:(userName.length > 0) ? userName : name forKey:@"name"];
        [dic setSTIMSafeObject:headerUri forKey:@"headerUri"];
        [array addObject:dic];
    }
    
    callback(@[@{@"UserList" : array, @"ok" : @(YES)}]);
}

RCT_EXPORT_METHOD(kickGroupMember:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSDictionary *selectGroupMemebers = [param objectForKey:@"members"];
    BOOL kickSuccess = NO;
    for (NSDictionary *groupMemberDic in [selectGroupMemebers allValues]) {
        NSString *name = [groupMemberDic objectForKey:@"name"];
        NSString *xmppId = [groupMemberDic objectForKey:@"xmppId"];
        NSDictionary *groupMemberInfo = [[STIMKit sharedInstance] getUserInfoByUserId:xmppId];
        NSString *memberName = [groupMemberInfo objectForKey:@"Name"];
        kickSuccess = [[STIMKit sharedInstance] removeGroupMemberWithName:memberName WithJid:xmppId ForGroupId:groupId];
    }
    if (kickSuccess == YES) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"closeKickMembers" body:@{}];
        NSString *str = @"踢出群成员成功";
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject stimDB_makeToast:str];
            });
        });
    } else {
        NSString *str = @"踢出群成员失败";
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject stimDB_makeToast:str];
            });
        });
    }
}

RCT_EXPORT_METHOD(setGroupAdmin:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *name = [param objectForKey:@"name"];
    BOOL isAdmin = [[param objectForKey:@"isAdmin"] boolValue];
    BOOL setSuccess = [[STIMKit sharedInstance] setGroupAdminWithGroupId:groupId withIsAdmin:isAdmin WithAdminNickName:name ForJid:xmppId];
    if (YES == setSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STIMGroupMemberWillUpdate" object:groupId];
        });
    } else {
        
    }
}

RCT_EXPORT_METHOD(showRedView:(RCTResponseSenderBlock)callback) {
    BOOL show = [[[STIMKit sharedInstance] userObjectForKey:@"qimrn_searchlocal"] boolValue];
    callback(@[@{@"show" : @(!show)}]);
}

RCT_EXPORT_METHOD(isShowRedView) {
    [[STIMKit sharedInstance] setUserObject:@(YES) forKey:@"qimrn_searchlocal"];
}

// 获取群PushState
RCT_EXPORT_METHOD(syncPushState:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    BOOL pushState = [[STIMKit sharedInstance] groupPushState:groupId];
    callback(@[@{@"state" : @(pushState)}]);
}

// 更新群PushState
RCT_EXPORT_METHOD(updatePushState:(NSString *)groupId :(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL isSuccess = [[STIMKit sharedInstance] updatePushState:groupId withOn:state];
    callback(@[@{@"ok" : @(isSuccess)}]);
}

//获取群置顶stickyState
RCT_EXPORT_METHOD(syncGroupStickyState:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    NSString *combineId = [NSString stringWithFormat:@"%@<>%@", groupId, groupId];
    BOOL stickyState = [[[STIMKit sharedInstance] stickList] objectForKey:combineId];
    callback(@[@{@"state" : @(stickyState)}]);
}

//更新群置顶状态
RCT_EXPORT_METHOD(updateGroupStickyState:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length > 0) {
        if ([[STIMKit sharedInstance] isStickWithCombineJid:[NSString stringWithFormat:@"%@<>%@", groupId, groupId]]) {
            BOOL isSuccess = [[STIMKit sharedInstance] removeStickWithCombineJid:[NSString stringWithFormat:@"%@<>%@", groupId, groupId] WithChatType:ChatType_GroupChat];
            callback(@[@{@"ok" : @(isSuccess)}]);
        } else {
            BOOL isSuccess = [[STIMKit sharedInstance] setStickWithCombineJid:[NSString stringWithFormat:@"%@<>%@", groupId, groupId] WithChatType:ChatType_GroupChat];
            callback(@[@{@"ok" : @(isSuccess)}]);
        }
    }
}

// 获取群名片信息
RCT_EXPORT_METHOD(getGroupInfo:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length <= 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *properties = [QimRNBModule qimrn_getGroupInfoByGroupId:groupId];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[STIMKit sharedInstance] updateGroupCardByGroupId:groupId];
        });
        callback(@[@{@"ok" : @(YES),@"GroupInfo" : properties ? properties : @{}}]);
    });
}

// 设置群名称
RCT_EXPORT_METHOD(saveGroupName:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"GroupId"];
    NSString *groupName = [param objectForKey:@"GroupName"];
    NSString *groupTopic = [param objectForKey:@"GroupTopic"];

    if (groupTopic.length <= 0) {
        NSDictionary *groupCardDic = [[STIMKit sharedInstance] getGroupCardByGroupId:groupId];
        groupTopic = [groupCardDic objectForKey:@"Topic"];
    }
    [[STIMKit sharedInstance] setMucVcardForGroupId:groupId WithNickName:groupName WithTitle:groupTopic WithDesc:nil WithHeaderSrc:nil withCallBack:^(BOOL successed) {
        callback(@[@{@"ok" : @(successed)}]);
    }];
}

// 设置群公告
RCT_EXPORT_METHOD(saveGroupTopic:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"GroupId"];
    NSString *groupName = [param objectForKey:@"GroupName"];
    NSString *groupTopic = [param objectForKey:@"GroupTopic"];
    if (groupName.length <= 0) {
        NSDictionary *groupCardDic = [[STIMKit sharedInstance] getGroupCardByGroupId:groupId];
        groupName = [groupCardDic objectForKey:@"Name"];
    }
    [[STIMKit sharedInstance] setMucVcardForGroupId:groupId WithNickName:groupName WithTitle:groupTopic WithDesc:nil WithHeaderSrc:nil withCallBack:^(BOOL successed) {
        callback(@[@{@"ok" : @(successed)}]);
    }];
}

// 添加群成员
RCT_EXPORT_METHOD(addGroupMember:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    //如果是群组情况直接添加
    BOOL isGroup = [[param objectForKey:@"isGroup"] boolValue];
    NSDictionary *selectMembers = [param objectForKey:@"members"];
    NSString *groupId = [param objectForKey:@"groupId"];
    if (selectMembers.count <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[STIMKit sharedInstance] clearNotReadMsgByGroupId:groupId];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            [navVC popToRootViewControllerAnimated:NO];
            [STIMFastEntrance openGroupChatVCByGroupId:groupId];
        });
        return;
    }
    NSMutableArray *memberIds = [NSMutableArray arrayWithCapacity:5];
    
    NSMutableString *groupName = [NSMutableString stringWithString:[selectMembers count] > 1 ? @"":@"群组("];
    NSString *nickName = [[STIMKit sharedInstance] getMyNickName];
    
    for (NSDictionary *memberDict in [selectMembers allValues]) {
        NSString *memberName = [memberDict objectForKey:@"name"];
        NSString *memberId = [memberDict objectForKey:@"xmppId"];
        [groupName appendString:memberName];
        [groupName appendString:([memberDict isEqual:[[selectMembers allValues] lastObject]]) ? selectMembers.count>1?@"":@")" :@","];
        [memberIds addObject:memberId];
    }
    
    if (isGroup) {
        [[STIMKit sharedInstance] joinGroupWithBuddies:groupId groupName:@"" WithInviteMember:memberIds withCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[STIMKit sharedInstance] clearNotReadMsgByGroupId:groupId];
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                }
                [navVC popToRootViewControllerAnimated:NO];
                [STIMFastEntrance openGroupChatVCByGroupId:groupId];
            });
        }];
    } else {
        NSString *nickName = [[STIMKit sharedInstance] getMyNickName];
        [[STIMKit sharedInstance] createGroupByGroupName:[STIMUUIDTools UUID]
                                         WithMyNickName:nickName
                                       WithInviteMember:memberIds
                                            WithSetting:[[STIMKit sharedInstance] defaultGroupSetting]
                                               WithDesc:@""
                                      WithGroupNickName:groupName
                                           WithComplate:^(BOOL finish,NSString *groupId) {
                                               if (finish) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [[STIMKit sharedInstance] clearNotReadMsgByGroupId:groupId];
                                                       UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                                                       if (!navVC) {
                                                           navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                                                       }
                                                       [navVC popToRootViewControllerAnimated:NO];
                                                       [STIMFastEntrance openGroupChatVCByGroupId:groupId];
                                                   });
                                               } else {
                                                   
                                               }
                                           }];
    }
}

//退出群组
RCT_EXPORT_METHOD(quitGroup:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length > 0) {
        BOOL result = [[STIMKit sharedInstance] quitGroupId:groupId];
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *combineGroupId = [NSString stringWithFormat:@"%@<>%@", groupId, groupId];
                [[STIMKit sharedInstance] removeStickWithCombineJid:combineGroupId WithChatType:ChatType_GroupChat];
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                }
                [navVC popToRootViewControllerAnimated:YES];
            });
        }
        callback(@[@{@"ok" : @(result)}]);
    }
}

//退出群聊
RCT_EXPORT_METHOD(destructionGroup:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length > 0) {
        BOOL result = [[STIMKit sharedInstance] destructionGroup:groupId];
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *combineGroupId = [NSString stringWithFormat:@"%@<>%@", groupId, groupId];
                [[STIMKit sharedInstance] removeStickWithCombineJid:combineGroupId WithChatType:ChatType_GroupChat];
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                }
                [navVC popToRootViewControllerAnimated:YES];
            });
        }
        callback(@[@{@"ok" : @(result)}]);
    }
}

RCT_EXPORT_METHOD(selectUserListByText:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [params objectForKey:@"groupId"];
    NSString *searchText = [params objectForKey:@"searchText"];
    NSArray *users = [[STIMKit sharedInstance] searchUserListBySearchStr:[searchText lowercaseString]];
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:3];

    for (NSDictionary *memberDic in users) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
        NSString *name = [memberDic objectForKey:@"Name"];
        NSString *userId = [memberDic objectForKey:@"UserId"];
        NSString *xmppId = [memberDic objectForKey:@"XmppId"];
        NSString *uri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:xmppId];
        BOOL hasInGroup = [[STIMKit sharedInstance] isGroupMemberByUserId:xmppId ByGroupId:groupId];
        [dic setSTIMSafeObject:name forKey:@"name"];
        [dic setSTIMSafeObject:xmppId forKey:@"xmppId"];
        [dic setSTIMSafeObject:uri forKey:@"headerUri"];
        [dic setSTIMSafeObject:@(hasInGroup) forKey:@"hasInGroup"];
        [properties addObject:dic];
    }
    
    callback(@[@{@"ok" : @(YES), @"UserList" : properties ? properties : @[]}]);
}

@end

@implementation QimRNBModule(MySetting)

// 获取自己的信息
RCT_EXPORT_METHOD(getMyInfo:(RCTResponseSenderBlock)callback) {
    NSString *userId = [[STIMKit sharedInstance] getLastJid];
    NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    NSString *name = [userInfo objectForKey:@"Name"];
    NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:[NSBundle stimDB_localizedStringForKey:@"moment_Unknown"];
    NSString *mood = [QimRNBModule qimrn_getUserMoodByUserId:userId];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:name ? name : [userId componentsSeparatedByString:@"@"].firstObject forKey:@"Name"];
    [info setObject:mood ? mood : @"" forKey:@"Mood"];
    NSString *headerSrc = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:userId];

    [info setObject:headerSrc ? headerSrc : @"" forKey:@"HeaderUri"];
    [info setObject:department ? department : @"" forKey:@"Department"];
    [info setObject:userId ? userId : @"" forKey:@"UserId"];
    
    NSArray *medals = [QimRNBModule qimrn_getNewUserMedalByUserId:userId];
    
    callback(@[@{@"MyInfo":info?info:@{}, @"medalList": medals?medals:@[]}]);
}

//获取自己的个性签名
RCT_EXPORT_METHOD(getMyMood:(RCTResponseSenderBlock)callback) {
    NSString *userId = [[STIMKit sharedInstance] getLastJid];
    NSString *mood = [QimRNBModule qimrn_getUserMoodByUserId:userId];
    callback(@[@{@"mood": mood ? mood : @""}]);
}

// 设置个性签名
RCT_EXPORT_METHOD(savePersonalSignature:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *userId = [params objectForKey:@"UserId"];
    NSString *signature = [params objectForKey:@"PersonalSignature"];
    if ([userId isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
        [[STIMKit sharedInstance] updateUserSignature:signature withCallBack:^(BOOL successed) {
            callback(@[@{@"ok":@(successed)}]);
        }];
    } else {
        callback(@[@{@"ok":@(NO),@"message":@"无权访问"}]);
    }
}

// 设置我的二维码
RCT_EXPORT_METHOD(getUserQRCode:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    UIImage *qrCodeImage = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"qtalk://user?id=%@",userId] imageSize:256];
    NSString *base64Image = [UIImage stimDB_image2DataURL:qrCodeImage];
    callback(@[@{@"qrCode":base64Image?base64Image:@""}]);
}

//从相册更新我的头像
RCT_EXPORT_METHOD(updateMyPhotoFromImagePicker) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        }
        picker.delegate = self;
        picker.allowsEditing = YES;
        [navVC presentViewController:picker animated:YES completion:nil];
    });
}

//拍照更新我的头像
RCT_EXPORT_METHOD(takePhoto) {
    dispatch_async(dispatch_get_main_queue(), ^{
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerControllerSourceType souceType = UIImagePickerControllerSourceTypeCamera;
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = souceType;
            [navVC presentViewController:picker animated:YES completion:nil];
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"当前设备不支持拍照" delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    });
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [__innerCacheBridge.eventDispatcher sendAppEventWithName:@"imageUpdateStart" body:@{@"name": @"aaa"}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self saveImage:image WithImageName:@"currentImage"];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image WithImageName:(NSString *)ImageName{
    NSData *currentImageData = UIImageJPEGRepresentation(image, 1.0);
    if (currentImageData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[STIMKit sharedInstance] updateMyPhoto:currentImageData];
        });
    }
}

@end

@implementation QimRNBModule(AdviceAndFeedback)

// 打开开发人员会话窗口
RCT_EXPORT_METHOD(openDeveloperChat) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = @"lilulucas.li@ejabhost1";
        if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
            userId = @"qcxjfu@ejabhost1";
        } else if ([STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
            userId = @"lilulucas.li@ejabhost1";
        } else {
            userId = @"lilulucas.li@ejabhost1";
        }
        [STIMFastEntrance openSingleChatVCByUserId:userId];
    });
}

// 发送反馈意见
RCT_EXPORT_METHOD(sendAdviceMessage:(NSDictionary *)adviceParam :(RCTResponseSenderBlock)callback) {
    
    NSString *adviceMsg = [adviceParam objectForKey:@"adviceText"];
    BOOL logSelected = [[adviceParam objectForKey:@"logSelected"] boolValue];
#if __has_include("STIMLocalLog.h")
    callback(@[@{@"ok":@(YES)}]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [[STIMLocalLog sharedInstance] submitFeedBackWithContent:adviceMsg WithLogSelected:logSelected];
    });
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"Suggestions" withDescription:@"建议反馈"];
#endif
#endif
}

@end

@implementation QimRNBModule(Contacts)

RCT_EXPORT_METHOD(getContactsNick:(NSString *)xmppId :(RCTResponseSenderBlock)callback) {
    
    if (xmppId.length <= 0 || !xmppId) {
        return;
    }
    NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:xmppId];
    NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:xmppId];
    NSString *userNickName = [userInfo objectForKey:@"Name"];
    NSString *name = remarkName.length ? remarkName : (userNickName.length ? userNickName : [xmppId componentsSeparatedByString:@"@"].firstObject);
    NSString *pinyin = [STIMPinYinForObjc chineseConvertToPinYin:userNickName];
    NSString *headerSrc = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:xmppId];
    NSString *mood = [userInfo objectForKey:@"Mood"];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setSTIMSafeObject:name forKey:@"Name"];
    [properties setSTIMSafeObject:headerSrc ? headerSrc : @"" forKey:@"HeaderUri"];
    [properties setSTIMSafeObject:pinyin forKey:@"SearchIndex"];
    [properties setSTIMSafeObject:xmppId forKey:@"XmppId"];
    [properties setSTIMSafeObject:mood forKey:@"Mood"];
    callback(@[@{@"nick":properties ? properties : @{}}]);
}

RCT_EXPORT_METHOD(selectFriendsForGroupAdd:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSArray *friendList = [[STIMKit sharedInstance] stIMDB_selectFriendListInGroupId:groupId];
    if (friendList) {
        NSMutableArray *contactList = [NSMutableArray array];
        for (NSDictionary *userInfo in friendList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            NSString *jid = [dic objectForKey:@"XmppId"];
            NSString *name = [dic objectForKey:@"Name"];
            NSString *pinyin = [STIMPinYinForObjc chineseConvertToPinYin:name];
            NSString *uri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:jid];
            NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
            NSString *username = remarkName.length ? remarkName : (name.length ? name : [jid componentsSeparatedByString:@"@"].firstObject);
            [dic setObject:name forKey:@"name"];
            [dic setObject:jid forKey:@"xmppId"];
            [dic setObject:uri ? uri : @"" forKey:@"headerUri"];
            [dic setObject:@(YES) forKey:@"friend"];
            [contactList addObject:dic];
        }
        callback(@[@{@"UserList":contactList?contactList:@[], @"ok":@(YES)}]);
    } else {
        callback(@[@{@"UserList":@[], @"ok":@(YES)}]);
    }
}

// 获取联系人页展示的用户
RCT_EXPORT_METHOD(getContacts:(RCTResponseSenderBlock)callback) {
    NSArray *friendList = [[STIMKit sharedInstance] selectFriendList];
    if (friendList) {
        NSMutableArray *contactList = [NSMutableArray array];
        for (NSDictionary *userInfo in friendList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            NSString *jid = [dic objectForKey:@"XmppId"];
            NSString *name = [dic objectForKey:@"Name"];
            NSString *pinyin = [STIMPinYinForObjc chineseConvertToPinYin:name];
            NSString *uri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:jid];
            NSDictionary *userDic = [[STIMKit sharedInstance] getUserInfoByUserId:jid];
            NSString *mood = [userDic objectForKey:@"Mood"];
            
            [dic setSTIMSafeObject:uri ? uri : @"" forKey:@"HeaderUri"];
            [dic setSTIMSafeObject:@(1) forKey:@"Type"];
            [dic setSTIMSafeObject:pinyin forKey:@"SearchIndex"];
            [dic setSTIMSafeObject:mood forKey:@"Mood"];
            [contactList addObject:dic];
        }
        callback(@[@{@"contacts" : contactList ? contactList : @[]}]);
    } else {
        callback(@[@{@"contacts" : @[]}]);
    }
}

// 获取群列表
RCT_EXPORT_METHOD(getGroupList:(RCTResponseSenderBlock)callback) {
    NSArray *tempList = [[STIMKit sharedInstance] getMyGroupList];
    NSMutableArray *groupList = [NSMutableArray array];
    for (NSDictionary *groupInfo in tempList) {
        NSMutableDictionary *groupDic = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
        NSString *groupId = [groupDic objectForKey:@"GroupId"];
        NSString *groupHeaderUrl = [groupDic objectForKey:@"HeaderSrc"];
        NSString *headerUri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithHeaderUrl:groupHeaderUrl];
        [groupDic setObject:headerUri forKey:@"HeaderUri"];
        [groupList addObject:groupDic];
    }
    callback(@[@{@"groupList":groupList?groupList:@[]}]);
}

// 获取公众号列表
RCT_EXPORT_METHOD(getPublicNumberList:(RCTResponseSenderBlock)callback) {
    NSArray *tempList = [[STIMKit sharedInstance] getPublicNumberList];
    NSMutableArray *publicNumberList = [NSMutableArray array];
    for (NSDictionary *pInfo in tempList) {
        NSMutableDictionary *pNumberDic = [NSMutableDictionary dictionaryWithDictionary:pInfo];
        NSString *headerSrc = [pInfo objectForKey:@"HeaderSrc"];
        NSString *headerPath = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithHeaderUrl:headerSrc];
        if (![[NSFileManager defaultManager] fileExistsAtPath:headerPath] || !headerPath) {
            headerPath = [[STIMKit sharedInstance] getPublicNumberDefaultHeaderPath];
        }
        [pNumberDic setSTIMSafeObject:headerPath ? headerPath : [[STIMKit sharedInstance] getPublicNumberDefaultHeaderPath] forKey:@"HeaderUri"];
        [publicNumberList addObject:pNumberDic];
    }
    callback(@[@{@"publicNumberList":publicNumberList?publicNumberList:@[]}]);
}

RCT_EXPORT_METHOD(searchGroupListWithKey:(NSString *)searchText :(RCTResponseSenderBlock)callback) {
    NSArray *tempList = [[STIMKit sharedInstance] getMyGroupList];
    NSMutableArray *groupList = [NSMutableArray array];
    NSString * keyName = @"Name";
    for (NSDictionary * groupInfo in tempList) {
        
        NSString *pinyin = [groupInfo objectForKey:@"pinyin"];
        if (pinyin == nil){
            pinyin = [STIMPinYinForObjc chineseConvertToPinYin:[groupInfo objectForKey:keyName]];
            NSMutableDictionary *dicn = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
            [dicn setObject:pinyin forKey:@"pinyin"];
        }
        if ([pinyin rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [[groupInfo objectForKey:keyName] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            NSMutableDictionary *groupDic = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
            NSString *groupId = [groupDic objectForKey:@"GroupId"];
            NSString *groupHeaderUrl = [groupDic objectForKey:@"HeaderSrc"];
            NSString *headerUri = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithHeaderUrl:groupHeaderUrl];
            [groupDic setObject:headerUri ? headerUri : @"" forKey:@"HeaderUri"];
            [groupList addObject:groupDic];
        }
    }
    callback(@[@{@"groupList":groupList?groupList:@[]}]);
}

@end

@implementation QimRNBModule (PublicNumberList)

//RCT_EXPORT_METHOD(getPublicNumberList:(RCTResponseSenderBlock)callback) {
//    NSMutableArray *publicNumberList = [NSMutableArray arrayWithArray:[[STIMKit sharedInstance] getPublicNumberList]];
//    callback(@[@{@"publicNumberList":publicNumberList ? publicNumberList : @[]}]);
//}

@end

@interface QimRNBModule (Setting) <STIMSwitchAccountViewDelegate>

@end

@implementation QimRNBModule (Setting)

//是否是黑名单和星标用户
RCT_EXPORT_METHOD(isStarOrBlackContact:(NSString *) xmppid ConfigKey:(NSString *) pkey :(RCTResponseSenderBlock)callback){
    BOOL flag = [[STIMKit sharedInstance] isStarOrBlackContact:xmppid ConfigKey:pkey];
    callback(@[@{@"ok" : @(flag)}]);
}
//设置取消星标&黑名单
RCT_EXPORT_METHOD(setStarOrblackContact:(NSString *)xmppid ConfigKey:(NSString *)pkey :(BOOL)value :(RCTResponseSenderBlock)callback){
    BOOL flag = [[STIMKit sharedInstance] setStarOrblackContact:xmppid ConfigKey:pkey Flag:value];
    callback(@[@{@"ok" : @(flag)}]);
}
//设置取消星标&黑名单(多个)
RCT_EXPORT_METHOD(setStarOrBlackContacts:(NSDictionary*)map ConfigKey:(NSString *)pkey :(BOOL)value :(RCTResponseSenderBlock)callback){
    BOOL flag = [[STIMKit sharedInstance] setStarOrblackContacts:map ConfigKey:pkey Flag:value];
    callback(@[@{@"ok" : @(flag)}]);
}

//获取用户在线也收通知状态
RCT_EXPORT_METHOD(syncOnLineNotifyState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGPUSH_ONLINE];
    STIMVerboseLog(@"syncOnLineNotifyState : %d", state);
    callback(@[@{@"state" : @(state)}]);
}

//设置在线也收通知状态
RCT_EXPORT_METHOD(updateOnLineNotifyState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[STIMKit sharedInstance] setMsgNotifySettingWithIndex:STIMMSGSETTINGPUSH_ONLINE WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取用户通知声音状态
RCT_EXPORT_METHOD(getNotifySoundState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGSOUND_INAPP];
    STIMVerboseLog(@"getNotifySoundState : %d", state);
    callback(@[@{@"state" : @(state)}]);
}

//设置用户通知声音状态
RCT_EXPORT_METHOD(updateNotifySoundState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[STIMKit sharedInstance] setMsgNotifySettingWithIndex:STIMMSGSETTINGSOUND_INAPP WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取消息推送状态
RCT_EXPORT_METHOD(getStartPushState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGPUSH_SWITCH];
    callback(@[@{@"state" : @(state)}]);
}

//设置开启消息推送状态
RCT_EXPORT_METHOD(updateStartNotifyState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[STIMKit sharedInstance] setMsgNotifySettingWithIndex:STIMMSGSETTINGPUSH_SWITCH WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取用户通知震动状态
RCT_EXPORT_METHOD(getNotifyVibrationState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGVIBRATE_INAPP];
    callback(@[@{@"state" : @(state)}]);
}

//设置用户通知震动状态
RCT_EXPORT_METHOD(updateNotifyVibrationState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[STIMKit sharedInstance] setMsgNotifySettingWithIndex:STIMMSGSETTINGVIBRATE_INAPP WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取用户是否显示通知详情
RCT_EXPORT_METHOD(getNotifyPushDetailsState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGSHOW_CONTENT];
    callback(@[@{@"state" : @(state)}]);
}

//设置用户通知是否显示详情
RCT_EXPORT_METHOD(updateNotifyPushDetailsState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[STIMKit sharedInstance] setMsgNotifySettingWithIndex:STIMMSGSETTINGSHOW_CONTENT WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取显示用户签名状态
RCT_EXPORT_METHOD(getShowUserModState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] moodshow];
    STIMVerboseLog(@"getShowUserModState : %d", state);
    callback(@[@{@"state" : @(state)}]);
}

//
RCT_EXPORT_METHOD(updateShowUserModState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    [[STIMKit sharedInstance] setMoodshow:state];
    callback(@[@{@"ok" : @(YES)}]);
}

//获取水印状态
RCT_EXPORT_METHOD(getWaterMark:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] waterMarkState];
    callback(@[@(state)]);
}

//设置水印状态，仅限本地
RCT_EXPORT_METHOD(setWaterMark:(BOOL)isOpen) {
    [[STIMKit sharedInstance] setWaterMarkState:isOpen];
}

//获取驼圈提醒
RCT_EXPORT_METHOD(getworkWorldRemind:(RCTResponseSenderBlock)callback) {
    BOOL state = [[STIMKit sharedInstance] getLocalWorkMomentNotifyConfig];
    callback(@[@{@"state" : @(state)}]);
}

//设置驼圈提醒
RCT_EXPORT_METHOD(updateWorkWorldRemind:(BOOL)state :(RCTResponseSenderBlock)callback) {
    [[STIMKit sharedInstance] updateRemoteWorkMomentNotifyConfig:state withCallBack:^(BOOL successed) {
       callback(@[@{@"ok" : @(successed)}]);
    }];
}

//获取客服服务模式
RCT_EXPORT_METHOD(getServiceState:(RCTResponseSenderBlock)callback) {
    
    NSArray *array = [[STIMKit sharedInstance] getSeatSeStatus];
    callback(@[@{@"JsonData" : array ? array : @[]}]);
}

//设置客服服务模式
RCT_EXPORT_METHOD(setServiceState:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    if (!param) {
        return;
    }
    NSInteger st = [[param objectForKey:@"state"] integerValue];
    NSInteger sid = [[param objectForKey:@"sid"] integerValue];
    if (sid) {
        BOOL success = [[STIMKit sharedInstance] updateSeatSeStatusWithShopId:sid WithStatus:st];
        callback(@[@{@"result" : @(success)}]);
    }
}

RCT_EXPORT_METHOD(getAlertVoiceType:(RCTResponseSenderBlock)callback) {
    NSString *soundName = [[STIMKit sharedInstance] getClientNotificationSoundName];
    callback(@[@{@"state" : [soundName isEqualToString:@"default"] ? @(YES) : @(NO)}]);
}

RCT_EXPORT_METHOD(changeConfigAlertStatus:(BOOL)state :(RCTResponseSenderBlock)callback) {
    NSString *soundName = nil;
    if (state == YES) {
        soundName = @"default";
    } else {
        soundName = @"msg.wav";
    }
    BOOL success = [[STIMKit sharedInstance] setClientNotificationSound:soundName];
    callback(@[@{@"ok" : @(success)}]);
}

//获取App版本信息
RCT_EXPORT_METHOD(getAppVersion:(RCTResponseSenderBlock)callback) {
    NSString *appVersion = [NSString stringWithFormat:@"%@", [[STIMKit sharedInstance] AppVersion]];
    callback(@[@{@"AppVersion" : appVersion ? appVersion : @""}]);
}

//打开装扮
RCT_EXPORT_METHOD(openDressUpVc) {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMDressUpController *dressUpVC = [[STIMDressUpController alloc] init];
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:dressUpVC animated:YES];
    });
}

//搜索聊天历史
RCT_EXPORT_METHOD(openSearchHistoryVc) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *searchUrl = [NSString stringWithFormat:@"%@/lookback/main_controller.php", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost]];
        if (searchUrl.length > 0) {
            [STIMFastEntrance openWebViewForUrl:searchUrl showNavBar:YES];
        }
    });
}

//清空会话列表
RCT_EXPORT_METHOD(clearSessionList) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[STIMKit sharedInstance] clearAllNoRead];
        [[STIMKit sharedInstance] deleteSessionList];
    });
}

//打开账户关联页面
RCT_EXPORT_METHOD(openMcConfig) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *linkUrl = [NSString stringWithFormat:@"%@?u=%@&d=%@&navBarBg=208EF2", [[STIMKit sharedInstance] qimNav_Mconfig], [STIMKit getLastUserName], [[STIMKit sharedInstance] qimNav_Domain]];
        [STIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
    });
}

//打开切换账号
RCT_EXPORT_METHOD(openSwitchAccount) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self swicthAccount];
    });
}

- (STIMSwitchAccountView *)accountCollectionView {
    
    NSDictionary *addDict = @{@"userFullJid":@"Add@System"};
    NSArray *accounts = [[STIMKit sharedInstance] getLoginUsers];
    NSMutableArray *userDatas = [NSMutableArray arrayWithArray:accounts];
    [userDatas addObject:addDict];
    STIMSwitchAccountView *accountCollectionView = [[STIMSwitchAccountView alloc] initWithFrame:CGRectMake(0, 0, 220, 120) WithAccounts:userDatas];
    accountCollectionView.delegate = self;
    _accountCollectionView = accountCollectionView;
    return _accountCollectionView;
}

- (SCLAlertView *)swicthAccountAlert {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSwitchAccount:) name:kNotifySwichUserSuccess object:nil];
    SCLAlertView *swicthAccountAlert = [[SCLAlertView alloc] init];
    swicthAccountAlert.shouldDismissOnTapOutside = YES;
    [swicthAccountAlert setHorizontalButtons:YES];
    [swicthAccountAlert addCustomView:self.accountCollectionView];
    swicthAccountAlert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];
    _swicthAccountAlert = swicthAccountAlert;
    return _swicthAccountAlert;
}

- (SCLAlertView *)waitingAlert {
    _waitingAlert = [[SCLAlertView alloc] init];
    return _waitingAlert;
}

- (void)swicthAccount {
    [[self swicthAccountAlert] showCustom:[[[[UIApplication sharedApplication] delegate] window] rootViewController] image:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"switch"] color:[UIColor brownColor] title:@"切换账号" subTitle:nil closeButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] duration:0];
}

- (void)showSwitchAccountView {
    [[self swicthAccountAlert] showCustom:[[[[UIApplication sharedApplication] delegate] window] rootViewController] image:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"switch"] color:[UIColor brownColor] title:@"切换账号" subTitle:nil closeButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] duration:0];
}

- (void)swicthAccountWithAccount:(NSDictionary *)accountDict {
    
    STIMVerboseLog(@"将要切换账号 ： %@", accountDict);
    [STIMMainVC setMainVCReShow:YES];
    if (accountDict) {
        NSString *userId = [accountDict objectForKey:@"userId"];
        [[STIMKit sharedInstance] setUserObject:userId forKey:@"currentLoginName"];
        if (![userId isEqualToString:@"Add"]) {
            NSString *userFullJid = [accountDict objectForKey:@"userFullJid"];
            userId = [[userFullJid componentsSeparatedByString:@"@"] firstObject];
            NSString *pwd = [accountDict objectForKey:@"LoginToken"];
            NSDictionary *navDict = [accountDict objectForKey:@"NavDict"];
            if (userId && pwd) {
//                [[STIMKit sharedInstance] sendNoPush];
                [[STIMKit sharedInstance] clearcache];
                [[STIMKit sharedInstance] clearLogginUser];
                [[STIMKit sharedInstance] quitLogin];
                [[STIMKit sharedInstance] clearUserToken];
                [[STIMKit sharedInstance] setCacheName:userFullJid];
                [[STIMKit sharedInstance] qimNav_swicthLocalNavConfigWithNavDict:navDict];
                [[STIMKit sharedInstance] loginWithUserName:userId WithPassWord:pwd WithLoginNavDict:navDict];
                [[self waitingAlert] showWaiting:[[[[UIApplication sharedApplication] delegate] window] rootViewController] title:@"Waiting..." subTitle:@"账号切换中" closeButtonTitle:nil duration:20.0f];
            } else if (userId && !pwd) {
                [[STIMKit sharedInstance] quitLogin];
                [[STIMKit sharedInstance] clearLogginUser];
                [[STIMKit sharedInstance] setCacheName:userFullJid];
                [self reloginAccount];
            }
        } else {
            [[STIMKit sharedInstance] quitLogin];
            [[STIMKit sharedInstance] clearLogginUser];
            [[STIMKit sharedInstance] setCacheName:@""];
            [self reloginAccount];
        }
    }
    [_swicthAccountAlert hideView];
}

- (void)reloginAccount {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [STIMFastEntrance reloginAccount];
    });
}

- (void)refreshSwitchAccount:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_swicthAccountAlert hideView];
        [_waitingAlert hideView];
    });
}

RCT_EXPORT_METHOD(openQChatServers) {
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            [navVC setNavigationBarHidden:NO animated:NO];
            STIMServiceStatusViewController *serverVc = [[STIMServiceStatusViewController alloc] init];
            [navVC pushViewController:serverVc animated:YES];
        });
    }
}

RCT_EXPORT_METHOD(updateCheckConfig) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[STIMKit sharedInstance] checkClientConfig];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"配置更新完成，建议重启客户端进行查看！" delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
            [alertView show];
        });
    });
}

RCT_EXPORT_METHOD(getAppCache:(RCTResponseSenderBlock)callback) {
    long long totalSize = [[STIMDataController getInstance] sizeofImagePath];
    NSString *str = [[STIMDataController getInstance] transfromTotalSize:totalSize];
    callback(@[@{@"AppCache" : str ? str : @""}]);
}

//清除App缓存
RCT_EXPORT_METHOD(clearAppCache) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[STIMDataController getInstance] removeAllImage];
        [[STIMDataController getInstance] clearLogFiles];
    });
    [__innerCacheBridge.eventDispatcher sendAppEventWithName:@"STIM_AppCache_Will_Update" body:@{@"name": @"aaa"}];
}

//退出登录
RCT_EXPORT_METHOD(logout) {
    [STIMFastEntrance signOut];
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"log out" withDescription:@"退出登录"];
#endif
}

@end

@implementation QimRNBModule (PublicNumber)

RCT_EXPORT_METHOD(scanQrcode) {
    [STIMFastEntrance openQRCodeVC];
}

RCT_EXPORT_METHOD(searchPublicNumber) {
    dispatch_async(dispatch_get_main_queue(), ^{
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        STIMPublicNumberSearchVC *searchVC = [[STIMPublicNumberSearchVC alloc] init];
        [navVC pushViewController:searchVC animated:YES];
    });
}

@end

@implementation QimRNBModule (About)

RCT_EXPORT_METHOD(openAbout) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC setNavigationBarHidden:NO animated:NO];
        STIMAboutVC *aboutVc = [[STIMAboutVC alloc] init];
        [navVC pushViewController:aboutVc animated:YES];
    });
}

RCT_EXPORT_METHOD(rateApp:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *AppStr = [params objectForKey:@"AppStr"];
    if (AppStr.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStr]];
        });
    }
}

@end

@implementation QimRNBModule (Travel)

RCT_EXPORT_METHOD(selectUserTripByDate:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    
    NSString *date = [params objectForKey:@"showDate"];
    NSArray *list = [[STIMKit sharedInstance] selectTripByYearMonth:date];
    list = [list sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *tripDic1 = (NSDictionary *)obj1;
        NSDictionary *tripDic2 = (NSDictionary *)obj2;
        NSString *beginTime1 = [tripDic1 objectForKey:@"beginTime"];
        NSString *beginTime2 = [tripDic2 objectForKey:@"beginTime"];
        NSDate *beginDate1 = [NSDate date:beginTime1 WithFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *beginDate2 = [NSDate date:beginTime2 WithFormat:@"yyyy-MM-dd HH:mm:ss"];
        return [beginDate1 compare:beginDate2];
    }];
    NSMutableArray *localMap = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *tripItem in list) {
        NSDictionary *newTripItem = [self qimrn_grtRNDataByTrip:tripItem];
        [localMap addObject:newTripItem];
    }
    
    NSMutableArray *indexArray = [NSMutableArray array];
    indexArray = [localMap valueForKeyPath:@"tripDate"];
    // 将array装换成NSSet类型，重新排序生成新的数组
    NSSet *indexSet = [NSSet setWithArray:indexArray];
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [indexSet sortedArrayUsingDescriptors:sortDesc];
    // 遍历数组并进行归类
    NSMutableArray *resultArray = [NSMutableArray array];
    NSMutableDictionary *dataMap = [NSMutableDictionary dictionaryWithCapacity:2];
    [sortSetArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 根据NSPredicate获取array
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripDate == %@",obj];
        NSArray *indexArray = [localMap filteredArrayUsingPredicate:predicate];
        STIMVerboseLog(@"indexArray : %@", indexArray);
        // 将查询结果加入到dataMap中
        [dataMap setSTIMSafeObject:indexArray forKey:obj];
    }];
    
    callback(@[@{@"ok" : @(YES),@"data" : dataMap ? dataMap : @{}}]);
}

RCT_EXPORT_METHOD(getTripArea:(RCTResponseSenderBlock)callback) {
    
    NSArray *areaList = [self qimrn_getTripArea];
    callback(@[@{@"ok" : @(YES),@"areaList" : areaList ? areaList : @[]}]);
}

RCT_EXPORT_METHOD(getTripAreaAvailableRoom:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    STIMVerboseLog(@"params : %@", params);
    NSInteger areaId = [[params objectForKey:@"areaId"] integerValue];
    NSString *date = [params objectForKey:@"date"];
    NSString *endTime = [params objectForKey:@"endTime"];
    NSString *startTime = [params objectForKey:@"startTime"];
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    [[STIMKit sharedInstance] getTripAreaAvailableRoom:params callBack:^(NSArray *availableRooms) {
        STIMVerboseLog(@"callBack : %@", availableRooms);
        for (NSDictionary *roomInfo in availableRooms) {
            NSInteger roomId = [[roomInfo objectForKey:@"roomId"] integerValue];
            NSString *roomName = [roomInfo objectForKey:@"roomName"];
            NSInteger capacity = [[roomInfo objectForKey:@"capacity"] integerValue];
            NSString *description = [roomInfo objectForKey:@"description"];
            NSInteger canUse = [[roomInfo objectForKey:@"canUse"] integerValue];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setSTIMSafeObject:@(areaId) forKey:@"AddressNumber"];
            [dic setSTIMSafeObject:roomName forKey:@"RoomName"];
            [dic setSTIMSafeObject:@(roomId) forKey:@"RoomNumber"];
            [dic setSTIMSafeObject:description forKey:@"RoomDetails"];
            [dic setSTIMSafeObject:@(capacity) forKey:@"RoomCapacity"];
            if (canUse == 0) {
//                "canUse": 0//是否可用0:可用;1:不可用
                [result addObject:dic];
            }
        }
        if (result.count) {
            callback(@[@{@"ok" : @(YES), @"roomList" : result ? result : @[]}]);
        }
    }];
}

RCT_EXPORT_METHOD(getTripCity:(RCTResponseSenderBlock)callback) {
    [[STIMKit sharedInstance] getAllCityList:^(NSArray *allCitys) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
        for (NSDictionary *cityDic in allCitys) {
            NSMutableDictionary *cityNewDic = [NSMutableDictionary dictionaryWithCapacity:2];
            NSString *cityName = [cityDic objectForKey:@"cityName"];
            NSString *cityId = [cityDic objectForKey:@"id"];
            [cityNewDic setSTIMSafeObject:cityName forKey:@"CityName"];
            [cityNewDic setSTIMSafeObject:cityId forKey:@"CityId"];
            [array addObject:cityNewDic];
        }
        callback(@[@{@"ok" : @(YES), @"cityList" : array ? array : @[]}]);
    }];
}

RCT_EXPORT_METHOD(getNewTripArea:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    [[STIMKit sharedInstance] getAreaByCityId:params :^(NSArray *availableRooms) {
        NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:3];
        for (NSDictionary *roomDic in availableRooms) {
            NSMutableDictionary *roomNewDic = [NSMutableDictionary dictionaryWithCapacity:2];
            NSString *areaId = [roomDic objectForKey:@"areaID"];
            NSString *areaName = [roomDic objectForKey:@"areaName"];
            NSString *eveningEnds = [roomDic objectForKey:@"eveningEnds"];
            NSString *morningStarts = [roomDic objectForKey:@"morningStarts"];
            NSString *description = [roomDic objectForKey:@"description"];
            
            [roomNewDic setSTIMSafeObject:areaId forKey:@"AddressNumber"];
            [roomNewDic setSTIMSafeObject:areaName forKey:@"AddressName"];
            [roomNewDic setSTIMSafeObject:morningStarts forKey:@"rStartTime"];
            [roomNewDic setSTIMSafeObject:eveningEnds forKey:@"rEndTime"];

            [rooms addObject:roomNewDic];
        }
        callback(@[@{@"ok" : @(YES), @"areaList" : rooms ? rooms : @[]}]);
    }];
}

RCT_EXPORT_METHOD(tripMemberCheck:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    STIMVerboseLog(@"tripMemberCheck : %@", params);
    [[STIMKit sharedInstance] tripMemberCheck:params callback:^(BOOL isConform) {
        callback(@[@{@"ok" : @(YES), @"isConform" : @(isConform)}]);
    }];
}

RCT_EXPORT_METHOD(createTrip:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    STIMVerboseLog(@"createTrip : %@", params);
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"create itinerary" withDescription:@"创建行程"];
#endif
    NSMutableDictionary *newParam = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSMutableArray *newMemberList = [[NSMutableArray alloc] init];
    NSArray *memberList = [params objectForKey:@"memberList"];
    BOOL checkMe = NO;
    for (NSDictionary *memberInfo in memberList) {
        NSString *memberId = [memberInfo objectForKey:@"memberId"];
        if (memberId.length > 0) {
            if ([memberId isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
                checkMe = YES;
            }
            [newMemberList addObject:@{@"memberId" : memberId}];
        }
    }
    if (!checkMe) {
        [newMemberList addObject:@{@"memberId":[[STIMKit sharedInstance] getLastJid]}];
    }
    [newParam setObject:newMemberList forKey:@"memberList"];
    [newParam setObject:@(111) forKey:@"updateTime"];
    [newParam setObject:[[STIMKit sharedInstance] getLastJid] forKey:@"tripInviter"];
    [[STIMKit sharedInstance] createTrip:newParam callBack:^(BOOL success, NSString *errMsg) {
        callback(@[@{@"ok" : @(success), @"errMsg":errMsg?errMsg:@""}]);
    }];
}

@end

@implementation QimRNBModule (Search)

//本地消息搜索
RCT_EXPORT_METHOD(searchLocalMessageByKeyword:(NSDictionary *)param :(RCTResponseSenderBlock)callback){

    NSDictionary *map = [QimRNBModule qimrn_searchLocalMsgWithUserParam:param];
    callback(@[map]);
}
//搜索后点击跳转会话
RCT_EXPORT_METHOD(openChatForLocalSearch:(NSString *)xmppid :(NSString *)realjid :(NSString *)chattype :(nonnull NSNumber *)time){
    STIMVerboseLog(@"xmppid= %@ realjid= %@ chattype=%@ time=%@", xmppid, realjid, chattype, time);
    long long fastMsgTime = [time longLongValue];
    if (chattype == nil) {
        chattype = [xmppid containsString:@"conference."] ? @"1" : @"0";
    }
    NSInteger chatType = [chattype integerValue];
    [STIMFastEntrance openFastChatVCByXmppId:xmppid WithRealJid:realjid WithChatType:chatType WithFastMsgTimeStamp:fastMsgTime];
}

//搜索图片视频
RCT_EXPORT_METHOD(openLocalSearchImage:(NSDictionary *)param) {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    ChatType chattype = [[param objectForKey:@"chatType"] integerValue];
    [STIMFastEntrance openLocalMediaWithXmppId:xmppId withRealJid:realjid withChatType:chattype];
}

//本地文件搜索
RCT_EXPORT_METHOD(searchLocalFile:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSDictionary *map = [QimRNBModule qimrn_searchLocalFileWithUserParam:param];
    callback(@[map]);
}

//本地链接搜索
RCT_EXPORT_METHOD(searchLocalLink:(NSDictionary *)param callback:(RCTResponseSenderBlock)callback) {
    NSDictionary *map = [QimRNBModule qimrn_searchLocalLinkWithUserParam:param];
    callback(@[map]);
}

@end

@implementation QimRNBModule (StarBlackContacts)

//黑名单&星标联系人
RCT_EXPORT_METHOD(selectStarOrBlackContacts:(NSString *)pkey :(RCTResponseSenderBlock)callback){
    NSMutableArray *contacts = [[STIMKit sharedInstance] selectStarOrBlackContacts:pkey];
    NSMutableArray *tempContacts = [NSMutableArray arrayWithCapacity:3];
    for (NSDictionary *user in contacts) {
        NSLog(@"user : %@", user);

        NSString *headerUrl = [user objectForKey:@"HeaderUrl"];
        NSString *name = [user objectForKey:@"Name"];
        NSString *xmppId = [user objectForKey:@"XmppId"];
        NSString *userId = [user objectForKey:@"userId"];
        
        NSString *userLocalHeaderPath = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:xmppId];

        NSMutableDictionary *tempUserInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [tempUserInfo setSTIMSafeObject:userLocalHeaderPath forKey:@"HeaderUri"];
        [tempUserInfo setSTIMSafeObject:name forKey:@"Name"];
        [tempUserInfo setSTIMSafeObject:xmppId forKey:@"XmppId"];
        [tempUserInfo setSTIMSafeObject:userId forKey:@"userId"];
        [tempContacts addObject:tempUserInfo];
    }
    callback(@[@{@"data" : tempContacts ? tempContacts : @[]}]);
}
RCT_EXPORT_METHOD(selectFriendsNotInStarContacts:(RCTResponseSenderBlock)callback){
    NSMutableArray *contacts = [[STIMKit sharedInstance] selectFriendsNotInStarContacts];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:3];
    for (NSDictionary *friendInfo in contacts) {
        NSMutableDictionary *tempFriendInfo = [NSMutableDictionary dictionaryWithDictionary:friendInfo];
        NSString *userXmppJid = [friendInfo objectForKey:@"XmppId"];
        NSString *userName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userXmppJid];
        NSString *userHeaderUrl = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithJid:userXmppJid];
        
        [tempFriendInfo setSTIMSafeObject:userName forKey:@"Name"];
        [tempFriendInfo setSTIMSafeObject:userHeaderUrl forKey:@"HeaderUri"];
        [result addObject:tempFriendInfo];
    }
    callback(@[@{@"contacts" : result ? result : @[]}]);
}

RCT_EXPORT_METHOD(selectUserNotInStartContacts:(NSString *)key :(RCTResponseSenderBlock)callback){
    NSMutableArray *contacts = [[STIMKit sharedInstance] selectUserNotInStartContacts:key];
    callback(@[@{@"users" : contacts ? contacts : @[]}]);
}

@end

@implementation QimRNBModule (WorkFeed)

RCT_EXPORT_METHOD(openUserWorkWorld:(NSDictionary *)param) {
    [[STIMFastEntrance sharedInstance] openUserWorkWorldWithParam:param];
}

@end


@implementation QimRNBModule (Log)

//RN点击事件
RCT_EXPORT_METHOD(saveRNActLog:(NSString *)desc) {

#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:desc withDescription:desc];
#endif
}

/**
 * RN点击埋点统计
 *
 * @param desc
 */
RCT_EXPORT_METHOD(saveRNActLog:(NSString *)eventId :(NSString *)desc :(NSString *)currentPage) {
    
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:eventId withDescription:desc];
#endif
}

@end

//
//  STIMFastEntrance.m
//  qunarChatIphone
//
//  Created by admin on 16/6/15.
//
//

#import "STIMFastEntrance.h"
#import "STIMCommonCategories.h"
#import "STIMCommonUIFramework.h"
#import "UIApplication+STIMApplication.h"
#import "STIMGroupCardVC.h"
#import "STIMChatVC.h"
#import "QTalkSessionView.h"
#import "STIMAdvertisingVC.h"
#import "STIMProgressHUD.h"
#import "STIMFriendNotifyViewController.h"
#import "STIMGroupChatVC.h"
#import "STIMFriendListViewController.h"
#import "STIMGroupListVC.h"
#import "STIMMessageHelperVC.h"
#import "STIMPublicNumberVC.h"
#import "STIMWebView.h"
#import "STIMNewMoivePlayerVC.h"
#import "STIMPublicNumberCardVC.h"
#import "STIMUserProfileViewController.h"
#import "STIMWindowManager.h"

#if __has_include("STIMNoteManager.h")

#import "QTalkNotesCategoriesVc.h"

#endif

#import <MessageUI/MFMailComposeViewController.h>
#import "STIMPublicNumberRobotVC.h"
#import "STIMFileManagerViewController.h"
#import "STIMOrganizationalVC.h"
#import "STIMZBarViewController.h"
#import "STIMJumpURLHandle.h"
#import "STIMLoginVC.h"
#import "STIMPublicLogin.h"
#import "STIMMainVC.h"
#import "STIMLoginViewController.h"
#import "STIMWebLoginVC.h"
#import "STIMQRCodeViewDisplayController.h"
#import "STIMContactSelectionViewController.h"
#import "STIMFileTransMiddleVC.h"
#import "STIMWorkFeedDetailViewController.h"

#if __has_include("STIMIPadWindowManager.h")

//#import "IPAD_RemoteLoginVC.h"
#import "IPAD_NAVViewController.h"
#import "STIMIPadWindowManager.h"

#endif
//#import "STIMMainSplitVC.h"

#import "STIMMainSplitViewController.h"
#import "STIMWatchDog.h"
#import "STIMUUIDTools.h"
#import "STIMPublicRedefineHeader.h"
#import "STIMMWPhotoBrowser.h"
#import "STIMFilePreviewVC.h"
#import "STIMMWPhotoSectionBrowserVC.h"
#import "STIMWorkFeedViewController.h"
#import "STIMWorkFeedSearchViewController.h"
#import "STIMWorkMomentPushViewController.h"
#import "STIMWorkFeedMYCirrleViewController.h"

#if __has_include("STIMFlutterModule.h")
#import "STIMFlutterModule.h"
#endif

@interface STIMFastEntrance () <MFMailComposeViewControllerDelegate>

@end

@interface STIMFastEntrance () <STIMMWPhotoBrowserDelegate>

@property(nonatomic, strong) UINavigationController *rootNav;

@property(nonatomic, strong) UIViewController *rootVc;

@property(nonatomic, copy) NSString *browerImageUserId;

@property(nonatomic, copy) NSString *browerImageUrl;

@property(nonatomic, strong) NSArray *browerImageUrlList;

@property(nonatomic, strong) NSArray *browerMWPhotoList;

@end

@implementation STIMFastEntrance

static STIMFastEntrance *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[STIMFastEntrance alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype)sharedInstanceWithRootNav:(UINavigationController *)nav rootVc:(UIViewController *)rootVc {
    STIMFastEntrance *instance = [STIMFastEntrance sharedInstance];
    instance.rootVc = rootVc;
    instance.rootNav = nav;
    STIMVerboseLog(@"sharedInstanceWithRootNav : %@, rootVc : %@, rootNav : %@", instance, rootVc, nav);
    return instance;
}

- (UINavigationController *)getSTIMFastEntranceRootNav {
    STIMVerboseLog(@"getSTIMFastEntranceRootNav: %@", _sharedInstance.rootNav);
    if (!self.rootNav) {
        if ([[STIMKit sharedInstance] getIsIpad] == YES) {
#if __has_include("STIMIPadWindowManager.h")
            self.rootNav = [[STIMIPadWindowManager sharedInstance] getDetailNav];
#endif
        } else {
            self.rootNav = [[self getSTIMFastEntranceRootVc] navigationController];
        }
    }
    /*
     //Mark by newIpad
    if ([[STIMKit sharedInstance] getIsIpad] == YES && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) == NO) {
        self.rootNav = [[STIMWindowManager shareInstance] getDetailRootNav];
    } else if ([[STIMKit sharedInstance] getIsIpad] == YES && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) == YES) {
        self.rootNav = [[STIMWindowManager shareInstance] getMasterRootNav];
    } else {
        
    }
    */
    //Mark by oldIpad
    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
#if __has_include("STIMIPadWindowManager.h")
        self.rootNav = [[STIMIPadWindowManager sharedInstance] getDetailNav];
#endif
    }
    return self.rootNav;
}

- (UIViewController *)getSTIMFastEntranceRootVc {
    STIMVerboseLog(@"getSTIMFastEntranceRootVc: %@", _sharedInstance.rootVc);
    return self.rootVc;
}

- (void)launchMainControllerWithWindow:(UIWindow *)window {
    STIMVerboseLog(@"开始加载主界面");
    CFAbsoluteTime startTime = [[STIMWatchDog sharedInstance] startTime];
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        if ([[STIMKit sharedInstance] qimNav_Debug] == 1) {
            STIMLoginViewController *loginVc = [[STIMLoginViewController alloc] initWithNibName:@"STIMLoginViewController" bundle:nil];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVc];
            [window setRootViewController:nav];
        } else {
            STIMWebLoginVC *loginVc = [[STIMWebLoginVC alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVc];
            [window setRootViewController:nav];
        }
        return;
    } else {
        NSString *userName = [STIMKit getLastUserName];
        NSString *userToken = [[STIMKit sharedInstance] getLastUserToken];
        if (userName.length > 0 && userToken.length > 0 && [[STIMKit sharedInstance] getIsIpad] == NO) {
            STIMMainVC *mainVC = [STIMMainVC sharedInstanceWithSkipLogin:YES];
            STIMNavController *navVC = [[STIMNavController alloc] initWithRootViewController:mainVC];
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navVC];
        } else {
            if (userName && userToken && [STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
                STIMLoginVC *remoteVC = [[STIMLoginVC alloc] init];
                [STIMMainVC setMainVCReShow:YES];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                [window setRootViewController:nav];
            } else {
                if ([STIMKit getSTIMProjectType] == STIMProjectTypeStartalk) {
                    STIMPublicLogin *remoteVC = [[STIMPublicLogin alloc] init];
                    [STIMMainVC setMainVCReShow:YES];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                    [window setRootViewController:nav];
                } else {
                    STIMLoginVC *remoteVC = [[STIMLoginVC alloc] init];
                    [STIMMainVC setMainVCReShow:YES];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                    [window setRootViewController:nav];
                }
            }
        }
    }
    STIMVerboseLog(@"加载主界面VC耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
}

- (void)launchMainAdvertWindow {
    UIWindow *advertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    advertWindow.backgroundColor = [UIColor whiteColor];
    [advertWindow makeKeyAndVisible];
    STIMAdvertisingVC *vc = [[STIMAdvertisingVC alloc] init];
    STIMNavController *navVC = [[STIMNavController alloc] initWithRootViewController:vc];
    [advertWindow setRootViewController:navVC];
    [[STIMAppWindowManager sharedInstance] setAdvertWindow:advertWindow];
    NSTimeInterval nowAdTime = [NSDate timeIntervalSinceReferenceDate];
    [[STIMKit sharedInstance] setUserObject:@(nowAdTime) forKey:@"lastAdShowTime"];
}

+ (void)showMainVc {
    if ([STIMMainVC checkMainVC] == NO || [STIMMainVC getMainVCReShow] == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[STIMKit sharedInstance] getIsIpad] == YES) {
                /* mark by newipad
                STIMMainVC *mainVC = [STIMMainVC sharedInstanceWithSkipLogin:NO];
                STIMNavController *navVC = [[STIMNavController alloc] initWithRootViewController:mainVC];
                UIViewController *detailVc = [[UIViewController alloc] init];
                detailVc.title = @"Detail";
                detailVc.view.backgroundColor = [UIColor greenColor];
                UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:detailVc];
                STIMMainSplitViewController *mainSPVC = [[STIMMainSplitViewController alloc] initWithMaster:navVC detail:detailNav];
                mainSPVC.placeholderViewControllerClass = NSClassFromString(@"STIMEmptyViewController");
                [[STIMWindowManager shareInstance] setMainSplitVC:mainSPVC];
                [[[UIApplication sharedApplication] keyWindow] setRootViewController:mainSPVC];
                */
                
                //mark by oldIpad
#if __has_include("STIMIPadWindowManager.h")
                IPAD_STIMMainSplitVC *mainVC = [[IPAD_STIMMainSplitVC alloc] init];
                [[STIMIPadWindowManager sharedInstance] setiPadRootVc:mainVC];
#endif
            } else {
                STIMMainVC *mainVC = [STIMMainVC sharedInstanceWithSkipLogin:NO];
                STIMNavController *navVC = [[STIMNavController alloc] initWithRootViewController:mainVC];
                [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navVC];
            }
        });
    }
}

- (UIView *)getSTIMSessionListViewWithBaseFrame:(CGRect)frame {
    QTalkSessionView *sessionView = [[QTalkSessionView alloc] initWithFrame:frame];
    return sessionView;
}

- (void)sendMailWithRootVc:(UIViewController *)rootVc ByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:@[[NSString stringWithFormat:@"%@@%@", [[userId componentsSeparatedByString:@"@"] firstObject], [[STIMKit sharedInstance] qimNav_Email]]]];
            [controller setSubject:[NSString stringWithFormat:@"From %@", [[STIMKit sharedInstance] getMyNickName]]];
            [controller setMessageBody:[NSString stringWithFormat:@"\r\r\r\r\r\r\r\r\r\r\r From Iphone %@.", [STIMKit getSTIMProjectTitleName]] isHTML:NO];
            if (rootVc) {
                [rootVc presentViewController:controller animated:YES completion:nil];
            } else {
                [[[UIApplication sharedApplication] visibleViewController] presentViewController:controller animated:YES completion:nil];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Please configure email account first, or you are unable to send emails with this device"] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (UIViewController *)getUserChatInfoByUserId:(NSString *)userId {
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
    }
    //打开用户名片页
    //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
    if ([[STIMKit sharedInstance] getIsIpad]) {

    } else {
#if __has_include("QimRNBModule.h")

        if ([[STIMKit sharedInstance] qimNav_RNUserCardView]) {
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"getVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"UserCard", @"properties": @{@"UserId": userId, @"Screen": @"ChatInfo", @"RealJid": userId, @"HeaderUri": @"33"}};
                vc = [RunC performSelector:sel withObject:param];
            }
            return vc;
        } else {
#endif
            STIMUserProfileViewController *userProfileVc = [[STIMUserProfileViewController alloc] init];
            userProfileVc.userId = userId;
            return userProfileVc;
#if __has_include("QimRNBModule.h")
        }
#endif
    }
    return nil;
}

+ (void)openUserChatInfoByUserId:(NSString *)userId {

    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        //打开用户名片页
        //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
#if __has_include("QimRNBModule.h")

        if ([[STIMKit sharedInstance] qimNav_RNUserCardView]) {
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"UserCard", @"properties": @{@"UserId": userId, @"Screen": @"ChatInfo", @"RealJid": userId, @"HeaderUri": @"33"}};
                [RunC performSelector:sel withObject:param];
            }
        } else {
#endif
            STIMUserProfileViewController *userProfileVc = [[STIMUserProfileViewController alloc] init];
            userProfileVc.userId = userId;
            [navVC pushViewController:userProfileVc animated:YES];
#if __has_include("QimRNBModule.h")
        }
#endif
    });
}

- (UIViewController *)getUserCardVCByUserId:(NSString *)userId {
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
    }
    //打开用户名片页
    //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
    if ([[STIMKit sharedInstance] getIsIpad]) {

    } else {
#if __has_include("QimRNBModule.h")

        if ([[STIMKit sharedInstance] qimNav_RNUserCardView]) {

            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"getVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"UserCard", @"properties": @{@"UserId": userId}};
                vc = [RunC performSelector:sel withObject:param];
            }
            return vc;
        } else {
#endif
            STIMUserProfileViewController *userProfileVc = [[STIMUserProfileViewController alloc] init];
            userProfileVc.userId = userId;
            return userProfileVc;
#if __has_include("QimRNBModule.h")
        }
#endif
    }
    return nil;
}

+ (void)openUserCardVCByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        //打开用户名片页
        //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
#if __has_include("QimRNBModule.h")

        if ([[STIMKit sharedInstance] qimNav_RNUserCardView]) {
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"UserCard", @"properties": @{@"UserId": userId}};
                [RunC performSelector:sel withObject:param];
            }
        } else {
#endif
            STIMUserProfileViewController *userProfileVc = [[STIMUserProfileViewController alloc] init];
            userProfileVc.userId = userId;
            [navVC pushViewController:userProfileVc animated:YES];
#if __has_include("QimRNBModule.h")
        }
#endif
    });
}

- (UIViewController *)getSTIMGroupCardVCByGroupId:(NSString *)groupId {
#if __has_include("QimRNBModule.h")

    if ([[STIMKit sharedInstance] qimNav_RNGroupCardView]) {
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"getVCWithParam:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            STIMGroupIdentity groupIdentity = [[STIMKit sharedInstance] GroupIdentityForUser:[[STIMKit sharedInstance] getLastJid] byGroup:groupId];
            NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"GroupCard", @"properties": @{@"groupId": groupId}, @"permissions": @(groupIdentity)};
            vc = [RunC performSelector:sel withObject:param];
        }
        return vc;
    } else {
#endif
        STIMGroupCardVC *groupCardVC = [[STIMGroupCardVC alloc] init];
        [groupCardVC setGroupId:groupId];
        return groupCardVC;
#if __has_include("QimRNBModule.h")
    }
#endif
    return nil;
}

+ (void)openSTIMGroupCardVCByGroupId:(NSString *)groupId {

#if __has_include("QimRNBModule.h")

    if ([[STIMKit sharedInstance] qimNav_RNGroupCardView]) {
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        BOOL isGroupOwner = [[STIMKit sharedInstance] isGroupOwner:groupId];
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            STIMGroupIdentity groupIdentity = [[STIMKit sharedInstance] GroupIdentityForUser:[[STIMKit sharedInstance] getLastJid] byGroup:groupId];
            NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"GroupCard", @"properties": @{@"groupId": groupId, @"permissions": @(groupIdentity)}};
            [RunC performSelector:sel withObject:param];
        }
    } else {
#endif
        STIMGroupCardVC *groupCardVC = [[STIMGroupCardVC alloc] init];
        [groupCardVC setGroupId:groupId];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:groupCardVC animated:YES];
#if __has_include("QimRNBModule.h")
    }
#endif
}

- (UIViewController *)getFastChatVCByXmppId:(NSString *)userId WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType WithFastMsgTimeStamp:(long long)fastMsgTime {
    UIViewController *fastChatVc = nil;
    switch (chatType) {
        case ChatType_SingleChat: {

            STIMChatVC *chatVc = [self getSingleChatVCByUserId:userId];
            [chatVc setFastMsgTimeStamp:fastMsgTime];
            return chatVc;
        }
            break;
        case ChatType_GroupChat: {
            STIMGroupChatVC *groupChatVc = [self getGroupChatVCByGroupId:userId];
            [groupChatVc setFastMsgTimeStamp:fastMsgTime];
            return groupChatVc;
        }
            break;
        case ChatType_System: {
            STIMChatVC *systemVc = [self getHeaderLineVCByJid:userId];
            [systemVc setFastMsgTimeStamp:fastMsgTime];
            return systemVc;
        }
            break;
        case ChatType_PublicNumber: {

        }
            break;
        case ChatType_Consult: {
            STIMChatVC *chatVc = [self getConsultChatByChatType:chatType UserId:realJid WithVirtualId:userId];
            [chatVc setFastMsgTimeStamp:fastMsgTime];
            return chatVc;
        }
            break;
        case ChatType_ConsultServer: {
            STIMChatVC *chatVc = [self getConsultChatByChatType:chatType UserId:realJid WithVirtualId:userId];
            [chatVc setFastMsgTimeStamp:fastMsgTime];
            return chatVc;
        }
            break;
        default:
            break;
    }
    return nil;
}

+ (void)openFastChatVCByXmppId:(NSString *)userId WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType WithFastMsgTimeStamp:(long long)fastMsgTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        UIViewController *chatVc = [[STIMFastEntrance sharedInstance] getFastChatVCByXmppId:userId WithRealJid:realJid WithChatType:chatType WithFastMsgTimeStamp:fastMsgTime];
        chatVc.hidesBottomBarWhenPushed = YES;
        [navVC pushViewController:chatVc animated:YES];
    });
}

- (UIViewController *)getConsultChatByChatType:(ChatType)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    STIMChatVC *chatVc = [[STIMChatVC alloc] init];
    [chatVc setChatId:userId];
    [chatVc setVirtualJid:virtualId];
    [chatVc setChatType:chatType];
    return chatVc;
}

+ (void)openConsultChatByChatType:(ChatType)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *consultChatVc = [[STIMFastEntrance sharedInstance] getConsultChatByChatType:chatType UserId:userId WithVirtualId:virtualId];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:consultChatVc animated:YES];
    });
}

- (UIViewController *)getConsultServerChatByChatType:(ChatType)chatType WithVirtualId:(NSString *)virtualId WithRealJid:(NSString *)realjid {
    STIMChatVC *chatVc = [[STIMChatVC alloc] init];
    [chatVc setChatId:realjid];
    [chatVc setVirtualJid:virtualId];
    [chatVc setChatType:chatType];
    return chatVc;
}

+ (void)openConsultServerChatByChatType:(ChatType)chatType WithVirtualId:(NSString *)virtualId WithRealJid:(NSString *)realjid {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *consultChatVc = [[STIMFastEntrance sharedInstance] getConsultServerChatByChatType:chatType WithVirtualId:virtualId WithRealJid:realjid];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:consultChatVc animated:YES];
    });
}

- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId withFastTime:(long long)fastTime withRemoteSearch:(BOOL)flag {
    NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    if (userInfo == nil) {
        [[STIMKit sharedInstance] updateUserCard:userId withCache:YES];
        userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    }
    NSString *name = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    if (name.length <= 0) {
        name = [userId componentsSeparatedByString:@"@"].firstObject;
    }
    ChatType chatType = [[STIMKit sharedInstance] openChatSessionByUserId:userId];
    
    STIMChatVC *chatVC = [[STIMChatVC alloc] init];
    [chatVC setFastMsgTimeStamp:fastTime];
    [chatVC setChatId:userId];
    [chatVC setTitle:name];
    [chatVC setChatType:chatType];
    [chatVC setVirtualJid:userId];
    [chatVC setNetWorkSearch:flag];
    return chatVC;
}

- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId {
    NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    if (userInfo == nil) {
        [[STIMKit sharedInstance] updateUserCard:userId withCache:YES];
        userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:userId];
    }
    NSString *name = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    if (name.length <= 0) {
        name = [userId componentsSeparatedByString:@"@"].firstObject;
    }
    ChatType chatType = [[STIMKit sharedInstance] openChatSessionByUserId:userId];

    STIMChatVC *chatVC = [[STIMChatVC alloc] init];
    [chatVC setChatId:userId];
    [chatVC setTitle:name];
    [chatVC setChatType:chatType];
    [chatVC setVirtualJid:userId];
    return chatVC;
}

+ (void)openSingleChatVCByUserId:(NSString *)userId withFastTime:(long long)fastTime withRemoteSearch:(BOOL)flag {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *chatVC = [[STIMFastEntrance sharedInstance] getSingleChatVCByUserId:userId withFastTime:fastTime withRemoteSearch:flag];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        chatVC.hidesBottomBarWhenPushed = YES;
        //Mark By oldiPad
        if ([[STIMKit sharedInstance] getIsIpad]) {
#if __has_include("STIMIPadWindowManager.h")
            [[STIMIPadWindowManager sharedInstance] showDetailViewController:chatVC];
#endif
        } else {
            [navVC pushViewController:chatVC animated:YES];
        }
        
        /* mark by newipad
        [navVC pushViewController:chatVC animated:YES];
         */
    });
}

+ (void)openSingleChatVCByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *chatVC = [[STIMFastEntrance sharedInstance] getSingleChatVCByUserId:userId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        chatVC.hidesBottomBarWhenPushed = YES;
        //mark by oldipad
        if ([[STIMKit sharedInstance] getIsIpad]) {
#if __has_include("STIMIPadWindowManager.h")
            [[STIMIPadWindowManager sharedInstance] showDetailViewController:chatVC];
#endif
        } else {
            [navVC pushViewController:chatVC animated:YES];
        }
        //mark by newipad
//        [navVC pushViewController:chatVC animated:YES];
    });
}

- (UIViewController *)getGroupChatVCByGroupId:(NSString *)groupId withFastTime:(long long)fastTime withRemoteSearch:(BOOL)flag {
    STIMGroupChatVC *chatGroupVC = [[STIMGroupChatVC alloc] init];
    [chatGroupVC setChatType:ChatType_GroupChat];
    [chatGroupVC setChatId:groupId];
    [chatGroupVC setFastMsgTimeStamp:fastTime];
    [chatGroupVC setNetWorkSearch:flag];
    return chatGroupVC;
}

- (UIViewController *)getGroupChatVCByGroupId:(NSString *)groupId {
    STIMGroupChatVC *chatGroupVC = [[STIMGroupChatVC alloc] init];
    [chatGroupVC setChatType:ChatType_GroupChat];
    [chatGroupVC setChatId:groupId];
    return chatGroupVC;
}

+ (void)openGroupChatVCByGroupId:(NSString *)groupId withFastTime:(long long)fastTime withRemoteSearch:(BOOL)flag {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *chatGroupVC = [[STIMFastEntrance sharedInstance] getGroupChatVCByGroupId:groupId withFastTime:fastTime withRemoteSearch:flag];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:chatGroupVC animated:YES];
    });
}

+ (void)openGroupChatVCByGroupId:(NSString *)groupId {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *chatGroupVC = [[STIMFastEntrance sharedInstance] getGroupChatVCByGroupId:groupId];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        //mark by oldipad
        if ([[STIMKit sharedInstance] getIsIpad]) {
#if __has_include("STIMIPadWindowManager.h")
            [[STIMIPadWindowManager sharedInstance] showDetailViewController:chatGroupVC];
#endif
        } else {
            [navVC pushViewController:chatGroupVC animated:YES];
        }
        //mark by newipad
//        [navVC pushViewController:chatGroupVC animated:YES];
    });
}

- (UIViewController *)getHeaderLineVCByJid:(NSString *)jid {
    if ([jid hasPrefix:@"FriendNotify"]) {

        STIMFriendNotifyViewController *friendVC = [[STIMFriendNotifyViewController alloc] init];
        return friendVC;
    } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
        STIMWebView *webView = [[STIMWebView alloc] init];
        webView.needAuth = YES;
        webView.fromOrderManager = YES;
        webView.navBarHidden = YES;
        webView.url = [[STIMKit sharedInstance] qimNav_QcGrabOrder];
        return webView;
    } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
        STIMWebView *webView = [[STIMWebView alloc] init];
        webView.needAuth = YES;
        webView.navBarHidden = YES;
        [[STIMKit sharedInstance] clearNotReadMsgByJid:jid];
        webView.url = [[STIMKit sharedInstance] qimNav_QcOrderManager];
        return webView;
    } else {

        STIMChatVC *chatSystemVC = [[STIMChatVC alloc] init];
        [chatSystemVC setChatId:jid];
        [chatSystemVC setChatType:ChatType_System];
        if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {

            if ([jid hasPrefix:@"rbt-notice"]) {
                [chatSystemVC setTitle:@"公告通知"];
            } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                [chatSystemVC setTitle:@"抢单通知"];
            } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                [chatSystemVC setTitle:@"抢单"];
            } else {
                [chatSystemVC setTitle:[NSBundle stimDB_localizedStringForKey:@"System Messages"]];//@"系统消息"];
            }
        } else {

            [chatSystemVC setTitle:[NSBundle stimDB_localizedStringForKey:@"System Messages"]];//@"系统消息"];
        }
        return chatSystemVC;
    }
}

+ (void)openHeaderLineVCByJid:(NSString *)jid {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[STIMKit sharedInstance] clearNotReadMsgByJid:jid];
        });
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        UIViewController *chatSystemVC = [[STIMFastEntrance sharedInstance] getHeaderLineVCByJid:jid];
        [navVC pushViewController:chatSystemVC animated:YES];

    });
}

- (UIViewController *)getWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar {
    STIMWebView *webView = [[STIMWebView alloc] init];
    [webView setHtmlString:htmlStr];
    if (!showNavBar) {
        webView.navBarHidden = !showNavBar;
    }
    return webView;
}

+ (void)openWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWebView *webView = [[STIMWebView alloc] init];
        [webView setHtmlString:htmlStr];
        if (!showNavBar) {
            webView.navBarHidden = !showNavBar;
        }
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:webView animated:YES];
    });
}

- (UIViewController *)getWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar {
    STIMWebView *webView = [[STIMWebView alloc] init];
    [webView setUrl:url];
    if (!showNavBar) {
        webView.navBarHidden = !showNavBar;
    }
    return webView;
}

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWebView *webView = [[STIMWebView alloc] init];
        [webView setUrl:url];
        if (!showNavBar) {
            webView.navBarHidden = !showNavBar;
        }
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:webView animated:YES];
    });
}

+ (void)openUserMedalFlutterWithUserId:(NSString *)userId {
#if __has_include("STIMFlutterModule.h")
    dispatch_async(dispatch_get_main_queue(), ^{
        [[STIMFlutterModule sharedInstance] openUserMedalFlutterWithUserId:userId];
    });
#endif
}

+ (void)openVideoPlayerForUrl:(NSString *)videoUrl LocalOutPath:(NSString *)localOutPath CoverImageUrl:(NSString *)coverImageUrl {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMNewMoivePlayerVC *videoPlayer = [[STIMNewMoivePlayerVC alloc] init];
//        videoPlayer.videoUrl = videoUrl;

//        [videoPlayer setLocalVideoPath:localOutPath];
//        [videoPlayer setRemoteVideoUrl:videoUrl];
//        [videoPlayer setRemoteVideoCoverImagePath:coverImageUrl];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:videoPlayer animated:YES];
    });
}

+ (void)openVideoPlayerForVideoModel:(STIMVideoModel *)videoModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMNewMoivePlayerVC *videoPlayer = [[STIMNewMoivePlayerVC alloc] init];
        videoPlayer.videoModel = videoModel;
//        videoPlayer.videoInfoDic = videoInfo;
        //        videoPlayer.videoUrl = videoUrl;

//        [videoPlayer setLocalVideoPath:localOutPath];
//        [videoPlayer setRemoteVideoUrl:videoUrl];
//        [videoPlayer setRemoteVideoCoverImagePath:coverImageUrl];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:videoPlayer animated:YES];
    });

}

+ (BOOL)handleOpsasppSchema:(NSDictionary *)reactInfoDic {
#if __has_include("RNSchemaParse.h")
    BOOL canParse = NO;
    Class RunC = NSClassFromString(@"RNSchemaParse");
    SEL sel = NSSelectorFromString(@"canHandleURL:");
    if ([RunC respondsToSelector:sel]) {
        canParse = [[RunC performSelector:sel withObject:reactInfoDic] boolValue];
    }
    if (canParse && [STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {

        NSString *reacturl = reactInfoDic[@"reacturl"];
        NSURL *url = [NSURL URLWithString:[reacturl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        UIViewController *reactVC = nil;
        STIMVerboseLog(@"url : %@", url);
        Class RunC = NSClassFromString(@"RNSchemaParse");
        SEL sel = NSSelectorFromString(@"handleOpsasppSchema:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            reactVC = [RunC performSelector:sel withObject:url];
        }

        if (reactVC != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
                }
                [navVC pushViewController:reactVC animated:YES];
            });
            return YES;
        }
        return NO;
    }
#endif
    return NO;
}

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar FromRedPack:(BOOL)fromRedPack {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWebView *webView = [[STIMWebView alloc] init];
        [webView setUrl:url];
        [webView setFromRegPackage:YES];
        if (!showNavBar) {
            webView.navBarHidden = !showNavBar;
        }
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:webView animated:YES];
    });
}

- (UIViewController *)getRNSearchVC {

#if __has_include("QTalkSearchViewManager.h")
    UIViewController *reactVC = [[NSClassFromString(@"QTalkSearchViewManager") alloc] init];
    return reactVC;
#endif
    return nil;
}

+ (void)openRNSearchVC {
    //mark by oldipad
#if __has_include("QTalkSearchViewManager.h")
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.duration = 0.1f;   //时间间隔
        animation.fillMode = kCAFillModeForwards;
        animation.type = @"rippleEffect";
        //动画效果
        animation.subtype = kCATransitionFromTop;   //动画方向
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
#if __has_include("STIMIPadWindowManager.h")
        if ([[STIMKit sharedInstance] getIsIpad]) {
            UINavigationController *rootNav = [[STIMIPadWindowManager sharedInstance] getLeftMainVcNav];
            [rootNav.view.layer addAnimation:animation forKey:@"animation"];
            UIViewController *reactVC = [[STIMFastEntrance sharedInstance] getRNSearchVC];
            [rootNav.view.layer addAnimation:animation forKey:nil];
            [rootNav pushViewController:reactVC animated:YES];
        } else {
            UIViewController *reactVC = [[STIMFastEntrance sharedInstance] getRNSearchVC];
            UINavigationController *reactNav = [[UINavigationController alloc] initWithRootViewController:reactVC];
            [navVC presentViewController:reactNav animated:NO completion:nil];
        }
#else
        [navVC.view.layer addAnimation:animation forKey:@"animation"];
        UIViewController *reactVC = [[STIMFastEntrance sharedInstance] getRNSearchVC];
        [navVC.view.layer addAnimation:animation forKey:nil];
        navVC.delegate = self;
        [navVC presentViewController:reactVC animated:YES completion:nil];
        [navVC setNavigationBarHidden:YES animated:YES];
        navVC.delegate = nil;
#endif
    });
#endif
    return;
    /* mark by newipad
#if __has_include("QTalkSearchViewManager.h")
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.duration = 0.1f;   //时间间隔
        animation.fillMode = kCAFillModeForwards;
        animation.type = @"rippleEffect";
        //动画效果
        animation.subtype = kCATransitionFromTop;   //动画方向
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        if ([[STIMKit sharedInstance] getIsIpad] == YES) {
            navVC = [[STIMWindowManager shareInstance] getMasterRootNav];
        }
        UIViewController *reactVC = [[STIMFastEntrance sharedInstance] getRNSearchVC];
        STIMNavController *reactNav = [[STIMNavController alloc] initWithRootViewController:reactVC];
        [navVC presentViewController:reactNav animated:YES completion:nil];
    });
#endif
    */
}

- (UIViewController *)getUserFriendsVC {
    STIMFriendListViewController *friendListVC = [[STIMFriendListViewController alloc] init];
    return friendListVC;
}

+ (void)openUserFriendsVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMFriendListViewController *friendListVC = [[STIMFriendListViewController alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:friendListVC animated:YES];
    });
}

- (UIViewController *)getSTIMGroupListVC {
    STIMGroupListVC *groupListVC = [[STIMGroupListVC alloc] init];
    return groupListVC;
}

+ (void)openSTIMGroupListVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMGroupListVC *groupListVC = [[STIMGroupListVC alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:groupListVC animated:YES];
    });
}

- (UIViewController *)getNotReadMessageVC {
    STIMMessageHelperVC *helperVC = [[STIMMessageHelperVC alloc] init];
    return helperVC;
}

+ (void)openNotReadMessageVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMMessageHelperVC *helperVC = [[STIMMessageHelperVC alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:helperVC animated:YES];
    });
}

- (UIViewController *)getSTIMPublicNumberVC {
    STIMPublicNumberVC *publicVC = [[STIMPublicNumberVC alloc] init];
    return publicVC;
}

+ (void)openSTIMPublicNumberVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMPublicNumberVC *publicVC = [[STIMPublicNumberVC alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:publicVC animated:YES];
    });
}

- (UIViewController *)getMyFileVC {
    STIMFileManagerViewController *fileManagerVc = [[STIMFileManagerViewController alloc] init];
    return fileManagerVc;
}

+ (void)openMyFileVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        STIMFileManagerViewController *fileManagerVc = [[STIMFileManagerViewController alloc] init];
        [navVC pushViewController:fileManagerVc animated:YES];
    });
}

- (UIViewController *)getOrganizationalVC {
    STIMOrganizationalVC *organizationalVC = [[STIMOrganizationalVC alloc] init];
    return organizationalVC;
}

+ (void)openOrganizationalVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        STIMOrganizationalVC *organizationalVC = [[STIMOrganizationalVC alloc] init];
        [navVC pushViewController:organizationalVC animated:YES];
    });
}

+ (void)openQRCodeVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMZBarViewController *vc = [[STIMZBarViewController alloc] initWithBlock:^(NSString *str, BOOL isScceed) {
            if (isScceed) {
                [STIMJumpURLHandle decodeQCodeStr:str];
            }
        }];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC presentViewController:vc animated:YES completion:nil];
    });
}

- (UIViewController *)getRobotChatVC:(NSString *)robotJid {
    NSDictionary *cardDic = [[STIMKit sharedInstance] getPublicNumberCardByJId:robotJid];
    if (cardDic.count > 0) {
        STIMPublicNumberRobotVC *robotVC = [[STIMPublicNumberRobotVC alloc] init];
        [robotVC setRobotJId:[cardDic objectForKey:@"XmppId"]];
        [robotVC setPublicNumberId:[cardDic objectForKey:@"PublicNumberId"]];
        [robotVC setName:[cardDic objectForKey:@"Name"]];
        [robotVC setTitle:robotVC.name];
        return robotVC;
    }
    return nil;
}

+ (void)openRobotChatVC:(NSString *)robotJid {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *cardDic = [[STIMKit sharedInstance] getPublicNumberCardByJId:robotJid];
        if (cardDic.count > 0) {
            STIMPublicNumberRobotVC *robotVC = [[STIMPublicNumberRobotVC alloc] init];
            [robotVC setRobotJId:[cardDic objectForKey:@"XmppId"]];
            [robotVC setPublicNumberId:[cardDic objectForKey:@"PublicNumberId"]];
            [robotVC setName:[cardDic objectForKey:@"Name"]];
            [robotVC setTitle:robotVC.name];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            [navVC pushViewController:robotVC animated:YES];
        }
    });
}

- (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties {
#if __has_include("QimRNBModule.h")

    Class RunC = NSClassFromString(@"QimRNBModule");
    SEL sel = NSSelectorFromString(@"getVCWithParam:");
    UIViewController *vc = nil;
    if ([RunC respondsToSelector:sel]) {
        NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(hiddenNav), @"module": module, @"properties": properties};
        vc = [RunC performSelector:sel withObject:param];
    }
    return vc;
#endif
    return nil;
}

+ (void)openSTIMRNVCWithModuleName:(NSString *)moduleName WithProperties:(NSDictionary *)properties {
    dispatch_async(dispatch_get_main_queue(), ^{
#if __has_include("QimRNBModule.h")
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": moduleName, @"properties": properties};
            [RunC performSelector:sel withObject:param];
        }
#endif
    });
}

- (UIViewController *)getRobotCard:(NSString *)robotJid {
    STIMPublicNumberCardVC *cardVC = [[STIMPublicNumberCardVC alloc] init];
    NSString *publicNumberId = [[robotJid componentsSeparatedByString:@"@"] firstObject];
    if (publicNumberId) {
        [cardVC setPublicNumberId:publicNumberId];
    }
    [cardVC setJid:robotJid];
    if ([[STIMKit sharedInstance] getPublicNumberCardByJid:robotJid]) {
        [cardVC setNotConcern:NO];
    } else {
        [cardVC setNotConcern:YES];
    }
    return cardVC;
}

+ (void)openRobotCard:(NSString *)robotJId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!robotJId) {
            return;
        } else {
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            STIMPublicNumberCardVC *cardVC = [[STIMPublicNumberCardVC alloc] init];
            NSString *publicNumberId = [[robotJId componentsSeparatedByString:@"@"] firstObject];
            if (publicNumberId) {
                [cardVC setPublicNumberId:publicNumberId];
            }
            [cardVC setJid:robotJId];
            if ([[STIMKit sharedInstance] getPublicNumberCardByJid:robotJId]) {
                [cardVC setNotConcern:NO];
            } else {
                [cardVC setNotConcern:YES];
            }
            [navVC pushViewController:cardVC animated:YES];
        }
    });
}

- (UIViewController *)getQTalkNotesVC {
#if __has_include("STIMNoteManager.h")
    QTalkNotesCategoriesVc *notesCategoriesVc = [[QTalkNotesCategoriesVc alloc] init];
    return notesCategoriesVc;
#endif
    return nil;
}

+ (void)openQTalkNotesVC {
#if __has_include("STIMNoteManager.h")
    dispatch_async(dispatch_get_main_queue(), ^{
        QTalkNotesCategoriesVc *notesCategoriesVc = [[QTalkNotesCategoriesVc alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:notesCategoriesVc animated:YES];
    });
#endif
}

+ (void)openLocalMediaWithXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMMWPhotoSectionBrowserVC *mwphotoVc = [[STIMMWPhotoSectionBrowserVC alloc] init];
        mwphotoVc.chatType = chatType;
        mwphotoVc.xmppId = xmppId;
        mwphotoVc.realJid = realJid;
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:mwphotoVc animated:YES];
    });
}

- (UIViewController *)getMyRedPack {
    //我的红包
    NSString *myRedpackageUrl = [[STIMKit sharedInstance] myRedpackageUrl];
    if (myRedpackageUrl.length > 0) {
        return [[STIMFastEntrance sharedInstance] getWebViewForUrl:myRedpackageUrl showNavBar:YES];
    }
    return nil;
}

- (UIViewController *)getMyRedPackageBalance {
    //余额查询
    NSString *balacnceUrl = [[STIMKit sharedInstance] redPackageBalanceUrl];
    if (balacnceUrl.length > 0) {
        return [[STIMFastEntrance sharedInstance] getWebViewForUrl:balacnceUrl showNavBar:YES];
    }
    return nil;
}

+ (void)openSTIMRNWithScheme:(NSString *)scheme withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
#if __has_include("QimRNBModule.h")
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        [properties setSTIMSafeObject:@"" forKey:@"Screen"];
        [properties setSTIMSafeObject:[[STIMKit sharedInstance] getLastJid] forKey:@"from"];
        [properties setSTIMSafeObject:chatId forKey:@"to"];
        [properties setSTIMSafeObject:realJid forKey:@"realjid"];
        [properties setSTIMSafeObject:@(chatType) forKey:@"chatType"];

        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"Merchant", @"properties": @{@"Screen": @"Seats", @"from": [[STIMKit sharedInstance] getLastJid], @"to": chatId, @"customerName": realJid}};
            [RunC performSelector:sel withObject:param];
        }
#endif
    });
}

+ (void)openTransferConversation:(NSString *)shopId withVistorId:(NSString *)realJid {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
#if __has_include("QimRNBModule.h")
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"Merchant", @"properties": @{@"Screen": @"Seats", @"shopJid": shopId, @"customerName": realJid}};
            [RunC performSelector:sel withObject:param];
        }
#endif
    });
}

+ (void)openMyAccountInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
#if __has_include("RNSchemaParse.h")
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_QtalkSuggest_handle_opsapp_event object:nil userInfo:@{@"module": @"user-info", @"initParam": @[]}];
#endif
    });
}

- (UIViewController *)getQRCodeWithQRId:(NSString *)qrId withType:(QRCodeType)qrcodeType {
    STIMQRCodeViewDisplayController *QRVC = [[STIMQRCodeViewDisplayController alloc] init];
    QRVC.QRtype = qrcodeType;
    QRVC.jid = qrId;
    NSString *qrName = @"";
    switch (qrcodeType) {
        case QRCodeType_UserQR: {
            NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:qrId];
            qrName = [userInfo objectForKey:@"Name"];
        }
            break;
        case QRCodeType_GroupQR: {
            NSDictionary *groupVCard = [[STIMKit sharedInstance] getGroupCardByGroupId:qrId];
            qrName = [groupVCard objectForKey:@"Name"];
        }
            break;
        case QRCodeType_RobotQR: {
            NSDictionary *robotVCard = [[STIMKit sharedInstance] getPublicNumberCardByJid:qrId];
            qrName = [robotVCard objectForKey:@"Name"];
        }
            break;
        case QRCodeType_ClientNav: {
            qrName = qrId;
        }
            break;
        default:
            break;
    }
    QRVC.name = qrName ? qrName : qrId;
    return QRVC;
}

+ (void)showQRCodeWithQRId:(NSString *)qrId withType:(QRCodeType)qrcodeType {
    if (qrId.length <= 0) {
        NSAssert(qrId, @"qrId is nil, Please Check it");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *qrVC = [[STIMFastEntrance sharedInstance] getQRCodeWithQRId:qrId withType:qrcodeType];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:qrVC animated:YES];
    });


}

+ (void)signOutWithNoPush {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [[STIMKit sharedInstance] sendNoPush];
        [[STIMKit sharedInstance] clearcache];
        [[STIMKit sharedInstance] clearDataBase];
        [[STIMKit sharedInstance] clearLogginUser];
        [[STIMKit sharedInstance] quitLogin];
        [[STIMKit sharedInstance] setNeedTryRelogin:NO];
        [[STIMKit sharedInstance] clearUserToken];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[STIMKit sharedInstance] getIsIpad] && [STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
#if __has_include("STIMIPadWindowManager.h")
//                IPAD_RemoteLoginVC *ipadVc = [[IPAD_RemoteLoginVC alloc] init];
//                [[[[UIApplication sharedApplication] delegate] window] setRootViewController:ipadVc];
#endif
            } else {
                if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
                    if ([STIMKit getSTIMProjectType] == STIMProjectTypeStartalk) {
                        STIMPublicLogin *remoteVC = [[STIMPublicLogin alloc] init];
                        [STIMMainVC setMainVCReShow:YES];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                    } else {
                        STIMLoginVC *remoteVC = [[STIMLoginVC alloc] init];
                        [STIMMainVC setMainVCReShow:YES];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                    }
                } else {
                    if ([[STIMKit sharedInstance] qimNav_Debug] == 1) {
                        STIMLoginViewController *loginViewController = [[STIMLoginViewController alloc] initWithNibName:@"STIMLoginViewController" bundle:nil];
                        [loginViewController setLinkUrl:nil];
                        [STIMMainVC setMainVCReShow:YES];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                    } else {
                        STIMWebLoginVC *loginVC = [[STIMWebLoginVC alloc] init];
                        [loginVC clearLoginCookie];
                        [STIMMainVC setMainVCReShow:YES];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                    }
                }
            }
        });
    });
}

+ (void)signOut {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[STIMProgressHUD sharedInstance] showProgressHUDWithTest:@"退出登录中..."];
        BOOL result = [[STIMKit sharedInstance] sendPushTokenWithMyToken:nil WithDeleteFlag:YES];
        [[STIMProgressHUD sharedInstance] closeHUD];
        if (result) {
            [[STIMKit sharedInstance] clearcache];
            [[STIMKit sharedInstance] clearDataBase];
            [[STIMKit sharedInstance] clearLogginUser];
            [[STIMKit sharedInstance] quitLogin];
            [[STIMKit sharedInstance] setNeedTryRelogin:NO];
            [[STIMKit sharedInstance] clearUserToken];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[STIMKit sharedInstance] getIsIpad]) {
#if __has_include("STIMIPadWindowManager.h")
                    [[STIMFastEntrance sharedInstance] launchMainControllerWithWindow:[[[UIApplication sharedApplication] delegate] window]];
//                    IPAD_RemoteLoginVC *ipadVc = [[IPAD_RemoteLoginVC alloc] init];
//                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:ipadVc];
#endif
                } else {
                    if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
                        if ([STIMKit getSTIMProjectType] == STIMProjectTypeStartalk) {
                            STIMPublicLogin *remoteVC = [[STIMPublicLogin alloc] init];
                            [STIMMainVC setMainVCReShow:YES];
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                        } else {
                            STIMLoginVC *remoteVC = [[STIMLoginVC alloc] init];
                            [STIMMainVC setMainVCReShow:YES];
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                        }
                    } else {
                        if ([[STIMKit sharedInstance] qimNav_Debug] == 1) {
                            STIMLoginViewController *loginViewController = [[STIMLoginViewController alloc] initWithNibName:@"STIMLoginViewController" bundle:nil];
                            [loginViewController setLinkUrl:nil];
                            [STIMMainVC setMainVCReShow:YES];
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                        } else {
                            STIMWebLoginVC *loginVC = [[STIMWebLoginVC alloc] init];
                            [loginVC clearLoginCookie];
                            [STIMMainVC setMainVCReShow:YES];
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                        }
                    }
                }
            });
        } else {
            if ([[STIMKit sharedInstance] getIsIpad]) {
#if __has_include("STIMIPadWindowManager.h")
                [[STIMFastEntrance sharedInstance] launchMainControllerWithWindow:[[[UIApplication sharedApplication] delegate] window]];
                //                    IPAD_RemoteLoginVC *ipadVc = [[IPAD_RemoteLoginVC alloc] init];
                //                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:ipadVc];
#endif
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Failed to log out, please try again"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
                        
                    }];
                    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Log out anyway"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                        [STIMFastEntrance signOutWithNoPush];
                    }];
                    [alertVc addAction:okAction];
                    [alertVc addAction:quitAction];
                    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                    [navVC presentViewController:alertVc animated:YES completion:nil];
                });
            }
        }
    });
}

+ (void)reloginAccount {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[STIMKit sharedInstance] setNeedTryRelogin:NO];
        if ([[STIMKit sharedInstance] getIsIpad] && [STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
#if __has_include("STIMIPadWindowManager.h")
            [[STIMKit sharedInstance] clearUserToken];
//            IPAD_RemoteLoginVC *ipadVc = [[IPAD_RemoteLoginVC alloc] init];
//            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:ipadVc];
#endif
        } else {
            if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
                [[STIMKit sharedInstance] clearUserToken];
                if ([STIMKit getSTIMProjectType] == STIMProjectTypeStartalk) {
                    STIMPublicLogin *remoteVC = [[STIMPublicLogin alloc] init];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                } else {
                    STIMLoginVC *remoteVC = [[STIMLoginVC alloc] init];
                    [STIMMainVC setMainVCReShow:YES];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                }
            } else {
                if ([[STIMKit sharedInstance] qimNav_Debug] == 1) {
                    STIMLoginViewController *loginVC = [[STIMLoginViewController alloc] initWithNibName:@"STIMLoginViewController" bundle:nil];
                    [STIMMainVC setMainVCReShow:YES];
                    [loginVC setLinkUrl:nil];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:loginVC];
                } else {
                    STIMWebLoginVC *loginVC = [[STIMWebLoginVC alloc] init];
                    [STIMMainVC setMainVCReShow:YES];
                    [loginVC clearLoginCookie];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:loginVC];
                }
            }
        }
    });
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {

        } else {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[error description] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

- (UIViewController *)getContactSelectionVC:(STIMMessageModel *)msg withExternalForward:(BOOL)externalForward {
    STIMContactSelectionViewController *controllerVc = [[STIMContactSelectionViewController alloc] init];
    controllerVc.ExternalForward = YES;
    [controllerVc setMessage:msg];
    return controllerVc;
}

- (void)openFileTransMiddleVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMFileTransMiddleVC *fileMiddleVc = [[STIMFileTransMiddleVC alloc] init];
        UINavigationController *fileMiddleNav = [[UINavigationController alloc] initWithRootViewController:fileMiddleVc];
        if (!self.rootVc) {
            self.rootVc = [[UIApplication sharedApplication] visibleViewController];
        }
        //Mark by oldiPad
        if ([[STIMKit sharedInstance] getIsIpad]) {
#if __has_include("STIMIPadWindowManager.h")
            [[STIMIPadWindowManager sharedInstance] showDetailViewController:fileMiddleVc];
#endif
        } else {
            [self.rootVc presentViewController:fileMiddleNav animated:YES completion:nil];
        }
        /* mark by newipad
        [self.rootVc presentViewController:fileMiddleNav animated:YES completion:nil];
         */
    });
}

- (void)browseBigHeader:(NSDictionary *)param {

    self.browerImageUserId = [param objectForKey:@"UserId"];
    NSString *imageUrl = [param objectForKey:@"imageUrl"];
    NSArray *imageUrlList = [param objectForKey:@"imageUrlList"];
    NSArray *mwPhotoList = [param objectForKey:@"MWPhotoList"];
    NSInteger currentIndex = [[param objectForKey:@"CurrentIndex"] integerValue];
    if (imageUrl.length > 0) {
        self.browerImageUrl = imageUrl;
    } else if (imageUrlList.count > 0) {
        self.browerImageUrlList = imageUrlList;
    } else if (mwPhotoList.count > 0) {
        self.browerMWPhotoList = mwPhotoList;
    } else {
        //1.根据UserId读取名片信息，取出RemoteUrl，直接加载用户头像大图
        NSString *headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:self.browerImageUserId];
        if (![headerUrl stimDB_hasPrefixHttpHeader]) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        }
        self.browerImageUrl = headerUrl;
    }
    STIMMWPhotoBrowser *browser = [[STIMMWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = YES;
    if (currentIndex > 0) {
        [browser setCurrentPhotoIndex:currentIndex];
    } else {
        [browser setCurrentPhotoIndex:0];
    }

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif

    //初始化navigation
    STIMNavController *nc = [[STIMNavController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [navVC presentViewController:nc animated:YES completion:nil];
    });
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(STIMMWPhotoBrowser *)photoBrowser {
    if (self.browerImageUrlList.count > 0) {
        
        return self.browerImageUrlList.count;
    } else if (self.browerMWPhotoList.count > 0) {
        
        return self.browerMWPhotoList.count;
    } else {
        
        return 1;
    }
}

- (id <STIMMWPhoto>)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {

#pragma mark - 查看大图
    if (self.browerImageUrlList.count > 0) {
        NSString *imageUrl = [self.browerImageUrlList objectAtIndex:index];
        if (![imageUrl stimDB_hasPrefixHttpHeader]) {
            imageUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], imageUrl];
        }
        if (![imageUrl containsString:@"?"]) {
            imageUrl = [imageUrl stringByAppendingString:@"?"];
            if (![imageUrl containsString:@"platform"]) {
                imageUrl = [imageUrl stringByAppendingString:@"platform=touch"];
            }
            if (![imageUrl containsString:@"imgtype"]) {
                imageUrl = [imageUrl stringByAppendingString:@"&imgtype=origin"];
            }
            if (![imageUrl containsString:@"webp="]) {
                imageUrl = [imageUrl stringByAppendingString:@"&webp=true"];
            }
        } else {
            if (![imageUrl containsString:@"platform"]) {
                imageUrl = [imageUrl stringByAppendingString:@"&platform=touch"];
            }
            if (![imageUrl containsString:@"imgtype"]) {
                imageUrl = [imageUrl stringByAppendingString:@"&imgtype=origin"];
            }
            if (![imageUrl containsString:@"webp="]) {
                imageUrl = [imageUrl stringByAppendingString:@"&webp=true"];
            }
        }
        NSURL *url = [NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return url ? [[STIMMWPhoto alloc] initWithURL:url] : nil;
    } else if (self.browerMWPhotoList.count > 0) {
        STIMMWPhoto *mwphoto = [self.browerMWPhotoList objectAtIndex:index];
        return mwphoto;
    } else {
        if (![self.browerImageUrl stimDB_hasPrefixHttpHeader]) {
            self.browerImageUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], self.browerImageUrl];
        }
        if (![self.browerImageUrl containsString:@"?"]) {
            self.browerImageUrl = [self.browerImageUrl stringByAppendingString:@"?"];
            if (![self.browerImageUrl containsString:@"platform"]) {
                self.browerImageUrl = [self.browerImageUrl stringByAppendingString:@"platform=touch"];
            }
            if (![self.browerImageUrl containsString:@"imgtype"]) {
                self.browerImageUrl = [self.browerImageUrl stringByAppendingString:@"&imgtype=origin"];
            }
            if (![self.browerImageUrl containsString:@"webp="]) {
                self.browerImageUrl = [self.browerImageUrl stringByAppendingString:@"&webp=true"];
            }
        } else {
            if (![self.browerImageUrl containsString:@"platform"]) {
                self.browerImageUrl = [self.browerImageUrl stringByAppendingString:@"&platform=touch"];
            }
            if (![self.browerImageUrl containsString:@"imgtype"]) {
                self.browerImageUrl = [self.browerImageUrl stringByAppendingString:@"&imgtype=origin"];
            }
            if (![self.browerImageUrl containsString:@"webp="]) {
                self.browerImageUrl = [self.browerImageUrl stringByAppendingString:@"&webp=true"];
            }
        }
        STIMMWPhoto *photo = [[STIMMWPhoto alloc] initWithURL:[NSURL URLWithString:self.browerImageUrl]];
        return photo;
    }
}

- (void)photoBrowserDidFinishModalPresentation:(STIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
        self.browerImageUrl = nil;
        self.browerImageUrlList = nil;
        self.browerMWPhotoList = nil;
        self.browerImageUserId = nil;
    }];
}

- (void)openSTIMFilePreviewVCWithParam:(NSDictionary *)param {
    NSString *fileUrl = [param objectForKey:@"httpUrl"];
    NSString *fileName = [param objectForKey:@"fileName"];
    NSString *fileSize = [param objectForKey:@"fileSize"];
    NSString *fileMd5 = [param objectForKey:@"fileMD5"];
    if (fileUrl.length <= 0 || fileName.length <= 0 || fileSize.length <= 0) {
        return;
    }
    STIMMessageModel *fileMsg = [[STIMMessageModel alloc] init];
    fileMsg.messageId = [STIMUUIDTools UUID];
    NSMutableDictionary *fileInfoDic = [[NSMutableDictionary alloc] init];
    [fileInfoDic setSTIMSafeObject:fileUrl forKey:@"HttpUrl"];
    [fileInfoDic setSTIMSafeObject:fileName forKey:@"FileName"];
    [fileInfoDic setSTIMSafeObject:fileSize forKey:@"FileLength"];
    [fileInfoDic setSTIMSafeObject:(fileMd5.length > 0) ? fileMd5 : fileName forKey:@"FileMd5"];
    fileMsg.message = [[STIMJSONSerializer sharedInstance] serializeObject:fileInfoDic];
    STIMFilePreviewVC *filePreviewVc = [[STIMFilePreviewVC alloc] init];
    filePreviewVc.message = fileMsg;
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [navVC pushViewController:filePreviewVc animated:YES];
    });
}

- (void)openLocalSearchWithXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid withChatType:(NSInteger)chatType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
#if __has_include("QimRNBModule.h")

        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(YES), @"module": @"Search", @"properties": @{@"Screen": @"LocalSearch", @"xmppid": xmppId, @"realjid": realJid?realJid:xmppId, @"chatType": @(chatType)}};
            [RunC performSelector:sel withObject:param];
        }
#endif
    });
}

- (void)openWorkFeedViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWorkFeedViewController *workfeedVc = [[STIMWorkFeedViewController alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        [navVC pushViewController:workfeedVc animated:YES];
    });
}

- (void)openUserWorkWorldWithParam:(NSDictionary *)param {
    NSLog(@"param : %@", param);
    if (![param objectForKey:@"UserId"]) {
        return;
    }
    NSString *userId = [param objectForKey:@"UserId"];
    if (![userId isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            STIMWorkFeedViewController *userWorkFeedVc = [[STIMWorkFeedViewController alloc] init];
            userWorkFeedVc.userId = [param objectForKey:@"UserId"];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            [navVC pushViewController:userWorkFeedVc animated:YES];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            STIMWorkFeedMYCirrleViewController *userWorkFeedVc = [[STIMWorkFeedMYCirrleViewController alloc] init];
            userWorkFeedVc.userId = [param objectForKey:@"UserId"];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
            }
            [navVC pushViewController:userWorkFeedVc animated:YES];
        });
    }
}

+ (void)openTravelCalendarVc {
#if __has_include("QimRNBModule.h")
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openSTIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC": navVC, @"hiddenNav": @(NO), @"module": @"TravelCalendar"};
            [RunC performSelector:sel withObject:param];
        }
    });
#endif
}

+ (void)openWorkMomentSearchVc {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
        }
        STIMWorkFeedSearchViewController *searchVC = [[STIMWorkFeedSearchViewController alloc] init];
        STIMNavController *pushNav = [[STIMNavController alloc] initWithRootViewController:searchVC];
        [navVC presentViewController:pushNav animated:YES completion:nil];
    });
}

+ (void)presentWorkMomentPushVCWithLinkDic:(NSDictionary *)linkDic withNavVc:(UINavigationController *)nav {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWorkMomentPushViewController *pushVc = [[STIMWorkMomentPushViewController alloc] init];
        pushVc.shareLinkUrlDic = linkDic;
        STIMNavController *pushNav = [[STIMNavController alloc] initWithRootViewController:pushVc];
        [nav presentViewController:pushNav animated:YES completion:nil];
    });
}

+ (void)presentWorkMomentPushVCWithVideoDic:(NSDictionary *)videoDic withNavVc:(UINavigationController *)nav {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWorkMomentPushViewController *pushVc = [[STIMWorkMomentPushViewController alloc] init];
        pushVc.shareVideoDic = videoDic;
        STIMNavController *pushNav = [[STIMNavController alloc] initWithRootViewController:pushVc];
        [nav presentViewController:pushNav animated:YES completion:nil];
    });
}

+ (void)openWorkMomentDetailWithPOSTUUId:(NSString *)postUUId {
    STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
    detailVc.momentId = postUUId;
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
    }
    [navVC pushViewController:detailVc animated:YES];
}

@end

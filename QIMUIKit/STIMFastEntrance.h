//
//  STIMFastEntrance.h
//  qunarChatIphone
//
//  Created by admin on 16/6/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STIMKitPublicHeader.h"
@class STIMVideoModel;

@interface STIMFastEntrance : NSObject

+ (instancetype)sharedInstance;

+ (instancetype)sharedInstanceWithRootNav:(UINavigationController *)nav rootVc:(UIViewController *)rootVc;

- (UINavigationController *)getSTIMFastEntranceRootNav;

- (UIViewController *)getSTIMFastEntranceRootVc;

- (void)launchMainControllerWithWindow:(UIWindow *)window;

- (void)launchMainAdvertWindow;

+ (void)showMainVc;

- (UIView *)getSTIMSessionListViewWithBaseFrame:(CGRect)frame;

- (void)sendMailWithRootVc:(UIViewController *)rootVc ByUserId:(NSString *)userId;

- (UIViewController *)getUserChatInfoByUserId:(NSString *)userId;

+ (void)openUserChatInfoByUserId:(NSString *)userId;

- (UIViewController *)getUserCardVCByUserId:(NSString *)userId;

+ (void)openUserCardVCByUserId:(NSString *)userId;

- (UIViewController *)getSTIMGroupCardVCByGroupId:(NSString *)groupId;

+ (void)openSTIMGroupCardVCByGroupId:(NSString *)groupId;

- (UIViewController *)getFastChatVCByXmppId:(NSString *)userId WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType WithFastMsgTimeStamp:(long long)fastMsgTime;

+ (void)openFastChatVCByXmppId:(NSString *)userId WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType WithFastMsgTimeStamp:(long long)fastMsgTime;

- (UIViewController *)getConsultChatByChatType:(ChatType)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId;

+ (void)openConsultChatByChatType:(NSInteger)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId;

- (UIViewController *)getConsultServerChatByChatType:(ChatType)chatType WithVirtualId:(NSString *)virtualId WithRealJid:(NSString *)realjid;

+ (void)openConsultServerChatByChatType:(ChatType)chatType WithVirtualId:(NSString *)virtualId WithRealJid:(NSString *)realjid;

- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId;

+ (void)openSingleChatVCByUserId:(NSString *)userId withFastTime:(long long)fastTime withRemoteSearch:(BOOL)flag;

+ (void)openSingleChatVCByUserId:(NSString *)userId;

- (UIViewController *)getGroupChatVCByGroupId:(NSString *)groupId;

+ (void)openGroupChatVCByGroupId:(NSString *)groupId withFastTime:(long long)fastTime withRemoteSearch:(BOOL)flag;

+ (void)openGroupChatVCByGroupId:(NSString *)groupId;

- (UIViewController *)getHeaderLineVCByJid:(NSString *)jid;

+ (void)openHeaderLineVCByJid:(NSString *)jid;

- (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties;

+ (void)openSTIMRNVCWithModuleName:(NSString *)moduleName WithProperties:(NSDictionary *)properties;

- (UIViewController *)getRobotCard:(NSString *)robotJid;

+ (void)openRobotCard:(NSString *)robotJId;

+ (void)openWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar;

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar;

+ (void)openUserMedalFlutterWithUserId:(NSString *)userId;

+ (void)openVideoPlayerForUrl:(NSString *)videoUrl LocalOutPath:(NSString *)localOutPath CoverImageUrl:(NSString *)coverImageUrl;

+ (void)openVideoPlayerForVideoModel:(STIMVideoModel *)videoModel;

+ (BOOL)handleOpsasppSchema:(NSDictionary *)reactInfoDic;

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar FromRedPack:(BOOL)fromRedPack;

- (UIViewController *)getRNSearchVC;

+ (void)openRNSearchVC;

- (UIViewController *)getUserFriendsVC;

+ (void)openUserFriendsVC;

- (UIViewController *)getSTIMGroupListVC;

+ (void)openSTIMGroupListVC;

- (UIViewController *)getNotReadMessageVC;

+ (void)openNotReadMessageVC;

- (UIViewController *)getSTIMPublicNumberVC;

+ (void)openSTIMPublicNumberVC;

- (UIViewController *)getMyFileVC;

+ (void)openMyFileVC;

- (UIViewController *)getOrganizationalVC;

+ (void)openOrganizationalVC;

+ (void)openQRCodeVC;

- (UIViewController *)getRobotChatVC:(NSString *)robotJid;

+ (void)openRobotChatVC:(NSString *)robotJid;

- (UIViewController *)getQTalkNotesVC;

+ (void)openQTalkNotesVC;

+ (void)openLocalMediaWithXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

- (UIViewController *)getMyRedPack;

- (UIViewController *)getMyRedPackageBalance;

+ (void)openSTIMRNWithScheme:(NSString *)scheme withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

+ (void)openTransferConversation:(NSString *)shopId withVistorId:(NSString *)realJid;

+ (void)openMyAccountInfo;


- (UIViewController *)getQRCodeWithQRId:(NSString *)qrId withType:(QRCodeType)qrcodeType;

+ (void)showQRCodeWithQRId:(NSString *)qrId withType:(NSInteger)qrcodeType;

- (UIViewController *)getContactSelectionVC:(STIMMessageModel *)msg withExternalForward:(BOOL)externalForward;

+ (void)signOutWithNoPush;

+ (void)signOut;

+ (void)signOutWithNoPush;

+ (void)reloginAccount;

- (void)openFileTransMiddleVC;

- (void)browseBigHeader:(NSDictionary *)param;

- (void)openSTIMFilePreviewVCWithParam:(NSDictionary *)param;

- (void)openLocalSearchWithXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid withChatType:(NSInteger)chatType;

- (void)openWorkFeedViewController;

- (void)openUserWorkWorldWithParam:(NSDictionary *)param;

+ (void)openTravelCalendarVc;

+ (void)openWorkMomentSearchVc;

+ (void)presentWorkMomentPushVCWithLinkDic:(NSDictionary *)linkDic withNavVc:(UINavigationController *)nav;

+ (void)presentWorkMomentPushVCWithVideoDic:(NSDictionary *)videoDic withNavVc:(UINavigationController *)nav;

+ (void)openWorkMomentDetailWithPOSTUUId:(NSString *)postUUId;

@end

//
//  STIMWebView.m
//  qunarChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import "STIMWebView.h"
#import "STIMChatVC.h"
#import "STIMGroupChatVC.h"
#import "STIMContactSelectionViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "UIImage+STIMButtonIcon.h"
#import "NSBundle+STIMLibrary.h"
#import "STIMJSONSerializer.h"
#import "STIMKit+STIMNavConfig.h"
#import "STIMMWPhoto.h"

static NSString *__default_ua = nil;

@protocol QActivityToWorkFeedDelegate <NSObject>
@optional
- (void)performShareWorkMomentActivity;
@end
@interface QActivityToWorkFeed : UIActivity
@property (nonatomic, weak) id<QActivityToWorkFeedDelegate> delegate;
@end
@implementation QActivityToWorkFeed
+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"QTalk.WebView.ToWorkFeed";
}

- (NSString *)activityTitle {
    return [NSBundle stimDB_localizedStringForKey:@"webview_share_workmoment"];
}

- (UIImage *)activityImage {
    return [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"webview_shareworkmoment"];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
- (void) performActivity {
    if ([self.delegate respondsToSelector:@selector(performShareWorkMomentActivity)]) {
        [self.delegate performShareWorkMomentActivity];
    }
}
- (void)prepareWithActivityItems:(NSArray *)activityItems {
}
- (UIViewController *)activityViewController{
    return nil;
}
@end

@protocol QActivityCopyLinkDelegate <NSObject>
@optional
- (void)performCopyLinkActivity;
@end
@interface QActivityCopyLink : UIActivity
@property (nonatomic, weak) id<QActivityCopyLinkDelegate> delegate;
@end
@implementation QActivityCopyLink
+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"QTalk.WebView.CopyLink";
}

- (NSString *)activityTitle {
    return [NSBundle stimDB_localizedStringForKey:@"webview_copy_link"];
}

- (UIImage *)activityImage {
    return [[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"webview_copylink"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
- (void) performActivity {
    if ([self.delegate respondsToSelector:@selector(performCopyLinkActivity)]) {
        [self.delegate performCopyLinkActivity];
    }
}
- (void)prepareWithActivityItems:(NSArray *)activityItems {
}
- (UIViewController *)activityViewController{
    return nil;
}
@end

@protocol QActivityToFriendDelegate <NSObject>
@optional
- (void)performActivity;
@end
@interface QActivityToFriend : UIActivity
@property (nonatomic, weak) id<QActivityToFriendDelegate> delegate;
@end
@implementation QActivityToFriend
+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"QTalk.WebView.ToFriend";
}

- (NSString *)activityTitle {
    return [NSBundle stimDB_localizedStringForKey:@"webview_share_conversion"];
}

- (UIImage *)activityImage {
    return [[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"webview_shareConversion"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
- (void) performActivity {
    if ([self.delegate respondsToSelector:@selector(performActivity)]) {
        [self.delegate performActivity];
    }
}
- (void)prepareWithActivityItems:(NSArray *)activityItems {
}
- (UIViewController *)activityViewController{
    return nil;
}
@end

@interface QActivitySafari : UIActivity
@property (nonatomic, weak) NSURL *url;
@end
@implementation QActivitySafari
+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}
- (NSString *)activityType {
    return @"QTalk.WebView.OpenSafari";
}
- (NSString *)activityTitle {
    return [NSBundle stimDB_localizedStringForKey:@"webview_open_safari"];
}
- (UIImage *)activityImage {
    return [[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"safari_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
- (void) performActivity {
    [[UIApplication sharedApplication] openURL:self.url];
}
- (void)prepareWithActivityItems:(NSArray *)activityItems {
}
- (UIViewController *)activityViewController{
    return nil;
}
@end

@interface QActivityRefresh : UIActivity
@property (nonatomic, weak) UIWebView *webView;
@end
@implementation QActivityRefresh
+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"QTalk.WebView.Refresh";
}

- (NSString *)activityTitle {
    return [NSBundle stimDB_localizedStringForKey:@"webview_refresh"];
}
- (UIImage *)activityImage {
    return [[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"webview_refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
- (void)prepareWithActivityItems:(NSArray *)activityItems {
}
- (UIViewController *)activityViewController{
    return nil;
}
- (void) performActivity {
    [self.webView reload];
}

@end

@interface STIMWebView() <NJKWebViewProgressDelegate, UIWebViewDelegate, QActivityToFriendDelegate,STIMContactSelectionViewControllerDelegate>
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic,strong) UIBarButtonItem *backButton;
@property (nonatomic,strong) UIBarButtonItem *forwardButton;
@property (nonatomic,strong) UIImage *reloadImg;
@property (nonatomic,strong) UIImage *stopImg;

@end
@implementation STIMWebView{
    NSURL *_requestUrl;
    BOOL _package;
    BOOL _publicIm;
    BOOL _qcGrab;
    BOOL _qcZhongbao;
    NJKWebViewProgressView *_progressProxyView;
    NJKWebViewProgress *_progressProxy;
    UIWebView *_webView;
}

+ (NSString *)defaultUserAgent{
    if (__default_ua == nil) {
        UIWebView *tempWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        __default_ua = [tempWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    return __default_ua;
}

- (void)dealloc{
    [self setToolbarItems:nil animated:YES];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self setUrl:nil];
    UIImage *image = [UIImage stimDB_imageWithColor:[UIColor stimDB_colorWithHex:0xDDDDDD] size:CGSizeMake([[STIMWindowManager shareInstance] getDetailWidth], 0.5)];
    [[UINavigationBar appearance] setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:image];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)chatVC:(STIMChatVC *)vc{
    [vc sendText:self.url];
}

- (void)groupChatVC:(STIMGroupChatVC *)vc{
    [vc sendText:self.url];
}

//分享到会话delegate
- (void)performActivity{
    NSURL *url = _webView.request.URL;
    STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
    STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
    
    NSString *title = self.title;
    NSURL *linkurl = _webView.request.URL;
    NSString *img = [NSString stringWithFormat:@"%@://%@/favicon.ico", [linkurl scheme], [linkurl host]];
    NSString *desc = @"点击查看全文";
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setSTIMSafeObject:(title.length > 0) ? title : linkurl.absoluteString forKey:@"title"];
    [infoDic setSTIMSafeObject:desc forKey:@"desc"];
    [infoDic setSTIMSafeObject:linkurl.absoluteString forKey:@"linkurl"];
    [infoDic setSTIMSafeObject:img forKey:@"img"];
    NSString *msgContent = [[STIMJSONSerializer sharedInstance] serializeObject:infoDic];

    STIMMessageModel *message = [STIMMessageModel new];
    [message setMessageType:STIMMessageType_CommonTrdInfo];
    [message setMessage:@"系统分享消息，请升级客户端版本进行查看"];
    message.extendInformation = msgContent;
    [controller setMessage:message];
    
    [controller setDelegate:self];
    [[self navigationController] presentViewController:nav animated:YES completion:^{
    }];
}

//分享到驼圈delegate
- (void)performShareWorkMomentActivity {
    NSString *title = self.title;
    NSURL *linkurl = _webView.request.URL;
    NSString *img = [NSString stringWithFormat:@"%@://%@/favicon.ico", [linkurl scheme], [linkurl host]];
    NSString *desc = @"点击查看全文";
    BOOL auth = NO;
    BOOL showas667 = NO;
    BOOL showbar = YES;
    NSDictionary *linkDic = @{@"title":title, @"img":img, @"desc":desc, @"linkurl":linkurl.absoluteString, @"showas667":@(showas667), @"showbar":@(showbar), @"auth":@(auth)};
    [STIMFastEntrance presentWorkMomentPushVCWithLinkDic:linkDic withNavVc:self.navigationController];
}

//拷贝Url
- (void)performCopyLinkActivity {
    NSURL *linkurl = _webView.request.URL;
    [[UIPasteboard generalPasteboard] setString:linkurl.absoluteString];
}

- (void)onMoreClick{
    
    NSURL * tempUrl = _webView.request.URL;
    STIMVerboseLog(@"onMoreClick webView Url : %@", _webView.request.URL);
    {
        //
        // 给appstore帐号审核用
        if (tempUrl == nil) {
            tempUrl = [NSURL URLWithString:@"https://dujia.qunar.com"];
        }
    }
    
    // Show activity view controller
    NSMutableArray *items = [NSMutableArray arrayWithObject:tempUrl];
    
    QActivityToFriend *toFriend = [[QActivityToFriend alloc] init];
    [toFriend setDelegate:self];
    
    QActivityToWorkFeed *shareWorkMoment = [[QActivityToWorkFeed alloc] init];
    [shareWorkMoment setDelegate:self];
    
    QActivityRefresh *refresh = [[QActivityRefresh alloc] init];
    [refresh setWebView:_webView];
    
    QActivityCopyLink *copyLink = [[QActivityCopyLink alloc] init];
    [copyLink setDelegate:self];
    
    QActivitySafari *safari = [[QActivitySafari alloc] init];
    [safari setUrl:tempUrl];
    
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
        self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[toFriend, shareWorkMoment, refresh, copyLink, safari]];
    } else {
        self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[toFriend, refresh, copyLink, safari]];
    }
    [self.activityViewController setExcludedActivityTypes:@[UIActivityTypeMail]];
    typeof(self) __weak weakSelf = self;
    [self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        weakSelf.activityViewController = nil;
    }];
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.needAuth = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    //Mark by oldiPad
    if ([[STIMKit sharedInstance] getIsIpad]) {
        self.view.frame = CGRectMake(0, 0, [[STIMWindowManager shareInstance] getDetailWidth], self.view.height);
    }
    [[UINavigationBar appearance] setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:nil];
    if (![[STIMKit sharedInstance] getIsIpad] && self.fromRegPackage == NO) {
        UIView *leftItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        [backButton setTitle:[NSBundle stimDB_localizedStringForKey:@"common_back"] forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [backButton setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"barbuttonicon_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftItem addSubview:backButton];
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
        [self.navigationController.navigationItem setLeftBarButtonItem:leftBarItem];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"barbuttonicon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(onMoreClick)];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    
    _progressProxyView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressProxyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_progressProxyView setProgress:0 animated:YES];
    [self.navigationController.navigationBar addSubview:_progressProxyView];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _webView.delegate = _progressProxy;
    if (self.needAuth) {
        if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
            NSString *ua = [[STIMWebView defaultUserAgent] stringByAppendingString:[[NSString alloc] initWithFormat:@"%@ - %@", @" qunartalk-ios-client", [[STIMKit sharedInstance] getDefaultUserAgentString]]];
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
        } else {
            if (self.fromMsgList) {
                NSString *ua = [[STIMWebView defaultUserAgent] stringByAppendingString:@" qchatiphone-msglist"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            } else if (self.fromOrderManager) {
                NSString *ua = [[STIMWebView defaultUserAgent] stringByAppendingString:@" qchatiphone-tts"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            } else if (self.fromQiangDan) {
                NSString *ua = [[STIMWebView defaultUserAgent] stringByAppendingString:@" qunariphone"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            } else {
                NSString *ua = [[STIMWebView defaultUserAgent] stringByAppendingString:@" qunarchat-ios-client"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            }
        }
    }
    if (![[STIMKit sharedInstance] getIsIpad]) {
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    }
    [_webView setScalesPageToFit:YES];
    [_webView setMultipleTouchEnabled:YES];
    [self.view addSubview:_webView];
    if (self.htmlString) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [_webView loadHTMLString:self.htmlString baseURL:baseURL];
    } else {
        if (self.fromRegPackage) {
            self.url = [self.url stringByAppendingFormat:@"&q_d=%@", [[STIMKit sharedInstance] getDomain]];
        }
        _requestUrl = [NSURL URLWithString:self.url];
        NSDictionary *queryDic = [[_requestUrl query] stimDB_dictionaryFromQueryComponents];
        if ([[queryDic objectForKey:@"navBarHidden"] isEqualToString:@"true"]) {
            [self setNavBarHidden:YES];
        }
        
        NSMutableURLRequest *request = nil;
        if (_package) {
            [self setNavigationButtons];
            [UIView performWithoutAnimation:^{
                [self layoutBottomNavigationToolbars];
            }];
            NSMutableDictionary *qckeyCookieProperties = [NSMutableDictionary dictionary];
            NSMutableDictionary *quCookieProperties = [NSMutableDictionary dictionary];
            NSMutableDictionary *qnmCookieProperties = [NSMutableDictionary dictionary];
            
            NSString *qckey = [[STIMKit sharedInstance] thirdpartKeywithValue];
            NSString *quserId = [STIMKit getLastUserName];
            [qckeyCookieProperties setSTIMSafeObject:qckey forKey:NSHTTPCookieValue];
            [qckeyCookieProperties setSTIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
            [qckeyCookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [qckeyCookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [qckeyCookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            [quCookieProperties setSTIMSafeObject:quserId forKey:NSHTTPCookieValue];
            [quCookieProperties setSTIMSafeObject:@"q_u" forKey:NSHTTPCookieName];
            [quCookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [quCookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [quCookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            [qnmCookieProperties setSTIMSafeObject:quserId forKey:NSHTTPCookieValue];
            [qnmCookieProperties setSTIMSafeObject:@"q_nm" forKey:NSHTTPCookieName];
            [qnmCookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [qnmCookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [qnmCookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            NSHTTPCookie*qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
            NSHTTPCookie*quCookie = [NSHTTPCookie cookieWithProperties:quCookieProperties];
            NSHTTPCookie*qnmCookie = [NSHTTPCookie cookieWithProperties:qnmCookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:quCookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qnmCookie];
            NSHTTPCookieStorage *cook = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            [cook setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
            request = [[NSMutableURLRequest alloc] initWithURL:_requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        } else if (_publicIm) {
            NSMutableDictionary *qckeyCookieProperties = [NSMutableDictionary dictionary];
            
            NSString *qckey = [[STIMKit sharedInstance] thirdpartKeywithValue];
            [qckeyCookieProperties setSTIMSafeObject:qckey forKey:NSHTTPCookieValue];
            [qckeyCookieProperties setSTIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
            [qckeyCookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [qckeyCookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [qckeyCookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            NSHTTPCookie*qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
            NSHTTPCookieStorage *cook = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            [cook setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
            request = [[NSMutableURLRequest alloc] initWithURL:_requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        } else if (_qcGrab || _qcZhongbao) {
            
            NSString * qCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
            NSString * vCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
            NSString * tCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
            
            if ([qCookie stimDB_isStringSafe] && [vCookie stimDB_isStringSafe] && [tCookie stimDB_isStringSafe])
            {
                NSMutableDictionary *qcookieProperties = [NSMutableDictionary dictionary];
                [qcookieProperties setSTIMSafeObject:@"_q" forKey:NSHTTPCookieName];
                [qcookieProperties setSTIMSafeObject:qCookie forKey:NSHTTPCookieValue];
                [qcookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost]forKey:NSHTTPCookieDomain];
                [qcookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [qcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*qcookie = [NSHTTPCookie cookieWithProperties:qcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qcookie];
                
                NSMutableDictionary *vcookieProperties = [NSMutableDictionary dictionary];
                [vcookieProperties setSTIMSafeObject:@"_v" forKey:NSHTTPCookieName];
                [vcookieProperties setSTIMSafeObject:vCookie forKey:NSHTTPCookieValue];
                [vcookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [vcookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [vcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*vcookie = [NSHTTPCookie cookieWithProperties:vcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:vcookie];
                
                NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
                [tcookieProperties setSTIMSafeObject:@"_t" forKey:NSHTTPCookieName];
                [tcookieProperties setSTIMSafeObject:tCookie forKey:NSHTTPCookieValue];
                [tcookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [tcookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [tcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*tcookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:tcookie];
            }
        } else if (self.fromHistory) {
            NSMutableDictionary *ucookieProperties = [NSMutableDictionary dictionary];
            NSMutableDictionary *kcookieProperties = [NSMutableDictionary dictionary];
            NSString *u = [STIMKit getLastUserName];
            NSString *k = [[STIMKit sharedInstance] remoteKey];
            
            [ucookieProperties setSTIMSafeObject:u forKey:NSHTTPCookieValue];
            [ucookieProperties setSTIMSafeObject:@"_u" forKey:NSHTTPCookieName];
            [ucookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [ucookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [ucookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            [kcookieProperties setSTIMSafeObject:k forKey:NSHTTPCookieValue];
            [kcookieProperties setSTIMSafeObject:@"_k" forKey:NSHTTPCookieName];
            [kcookieProperties setValue:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [kcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
            [kcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            NSHTTPCookie *uCookie = [NSHTTPCookie cookieWithProperties:ucookieProperties];
            NSHTTPCookie *kCookie = [NSHTTPCookie cookieWithProperties:kcookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:uCookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:kCookie];
        } else if (self.fromRegPackage) {
            
            NSMutableDictionary *dcookieProperties = [NSMutableDictionary dictionary];
            NSString *domain = [[STIMKit sharedInstance] getDomain];
            
            [dcookieProperties setSTIMSafeObject:domain forKey:NSHTTPCookieValue];
            [dcookieProperties setSTIMSafeObject:@"q_d" forKey:NSHTTPCookieName];
            [dcookieProperties setValue:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [dcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
            [dcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            NSHTTPCookie *dCookie = [NSHTTPCookie cookieWithProperties:dcookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:dCookie];
        } else {
            if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
                
                //QChat 默认qvt
                
                NSString * qCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
                NSString * vCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
                NSString * tCookie = [[[STIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
                
                NSMutableDictionary *qcookieProperties = [NSMutableDictionary dictionary];
                [qcookieProperties setSTIMSafeObject:@"_q" forKey:NSHTTPCookieName];
                [qcookieProperties setSTIMSafeObject:qCookie forKey:NSHTTPCookieValue];
                [qcookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [qcookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [qcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*qcookie = [NSHTTPCookie cookieWithProperties:qcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qcookie];
                
                NSMutableDictionary *vcookieProperties = [NSMutableDictionary dictionary];
                [vcookieProperties setSTIMSafeObject:@"_v" forKey:NSHTTPCookieName];
                [vcookieProperties setSTIMSafeObject:vCookie forKey:NSHTTPCookieValue];
                [vcookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [vcookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [vcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*vcookie = [NSHTTPCookie cookieWithProperties:vcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:vcookie];
                
                NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
                [tcookieProperties setSTIMSafeObject:@"_t" forKey:NSHTTPCookieName];
                [tcookieProperties setSTIMSafeObject:tCookie forKey:NSHTTPCookieValue];
                [tcookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [tcookieProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [tcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie *tcookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:tcookie];
                
                NSMutableDictionary *dcookieProperties = [NSMutableDictionary dictionary];
                NSString *domain = [[STIMKit sharedInstance] getDomain];
                
                [dcookieProperties setSTIMSafeObject:domain forKey:NSHTTPCookieValue];
                [dcookieProperties setSTIMSafeObject:@"q_d" forKey:NSHTTPCookieName];
                [dcookieProperties setValue:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [dcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [dcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                NSHTTPCookie *dcookie = [NSHTTPCookie cookieWithProperties:dcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:dcookie];
                
                NSMutableDictionary *qckeyCookieProperties = [NSMutableDictionary dictionary];
                NSString *qckey = [[STIMKit sharedInstance] thirdpartKeywithValue];
                [qckeyCookieProperties setSTIMSafeObject:qckey forKey:NSHTTPCookieValue];
                [qckeyCookieProperties setSTIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
                [qckeyCookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [qckeyCookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [qckeyCookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                NSHTTPCookie *qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
            } else {
                
                //QTalk 默认q_ckey
                NSMutableDictionary *dcookieProperties = [NSMutableDictionary dictionary];
                NSString *domain = [[STIMKit sharedInstance] getDomain];
                
                [dcookieProperties setSTIMSafeObject:domain forKey:NSHTTPCookieValue];
                [dcookieProperties setSTIMSafeObject:@"q_d" forKey:NSHTTPCookieName];
                [dcookieProperties setValue:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [dcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [dcookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSMutableDictionary *qckeyCookieProperties = [NSMutableDictionary dictionary];
                NSString *qckey = [[STIMKit sharedInstance] thirdpartKeywithValue];
                [qckeyCookieProperties setSTIMSafeObject:qckey forKey:NSHTTPCookieValue];
                [qckeyCookieProperties setSTIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
                [qckeyCookieProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [qckeyCookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [qckeyCookieProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
            
                NSDictionary*properties = [[NSMutableDictionary alloc] init];
                [properties setValue:[STIMKit getLastUserName] forKey:NSHTTPCookieValue];//value值
                [properties setValue:@"q_u" forKey:NSHTTPCookieName];//kay
                [properties setValue:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                
                [properties setValue:[[NSURL URLWithString:@"/"] path] forKey:NSHTTPCookiePath];
                NSHTTPCookie*cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

                
                NSHTTPCookie *qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
                NSHTTPCookie *dCookie = [NSHTTPCookie cookieWithProperties:dcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:dCookie];
               
            }
        }
//        if ([self.url isEqualToString:[[STIMKit sharedInstance] qimNav_getManagerAppUrl]]) {
            NSMutableDictionary *confignavProperties = [NSMutableDictionary dictionary];
            [confignavProperties setSTIMSafeObject:@"confignav" forKey:NSHTTPCookieName];
            [confignavProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_NavUrl] forKey:NSHTTPCookieValue];
            [confignavProperties setSTIMSafeObject:[[STIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [confignavProperties setSTIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [confignavProperties setSTIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            NSHTTPCookie *confignavCookie = [NSHTTPCookie cookieWithProperties:confignavProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:confignavCookie];
//        }
        NSHTTPCookieStorage *cook = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [cook setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        request = [[NSMutableURLRequest alloc] initWithURL:_requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [_webView loadRequest:request];
    }
    _webView.mediaPlaybackRequiresUserAction = NO;
    _webView.allowsInlineMediaPlayback = YES;
    STIMVerboseLog(@"WebView LoadRequest : %@ \n Cookie : %@", _requestUrl, [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies);
    if ([[STIMDeviceManager sharedInstance] isIphoneXSeries] == YES && @available(iOS 11.0, *)) {
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}
    
- (void)clearLoginCookie{
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [sharedHTTPCookieStorage cookies]) {
        [sharedHTTPCookieStorage deleteCookie:cookie];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController.navigationBar addSubview:_progressProxyView];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [_progressProxyView removeFromSuperview];
    self.toolbarItems = nil;
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[STIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    }else{
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[STIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        if (self.activityViewController) {
            return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
        } else {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[STIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft;
    }else{
        UIInterfaceOrientation orientation;
        switch ([[UIDevice currentDevice] orientation]) {
            case UIDeviceOrientationPortrait:
            {
                orientation = UIInterfaceOrientationPortrait;
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
            {
                orientation = UIInterfaceOrientationPortraitUpsideDown;
            }
                break;
            case UIDeviceOrientationLandscapeLeft:
            {
                orientation = UIInterfaceOrientationLandscapeLeft;
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                orientation = UIInterfaceOrientationLandscapeRight;
            }
                break;
            default:
            {
                orientation = UIInterfaceOrientationPortrait;
            }
                break;
        }
        return orientation;
    }
}

- (void)setUrl:(NSString *) theUrl {

    STIMVerboseLog(@"webView setUrl : %@", theUrl);
    if (!theUrl) {
        theUrl = @"https://dujia.qunar.com";
    }
    if (![theUrl stimDB_hasPrefixHttpHeader]) {
        theUrl = [NSString stringWithFormat:@"https://%@", theUrl];
    }
    if ([theUrl containsString:@"package/plts"]) {
        _package = YES;
        self.needAuth = NO;
    }
    if ([theUrl containsString:@"mainSite/touchs/"]) {
        _publicIm = YES;
        self.needAuth = NO;
        self.navBarHidden = YES;
    } else if ([theUrl containsString:@"qcGrab"]) {
        _qcGrab = YES;
    } else if ([theUrl containsString:@"qcOrder"] || [theUrl containsString:@"supplier.qunar"] ) {
        _qcZhongbao = YES;
        self.fromOrderManager = YES;
    }
    _url = theUrl;
}

#pragma mark Safari mode

- (void)setNavigationButtons{
    if (self.backButton == nil) {
        self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage stimDB_backButtonIcon:nil] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClicked:)];
    }
    if (self.forwardButton == nil) {
        self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage stimDB_forwardButtonIcon] style:UIBarButtonItemStylePlain target:self action:@selector(forwardBtnClicked:)];
    }
}


- (void)layoutBottomNavigationToolbars{
        [self.navigationController setToolbarHidden:NO animated:NO];
        //init
        self.toolbarItems = nil;
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.leftItemsSupplementBackButton = NO;
        
        //Set up array of buttons
        NSMutableArray *items = [NSMutableArray array];
        
        if (self.backButton){
            [items addObject:self.backButton];
        }
        if (self.forwardButton){
            [items addObject:self.forwardButton];
        }
        UIBarButtonItem *(^flexibleSpace)() = ^{
            return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        };
        
        BOOL lessThanFiveItems = items.count < 5;
        
        NSInteger index = 1;
        NSInteger itemsCount = items.count-1;
        for (NSInteger i = 0; i < itemsCount; i++) {
            [items insertObject:flexibleSpace() atIndex:index];
            index += 2;
        }
        
        if (lessThanFiveItems) {
            [items insertObject:flexibleSpace() atIndex:0];
            [items addObject:flexibleSpace()];
        }
        
        self.toolbarItems = items;
    
        return;
}
#pragma mark - toolbar button status


#pragma mark - Button action
- (void)backBtnClicked:(id)sender{
    [self goBack];
}

- (void)forwardBtnClicked:(id)sender{
    [_webView goForward];
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressProxyView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)openSingleChat:(NSString *)jid{
    
    NSDictionary *userInfoDic = [[STIMKit sharedInstance] getUserInfoByUserId:jid];
    if (userInfoDic == nil) {
//        [[STIMKit sharedInstance] updateUserCard:@[jid]];
        [[STIMKit sharedInstance] updateUserCard:jid withCache:YES];
        userInfoDic = [[STIMKit sharedInstance] getUserInfoByUserId:jid];
    }
    if (userInfoDic) {
        NSString *xmppId = [userInfoDic objectForKey:@"XmppId"];
        NSString *name = [userInfoDic objectForKey:@"Name"];
        [[STIMKit sharedInstance] clearNotReadMsgByJid:xmppId];
        [STIMFastEntrance openSingleChatVCByUserId:xmppId];
    }
}

- (void)openGroupChat:(NSString *)jid{
    NSDictionary *groupDic = [[STIMKit sharedInstance] getGroupCardByGroupId:jid];
    if (groupDic) {
        NSString *jid = [groupDic objectForKey:@"GroupId"];
        [[STIMKit sharedInstance] clearNotReadMsgByGroupId:jid];
        [STIMFastEntrance openGroupChatVCByGroupId:jid];
    }
}

- (void)openUrl:(NSString *)url{
    STIMWebView *webView = [[STIMWebView alloc] init];
    [webView setUrl:url];
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)resgisterJSMethod{
    JSContext *context=[_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"openNewSession"] = ^() {
        NSArray *args = [JSContext currentArguments];
        NSString *jid = [args.firstObject toString];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([jid rangeOfString:@"@conference"].location == NSNotFound) {
                [self openSingleChat:jid];
            } else {
                [self openGroupChat:jid];
            }
        });
    };
    context[@"openNewLink"] = ^() {
        NSArray *args = [JSContext currentArguments];
        NSString *url = [args.firstObject toString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openUrl:url];
        });
    };
    context[@"updateCardState"] = ^() {
        NSArray *args = [JSContext currentArguments];
        if (args.count >= 2) {
            NSString *msgId = [args[0] toString];
            NSString *state = [args[1] toString];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationUpdateQDMessageState" object:self.fromUserId userInfo:@{@"MsgId":msgId,@"State":state}];
            });
        }
    };
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.fromQiangDan) {
        [self resgisterJSMethod];
    }
    if (self.navBarHidden) {
        if (self.navigationController.navigationBarHidden == NO) {
            [self.navigationController setNavigationBarHidden:self.navBarHidden animated:YES];
        }
    } else {
        NSString *webTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        [[self navigationItem] setTitle:webTitle];
        
        UIView *leftItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        //            [leftItem setBackgroundColor:[UIColor redColor]];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        [backButton setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [backButton setTitle:[NSBundle stimDB_localizedStringForKey:@"common_back"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"barbuttonicon_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftItem addSubview:backButton];
        if (_webView.canGoBack) {
            UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 40, 44)];
            [closeButton setTitle:[NSBundle stimDB_localizedStringForKey:@"common_close"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(quitItemHandle:) forControlEvents:UIControlEventTouchUpInside];
            [closeButton setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
            [leftItem addSubview:closeButton];
            [leftItem setWidth:90];
        }
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
        [self.navigationController.navigationItem setLeftBarButtonItem:leftBarItem];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlStr = [[request URL] absoluteString];
    NSArray * components = [urlStr componentsSeparatedByString:@":"];
    if ([urlStr hasPrefix:@"qchatiphone://"] && components.count > 1) {
        if ([[[components objectAtIndex:1] lowercaseString] isEqualToString:@"//vacation/web/close"]) {
            [self quitItemHandle:nil];
            return NO;
        }
    }else if ([urlStr hasPrefix:@"qunartalk://"] && components.count > 1){
        if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//redpackge"]) {
            NSMutableDictionary *dictionaryQuery = [NSMutableDictionary dictionaryWithDictionary:[[[request URL] query] stimDB_dictionaryFromQueryComponents]];
            [[NSNotificationCenter defaultCenter] postNotificationName:WillSendRedPackNotification object:dictionaryQuery[@"content"]];
            [self.navigationController popViewControllerAnimated:YES];
            self.toolbarItems = nil;
            [self.navigationController setToolbarHidden:YES animated:NO];
            return NO;
        }else if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//closeredpackage"]){
            [self quitItemHandle:nil];
        }
        return NO;
    } else if ([urlStr hasPrefix:@"qchat://"] && components.count > 1) {
        if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//open_singlechat"]) {
            NSString *propertys = [[request URL] query];
            NSArray *subArray = [propertys componentsSeparatedByString:@"&"];
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
            
            for (int j = 0 ; j < subArray.count; j++)
            {
                
                //在通过=拆分键和值
                NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
                //给字典加入元素
                NSString *value = [[dicArray objectAtIndex:1] stimDB_URLDecodedString];
                NSString *key = [[dicArray objectAtIndex:0] stimDB_URLDecodedString];
                if (key && value) {
                    [tempDic setSTIMSafeObject:value forKey:key];
                }
            }
            STIMVerboseLog(@"打印参数列表生成的字典：\n%@", tempDic);
            NSString *xmppJid = [tempDic objectForKey:@"userid"];
            [[STIMKit sharedInstance] setConversationParam:tempDic WithJid:xmppJid];
            [self openSingleChat:xmppJid];
            return NO;
        }
    } else if ([urlStr hasPrefix:@"qim://"]) {
        if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//close"]) {
            [self quitItemHandle:nil];
            return NO;
        } else if ([[components objectAtIndex:1] hasPrefix:@"//publicNav/resetpwdSuccessed"]) {
            [STIMFastEntrance reloginAccount];
            return NO;
        } else if ([[components objectAtIndex:1] hasPrefix:@"//qrCodeShareImg"]){
            [self shareUrlImg:[request URL]];
            return NO;
        }
    } else if ([urlStr hasPrefix:@"qtalkaphone://"]  && components.count > 1) {
//        qtalkaphone://uploadNoteImage?fileName=2AE022E5-34DF-416A-8EB4-F29CBB7FCFB4.jpeg&fileStr=data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD/
        /*
        if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//uploadnoteimage"]) {
            NSString *propertys = [[request URL] query];
            NSArray *subArray = [propertys componentsSeparatedByString:@"&"];
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
            for (int j = 0 ; j < subArray.count; j++)
            {
                
                //在通过=拆分键和值
                NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
                //给字典加入元素
                NSString *value = [[dicArray objectAtIndex:1] stimDB_URLDecodedString];
                NSString *key = [[dicArray objectAtIndex:0] stimDB_URLDecodedString];
                if (key && value) {
                    [tempDic setSTIMSafeObject:value forKey:key];
                }
            }
            NSString *fileName = [tempDic objectForKey:@"fileName"];
            NSString *fileStr = [tempDic objectForKey:@"fileStr"];
            NSString *fileBaseStr = [[[[fileStr componentsSeparatedByString:@";"] lastObject] componentsSeparatedByString:@","] lastObject];
            NSData *decodedImgData = [[NSData alloc] initWithBase64EncodedString:fileBaseStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSLog(@"%@", fileBaseStr);
            NSString *fileUrl = [STIMHttpApi updateLoadFile:decodedImgData WithMsgId:[STIMUUIDTools UUID] WithMsgType:1 WithPathExtension:nil];
            NSLog(@"fileUrl : %@", fileUrl);
            if (![fileUrl stimDB_hasPrefixHttpHeader]) {
                fileUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], fileUrl];
                
                JSContext *context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
                
                
                NSString *jsStr = [NSString stringWithFormat:@"uploadCallback('%@')", fileUrl];
                //OC调用JS方法
                JSValue *value = [context evaluateScript:jsStr];
                NSLog(@"jsValue : %@", value);
//                NSString *str = [_webView stringByEvaluatingJavaScriptFromString:jsStr];
//                NSLog(@"str : %@", str);
            }
            return  NO;
        }
        */
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // 如果是被取消，什么也不干
    if([error code] == NSURLErrorCancelled)  {
        return;
    }
    return;
}

- (void)goBack
{
    if (_webView.canGoBack) {
        [_webView goBack];
        return;
    }else{
        if ([[STIMKit sharedInstance] getIsIpad]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.toolbarItems = nil;
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

- (void)quitItemHandle:(id)sender
{
    if ([[STIMKit sharedInstance] getIsIpad]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        self.toolbarItems = nil;
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

- (void)shareUrlImg:(NSURL *)url{
    
    NSString * query = url.query;
    NSString * urlStr;
    if (query.length > 0 && query) {
        urlStr = [query stringByReplacingOccurrencesOfString:@"imgUrl=" withString:@""];
    }
    else{
        return;
    }
    if (!urlStr && !urlStr<0) {
        return;
    }
    // Show activity view controller
    __weak typeof(self) weakSelf = self;
    [[STIMImageManager sharedInstance] loadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:image];
        weakSelf.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        // Show loading spinner after a couple of seconds
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (weakSelf.activityViewController) {
                //                    [self showProgressHUDWithMessage:nil];
            }
        });
        
        // Show
        typeof(self) __weak weakSelf = weakSelf;
        [weakSelf.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            weakSelf.activityViewController = nil;
        }];
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }];
    /*
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:image];
        weakSelf.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        // Show loading spinner after a couple of seconds
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (weakSelf.activityViewController) {
                //                    [self showProgressHUDWithMessage:nil];
            }
        });
        
        // Show
        typeof(self) __weak weakSelf = weakSelf;
        [weakSelf.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            weakSelf.activityViewController = nil;
        }];
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }];
    */
    /*
    [[STIMSDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr] options:STIMSDWebImageDownloaderLowPriority gifFlag:NO progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:image];
        weakSelf.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        // Show loading spinner after a couple of seconds
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (weakSelf.activityViewController) {
                //                    [self showProgressHUDWithMessage:nil];
            }
        });
        
        // Show
        typeof(self) __weak weakSelf = weakSelf;
        [weakSelf.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            weakSelf.activityViewController = nil;
        }];
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }];
    */
}

@end

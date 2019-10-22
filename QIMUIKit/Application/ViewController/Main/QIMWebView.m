//
//  QIMWebView.m
//  qunarChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import "QIMWebView.h"
#import "QIMChatVC.h"
#import "QIMGroupChatVC.h"
#import "QIMContactSelectionViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "UIImage+QIMButtonIcon.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMJSONSerializer.h"
#import "QIMKit+QIMNavConfig.h"
#import "QIMMWPhoto.h"

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
    return [NSBundle qim_localizedStringForKey:@"webview_share_workmoment"];
}

- (UIImage *)activityImage {
    return [UIImage qim_imageNamedFromQIMUIKitBundle:@"webview_shareworkmoment"];
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
    return [NSBundle qim_localizedStringForKey:@"webview_copy_link"];
}

- (UIImage *)activityImage {
    return [[UIImage qim_imageNamedFromQIMUIKitBundle:@"webview_copylink"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
    return [NSBundle qim_localizedStringForKey:@"webview_share_conversion"];
}

- (UIImage *)activityImage {
    return [[UIImage qim_imageNamedFromQIMUIKitBundle:@"webview_shareConversion"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
    return [NSBundle qim_localizedStringForKey:@"webview_open_safari"];
}
- (UIImage *)activityImage {
    return [[UIImage qim_imageNamedFromQIMUIKitBundle:@"safari_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
    return [NSBundle qim_localizedStringForKey:@"webview_refresh"];
}
- (UIImage *)activityImage {
    return [[UIImage qim_imageNamedFromQIMUIKitBundle:@"webview_refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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

@interface QIMWebView() <NJKWebViewProgressDelegate, UIWebViewDelegate, QActivityToFriendDelegate,QIMContactSelectionViewControllerDelegate>
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic,strong) UIBarButtonItem *backButton;
@property (nonatomic,strong) UIBarButtonItem *forwardButton;
@property (nonatomic,strong) UIImage *reloadImg;
@property (nonatomic,strong) UIImage *stopImg;

@end
@implementation QIMWebView{
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
    UIImage *image = [UIImage qim_imageWithColor:[UIColor qim_colorWithHex:0xDDDDDD] size:CGSizeMake([[QIMWindowManager shareInstance] getDetailWidth], 0.5)];
    [[UINavigationBar appearance] setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:image];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)chatVC:(QIMChatVC *)vc{
    [vc sendText:self.url];
}

- (void)groupChatVC:(QIMGroupChatVC *)vc{
    [vc sendText:self.url];
}

//分享到会话delegate
- (void)performActivity{
    NSURL *url = _webView.request.URL;
    QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
    
    NSString *title = self.title;
    NSURL *linkurl = _webView.request.URL;
    NSString *img = [NSString stringWithFormat:@"%@://%@/favicon.ico", [linkurl scheme], [linkurl host]];
    NSString *desc = @"点击查看全文";
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:(title.length > 0) ? title : linkurl.absoluteString forKey:@"title"];
    [infoDic setQIMSafeObject:desc forKey:@"desc"];
    [infoDic setQIMSafeObject:linkurl.absoluteString forKey:@"linkurl"];
    [infoDic setQIMSafeObject:img forKey:@"img"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];

    QIMMessageModel *message = [QIMMessageModel new];
    [message setMessageType:QIMMessageType_CommonTrdInfo];
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
    [QIMFastEntrance presentWorkMomentPushVCWithLinkDic:linkDic withNavVc:self.navigationController];
}

//拷贝Url
- (void)performCopyLinkActivity {
    NSURL *linkurl = _webView.request.URL;
    [[UIPasteboard generalPasteboard] setString:linkurl.absoluteString];
}

- (void)onMoreClick{
    
    NSURL * tempUrl = _webView.request.URL;
    QIMVerboseLog(@"onMoreClick webView Url : %@", _webView.request.URL);
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
    
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
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
    if ([[QIMKit sharedInstance] getIsIpad]) {
        self.view.frame = CGRectMake(0, 0, [[QIMWindowManager shareInstance] getDetailWidth], self.view.height);
    }
    [[UINavigationBar appearance] setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:nil];
    if (![[QIMKit sharedInstance] getIsIpad] && self.fromRegPackage == NO) {
        UIView *leftItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        [backButton setTitle:[NSBundle qim_localizedStringForKey:@"common_back"] forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [backButton setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"barbuttonicon_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftItem addSubview:backButton];
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
        [self.navigationController.navigationItem setLeftBarButtonItem:leftBarItem];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"barbuttonicon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(onMoreClick)];
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
        if ([QIMKit getQIMProjectType] != QIMProjectTypeQChat) {
            NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:[[NSString alloc] initWithFormat:@"%@ - %@", @" qunartalk-ios-client", [[QIMKit sharedInstance] getDefaultUserAgentString]]];
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
        } else {
            if (self.fromMsgList) {
                NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:@" qchatiphone-msglist"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            } else if (self.fromOrderManager) {
                NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:@" qchatiphone-tts"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            } else if (self.fromQiangDan) {
                NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:@" qunariphone"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            } else {
                NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:@" qunarchat-ios-client"];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
            }
        }
    }
    if (![[QIMKit sharedInstance] getIsIpad]) {
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
            self.url = [self.url stringByAppendingFormat:@"&q_d=%@", [[QIMKit sharedInstance] getDomain]];
        }
        _requestUrl = [NSURL URLWithString:self.url];
        NSDictionary *queryDic = [[_requestUrl query] qim_dictionaryFromQueryComponents];
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
            
            NSString *qckey = [[QIMKit sharedInstance] thirdpartKeywithValue];
            NSString *quserId = [QIMKit getLastUserName];
            [qckeyCookieProperties setQIMSafeObject:qckey forKey:NSHTTPCookieValue];
            [qckeyCookieProperties setQIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
            [qckeyCookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [qckeyCookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [qckeyCookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            [quCookieProperties setQIMSafeObject:quserId forKey:NSHTTPCookieValue];
            [quCookieProperties setQIMSafeObject:@"q_u" forKey:NSHTTPCookieName];
            [quCookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [quCookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [quCookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            [qnmCookieProperties setQIMSafeObject:quserId forKey:NSHTTPCookieValue];
            [qnmCookieProperties setQIMSafeObject:@"q_nm" forKey:NSHTTPCookieName];
            [qnmCookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [qnmCookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [qnmCookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
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
            
            NSString *qckey = [[QIMKit sharedInstance] thirdpartKeywithValue];
            [qckeyCookieProperties setQIMSafeObject:qckey forKey:NSHTTPCookieValue];
            [qckeyCookieProperties setQIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
            [qckeyCookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [qckeyCookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [qckeyCookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            NSHTTPCookie*qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
            NSHTTPCookieStorage *cook = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            [cook setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
            request = [[NSMutableURLRequest alloc] initWithURL:_requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        } else if (_qcGrab || _qcZhongbao) {
            
            NSString * qCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
            NSString * vCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
            NSString * tCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
            
            if ([qCookie qim_isStringSafe] && [vCookie qim_isStringSafe] && [tCookie qim_isStringSafe])
            {
                NSMutableDictionary *qcookieProperties = [NSMutableDictionary dictionary];
                [qcookieProperties setQIMSafeObject:@"_q" forKey:NSHTTPCookieName];
                [qcookieProperties setQIMSafeObject:qCookie forKey:NSHTTPCookieValue];
                [qcookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost]forKey:NSHTTPCookieDomain];
                [qcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [qcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*qcookie = [NSHTTPCookie cookieWithProperties:qcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qcookie];
                
                NSMutableDictionary *vcookieProperties = [NSMutableDictionary dictionary];
                [vcookieProperties setQIMSafeObject:@"_v" forKey:NSHTTPCookieName];
                [vcookieProperties setQIMSafeObject:vCookie forKey:NSHTTPCookieValue];
                [vcookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [vcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [vcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*vcookie = [NSHTTPCookie cookieWithProperties:vcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:vcookie];
                
                NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
                [tcookieProperties setQIMSafeObject:@"_t" forKey:NSHTTPCookieName];
                [tcookieProperties setQIMSafeObject:tCookie forKey:NSHTTPCookieValue];
                [tcookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [tcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [tcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*tcookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:tcookie];
            }
        } else if (self.fromHistory) {
            NSMutableDictionary *ucookieProperties = [NSMutableDictionary dictionary];
            NSMutableDictionary *kcookieProperties = [NSMutableDictionary dictionary];
            NSString *u = [QIMKit getLastUserName];
            NSString *k = [[QIMKit sharedInstance] remoteKey];
            
            [ucookieProperties setQIMSafeObject:u forKey:NSHTTPCookieValue];
            [ucookieProperties setQIMSafeObject:@"_u" forKey:NSHTTPCookieName];
            [ucookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [ucookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [ucookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            [kcookieProperties setQIMSafeObject:k forKey:NSHTTPCookieValue];
            [kcookieProperties setQIMSafeObject:@"_k" forKey:NSHTTPCookieName];
            [kcookieProperties setValue:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [kcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
            [kcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            NSHTTPCookie *uCookie = [NSHTTPCookie cookieWithProperties:ucookieProperties];
            NSHTTPCookie *kCookie = [NSHTTPCookie cookieWithProperties:kcookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:uCookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:kCookie];
        } else if (self.fromRegPackage) {
            
            NSMutableDictionary *dcookieProperties = [NSMutableDictionary dictionary];
            NSString *domain = [[QIMKit sharedInstance] getDomain];
            
            [dcookieProperties setQIMSafeObject:domain forKey:NSHTTPCookieValue];
            [dcookieProperties setQIMSafeObject:@"q_d" forKey:NSHTTPCookieName];
            [dcookieProperties setValue:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [dcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
            [dcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
            
            NSHTTPCookie *dCookie = [NSHTTPCookie cookieWithProperties:dcookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:dCookie];
        } else {
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                
                //QChat 默认qvt
                
                NSString * qCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
                NSString * vCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
                NSString * tCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
                
                NSMutableDictionary *qcookieProperties = [NSMutableDictionary dictionary];
                [qcookieProperties setQIMSafeObject:@"_q" forKey:NSHTTPCookieName];
                [qcookieProperties setQIMSafeObject:qCookie forKey:NSHTTPCookieValue];
                [qcookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [qcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [qcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*qcookie = [NSHTTPCookie cookieWithProperties:qcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qcookie];
                
                NSMutableDictionary *vcookieProperties = [NSMutableDictionary dictionary];
                [vcookieProperties setQIMSafeObject:@"_v" forKey:NSHTTPCookieName];
                [vcookieProperties setQIMSafeObject:vCookie forKey:NSHTTPCookieValue];
                [vcookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [vcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [vcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie*vcookie = [NSHTTPCookie cookieWithProperties:vcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:vcookie];
                
                NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
                [tcookieProperties setQIMSafeObject:@"_t" forKey:NSHTTPCookieName];
                [tcookieProperties setQIMSafeObject:tCookie forKey:NSHTTPCookieValue];
                [tcookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [tcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
                [tcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSHTTPCookie *tcookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:tcookie];
                
                NSMutableDictionary *dcookieProperties = [NSMutableDictionary dictionary];
                NSString *domain = [[QIMKit sharedInstance] getDomain];
                
                [dcookieProperties setQIMSafeObject:domain forKey:NSHTTPCookieValue];
                [dcookieProperties setQIMSafeObject:@"q_d" forKey:NSHTTPCookieName];
                [dcookieProperties setValue:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [dcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [dcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                NSHTTPCookie *dcookie = [NSHTTPCookie cookieWithProperties:dcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:dcookie];
                
                NSMutableDictionary *qckeyCookieProperties = [NSMutableDictionary dictionary];
                NSString *qckey = [[QIMKit sharedInstance] thirdpartKeywithValue];
                [qckeyCookieProperties setQIMSafeObject:qckey forKey:NSHTTPCookieValue];
                [qckeyCookieProperties setQIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
                [qckeyCookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [qckeyCookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [qckeyCookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                NSHTTPCookie *qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
            } else {
                
                //QTalk 默认q_ckey
                NSMutableDictionary *dcookieProperties = [NSMutableDictionary dictionary];
                NSString *domain = [[QIMKit sharedInstance] getDomain];
                
                [dcookieProperties setQIMSafeObject:domain forKey:NSHTTPCookieValue];
                [dcookieProperties setQIMSafeObject:@"q_d" forKey:NSHTTPCookieName];
                [dcookieProperties setValue:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [dcookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [dcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
                NSMutableDictionary *qckeyCookieProperties = [NSMutableDictionary dictionary];
                NSString *qckey = [[QIMKit sharedInstance] thirdpartKeywithValue];
                [qckeyCookieProperties setQIMSafeObject:qckey forKey:NSHTTPCookieValue];
                [qckeyCookieProperties setQIMSafeObject:@"q_ckey" forKey:NSHTTPCookieName];
                [qckeyCookieProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                [qckeyCookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
                [qckeyCookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
                
            
                NSDictionary*properties = [[NSMutableDictionary alloc] init];
                [properties setValue:[QIMKit getLastUserName] forKey:NSHTTPCookieValue];//value值
                [properties setValue:@"q_u" forKey:NSHTTPCookieName];//kay
                [properties setValue:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
                
                [properties setValue:[[NSURL URLWithString:@"/"] path] forKey:NSHTTPCookiePath];
                NSHTTPCookie*cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

                
                NSHTTPCookie *qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
                NSHTTPCookie *dCookie = [NSHTTPCookie cookieWithProperties:dcookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:dCookie];
               
            }
        }
//        if ([self.url isEqualToString:[[QIMKit sharedInstance] qimNav_getManagerAppUrl]]) {
            NSMutableDictionary *confignavProperties = [NSMutableDictionary dictionary];
            [confignavProperties setQIMSafeObject:@"confignav" forKey:NSHTTPCookieName];
            [confignavProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_NavUrl] forKey:NSHTTPCookieValue];
            [confignavProperties setQIMSafeObject:[[QIMKit sharedInstance] qimNav_DomainHost] forKey:NSHTTPCookieDomain];
            [confignavProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
            [confignavProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
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
    QIMVerboseLog(@"WebView LoadRequest : %@ \n Cookie : %@", _requestUrl, [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies);
    if ([[QIMDeviceManager sharedInstance] isIphoneXSeries] == YES && @available(iOS 11.0, *)) {
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
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    }else{
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[QIMKit sharedInstance] getIsIpad]) {
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
    if ([[QIMKit sharedInstance] getIsIpad]) {
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

    QIMVerboseLog(@"webView setUrl : %@", theUrl);
    if (!theUrl) {
        theUrl = @"https://dujia.qunar.com";
    }
    if (![theUrl qim_hasPrefixHttpHeader]) {
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
        self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage qim_backButtonIcon:nil] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClicked:)];
    }
    if (self.forwardButton == nil) {
        self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage qim_forwardButtonIcon] style:UIBarButtonItemStylePlain target:self action:@selector(forwardBtnClicked:)];
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
    
    NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    if (userInfoDic == nil) {
//        [[QIMKit sharedInstance] updateUserCard:@[jid]];
        [[QIMKit sharedInstance] updateUserCard:jid withCache:YES];
        userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    }
    if (userInfoDic) {
        NSString *xmppId = [userInfoDic objectForKey:@"XmppId"];
        NSString *name = [userInfoDic objectForKey:@"Name"];
        [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId];
        [QIMFastEntrance openSingleChatVCByUserId:xmppId];
    }
}

- (void)openGroupChat:(NSString *)jid{
    NSDictionary *groupDic = [[QIMKit sharedInstance] getGroupCardByGroupId:jid];
    if (groupDic) {
        NSString *jid = [groupDic objectForKey:@"GroupId"];
        [[QIMKit sharedInstance] clearNotReadMsgByGroupId:jid];
        [QIMFastEntrance openGroupChatVCByGroupId:jid];
    }
}

- (void)openUrl:(NSString *)url{
    QIMWebView *webView = [[QIMWebView alloc] init];
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
        [backButton setTitle:[NSBundle qim_localizedStringForKey:@"common_back"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"barbuttonicon_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftItem addSubview:backButton];
        if (_webView.canGoBack) {
            UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 40, 44)];
            [closeButton setTitle:[NSBundle qim_localizedStringForKey:@"common_close"] forState:UIControlStateNormal];
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
            NSMutableDictionary *dictionaryQuery = [NSMutableDictionary dictionaryWithDictionary:[[[request URL] query] qim_dictionaryFromQueryComponents]];
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
                NSString *value = [[dicArray objectAtIndex:1] qim_URLDecodedString];
                NSString *key = [[dicArray objectAtIndex:0] qim_URLDecodedString];
                if (key && value) {
                    [tempDic setQIMSafeObject:value forKey:key];
                }
            }
            QIMVerboseLog(@"打印参数列表生成的字典：\n%@", tempDic);
            NSString *xmppJid = [tempDic objectForKey:@"userid"];
            [[QIMKit sharedInstance] setConversationParam:tempDic WithJid:xmppJid];
            [self openSingleChat:xmppJid];
            return NO;
        }
    } else if ([urlStr hasPrefix:@"qim://"]) {
        if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//close"]) {
            [self quitItemHandle:nil];
            return NO;
        } else if ([[components objectAtIndex:1] hasPrefix:@"//publicNav/resetpwdSuccessed"]) {
            [QIMFastEntrance reloginAccount];
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
                NSString *value = [[dicArray objectAtIndex:1] qim_URLDecodedString];
                NSString *key = [[dicArray objectAtIndex:0] qim_URLDecodedString];
                if (key && value) {
                    [tempDic setQIMSafeObject:value forKey:key];
                }
            }
            NSString *fileName = [tempDic objectForKey:@"fileName"];
            NSString *fileStr = [tempDic objectForKey:@"fileStr"];
            NSString *fileBaseStr = [[[[fileStr componentsSeparatedByString:@";"] lastObject] componentsSeparatedByString:@","] lastObject];
            NSData *decodedImgData = [[NSData alloc] initWithBase64EncodedString:fileBaseStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSLog(@"%@", fileBaseStr);
            NSString *fileUrl = [QIMHttpApi updateLoadFile:decodedImgData WithMsgId:[QIMUUIDTools UUID] WithMsgType:1 WithPathExtension:nil];
            NSLog(@"fileUrl : %@", fileUrl);
            if (![fileUrl qim_hasPrefixHttpHeader]) {
                fileUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], fileUrl];
                
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
        if ([[QIMKit sharedInstance] getIsIpad]) {
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
    if ([[QIMKit sharedInstance] getIsIpad]) {
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
    [[QIMImageManager sharedInstance] loadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
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
    [[QIMSDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr] options:QIMSDWebImageDownloaderLowPriority gifFlag:NO progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
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

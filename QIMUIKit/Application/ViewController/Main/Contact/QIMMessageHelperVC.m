//
//  QIMMessageHelperVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import "QIMMessageHelperVC.h"
#import "NSBundle+QIMLibrary.h"
#import "UIApplication+QIMApplication.h"
#import "QTalkSessionView.h"

@interface QIMMessageHelperVC ()

@property(nonatomic, strong) UIView *emptyView;

@property(nonatomic, strong) QTalkSessionView *sessionView;

@property(nonatomic, strong) NSMutableArray *recentContactArray;

@end

@implementation QIMMessageHelperVC

- (QTalkSessionView *)sessionView {

    if (!_sessionView) {
        
        _sessionView = [[QTalkSessionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 5)];
        _sessionView.backgroundColor = [UIColor spectralColorWhiteColor];
        [_sessionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _sessionView.notShowHeader = YES;
        _sessionView.showNotReadList = YES;
        [_sessionView setSessionViewHeader:nil];
    }
    return _sessionView;
}

- (NSMutableArray *)recentContactArray {
    if (!_recentContactArray) {
        _recentContactArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _recentContactArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithNav];
    [self getNotReadMsgList];
    if (self.recentContactArray.count <= 0) {
        [self loadEmptyNotReadMsgList];
    } else {
        [self initWithTableView];
        [self.sessionView sessionViewWillAppear];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.sessionView sessionViewWillAppear];
}

#pragma mark - init ui

- (void)initWithNav {
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_not_read"]];
}

- (void)initWithTableView {
    [self.view addSubview:self.sessionView];
}

- (void)getNotReadMsgList {
    [self.recentContactArray removeAllObjects];
    self.recentContactArray = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getNotReadSessionList]];
}

- (void)loadEmptyNotReadMsgList {
    [self.emptyView removeAllSubviews];
    [self.emptyView removeFromSuperview];
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 130)];
    self.emptyView.backgroundColor = [UIColor whiteColor];
    self.emptyView.center = self.view.center;
    UIImageView *emptyIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    emptyIconView.backgroundColor = [UIColor whiteColor];
    emptyIconView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"EmptyNotReadList"];
    [self.emptyView addSubview:emptyIconView];
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyIconView.bottom + 5, 150, 25)];
    [emptyLabel setText:@"当前无未读消息"];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyView addSubview:emptyLabel];
    [self.view addSubview:self.emptyView];
    [self.view bringSubviewToFront:self.emptyView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

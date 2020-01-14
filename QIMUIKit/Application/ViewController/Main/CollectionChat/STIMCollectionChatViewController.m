//
//  STIMCollectionChatViewController.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/9/21.
//

#import "STIMCollectionChatViewController.h"
#import "QTalkNewSessionTableViewCell.h"
#import "STIMPublicNumberVC.h"
#import "STIMChatVC.h"
#import "STIMGroupChatVC.h"
#import "STIMFriendNotifyViewController.h"
#import "STIMWebView.h"
#import "SCLAlertView.h"

@interface STIMCollectionChatViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableDictionary *collectionChatDict;
@property (nonatomic, strong) NSMutableArray *collectionAccountList;
@property (nonatomic, strong) SCLAlertView *waitingAlert;

@end

@implementation STIMCollectionChatViewController

- (NSMutableDictionary *)collectionChatDict {
    if (!_collectionChatDict) {
        _collectionChatDict = [NSMutableDictionary dictionaryWithDictionary:[self getCollectionSessionDict]];
        if (!_collectionChatDict) {
            _collectionChatDict = [NSMutableDictionary dictionaryWithCapacity:5];
        }
    }
    return _collectionChatDict;
}

- (NSMutableArray *)collectionAccountList {
    if (!_collectionAccountList) {
        _collectionAccountList = [NSMutableArray arrayWithArray:[[STIMKit sharedInstance] getCollectionAccountList]];
        if (!_collectionAccountList) {
            _collectionAccountList = [NSMutableArray arrayWithCapacity:5];
        }
    }
    return _collectionAccountList;
}

- (SCLAlertView *)waitingAlert {
    _waitingAlert = [[SCLAlertView alloc] init];
    return _waitingAlert;
}

- (NSMutableDictionary *)getCollectionSessionDict {
    NSMutableDictionary *collectionChatSessionDict = [NSMutableDictionary dictionaryWithCapacity:5];
    for (NSDictionary *accountDic in self.collectionAccountList) {
        NSString *bindId = [accountDic objectForKey:@"BindId"];
        NSArray *collectionMsgList = [[STIMKit sharedInstance] getCollectionSessionListWithBindId:bindId];
        if (collectionMsgList.count > 0) {
            [collectionChatSessionDict setObject:collectionMsgList forKey:bindId];
        } else {
            [collectionChatSessionDict setObject:[NSArray array] forKey:bindId];
        }
    }
    return collectionChatSessionDict;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = stimDB_chatBgColor;
        _mainTableView.tableFooterView = [UIView new];
        _mainTableView.separatorInset = UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self initUI];
    [self registNotification];
}

- (void)setNav {
    self.title = @"我的其他关联账号";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStyleDone target:self action:@selector(manager)];
}

- (void)initUI {
    [self.view addSubview:self.mainTableView];
}

- (void)registNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"updateCollectionMsgList" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    [self.collectionChatDict removeAllObjects];
    self.collectionChatDict = [NSMutableDictionary dictionaryWithDictionary:[self getCollectionSessionDict]];
    [self.mainTableView reloadData];
}

- (void)manager {
    NSString *linkUrl = [NSString stringWithFormat:@"%@?u=%@&d=%@&navBarBg=208EF2", [[STIMKit sharedInstance] qimNav_Mconfig], [STIMKit getLastUserName], [[STIMKit sharedInstance] qimNav_Domain]];
    STIMWebView *webView = [[STIMWebView alloc] init];
    [webView setUrl:linkUrl];
    [self.navigationController pushViewController:webView animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSDictionary *collectionAccountDic = [self.collectionAccountList objectAtIndex:section];
    NSString *bindId = [collectionAccountDic objectForKey:@"BindId"];
    NSString *bindName = [collectionAccountDic objectForKey:@"BindName"];
    NSString *bindHeaderSrc = [collectionAccountDic objectForKey:@"HeaderSrc"];
    if (![bindHeaderSrc stimDB_hasPrefixHttpHeader] && bindHeaderSrc.length > 0) {
        bindHeaderSrc = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], bindHeaderSrc];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50.0f)];
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 36, 36)];
    headerView.layer.cornerRadius = 18;
    headerView.layer.masksToBounds = YES;
    
    [headerView stimDB_setImageWithURL:bindHeaderSrc placeholderImage:[UIImage imageWithData:[STIMKit defaultUserHeaderImage]]];
    [view addSubview:headerView];
    
    UILabel *bindNamelabel = [[UILabel alloc] initWithFrame:CGRectMake(headerView.right + 10, headerView.top, 100, 20)];
    [bindNamelabel setText:bindName];
    [bindNamelabel setTextColor:[UIColor qtalkTextBlackColor]];
    [view addSubview:bindNamelabel];
    UILabel *bindIdlabel = [[UILabel alloc] initWithFrame:CGRectMake(headerView.right + 10, bindNamelabel.bottom + 5, 200, 20)];
    [bindIdlabel setText:bindId];
    [bindIdlabel setTextColor:[UIColor qtalkTextLightColor]];
    [bindIdlabel setFont:[UIFont systemFontOfSize:14]];
    [view addSubview:bindIdlabel];
    view.backgroundColor = [UIColor qtalkChatBgColor];
    
    UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 10, 40, 30)];
    switchBtn.tag = section;
    [switchBtn setTitle:@"切换" forState:UIControlStateNormal];
    [switchBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [switchBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [switchBtn addTarget:self action:@selector(swicthAccount:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:switchBtn];
    STIMVerboseLog(@"%@账号下的总未读消息数 : %ld", bindId, (long)[[STIMKit sharedInstance] getNotReadCollectionMsgCountByBindId:bindId]);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.collectionAccountList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *accountDict = [self.collectionAccountList objectAtIndex:section];
    NSString *bindId = [accountDict objectForKey:@"BindId"];
    return [[self.collectionChatDict objectForKey:bindId] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *accountDict = [self.collectionAccountList objectAtIndex:indexPath.section];
    NSString *bindId = [accountDict objectForKey:@"BindId"];
    NSArray *bindSessionList = [self.collectionChatDict objectForKey:bindId];
    NSDictionary *infoDic = [bindSessionList objectAtIndex:indexPath.row];
    NSString *name = [infoDic objectForKey:@"Name"];
    QTalkNewSessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:name];
    if (!cell) {
        cell = [[QTalkNewSessionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:name];
    } else {

    }
    cell.bindId = bindId;
    cell.infoDic = infoDic;
    [cell refreshUI];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *accountDict = [self.collectionAccountList objectAtIndex:indexPath.section];
    NSString *bindId = [accountDict objectForKey:@"BindId"];
    NSArray *bindSessionList = [self.collectionChatDict objectForKey:bindId];
    NSDictionary *infoDic = [bindSessionList objectAtIndex:indexPath.row];
    QTalkViewController *chatVc = (QTalkViewController *)[self sessionViewDidSelectRowAtIndexPath:indexPath infoDic:infoDic BindId:bindId];
    if (chatVc) {
        [self.navigationController pushViewController:chatVc animated:YES];
    }
    STIMVerboseLog(@"infoDic : %@", infoDic);
}

- (QTalkViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath infoDic:(NSDictionary *)infoDic BindId:(NSString *)bindId{
    
//     Mark by DB
    NSString *jid = [infoDic objectForKey:@"XmppId"];
    NSString *name = [infoDic objectForKey:@"Name"];
    ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
    NSInteger notReadCount = [[STIMKit sharedInstance] getNotReadMsgCountByJid:jid WithRealJid:jid];
    if (jid) {
        switch (chatType) {
                
            case ChatType_GroupChat: {
                [[STIMKit sharedInstance] clearNotReadCollectionMsgByBindId:bindId WithUserId:jid];
                STIMGroupChatVC *chatGroupVC = [[STIMGroupChatVC alloc] init];
                [chatGroupVC setBindId:bindId];
                [chatGroupVC setChatId:jid];
                [chatGroupVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatGroupVC setNotReadCount:notReadCount];
                [chatGroupVC setReadedMsgTimeStamp:-1];
                if (chatGroupVC.needShowNewMsgTagCell) {
                    
                    chatGroupVC.readedMsgTimeStamp = [[STIMKit sharedInstance] getReadedTimeStampForUserId:chatGroupVC.chatId WithRealJid:chatGroupVC.chatId WithMsgDirection:STIMMessageDirection_Received withUnReadCount:notReadCount];
                }
                return chatGroupVC;
            }
                break;
            case ChatType_SingleChat: {
                [[STIMKit sharedInstance] clearNotReadCollectionMsgByBindId:bindId WithUserId:jid];
                
                STIMChatVC *chatSingleVC = [[STIMChatVC alloc] init];
                [chatSingleVC setBindId:bindId];
                [chatSingleVC setChatId:jid];
                [chatSingleVC setChatInfoDict:infoDic];
                [chatSingleVC setChatType:chatType];
                //备注
                NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
                [chatSingleVC setTitle:remarkName ? remarkName : name];
                [chatSingleVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatSingleVC setReadedMsgTimeStamp:-1];
                [chatSingleVC setNotReadCount:notReadCount];
                if (chatSingleVC.needShowNewMsgTagCell) {
                    
                    chatSingleVC.readedMsgTimeStamp = [[STIMKit sharedInstance] getReadedTimeStampForUserId:chatSingleVC.chatId WithRealJid:chatSingleVC.chatId WithMsgDirection:STIMMessageDirection_Received withUnReadCount:notReadCount];
                }
                return chatSingleVC;
            }
                break;
            default:
                break;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [QTalkNewSessionTableViewCell getCellHeight];
}

- (void)swicthAccount:(id)sender {
    UIButton *switchBtn = (UIButton *)sender;
    NSDictionary *bindAccountDict = [self.collectionAccountList objectAtIndex:switchBtn.tag];
    NSString *bindId = [bindAccountDict objectForKey:@"BindId"];
    NSArray *accounts = [[STIMKit sharedInstance] getLoginUsers];
    for (NSDictionary *accountDic in accounts) {
        NSString *userFullJid = [accountDic objectForKey:@"userFullJid"];
        if ([userFullJid isEqualToString:bindId]) {
           NSString *userId = [[userFullJid componentsSeparatedByString:@"@"] firstObject];
            NSString *pwd = [accountDic objectForKey:@"LoginToken"];
            NSDictionary *navDict = [accountDic objectForKey:@"NavDict"];
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
            [[STIMKit sharedInstance] clearLogginUser];
            [self reloginAccount];
        }
    }
}

- (void)reloginAccount {
    
    [STIMFastEntrance reloginAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

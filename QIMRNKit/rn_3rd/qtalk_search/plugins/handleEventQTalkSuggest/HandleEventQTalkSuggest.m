//
//  handleEventQTalkSuggest.m
//  STChatIphone
//
//  Created by wangyu.wang on 16/5/9.
//
//

#import "HandleEventQTalkSuggest.h"

@implementation HandleEventQTalkSuggest

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(handleEvent
                  :(nonnull NSNumber *)type
                  :(NSString *)uri
                  :(RCTResponseSenderBlock)success
                  :(RCTResponseSenderBlock)error) {
    STIMVerboseLog(@"handleEvent param: tyep: %@ key: %@", type, uri);
    
    NSString *handleEvent = @"handleEvent";
    NSLog(handleEvent);
    
    NSNumber *is_ok = @YES;
    NSString *errorMsg = @"";

    
    switch ([type intValue]) {
        case 0:
            // TODO 打开用户名片
            [self goUserCard:uri];
            break;
        case 1:
            // TODO 打开群组聊天
            [self goGroupChat:uri];
            break;
        case 2:
            // TODO 打开好友
            [self goFriends:uri];
            break;
        case 3:
            // TODO 打开群组列表
            [self goGroups:uri];
            break;
        case 4:
            // TODO 打开未读消息
            [self goUnreadMessages:uri];
            break;
        case 5:
            // TODO 打开公众号
            [self goPublicAccounts:uri];
            break;
        case 6:
            // TODO 打开webview
            [self goWebView:uri showNavBar:TRUE];
            break;
        case 7:
            // TODO 打开单人聊天
            [self goSingleChat:uri];
            break;
        case 8:
            // TODO 打开公众号名片
            [self goRobotCard:uri];
            break;
        case 9:
            // TODO 打开单人聊天聊天记录上下文
            [self goLookBackVCSingle: uri];
            break;
        case 10:
            // TODO 打开群组聊天聊天记录上下文
            [self goLookBackVCGroup: uri];
            break;
        case 11:
            //TODO 打开随记
            [self goQTalkNotesVC: uri];
            break;
        default:
            // TODO 未定义的处理方式
            is_ok = @NO;
            errorMsg = @"未注册的事件处理";
            break;
    }
    STIMVerboseLog(@"handleEvent param: tyep: %@", type);
    NSDictionary *resp = @{@"is_ok": is_ok, @"errorMsg": errorMsg};
    success(@[resp]);
}

RCT_EXPORT_METHOD(openWebPage
                  :(NSString *)uri
                  :(BOOL)showNavBar
                  :(RCTResponseSenderBlock)callback) {
    
    NSString *openWebPage = @"openWebPage";
    NSLog(openWebPage);
    
    NSNumber *is_ok = @YES;
    NSString *errorMsg = @"";
    
    // TODO 打开webview
    [self goWebView:uri showNavBar: showNavBar];
    
    NSDictionary *resp = @{@"is_ok": is_ok, @"errorMsg": errorMsg};
    callback(@[resp]);
}

-(void) goUserCard:(NSString*) uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goUserCard = @"goUserCard";
        NSLog(goUserCard);
        [STIMFastEntrance openUserCardVCByUserId:uri];
    });
}
-(void) goGroupChat:(NSString*) uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goGroupChat = @"goGroupChat";
        NSLog(goGroupChat);
        [STIMFastEntrance openGroupChatVCByGroupId:uri];
    });
}

-(void) goFriends:(NSString*) uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goFriends = @"goFriends";
        NSLog(goFriends);
        [STIMFastEntrance openUserFriendsVC];
    });
}
-(void) goGroups:(NSString*) uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goGroups = @"goGroups";
        NSLog(goGroups);
        [STIMFastEntrance openSTIMGroupListVC];
    });
}
-(void) goUnreadMessages:(NSString*) uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goUnreadMessages = @"goUnreadMessages";
        NSLog(goUnreadMessages);
        [STIMFastEntrance openNotReadMessageVC];
    });
}
-(void) goPublicAccounts:(NSString*) uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goPublicAccounts = @"goPublicAccounts";
        NSLog(goPublicAccounts);
        [STIMFastEntrance openSTIMPublicNumberVC];
    });
}

-(void) goWebView:(NSString*) uri
       showNavBar:(BOOL)showNavBar;{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goWebView = @"goWebView";
        NSLog(goWebView);
        [STIMFastEntrance openWebViewForUrl:uri showNavBar:showNavBar];
    });
}

-(void) goSingleChat:(NSString*) uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goSingleChat = @"goSingleChat";
        NSLog(goSingleChat);
        [STIMFastEntrance openSingleChatVCByUserId:uri];
    });
}

-(void) goRobotCard:(NSString *)uri {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goRobotCard = @"goRobotCard";
        NSLog(goRobotCard);
        [STIMFastEntrance openRobotCard:uri];
    });
}

-(void) goLookBackVCSingle:(NSString *)uri{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *goLookBackVCSingle = @"goLookBackVCSingle";
        NSLog(goLookBackVCSingle);
    });
}

-(void) goLookBackVCGroup:(NSString *)uri{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *goLookBackVCGroup = @"goLookBackVCGroup";
        NSLog(goLookBackVCGroup);
    });
}

- (void) goQTalkNotesVC:(NSString *)uri {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *goQTalkNotesVC = @"goQTalkNotesVC";
        NSLog(goQTalkNotesVC);
        [STIMFastEntrance openQTalkNotesVC];
    });
}

- (void)goTest:(NSString *)uri{
    NSString *goTest = @"goTest";
    NSLog(goTest);
}

@end

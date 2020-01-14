
//
//  QtalkPlugin.m
//  STIMUIKit
//
//  Created by 李海彬 on 11/13/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "QtalkPlugin.h"
#import "STIMFastEntrance.h"
#import "STIMNotificationKeys.h"
#import "STIMJSONSerializer.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "UIApplication+STIMApplication.h"


@implementation QtalkPlugin

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(browseBigImage:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[STIMFastEntrance sharedInstance] browseBigHeader:param];
}

RCT_EXPORT_METHOD(openDownLoad:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[STIMFastEntrance sharedInstance] openSTIMFilePreviewVCWithParam:param];
}

RCT_EXPORT_METHOD(openNativeWebView:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([STIMFastEntrance handleOpsasppSchema:param] == NO) {
            NSString *linkUrl = [param objectForKey:@"linkurl"];
            if (linkUrl.length > 0) {
                [STIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
            } else {
                NSString *linkUrl = [param objectForKey:@"url"];
                if (linkUrl.length > 0) {
                    [STIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
                }
            }
        } else {

        }
    });
}

RCT_EXPORT_METHOD(gotoWiki:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *wikiUrl = [[STIMKit sharedInstance] qimNav_WikiUrl];
        if (wikiUrl.length > 0) {
            [STIMFastEntrance openWebViewForUrl:wikiUrl showNavBar:YES];
        }
    });
}

RCT_EXPORT_METHOD(gotoNote:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [STIMFastEntrance openQTalkNotesVC];
    });
}

RCT_EXPORT_METHOD(getUserInfo:(RCTResponseSenderBlock)callback) {
    /*
    WritableNativeMap map = new WritableNativeMap();
    map.putString("userId", CurrentPreference.getInstance().getUserid());
    map.putString("clientIp", "192.168.0.1");
    map.putString("domain", QtalkNavicationService.getInstance().getXmppdomain());
    //            map.putString("token", CurrentPreference.getInstance().getToken());
    //            map.putString("q_auth", CurrentPreference.getInstance().getVerifyKey() == null ? "404" : CurrentPreference.getInstance().getVerifyKey());
    map.putString("ckey", getCKey());
    map.putString("httpHost", QtalkNavicationService.getInstance().getJavaUrl());
    map.putString("fileUrl", QtalkNavicationService.getInstance().getInnerFiltHttpHost());
    map.putString("qcAdminHost", QtalkNavicationService.getInstance().getQcadminHost());
    //        if (!("ejabhost1".equals(QtalkNavicationService.getInstance().getXmppdomain()))) {
    //            map.putInt("showOrganizational", 1);
    //        } else {
    //            map.putInt("showOrganizational", 0);
    //        }
    map.putBoolean("showServiceState", CurrentPreference.getInstance().isMerchants());
    map.putBoolean("isQtalk", CommonConfig.isQtalk);
    
    //            map.putDouble("timestamp", System.currentTimeMillis());
    callback.invoke(map);
    */
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:3];
    [map setObject:[[STIMKit sharedInstance] getLastJid] forKey:@"userId"];
    [map setObject:[[STIMKit sharedInstance] getDomain] forKey:@"domain"];
    [map setObject:@"192.168.0.1" forKey:@"clientIp"];
    
    [map setObject:[[STIMKit sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
    [map setObject:[[STIMKit sharedInstance] qimNav_HttpHost] forKey:@"httpHost"];
    [map setObject:[[STIMKit sharedInstance] qimNav_InnerFileHttpHost] forKey:@"fileUrl"];
    callback(@[map ? map : @{}]);
}

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

RCT_EXPORT_METHOD(getWorkWorldItem:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSDictionary *momentDic = [[STIMKit sharedInstance] getLastWorkMoment];
    NSLog(@"getWorkWorldItem : %@", momentDic);
    callback(@[momentDic ? momentDic : @{}]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[STIMKit sharedInstance] getRemoteLastWorkMoment];
    });
}

RCT_EXPORT_METHOD(getWorkWorldNotRead:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSInteger notReadMsgCount = [[STIMKit sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(STIMWorkFeedNotifyTypeComment), @(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)]];
    BOOL showNewPOST = NO;
    NSLog(@"getWorkWorldNotRead : %d", notReadMsgCount);
    NSDictionary *notReadMsgDic = @{@"notReadMsgCount":@(notReadMsgCount), @"showNewPost":@(showNewPOST)};
    callback(@[notReadMsgDic ? notReadMsgDic : @{}]);
}

//打开驼圈
RCT_EXPORT_METHOD(openWorkWorld:(NSDictionary *)param) {
    [[STIMFastEntrance sharedInstance] openWorkFeedViewController];
}

//打开笔记本
RCT_EXPORT_METHOD(openNoteBook:(NSDictionary *)param) {
    [STIMFastEntrance openQTalkNotesVC];
}

//打开文件助手
RCT_EXPORT_METHOD(openFileTransfer:(NSDictionary *)param) {
    NSString *xmppId = [NSString stringWithFormat:@"%@@%@", @"file-transfer", [[STIMKit sharedInstance] getDomain]];
    [STIMFastEntrance openSingleChatVCByUserId:xmppId];
}

//打开扫一扫
RCT_EXPORT_METHOD(openScan:(NSDictionary *)param) {
    [STIMFastEntrance openQRCodeVC];
}

//打开行程
RCT_EXPORT_METHOD(openTravelCalendar:(NSDictionary *)param) {
    [STIMFastEntrance openTravelCalendarVc];
}

//获取发现页应用列表
RCT_EXPORT_METHOD(getFoundInfo:(RCTResponseSenderBlock)callback) {
    NSString *foundListStr = [[STIMKit sharedInstance] getLocalFoundNavigation];
    NSArray *foundList = [[STIMJSONSerializer sharedInstance] deserializeObject:foundListStr error:nil];
    NSMutableArray *mutableGroupItems = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *mutableResult = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (NSDictionary *groupItemDic in foundList) {
        
        NSMutableDictionary *newGroupDic = [NSMutableDictionary dictionaryWithCapacity:2];
        
        NSInteger groupId = [[groupItemDic objectForKey:@"groupId"] integerValue];
        NSString *groupName = [groupItemDic objectForKey:@"groupName"];
        NSString *groupIcon = [groupItemDic objectForKey:@"groupIcon"];
        NSArray *groupItems = [groupItemDic objectForKey:@"members"];
        
        [newGroupDic setObject:@(groupId) forKey:@"groupId"];
        [newGroupDic setObject:groupName forKey:@"groupName"];
        [newGroupDic setObject:groupIcon forKey:@"groupIcon"];

        
        NSMutableArray *newGroupItems = [NSMutableArray arrayWithCapacity:3];
        if ([groupItems isKindOfClass:[NSArray class]]) {
            for (NSDictionary *childItemDic in groupItems) {
                NSInteger appType = [[childItemDic objectForKey:@"appType"] integerValue];
                NSString *bundle = [childItemDic objectForKey:@"bundle"];
                NSString *bundleUrls = [childItemDic objectForKey:@"bundleUrls"];
                NSString *entrance = [childItemDic objectForKey:@"entrance"];
                NSString *memberAction = [childItemDic objectForKey:@"memberAction"];
                NSString *memberIcon = [childItemDic objectForKey:@"memberIcon"];
                NSInteger memberId = [childItemDic objectForKey:@"memberId"];
                NSString *memberName = [childItemDic objectForKey:@"memberName"];
                NSString *module = [childItemDic objectForKey:@"module"];
                NSString *navTitle = [childItemDic objectForKey:@"navTitle"];
                NSString *properties = [childItemDic objectForKey:@"properties"];
                BOOL showNativeNav = [[childItemDic objectForKey:@"showNativeNav"] boolValue];
                
                NSMutableDictionary *newChildItemDic = [NSMutableDictionary dictionaryWithCapacity:3];
                [newChildItemDic setObject:[NSString stringWithFormat:@"%ld", appType] forKey:@"AppType"];
                [newChildItemDic setObject:bundle forKey:@"Bundle"];
                [newChildItemDic setObject:bundleUrls forKey:@"BundleUrls"];
                [newChildItemDic setObject:entrance forKey:@"Entrance"];
                [newChildItemDic setObject:memberAction forKey:@"memberAction"];
                [newChildItemDic setObject:memberIcon forKey:@"memberIcon"];
                [newChildItemDic setObject:@(memberId) forKey:@"memberId"];
                [newChildItemDic setObject:memberName forKey:@"memberName"];
                [newChildItemDic setObject:module forKey:@"Module"];
                [newChildItemDic setObject:navTitle forKey:@"navTitle"];
                [newChildItemDic setObject:properties forKey:@"appParams"];
                [newChildItemDic setObject:@(showNativeNav) forKey:@"showNativeNav"];
                
                [newGroupItems addObject:newChildItemDic];
            }
            [newGroupDic setObject:newGroupItems forKey:@"members"];
            [mutableGroupItems addObject:newGroupDic];
        }
        [mutableResult setObject:@(YES) forKey:@"isOk"];
        [mutableResult setObject:mutableGroupItems forKey:@"data"];
    }
    callback(@[mutableResult ? mutableResult : @{}]);

    NSLog(@"foundList : %@", foundListStr);
}

RCT_EXPORT_METHOD(getSearchInfo:(NSString *)searchUrl :(NSDictionary *)params :(NSDictionary *)cookie :(RCTResponseSenderBlock)callback1 :(RCTResponseSenderBlock)callback2) {
    NSLog(@"searchUrl : %@", searchUrl);
    NSLog(@"params : %@", params);
    NSLog(@"Cookie : %@", cookie);
    [[STIMKit sharedInstance] searchWithUrl:searchUrl withParams:params withSuccessCallBack:^(BOOL successed, NSString *responseJson) {
        NSLog(@"请求搜索结果 : %@", responseJson);
        NSMutableDictionary *resultMap = [NSMutableDictionary dictionaryWithCapacity:3];
        [resultMap setObject:@(successed) forKey:@"isOk"];
        [resultMap setObject:responseJson?responseJson:@"" forKey:@"responseJson"];
        callback2(@[resultMap ? resultMap : @{}]);
    } withFaildCallBack:^(BOOL successed, NSString *errmsg) {
        NSMutableDictionary *resultMap = [NSMutableDictionary dictionaryWithCapacity:3];
        [resultMap setObject:@(NO) forKey:@"isOk"];
        [resultMap setObject:@"" forKey:@"responseJson"];
        NSLog(@"请求搜索失败");
        callback2(@[resultMap ? resultMap : @{}]);
    }];
}

RCT_EXPORT_METHOD(openGroupChat:(NSDictionary *)params) {
    NSString *groupId = [params objectForKey:@"GroupId"];
    if (groupId.length > 0) {
        [STIMFastEntrance openGroupChatVCByGroupId:groupId];
    }
}

RCT_EXPORT_METHOD(openSignleChat:(NSDictionary *)params) {
    NSString *userId = [params objectForKey:@"UserId"];
    if (userId.length > 0) {
        [STIMFastEntrance openSingleChatVCByUserId:userId];
    }
}

RCT_EXPORT_METHOD(openUserCard:(NSDictionary *)params) {
    NSString *userId = [params objectForKey:@"UserId"];
    if (userId.length > 0) {
        [STIMFastEntrance openUserCardVCByUserId:userId];
    }
}

RCT_EXPORT_METHOD(showSearchHistoryResult:(NSDictionary *)params) {
    NSString *userJid = [params objectForKey:@"to"];
    NSString *from = [params objectForKey:@"from"];
    NSString *realfrom = [params objectForKey:@"realfrom"];

    NSString *realJid = [params objectForKey:@"realto"];
    long long time = [[params objectForKey:@"time"] longLongValue];
    NSInteger todoType = [[params objectForKey:@"todoType"] integerValue];
    ChatType chatType = ChatType_SingleChat;
    if (todoType == 16) {
        //群聊
        chatType = ChatType_GroupChat;
        [STIMFastEntrance openGroupChatVCByGroupId:userJid withFastTime:time withRemoteSearch:YES];
    } else {
        //单聊
        if([[[STIMKit sharedInstance] getLastJid] isEqualToString:from]){
//            userJid = userJid;
//            realJid = realto;
        }else{
            userJid = from;
            realJid = realfrom;
        }
        chatType="0";
        chatType = ChatType_SingleChat;
        [STIMFastEntrance openSingleChatVCByUserId:userJid withFastTime:time withRemoteSearch:YES];
    }
}

RCT_EXPORT_METHOD(exitSearchApp) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SEARCH_GO_BACK object:nil];
    });
}

#pragma mark - SearchKey History

//获取本地搜索Key历史
RCT_EXPORT_METHOD(getLocalSearchKeyHistory:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    
    NSInteger limit = [[param objectForKey:@"limit"] integerValue];
    NSInteger searchType = [[param objectForKey:@"searchType"] integerValue];
    NSArray *searchKeys = [[STIMKit sharedInstance] getLocalSearchKeyHistoryWithSearchType:searchType withLimit:limit];
    callback(@[@{@"ok" : @(YES), @"searchKeys" : searchKeys ? searchKeys : @[]}]);
}

//更新本地搜索Key历史
RCT_EXPORT_METHOD(updateLocalSearchKeyHistory:(NSDictionary *)param) {
    [[STIMKit sharedInstance] updateLocalSearchKeyHistory:param];
}

//清空本地搜索历史Key
RCT_EXPORT_METHOD(clearLocalSearchKeyHistory:(NSInteger)searchType) {
    [[STIMKit sharedInstance] deleteSearchKeyHistory];
}

@end

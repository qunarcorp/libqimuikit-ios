
//
//  QtalkPlugin.m
//  QIMUIKit
//
//  Created by 李露 on 11/13/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QtalkPlugin.h"
#import "QIMFastEntrance.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>


@implementation QtalkPlugin

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(browseBigImage:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[QIMFastEntrance sharedInstance] browseBigHeader:param];
}

RCT_EXPORT_METHOD(openDownLoad:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[QIMFastEntrance sharedInstance] openQIMFilePreviewVCWithParam:param];
}

RCT_EXPORT_METHOD(openNativeWebView:(NSDictionary *)param) {
    if ([QIMFastEntrance handleOpsasppSchema:param] == NO) {
        NSString *linkUrl = [param objectForKey:@"linkurl"];
        if (linkUrl.length > 0) {
            [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
        }
    } else {

    }
}

RCT_EXPORT_METHOD(getWorkWorldItem:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSDictionary *momentDic = [[QIMKit sharedInstance] getLastWorkMoment];
    NSLog(@"getWorkWorldItem : %@", momentDic);
    callback(@[momentDic ? momentDic : @{}]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[QIMKit sharedInstance] getRemoteLastWorkMoment];
    });
}

RCT_EXPORT_METHOD(getWorkWorldNotRead:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSInteger notReadMsgCount = [[QIMKit sharedInstance] getWorkNoticeMessagesCount];
    BOOL showNewPOST = NO;
    NSLog(@"getWorkWorldNotRead : %d", notReadMsgCount);
    NSDictionary *notReadMsgDic = @{@"notReadMsgCount":@(notReadMsgCount), @"showNewPost":@(showNewPOST)};
    callback(@[notReadMsgDic ? notReadMsgDic : @{}]);
}

RCT_EXPORT_METHOD(openWorkWorld:(NSDictionary *)param) {
    [[QIMFastEntrance sharedInstance] openWorkFeedViewController];
}

//打开笔记本
RCT_EXPORT_METHOD(openNoteBook:(NSDictionary *)param) {
    [QIMFastEntrance openQTalkNotesVC];
}

//打开文件助手
RCT_EXPORT_METHOD(openFileTransfer:(NSDictionary *)param) {
    [[QIMFastEntrance sharedInstance] openFileTransMiddleVC];
}

//打开行程
RCT_EXPORT_METHOD(openScan:(NSDictionary *)param) {
    [QIMFastEntrance openQRCodeVC];
}

@end

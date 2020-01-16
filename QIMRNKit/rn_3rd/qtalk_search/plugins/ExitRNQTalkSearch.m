//
//  ExitRNQTalkSearch.m
//  STChatIphone
//
//  Created by wangyu.wang on 2016/11/28.
//
//

#import "ExitRNQTalkSearch.h"
#import "QTalkSearchViewManager.h"
#import "QTalkSearchRNView.h"

@implementation ExitRNQTalkSearch

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(exitApp:(RCTResponseSenderBlock)success:(RCTResponseSenderBlock)error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *exitApp = @"exitApp";
        NSLog(exitApp);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SEARCH_GO_BACK object:nil];
    });
}

@end

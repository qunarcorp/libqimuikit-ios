//
// Created by lilu on 2019/10/30.
//

#import <QIMCommon/QIMKit.h>
#import "QIMKitPublicHeader.h"
#import "QIMRedPackManager.h"
#import "QIMRedPackOpenView.h"
#import "UIApplication+QIMApplication.h"

@interface QIMRedPackManager ()

@end

@implementation QIMRedPackManager {

}

+ (instancetype)sharedInstance {
    static QIMRedPackManager *_redPackManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       _redPackManager = [[QIMRedPackManager alloc] init];
    });
    return _redPackManager;
}

- (void)showRedPackWithChatId:(NSString *)chatId withRedPackFromId:(NSString *)userId withRedId:(NSString *)redId withISRoom:(BOOL)isRoom withRedPackInfoDic:(NSDictionary *)redPackInfoDic withCallManagerBack:(QIMKitOpenRedPackCallManagerBack)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        __block QIMRedPackOpenView *openView = [[QIMRedPackOpenView alloc] initWithChatId:chatId withUserId:userId withRedId:redId withISRoom:isRoom withRedPackInfoDic:redPackInfoDic];
        [openView setOpenCallBack:^(BOOL successed) {
            if (successed == YES) {
                NSLog(@"打开红包成功");
            } else {
                NSLog(@"打开红包失败");
            }
            if (callback) {
                callback(successed);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [openView removeFromSuperview];
            });
        }];
        [[[[UIApplication sharedApplication] visibleViewController] view] addSubview:openView];
    });
}

@end

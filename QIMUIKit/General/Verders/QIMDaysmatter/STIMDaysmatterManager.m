//
//  STIMDaysmatterManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/19.
//

#import "STIMDaysmatterManager.h"
#import "STIMJSONSerializer.h"

@interface STIMDaysmatterManager ()

@end

static STIMDaysmatterManager *_daysmatter = nil;
@implementation STIMDaysmatterManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _daysmatter = [[STIMDaysmatterManager alloc] init];
    });
    return _daysmatter;
}

- (void)getDaysmatterFromRemote {
    NSString *destUrl = @"http://beta.daysmatter.com/app/idays/on_this_day?lang=zh-hans&is_widget=1&app_ver=61&os_lang=";
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request startSynchronous];
    NSError *error = request.error;
    if ([request responseStatusCode] == 200 && !error) {
        NSDictionary *resultDic = [[STIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        STIMVerboseLog(@"请求回来的DaysMatter数据为： %@", resultDic);
    }
}

@end

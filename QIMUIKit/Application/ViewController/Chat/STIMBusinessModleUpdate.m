//
//  STIMBusinessModleUpdate.m
//  qunarChatIphone
//
//  Created by admin on 16/5/20.
//
//

#import "STIMBusinessModleUpdate.h"
#import "NSBundle+STIMLibrary.h"
#import "STIMJSONSerializer.h"
#import "STIMHTTPRequest.h"
#import "STIMHTTPClient.h"

@implementation STIMBusinessModleUpdate

+ (void)updateMicroTourModel{
    NSString *oldVersion = [[STIMKit sharedInstance] userObjectForKey:@"MicroTourModelVersion"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://touch.dujia.qunar.com/tour/qd/gnt.json?v=%@&p=ios&u=%@&tv=%@",[[STIMKit sharedInstance] AppBuildVersion],[[STIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],oldVersion]];
    
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:2];
    [requestHeader setObject:@"application/json; encoding=utf-8" forKey:@"Content-Type"];
    [requestHeader setObject:@"application/json" forKey:@"Accept"];
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:url];
    [request setTimeoutInterval:2];
    [request setHTTPRequestHeaders:requestHeader];
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *resultDic = [[STIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                NSString *version = [dataDic objectForKey:@"version"];
                NSString *template = [dataDic objectForKey:@"template"];
                if ( version && template.length > 0) {
                    [[STIMKit sharedInstance] setUserObject:version forKey:@"MicroTourModelVersion"];
                    NSString *modelFilePath = [[NSBundle mainBundle] pathForResource:@"STIMMicroTourRoot" ofType:@"html"];
                    [[template dataUsingEncoding:NSUTF8StringEncoding] writeToFile:modelFilePath atomically:YES];
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

@end

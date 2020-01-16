//
//  ModuleEventHandler.m
//  STChatIphone
//
//

#import "STIMCommonUIFramework.h"
#import "ModuleEventHandler.h"

@implementation ModuleEventHandler

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(handModuleEvent:(NSString *)module_name
                  :(NSDictionary *)initParam
                  :(RCTResponseSenderBlock)success
                  :(RCTResponseSenderBlock)error) {
    STIMVerboseLog(@"handModuleEvent");//TODO Startalk
    NSDictionary *responseData = @{};
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_QtalkSuggest_handle_opsapp_event object:nil userInfo:@{@"module":module_name, @"initParam":initParam}];
    });
    
    success(@[responseData]);
}

@end

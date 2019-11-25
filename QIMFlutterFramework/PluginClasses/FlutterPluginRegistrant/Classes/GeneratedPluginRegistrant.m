//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
    #import <fluttertoast/FluttertoastPlugin.h>
#endif

#if __has_include(<path_provider/PathProviderPlugin.h>)
    #import <path_provider/PathProviderPlugin.h>
#endif

#if __has_include(<shared_preferences/SharedPreferencesPlugin.h>)
    #import <shared_preferences/SharedPreferencesPlugin.h>
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    
#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
    [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
#endif
  
#if __has_include(<path_provider/PathProviderPlugin.h>)

  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
#endif
    
#if __has_include(<shared_preferences/SharedPreferencesPlugin.h>)

  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
#endif
}

@end

//
//  BSDiff.h
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/8/31.
//
//

#ifndef BSDiff_h
#define BSDiff_h

#import <Foundation/Foundation.h>

@interface BSDiff : NSObject

+ (BOOL)bsdiffPatch:(NSString *)path
             origin:(NSString *)origin
      toDestination:(NSString *)destination;
@end


#endif /* BSDiff_h */

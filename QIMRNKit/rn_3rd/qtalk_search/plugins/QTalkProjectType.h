//
//  QTalkProjectType.h
//  STChatIphone
//
//  Created by wangyu.wang on 16/9/12.
//
//

#ifndef QTalkProjectType_h
#define QTalkProjectType_h

#import "STIMCommonUIFramework.h"
#import <React/RCTBridgeModule.h>

@interface QTalkProjectType : NSObject <RCTBridgeModule>

@property (nonatomic, strong) NSString *remoteKey;
@property (nonatomic, strong) NSString *testKey;

@end


#endif /* QTalkProjectType_h */

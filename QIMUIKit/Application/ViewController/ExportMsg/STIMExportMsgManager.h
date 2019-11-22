//
//  STIMExportMsgManager.h
//  qunarChatIphone
//
//  Created by chenjie on 2016/08/26.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMExportMsgManager : NSObject

+ (NSString *)parseForJsonStrFromMsgList:(NSArray *)msgList withTitle:(NSString *)title;

+ (NSString *)exportMsgList:(NSArray *)msgList withTitle:(NSString *)title;

@end

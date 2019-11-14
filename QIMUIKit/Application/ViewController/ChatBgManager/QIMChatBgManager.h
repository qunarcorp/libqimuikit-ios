//
//  QIMChatBgManager.h
//  QIMUIKit
//
//  Created by admin on 2019/4/25.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMChatBgManager : NSObject

+ (instancetype)sharedInstance;

- (NSString *)getChatBgSourcePath:(NSString *)fileName;

- (void)deleteChatBgImageWithFileName:(NSString *)fileName;

- (void)saveChatBgImageWithFileName:(NSString *)fileName imageData:(NSData *)data;

- (void)getChatBgById:(NSString *)userId ByName:(NSString *)name WithReset:(BOOL)reset Complete:(void(^)(UIImage *bgImage)) complete;

@end

NS_ASSUME_NONNULL_END

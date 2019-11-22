//
//  STIMMessageTextAttachment.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/4.
//

#import "STIMCommonUIFramework.h"

@interface STIMMessageTextAttachment : NSObject

+ (instancetype)sharedInstance;

- (NSString *)getStringFromAttributedString:(NSAttributedString *)attributedString WithOutAtInfo:(NSMutableArray **)outAtInfo;

@end

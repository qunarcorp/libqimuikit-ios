//
//  STIMMessageParser.h
//  STChatIphone
//
//  Created by haibin.li on 16/7/6.
//
//

#import "STIMCommonUIFramework.h"

@class STIMMessageModel;
@class STIMAttributedLabel;
@class STIMTextContainer;

@interface STIMMessageParser : NSObject

+ (instancetype)sharedInstance;

+ (STIMAttributedLabel *)attributedLabelForMessage:(STIMMessageModel *)message;

+ (STIMTextContainer *)textContainerForMessage:(STIMMessageModel *)message;

+ (STIMTextContainer *)textContainerForMessage:(STIMMessageModel *)message fromCache:(BOOL)fromCache;

+ (STIMTextContainer *)textContainerForMessageCtnt:(NSString *)ctnt withId:(NSString *)signId direction:(STIMMessageDirection)direction;

+ (NSArray *)storagesFromMessage:(STIMMessageModel *)message;

+ (float)getCellWidth;

+ (STIMMessageModel *)reductionMessageForMessage:(STIMMessageModel *)message;

            

- (void)parseForXMLString:(NSString *)xmlStr complete:(void (^)(NSDictionary *info))complete;

@end

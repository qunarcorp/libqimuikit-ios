//
//  QIMMessageParser.h
//  qunarChatIphone
//
//  Created by chenjie on 16/7/6.
//
//

#import "QIMCommonUIFramework.h"

@class QIMMessageModel;
@class QIMAttributedLabel;
@class QIMTextContainer;

@interface QIMMessageParser : NSObject

+ (instancetype)sharedInstance;

+ (QIMAttributedLabel *)attributedLabelForMessage:(QIMMessageModel *)message;

+ (QIMTextContainer *)textContainerForMessage:(QIMMessageModel *)message;

+ (QIMTextContainer *)textContainerForMessage:(QIMMessageModel *)message fromCache:(BOOL)fromCache;

+ (QIMTextContainer *)textContainerForMessageCtnt:(NSString *)ctnt withId:(NSString *)signId direction:(QIMMessageDirection)direction;

+ (NSArray *)storagesFromMessage:(QIMMessageModel *)message;

+ (float)getCellWidth;

+ (QIMMessageModel *)reductionMessageForMessage:(QIMMessageModel *)message;

            

- (void)parseForXMLString:(NSString *)xmlStr complete:(void (^)(NSDictionary *info))complete;

@end

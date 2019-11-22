//
//  STIMWorkMomentParser.h
//  STIMUIKit
//
//  Created by lilu on 2019/2/25.
//  Copyright © 2019 STIM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class STIMMessageModel;
@class STIMAttributedLabel;
@class STIMTextContainer;
@interface STIMWorkMomentParser : NSObject

+ (instancetype) sharedInstance;
+ (STIMTextContainer *)textContainerForMessage:(STIMMessageModel *)message fromCache:(BOOL)fromCache withCellWidth:(CGFloat)cellWidth withFontSize:(CGFloat)fontSize withFontColor:(UIColor *)textColor withNumberOfLines:(NSInteger)numberOfLines;

+ (NSArray *)storagesFromMessage:(STIMMessageModel *)message;
            
- (void)parseForXMLString:(NSString *)xmlStr complete:(void (^)(NSDictionary * info))complete;

@end

NS_ASSUME_NONNULL_END

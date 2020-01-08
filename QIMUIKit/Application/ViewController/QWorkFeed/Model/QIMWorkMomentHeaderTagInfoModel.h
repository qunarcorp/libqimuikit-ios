//
//  QIMWorkMomentHeaderTagInfoModel.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentHeaderTagInfoModel : NSObject

@property (nonatomic, copy) NSNumber * activeUserTotal;
@property (nonatomic, copy) NSString * descriptionString;
@property (nonatomic, copy) NSNumber * postTotal;
@property (nonatomic, copy) NSNumber * tagId;
@property (nonatomic, copy) NSString * tagTitle;
@property (nonatomic, copy) NSString * topicBGColor;
@property (nonatomic, copy) NSString * topicColor;
@property (nonatomic, strong) NSArray * users;
@end

NS_ASSUME_NONNULL_END

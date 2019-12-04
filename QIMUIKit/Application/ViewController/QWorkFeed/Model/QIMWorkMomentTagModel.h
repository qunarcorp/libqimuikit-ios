//
//  QIMWorkMomentTagModel.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentTagModel : NSObject
@property (nonatomic, copy) NSNumber *tagId;
@property (nonatomic, copy) NSString *tagTitle;
@property (nonatomic, copy) NSString *tagColor;
@property (nonatomic, assign) BOOL selected;
@end

NS_ASSUME_NONNULL_END

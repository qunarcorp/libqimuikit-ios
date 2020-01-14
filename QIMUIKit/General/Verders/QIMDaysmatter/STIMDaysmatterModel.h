//
//  STIMDaysmatterModel.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/3/19.
//

#import "STIMCommonUIFramework.h"

typedef NS_ENUM(NSUInteger, QTDaysmatterType) {
    QTDaysmatterTypeFestival = 0,
    QTDaysmatterTypeBirth,
    QTDaysmatterTypeYear,
};

@interface STIMDaysmatterModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;

@end

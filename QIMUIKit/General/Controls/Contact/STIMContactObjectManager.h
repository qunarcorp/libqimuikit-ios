#import "STIMCommonUIFramework.h"

@import AddressBook;

@class STIMContactObject;

NS_ASSUME_NONNULL_BEGIN

@interface STIMContactObjectManager : NSObject

/**
 *  根据ABRecordRef数据获得YContantObject对象
 *
 *  @param recordRef ABRecordRef对象
 *
 *  @return YContantObject对象
 */
+ (STIMContactObject *)contantObject:(ABRecordRef)recordRef;

@end

NS_ASSUME_NONNULL_END

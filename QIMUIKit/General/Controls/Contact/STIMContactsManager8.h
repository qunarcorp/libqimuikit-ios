#import "STIMCommonUIFramework.h"

@class STIMContactObject;

NS_ASSUME_NONNULL_BEGIN

/**
 *  请求通讯录所有联系人的Manager
 */
@interface STIMContactsManager8 : NSObject

/**
 *  YAddressBookManager单例
 */
+(instancetype)sharedInstance;

/**
 *  请求所有的联系人,按照添加人的时间顺序
 *
 *  @param completeBlock 完成的回调
 */
- (void)requestContactsComplete:(void (^)(NSArray <STIMContactObject *> *))completeBlock;

@end

/**
 *  手动进行联系人数据添加类目
 */
@interface STIMContactsManager8 (YCodingHandle)

- (void)codingAddPersonToAddressBook;

@end

NS_ASSUME_NONNULL_END

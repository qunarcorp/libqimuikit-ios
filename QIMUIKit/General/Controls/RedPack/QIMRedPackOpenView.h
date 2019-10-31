//
// Created by lilu on 2019/10/30.
//

#import <UIKit/UIKit.h>

typedef void(^QIMKitOpenRedPackBlock)(BOOL successed);

@interface QIMRedPackOpenView : UIView

@property (nonatomic, copy) QIMKitOpenRedPackBlock openCallBack;

- (instancetype)initWithUserId:(NSString *)userId withRedId:(NSString *)redId withISRoom:(BOOL)isRoom withRedPackInfoDic:(NSDictionary *)redPackInfoDic;

@end
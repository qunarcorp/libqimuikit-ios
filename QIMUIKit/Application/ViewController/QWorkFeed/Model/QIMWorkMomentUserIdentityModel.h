//
//  QIMWorkMomentUserIdentityModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentUserIdentityModel : NSObject

@property (nonatomic, assign) BOOL isAnonymous; //是否匿名发布

@property (nonatomic, assign) NSInteger anonymousId;  //匿名Id

@property (nonatomic, copy) NSString *anonymousName;   //匿名名称

@property (nonatomic, copy) NSString *anonymousPhoto;   //匿名头像

@property (nonatomic, assign) BOOL mockAnonymous;       //Mock匿名

@property (nonatomic, assign) BOOL replaceable;         //匿名头像换一换

@end

@interface QIMWorkMomentUserIdentityManager : NSObject

+ (instancetype)sharedInstance;

+ (instancetype)sharedInstanceWithPOSTUUID:(NSString *)postuuid;

@property (nonatomic, strong) QIMWorkMomentUserIdentityModel *userIdentityModel; //用户身份Model

//@property (nonatomic, assign) BOOL isAnonymous;         //是否匿名发布
//
//@property (nonatomic, assign) NSInteger anonymousId;      //匿名Id
//
//@property (nonatomic, copy) NSString *anonymousName;    //匿名名称
//
//@property (nonatomic, copy) NSString *anonymousPhoto;   //匿名头像
//
//@property (nonatomic, assign) BOOL replaceable;         //匿名头像换一换

@end

NS_ASSUME_NONNULL_END

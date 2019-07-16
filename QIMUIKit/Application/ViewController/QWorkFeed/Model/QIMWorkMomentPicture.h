//
//  QIMWorkMomentPicture.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentPicture : NSObject

//图片地址
@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, assign) long long addTime;

@property (nonatomic, assign) NSInteger imageWidth;

@property (nonatomic, assign) NSInteger imageHeight;

@end

NS_ASSUME_NONNULL_END

//
//  STIMWorkMomentPicture.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/8.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkMomentPicture : NSObject

//图片地址
@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, assign) long long addTime;

@property (nonatomic, assign) NSInteger imageWidth;

@property (nonatomic, assign) NSInteger imageHeight;

@end

NS_ASSUME_NONNULL_END
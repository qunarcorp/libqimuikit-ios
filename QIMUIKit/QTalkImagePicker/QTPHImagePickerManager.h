//
//  QTPHImagePickerManager.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QTPHImagePickerManager : NSObject

+ (instancetype)sharedInstance;

/**
 最大选择数
 */
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;

/**
 是否支持选择视频
 */
@property (nonatomic, assign) BOOL notAllowSelectVideo;

/**
 是否支持混合选择
 */
@property (nonatomic, assign) BOOL mixedSelection;

/**
 是否支持继续选择视频
 */
@property (nonatomic, assign) BOOL canContinueSelectionVideo;

/**
 是否为驼圈相册选择
 */
@property (nonatomic, assign) BOOL workFeedImagePicker;

@end

NS_ASSUME_NONNULL_END

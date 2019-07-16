//
//  QIMImageRequestOperation.h
//  QIMImagePickerControllerFramework
//
//  Created by 谭真 on 2018/12/20.
//  Copyright © 2018 谭真. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMImageRequestOperation : NSOperation

typedef void(^QIMImageRequestCompletedBlock)(UIImage *photo, NSDictionary *info, BOOL isDegraded);
typedef void(^QIMImageRequestProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@property (nonatomic, copy, nullable) QIMImageRequestCompletedBlock completedBlock;
@property (nonatomic, copy, nullable) QIMImageRequestProgressBlock progressBlock;
@property (nonatomic, strong, nullable) PHAsset *asset;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

- (instancetype)initWithAsset:(PHAsset *)asset completion:(QIMImageRequestCompletedBlock)completionBlock progressHandler:(QIMImageRequestProgressBlock)progressHandler;
- (void)done;
@end

NS_ASSUME_NONNULL_END

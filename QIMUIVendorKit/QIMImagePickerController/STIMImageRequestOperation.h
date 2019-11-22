//
//  STIMImageRequestOperation.h
//  STIMImagePickerControllerFramework
//
//  Created by 谭真 on 2018/12/20.
//  Copyright © 2018 谭真. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface STIMImageRequestOperation : NSOperation

typedef void(^STIMImageRequestCompletedBlock)(UIImage *photo, NSDictionary *info, BOOL isDegraded);
typedef void(^STIMImageRequestProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@property (nonatomic, copy, nullable) STIMImageRequestCompletedBlock completedBlock;
@property (nonatomic, copy, nullable) STIMImageRequestProgressBlock progressBlock;
@property (nonatomic, strong, nullable) PHAsset *asset;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

- (instancetype)initWithAsset:(PHAsset *)asset completion:(STIMImageRequestCompletedBlock)completionBlock progressHandler:(STIMImageRequestProgressBlock)progressHandler;
- (void)done;
@end

NS_ASSUME_NONNULL_END

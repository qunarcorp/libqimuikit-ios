//
//  STIMVideoModel.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/8/9.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMVideoModel : NSObject

@property (nonatomic, copy) NSString *Duration;
@property (nonatomic, copy) NSString *FileName;
@property (nonatomic, copy) NSString *FileSize;
@property (nonatomic, copy) NSString *FileUrl;
@property (nonatomic, copy) NSString *Height;
@property (nonatomic, copy) NSString *ThumbName;
@property (nonatomic, copy) NSString *ThumbUrl;
@property (nonatomic, copy) NSString *Width;
@property (nonatomic, assign) BOOL newVideo;
@property (nonatomic, copy) NSString *LocalVideoOutPath;
@property (nonatomic, strong) UIImage *LocalThubmImage;

@end

NS_ASSUME_NONNULL_END

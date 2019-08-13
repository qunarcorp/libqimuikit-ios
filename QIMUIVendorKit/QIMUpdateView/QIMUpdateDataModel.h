//
//  QIMUpdateDataModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMUpdateDataModel : NSObject

@property (nonatomic, assign) NSInteger fileSize;   //文件大小

@property (nonatomic, copy) NSString *linkUrl;      //下载地址

@property (nonatomic, assign) BOOL istesting;       //是否为灰度发布

@property (nonatomic, assign) BOOL isUpdated;       //是否需要更新 true - 需要更新 false - 不需要更新

@property (nonatomic, assign) BOOL forceUpdate;     //是否强制更新

@property (nonatomic, copy) NSString *message;      //更新文案

@property (nonatomic, assign) NSInteger version;    //最新版本（若需要更新，则为最新客户端版本， 若不需要更新，则返回请求参数中的版本）

@property (nonatomic, copy) NSString *platform;     //所属平台，android/ios

@property (nonatomic, copy) NSString *md5;          //安装文件的md5

@end

NS_ASSUME_NONNULL_END

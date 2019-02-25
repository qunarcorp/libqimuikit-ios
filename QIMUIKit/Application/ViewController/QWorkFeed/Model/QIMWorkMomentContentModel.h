//
//  QIMWorkMomentContentModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMWorkMomentPicture.h"

typedef enum : NSUInteger {
    QIMWorkMomentContentTypeText,   //文本
    QIMWorkMomentContentTypeVideo,  //视频
    QIMWorkMomentContentTypeCommonTrdInfo, //666
} QIMWorkMomentContentType;

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentContentModel : NSObject

@property (nonatomic, copy) NSString *content;  //Content

@property (nonatomic, copy) NSString *exContent;  //NewContent

@property (nonatomic, assign) QIMWorkMomentContentType type;   //Type

@property (nonatomic, strong) NSArray <QIMWorkMomentPicture *> *imgList;

@end

NS_ASSUME_NONNULL_END

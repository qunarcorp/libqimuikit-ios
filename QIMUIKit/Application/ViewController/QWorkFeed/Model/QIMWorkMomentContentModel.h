//
//  QIMWorkMomentContentModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMWorkMomentPicture.h"
#import "QIMWorkMomentContentLinkModel.h"
#import "QIMVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentContentModel : NSObject

@property (nonatomic, copy) NSString *content;  //Content

@property (nonatomic, copy) NSString *exContent;  //NewContent

@property (nonatomic, assign) QIMWorkFeedContentType type;   //Type

@property (nonatomic, strong) NSArray <QIMWorkMomentPicture *> *imgList;

@property (nonatomic, strong) QIMVideoModel *videoContent;

@property (nonatomic, strong) QIMWorkMomentContentLinkModel *linkContent;

@end

NS_ASSUME_NONNULL_END

//
//  STIMWorkMomentContentModel.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMWorkMomentPicture.h"
#import "STIMWorkMomentContentLinkModel.h"
#import "STIMVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkMomentContentModel : NSObject

@property (nonatomic, copy) NSString *content;  //Content

@property (nonatomic, copy) NSString *exContent;  //NewContent

@property (nonatomic, assign) STIMWorkFeedContentType type;   //Type

@property (nonatomic, strong) NSArray <STIMWorkMomentPicture *> *imgList;

@property (nonatomic, strong) STIMVideoModel *videoContent;

@property (nonatomic, strong) STIMWorkMomentContentLinkModel *linkContent;

@end

NS_ASSUME_NONNULL_END

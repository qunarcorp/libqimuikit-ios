//
//  STIMWorkMomentPushViewController.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/2.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkMomentPushViewController : QTalkViewController

@property (nonatomic, assign) BOOL shareWorkMoment;     //分享驼圈，不能选择本地图片

@property (nonatomic, copy) NSMutableArray *selectPhoto;   //本地分享图片

@property (nonatomic, strong) NSDictionary *shareLinkUrlDic; //分享链接

@property (nonatomic, strong) NSDictionary *shareVideoDic; //分享视频

@end

NS_ASSUME_NONNULL_END

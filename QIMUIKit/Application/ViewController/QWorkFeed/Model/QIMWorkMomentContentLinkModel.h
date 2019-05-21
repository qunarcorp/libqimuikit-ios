//
//  QIMWorkMomentContentLinkModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/5/19.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentContentLinkModel : NSObject
/*
"auth": false,
"desc": "点击查看全文",
"img": "http://www.baidu.com/favicon.ico",
"linkurl": "https://m.baidu.com/?from\u003d844b\u0026vit\u003dfps",
"showas667": false,
"showbar": true,
"title": "百度一下"
*/
@property (nonatomic, assign) BOOL auth;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *linkurl;
@property (nonatomic, assign) BOOL showas667;
@property (nonatomic, assign) BOOL showbar;
@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END

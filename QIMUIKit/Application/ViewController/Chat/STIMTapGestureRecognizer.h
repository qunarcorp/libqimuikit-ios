//
//  STIMTapGestureRecognizer.h
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/3/27.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@interface STIMTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic, retain)NSString *imageLink;
@property (nonatomic, retain)NSDictionary *userInfo;
@property (nonatomic, assign)CGRect imageRect;
@property (nonatomic, retain)UIImage *image;
@property (nonatomic, assign)NSInteger currentImageNum;
@end

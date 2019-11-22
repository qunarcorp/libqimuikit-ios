//
//  STIMSingleChatImageTools.h
//  DangDiRen
//
//  Created by 平 薛 on 14-4-23.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@interface STIMSingleChatImageTools : NSObject

+ (STIMSingleChatImageTools *)sharedInstance;

- (UIImage *)getSentBg;
- (UIImage *)getReceivedBg;
- (UIImage *)getImageDownloadFaildWithDirect:(int)direct;
- (UIImage *)getImageDownloading;

@end

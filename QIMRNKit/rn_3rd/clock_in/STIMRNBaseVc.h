//
//  STIMRNBaseVc.h
//  QIMRNKit
//
//  Created by 李海彬 on 2018/8/23.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import <React/RCTBridge.h>
#import "STIMMWPhotoBrowser.h"

@interface STIMRNBaseVc : UIViewController

@property (nonatomic, strong) NSString *rnName;
@property (nonatomic, assign) BOOL hiddenNav;
@property (nonatomic, strong) RCTBridge *bridge;

@end

@interface STIMRNBaseVc (PhotoBrowser) <STIMMWPhotoBrowserDelegate>

- (void)browseBigHeader:(NSNotification *)notify;

@end

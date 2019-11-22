//
//  STIMMWQRCodeActivity.h
//  STIMUIKit
//
//  Created by 李露 on 2018/6/27.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMWPhotoBrowser.h"

@interface STIMMWQRCodeActivity : NSObject

@property (nonatomic, weak) STIMMWPhotoBrowser *fromPhotoBrowser;

+ (instancetype)sharedInstance;

- (BOOL)canPerformQRCodeWithImage:(UIImage *)image;

- (void)performActivity;

@end

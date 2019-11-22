//
//  STIMUIImagePickerBrowserVC.h
//  DangDiRen
//
//  Created by 平 薛 on 14-4-14.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@protocol STIMUIImagePickerBrowserVCDelegate;

@interface STIMUIImagePickerBrowserVC : QTalkViewController

@property (nonatomic, retain) UIImage *sourceImage;
@property (nonatomic, assign) id<STIMUIImagePickerBrowserVCDelegate> delegate;

@end

@protocol STIMUIImagePickerBrowserVCDelegate <NSObject>
@required
- (void)imagePickerBrowserDidCancel:(STIMUIImagePickerBrowserVC *)pickerBrowser;
- (void)imagePickerBrowserDidFinish:(STIMUIImagePickerBrowserVC *)pickerBrowser;
@end

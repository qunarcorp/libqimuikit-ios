//
//  STIMMWPhotoSectionBrowserCollectionView.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2018/12/12.
//  Copyright © 2018 STIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STIMMWPhotoSectionBrowserVC : UIViewController

@property (nonatomic, copy) NSString *xmppId;

@property (nonatomic, copy) NSString *realJid;

@property (nonatomic, assign) NSInteger chatType;

@end

NS_ASSUME_NONNULL_END

//
//  STIMMWPhotoSectionBrowserCell.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2018/12/12.
//  Copyright © 2018 STIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STIMMWPhoto.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    STIMMWTypePhoto,
    STIMMWTypeGif,
    STIMMWTypeVideo,
} STIMMWType;

@class STIMMWPhotoSectionBrowserCell;

@protocol STIMMWPhotoSectionBrowserChooseDelegate <NSObject>

- (void)selectedSTIMMWPhotoSectionBrowserChoose:(STIMMWPhoto *)photo;

- (void)deSelectedSTIMMWPhotoSectionBrowserChoose:(STIMMWPhoto *)photo;

@end

@interface STIMMWPhotoSectionBrowserCell : UICollectionViewCell

@property (nonatomic, strong) NSURL *thumbUrl;

@property (nonatomic, assign) BOOL reloaded;

@property (nonatomic, assign) STIMMWType type;

@property (nonatomic, assign) NSString *videoDuration;

@property (nonatomic, assign) BOOL shouldChooseFlag;

@property (nonatomic, strong) STIMMWPhoto *photo;

@property (nonatomic, weak) id <STIMMWPhotoSectionBrowserChooseDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

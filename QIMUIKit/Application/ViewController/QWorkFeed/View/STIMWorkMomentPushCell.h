//
//  STIMWorkMomentPushCell.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@class STIMWorkMomentPushCell;

@protocol STIMWorkMomentPushCellDeleteDelegate <NSObject>

- (void)removeSelectPhoto:(STIMWorkMomentPushCell *)cell;

- (void)playSelectVideo:(STIMWorkMomentPushCell *)cell;

@end

@interface STIMWorkMomentPushCell : UICollectionViewCell

@property (nonatomic, weak) id <STIMWorkMomentPushCellDeleteDelegate> dDelegate;

@property (nonatomic, assign) STIMWorkMomentMediaType mediaType;

@property (nonatomic, assign) BOOL canDelete;

@end

NS_ASSUME_NONNULL_END

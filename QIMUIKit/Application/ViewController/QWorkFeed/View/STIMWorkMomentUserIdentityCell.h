//
//  STIMWorkMomentUserIdentityCell.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/11.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STIMWorkMomentUserIdentityReplaceDelegate <NSObject>

- (void)replaceWorkMomentUserIdentity;

@end

@interface STIMWorkMomentUserIdentityCell : UITableViewCell

@property (nonatomic, assign) BOOL userIdentitySelected;

@property (nonatomic, weak) id <STIMWorkMomentUserIdentityReplaceDelegate> delegate;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

- (void)setUserIdentitySelected:(BOOL)selected;

- (void)setUserIdentityReplaceable:(BOOL)replaceable;

@end

NS_ASSUME_NONNULL_END

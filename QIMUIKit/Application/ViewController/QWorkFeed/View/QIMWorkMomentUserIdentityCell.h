//
//  QIMWorkMomentUserIdentityCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/11.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QIMWorkMomentUserIdentityReplaceDelegate <NSObject>

- (void)replaceWorkMomentUserIdentity;

@end

@interface QIMWorkMomentUserIdentityCell : UITableViewCell

@property (nonatomic, assign) BOOL userIdentitySelected;

@property (nonatomic, weak) id <QIMWorkMomentUserIdentityReplaceDelegate> delegate;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

- (void)setUserIdentitySelected:(BOOL)selected;

- (void)setUserIdentityReplaceable:(BOOL)replaceable;

@end

NS_ASSUME_NONNULL_END

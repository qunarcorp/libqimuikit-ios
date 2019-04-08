//
//  QIMNacConfigTableViewCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/3/26.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QIMNavConfigDelegate <NSObject>

- (void)deleteNavWithNavCell:(id)cell;

- (void)modifyNavWithNavCell:(id)cell;

- (void)showNavQRWithNavCell:(id)cell;

- (void)selectNavWithNavCell:(id)cell;

@end

@interface QIMNacConfigTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *navInfo;

@property (nonatomic, weak) id <QIMNavConfigDelegate> delegate;

- (void)setUpUINormal;
- (void)setUpUISelected;

@end

NS_ASSUME_NONNULL_END

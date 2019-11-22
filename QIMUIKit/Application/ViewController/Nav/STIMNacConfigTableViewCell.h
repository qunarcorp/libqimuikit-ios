//
//  STIMNacConfigTableViewCell.h
//  STIMUIKit
//
//  Created by lilu on 2019/3/26.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STIMNavConfigDelegate <NSObject>

- (void)deleteNavWithNavCell:(id)cell;

- (void)modifyNavWithNavCell:(id)cell;

- (void)showNavQRWithNavCell:(id)cell;

- (void)selectNavWithNavCell:(id)cell;

@end

@interface STIMNacConfigTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *navInfo;

@property (nonatomic, weak) id <STIMNavConfigDelegate> delegate;

- (void)setUpUINormal;
- (void)setUpUISelected;

@end

NS_ASSUME_NONNULL_END

//
//  STIMWorkFeedAtUserTableViewCell.h
//  STIMUIKit
//
//  Created by lilu on 2019/4/29.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkFeedAtUserTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *userXmppId;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) BOOL userSelected;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end

NS_ASSUME_NONNULL_END

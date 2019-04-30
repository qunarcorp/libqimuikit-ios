//
//  QIMWorkFeedAtUserTableViewCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/4/29.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkFeedAtUserTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *userXmppId;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) BOOL userSelected;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end

NS_ASSUME_NONNULL_END

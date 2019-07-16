//
//  QIMAtUserTableViewCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/4/8.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMAtUserTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *name;
+ (CGFloat)getCellHeight;
- (void)refreshUI;

@end

NS_ASSUME_NONNULL_END

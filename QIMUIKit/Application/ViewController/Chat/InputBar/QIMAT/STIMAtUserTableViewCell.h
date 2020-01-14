//
//  STIMAtUserTableViewCell.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/4/8.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMAtUserTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *name;
+ (CGFloat)getCellHeight;
- (void)refreshUI;

@end

NS_ASSUME_NONNULL_END

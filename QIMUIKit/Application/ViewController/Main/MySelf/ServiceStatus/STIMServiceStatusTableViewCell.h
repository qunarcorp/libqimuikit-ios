//
//  STIMServiceStatusTableViewCell.h
//  STChatIphone
//
//  Created by Qunar-Lu on 2017/4/11.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMServiceStatusTableViewCell : UITableViewCell

+ (CGFloat)getCellHeight;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setServiceStatusDetail:(NSString *)detailStr;

- (void)setServiceStatusTitle:(NSString *)statusTitle;

@end

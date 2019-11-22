//
//  STIMHintTableViewCell.h
//  STIMUIKit
//
//  Created by qitmac000645 on 2019/8/22.
//

#import "STIMMsgBaloonBaseCell.h"

@class STIMHintTableViewCell;
@protocol STIMHintCellDelegate <NSObject>

- (void)hintCell:(STIMHintTableViewCell *)cell linkClickedWithInfo:(NSDictionary *)infoFic;

@end
NS_ASSUME_NONNULL_BEGIN

@interface STIMHintTableViewCell : STIMMsgBaloonBaseCell
@property (nonatomic,weak) id<STIMHintCellDelegate> hintDelegate;

+ (CGFloat)getCellHeightWihtMessage:(STIMMessageModel *)message chatType:(ChatType)chatType;

@end

NS_ASSUME_NONNULL_END

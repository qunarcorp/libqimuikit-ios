//
//  STIMColorfulBubbleCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@class STIMColorfulBubbleCell;
@protocol STIMColorfulBubbleCellDelegate <NSObject>

- (void)colorfulBubbleCell :(STIMColorfulBubbleCell *)cell didSelectedBubbleAtIndex:(NSInteger)index;

@end

@interface STIMColorfulBubbleCell : UITableViewCell

@property (nonatomic,assign)id<STIMColorfulBubbleCellDelegate>  delegate;

- (void)setBubbles:(NSArray *)bubbles;

@end

//
//  STIMChatBGImageDisplayCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

#define kCellImageCount 3.0

@class STIMChatBGImageDisplayCell;
@protocol STIMChatBGImageDisplayCellDelegate <NSObject>

- (void)imageDisplayCell:(STIMChatBGImageDisplayCell *)cell didSelectedImageAtIndex:(NSInteger )index;

@end

@interface STIMChatBGImageDisplayCell : UITableViewCell

@property (nonatomic, assign)id<STIMChatBGImageDisplayCellDelegate> delegate;

+ (CGSize)getImageSize;

- (void)setImages:(NSArray *)images;

@end

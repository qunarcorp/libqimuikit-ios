//
//  STIMOpenPlatformCell.h
//  qunarChatIphone
//
//  Created by admin on 16/4/18.
//
//

#import "STIMCommonUIFramework.h"

@class STIMOpenPlatformCell;

@protocol STIMOpenPlatformCellDelegate <NSObject>
@optional
- (void)STIMOpenPlatformCellClick:(STIMOpenPlatformCell *)openPlatformCel;
@end

@interface STIMOpenPlatformCell : UITableViewCell
//@property (nonatomic, strong) NSString *tagStr;
//@property (nonatomic, strong) NSString *content;
//@property (nonatomic, assign) long long msgTime;
//@property (nonatomic, assign) NSString *linkUrl;
@property (nonatomic, strong)STIMMessageModel *message;
@property (nonatomic, weak) id<STIMOpenPlatformCellDelegate> delegate;
+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message;
- (void)refreshUI;
@end

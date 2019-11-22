//
//  STIMPNActionRichTextCell.h
//  qunarChatIphone
//
//  Created by admin on 15/9/6.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMPNActionRichTextCellDelegate <NSObject>
@optional
- (void)openWebUrl:(NSString *)url;
@end

@interface STIMPNActionRichTextCell : UITableViewCell
@property (nonatomic, weak) id<STIMPNActionRichTextCellDelegate> delegate;
@property (nonatomic, strong) NSString *content;

+ (CGFloat)getCellHeightByContent:(NSString *)content;

- (void)refreshUI;

@end

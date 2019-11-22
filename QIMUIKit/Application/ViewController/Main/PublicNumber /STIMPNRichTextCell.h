//
//  STIMPNRichTextCell.h
//  qunarChatIphone
//
//  Created by admin on 15/9/6.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMPNRichTextCellDelegate <NSObject>
@optional
- (void)openWebUrl:(NSString *)url;
@end

@interface STIMPNRichTextCell : UITableViewCell
@property (nonatomic, weak) id<STIMPNRichTextCellDelegate> delegate;
@property (nonatomic, strong) NSString *content;

+ (CGFloat)getCellHeightByContent:(NSString *)content;

- (void)refreshUI;

@end

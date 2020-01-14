//
//  STIMContactUserCell.h
//  STChatIphone
//
//  Created by xueping on 15/7/16.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMContactUserCell : UITableViewCell

@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak)  NSDictionary *infoDic;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL hasAtCell;
@property (nonatomic, assign) BOOL isSystem;
+ (CGFloat)getCellHeight;
- (void)refreshUI;

@end

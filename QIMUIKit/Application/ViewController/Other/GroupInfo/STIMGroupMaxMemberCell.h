//
//  STIMGroupMaxMemberCell.h
//  STChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMGroupMaxMemberCell : UITableViewCell

@property (nonatomic, assign) NSString *maxCount;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end

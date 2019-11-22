//
//  STIMPublicNumberCardCommonCell.h
//  qunarChatIphone
//
//  Created by admin on 15/8/27.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMPublicNumberCardCommonCell : UITableViewCell
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, assign) NSTextAlignment infoTextAlignment;

+ (CGFloat)getCellHeightByInfo:(NSString *)info;

- (void)refreshUI;

@end

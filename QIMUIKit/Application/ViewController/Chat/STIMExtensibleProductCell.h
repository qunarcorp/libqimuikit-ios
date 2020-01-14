//
//  STIMExtensibleProductCell.h
//  STChatIphone
//
#import "STIMCommonUIFramework.h"

@class STIMMsgBaloonBaseCell;
@interface STIMExtensibleProductCell : STIMMsgBaloonBaseCell

@property (nonatomic, strong) UIViewController *owner;

+ (float)getCellHeightForProductInfo:(NSString *)infoStr;

- (void)setProDcutInfoDic:(NSDictionary *)infoDic;

- (void)refreshUI;

@end

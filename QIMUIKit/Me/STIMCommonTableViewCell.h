//
//  STIMCommonTableViewCell.h
//  STChatIphone
//
//  Created by 李海彬 on 2017/12/21.
//

#import "STIMCommonUIFramework.h"
#define TABLE_VIEW_CELL_DEFAULT_FONT_SIZE 17

#define TABLE_VIEW_CELL_LEFT_MARGIN 20

#define TABLE_VIEW_CELL_DEFAULT_HEIGHT 44

typedef NS_ENUM(NSInteger, STIMCommonTableViewCellStyle) {
    kSTIMCommonTableViewCellStyleDefault = UITableViewCellStyleDefault,
    kSTIMCommonTableViewCellStyleValue1 = UITableViewCellStyleValue1,
    kSTIMCommonTableViewCellStyleValue2 = UITableViewCellStyleValue2,
    kSTIMCommonTableViewCellStyleSubtitle = UITableViewCellStyleSubtitle,
    
    kSTIMCommonTableViewCellStyleValueCenter = 1000,
    kSTIMCommonTableViewCellStyleValueLeft,
    kSTIMCommonTableViewCellStyleContactList,
    kSTIMCommonTableViewCellStyleContactSearchList
};


typedef NS_ENUM(NSInteger, STIMCommonTableViewCellAccessoryType) {
    kSTIMCommonTableViewCellAccessoryNone = UITableViewCellAccessoryNone,
    kSTIMCommonTableViewCellAccessoryDisclosureIndicator = UITableViewCellAccessoryDisclosureIndicator,
    kSTIMCommonTableViewCellAccessoryDetailDisclosureButton = UITableViewCellAccessoryDetailDisclosureButton,
    kSTIMCommonTableViewCellAccessoryCheckmark = UITableViewCellAccessoryCheckmark,
    kSTIMCommonTableViewCellAccessoryDetailButton = UITableViewCellAccessoryDetailButton,
    
    kSTIMCommonTableViewCellAccessorySwitch,
    kSTIMCommonTableViewCellAccessoryText,
};

@interface STIMCommonTableViewCell : UITableViewCell

@property (nonatomic) STIMCommonTableViewCellAccessoryType accessoryType_LL;

+ (instancetype)cellWithStyle:(STIMCommonTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (BOOL)isSwitchOn;

- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated;

- (void)addSwitchTarget:(id)object tag:(NSUInteger)type action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (NSString *)rightTextValue;

- (void)setRightTextValue:(NSString *)value;

@end

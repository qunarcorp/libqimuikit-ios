
#import "QIMCommonUIFramework.h"

typedef NS_ENUM(NSInteger, BarItemKind){
    kBarItemVoice,
    kBarItemFace,
    kBarItemMore,
    kBarItemSwitchBar
};

@interface QIMChatToolBarItem : NSObject

@property (nonatomic, strong) UIImage *normal;
@property (nonatomic, strong) UIImage *highImage;
@property (nonatomic, strong) UIImage *selectImage;
@property (nonatomic, assign) BarItemKind itemKind;

+ (instancetype)barItemWithKind:(BarItemKind)itemKind normal:(UIImage*)normal high:(UIImage *)highImage select:(UIImage *)selectImage;

@end

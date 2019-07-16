
#import "QIMChatToolBarItem.h"

@implementation QIMChatToolBarItem

+ (instancetype)barItemWithKind:(BarItemKind)itemKind normal:(UIImage*)normalImage high:(UIImage *)highImage select:(UIImage *)selectImage
{
    return [[[self class] alloc] initWithItemKind:itemKind normal:normalImage high:highImage select:selectImage];
}


- (instancetype)initWithItemKind:(BarItemKind)itemKind normal:(UIImage*)normalImage high:(UIImage *)highImage select:(UIImage *)selectImage 
{
    if (self = [super init]) {
        self.itemKind = itemKind;
        self.normal = normalImage;
        self.highImage = highImage;
        self.selectImage = selectImage;
    }
    return self;
}

@end

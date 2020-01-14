//
//  STIMCommonTableViewCellData.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/12/21.
//

#import "STIMCommonTableViewCellData.h"
#import "STIMIconInfo.h"
#import "STIMIconFont.h"

@implementation STIMCommonTableViewCellData

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName cellDataType:(STIMCommonTableViewCellDataType)cellDataType {
    return [self initWithTitle:title subTitle:nil iconName:iconName cellDataType:cellDataType];
}

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconName:(NSString *)iconName cellDataType:(STIMCommonTableViewCellDataType)cellDataType {
    self = [super init];
    if (self) {
        self.title = title;
        if (iconName) {
            self.icon = [UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:iconName size:24 color:[UIColor stimDB_colorWithHex:0x9e9e9e alpha:1.0]]];
        }
        self.subTitle = subTitle;
        self.cellDataType = cellDataType;
    }
    
    return self;
}

@end

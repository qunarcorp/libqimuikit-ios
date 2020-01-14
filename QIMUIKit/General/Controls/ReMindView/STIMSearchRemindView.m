//
//  STIMSearchRemindView.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2018/12/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMSearchRemindView.h"
#import "STIMFastEntrance.h"
#import "STIMCommonCategories.h"
#import "STIMIconInfo.h"
#import "UIImage+STIMIconFont.h"

@interface STIMSearchRemindView ()

@end

@implementation STIMSearchRemindView

- (instancetype)initWithChatId:(NSString *)chatId withRealJid:(NSString *)realjid withChatType:(NSInteger)chatType {
    if (self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, 110, 120, 36)]) {
        self.backgroundColor = [UIColor whiteColor];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(18, 18)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        UIImageView *searchIconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 12, 12)];
        searchIconView.image = [UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:stimDB_chatsearchRemindViewTextFont size:21 color:stimDB_chatsearchRemindViewIconColor]];
        [self addSubview:searchIconView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchIconView.right + 5, 8, 80, 20)];
        [textLabel setText:@"搜索聊天记录"];
        [textLabel setTextColor:stimDB_chatsearchRemindViewTextColor];
        [textLabel setFont:[UIFont systemFontOfSize:stimDB_chatsearchRemindViewTextSize]];
        [self addSubview:textLabel];
    }
    return self;
}

@end

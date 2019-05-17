//
//  QIMSearchRemindView.m
//  QIMUIKit
//
//  Created by lilu on 2018/12/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMSearchRemindView.h"
#import "QIMFastEntrance.h"
#import "QIMCommonCategories.h"
#import "QIMIconInfo.h"
#import "UIImage+QIMIconFont.h"

@interface QIMSearchRemindView ()

@end

@implementation QIMSearchRemindView

- (instancetype)initWithChatId:(NSString *)chatId withRealJid:(NSString *)realjid withChatType:(NSInteger)chatType {
    if (self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, 110, 120, 36)]) {
        self.backgroundColor = [UIColor whiteColor];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(18, 18)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        UIImageView *searchIconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 12, 12)];
        searchIconView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_chatsearchRemindViewTextFont size:21 color:qim_chatsearchRemindViewIconColor]];
        [self addSubview:searchIconView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchIconView.right + 5, 8, 80, 20)];
        [textLabel setText:@"搜索聊天记录"];
        [textLabel setTextColor:qim_chatsearchRemindViewTextColor];
        [textLabel setFont:[UIFont systemFontOfSize:qim_chatsearchRemindViewTextSize]];
        [self addSubview:textLabel];
    }
    return self;
}

@end

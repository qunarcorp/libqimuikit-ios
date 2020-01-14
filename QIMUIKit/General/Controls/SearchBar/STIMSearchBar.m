//
//  STIMSearchBar.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/4/25.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMSearchBar.h"
#import "Masonry.h"
#import "STIMUIFontConfig.h"
#import "STIMUIColorConfig.h"
#import "STIMUISizeConfig.h"
#import "STIMIconInfo.h"
#import "UIImage+STIMIconFont.h"

@interface STIMSearchBar ()

@property (nonatomic, strong) UIView *searchBgView;

@end

@implementation STIMSearchBar

- (UIView *)searchBgView {
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchBgView.backgroundColor = stimDB_listSearchBgViewColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToSearchVc:)];
        [_searchBgView addGestureRecognizer:tap];
    }
    return _searchBgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.searchBgView];
        self.searchBgView.layer.cornerRadius = 4.0f;
        [self.searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.right.mas_offset(-15);
            make.top.mas_offset(13);
            make.bottom.mas_offset(-3);
        }];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconView.image = [UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e752" size:30 color:[UIColor stimDB_colorWithHex:0xBFBFBF]]];
        [self.searchBgView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.width.mas_equalTo(15);
            make.top.mas_offset(13);
            make.height.mas_equalTo(15);
        }];
        
        UILabel *promotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        promotLabel.text = [NSBundle stimDB_localizedStringForKey:@"Search"];//@"搜索";
        promotLabel.textColor = [UIColor stimDB_colorWithHex:0xB5B5B5];
        promotLabel.font = [UIFont systemFontOfSize:stimDB_listSearchTextSize];
        [self.searchBgView addSubview:promotLabel];
        [promotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(iconView.mas_right).mas_offset(8);
            make.top.mas_offset(12);
            make.bottom.mas_offset(-12);
            make.width.mas_equalTo(100);
        }];
        
    }
    return self;
}

- (void)jumpToSearchVc:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stimDB_searchBarBecomeFirstResponder)]) {
        [self.delegate stimDB_searchBarBecomeFirstResponder];
    }
}

@end

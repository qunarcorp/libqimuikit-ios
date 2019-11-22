//
//  STIMGroupSettingCell.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "STIMGroupSettingCell.h"
#import "STIMCommonFont.h"
#import "NSBundle+STIMLibrary.h"

@implementation STIMGroupSettingCell{
    UIView *_rootView;
    UILabel *_titleLabel;
    UILabel *_accountLabel;
}

+ (CGFloat)getCellHeight{
    return [[STIMCommonFont sharedInstance] currentFontSize] + 32;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [STIMGroupSettingCell getCellHeight])];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, _rootView.width - 60, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:[NSBundle stimDB_localizedStringForKey:@"group_setting"]];
        [_rootView addSubview:_titleLabel];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshUI{
    _titleLabel.font = [UIFont boldSystemFontOfSize:[[STIMCommonFont sharedInstance] currentFontSize] - 2];
    _titleLabel.frame = CGRectMake(10, 0, _rootView.width - 60, [self.class getCellHeight]);
}
@end

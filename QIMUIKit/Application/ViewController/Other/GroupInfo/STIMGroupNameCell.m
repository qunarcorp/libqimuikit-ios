//
//  STIMGroupNameCell.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "STIMGroupNameCell.h"
#import "STIMMenuView.h"
#import "STIMCommonFont.h"
#import "NSBundle+STIMLibrary.h"

@implementation STIMGroupNameCell{ 
    UIView *_rootView;
    UILabel *_titleLabel;
    UILabel *_groupNameLabel;
    STIMMenuView * _menuView;
}

+ (CGFloat)getCellHeight{
    return [[STIMCommonFont sharedInstance] currentFontSize] + 32;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [STIMGroupNameCell getCellHeight])];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:[NSBundle stimDB_localizedStringForKey:@"group_name"]];
        [_rootView addSubview:_titleLabel];
        
        _groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right + 10, 15, _rootView.width - _titleLabel.right - 10 - 30, 20)];
        [_groupNameLabel setBackgroundColor:[UIColor clearColor]];
        [_groupNameLabel setFont:[UIFont systemFontOfSize:14]];
        [_groupNameLabel setTextColor:[UIColor blackColor]];
        [_groupNameLabel setTextAlignment:NSTextAlignmentRight];
        [_rootView addSubview:_groupNameLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, _rootView.height - 0.5, _rootView.width - 10, 0.5)];
        [line setBackgroundColor:[UIColor qtalkTableDefaultColor]];
        [_rootView addSubview:line];
        
        _menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [STIMGroupNameCell getCellHeight])];
        [self.contentView addSubview:_menuView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshUI{
    
    [_menuView setCoprText:self.name];
    
    _titleLabel.frame = CGRectMake(15, 0, 100, [self.class getCellHeight]);
    _titleLabel.font = [UIFont boldSystemFontOfSize:[[STIMCommonFont sharedInstance] currentFontSize] - 2];
    
    _groupNameLabel.frame = CGRectMake(_titleLabel.right, 0, _rootView.width - _titleLabel.right - 10 - 30, [self.class getCellHeight]);
    _groupNameLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
    
    [_groupNameLabel setText:self.name];
}

@end

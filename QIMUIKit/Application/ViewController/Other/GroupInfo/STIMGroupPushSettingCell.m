//
//  STIMGroupPushSettingCell.m
//  STChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMGroupPushSettingCell.h"
#import "STIMCommonFont.h"
//#import "NSBundle+STIMLibrary.h"

@interface STIMGroupPushSettingCell(){
    UIView      *_rootView;
    UILabel     *_titleLabel;
    UISwitch    *_switchBtn;
    UIView      *_line;
}

@end

@implementation STIMGroupPushSettingCell

+ (CGFloat)getCellHeight{
    return [[STIMCommonFont sharedInstance] currentFontSize] + 32;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [STIMGroupPushSettingCell getCellHeight])];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 200, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:[NSBundle stimDB_localizedStringForKey:@"group_push"]];
        [_rootView addSubview:_titleLabel];
        
        _switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
        BOOL swicthOn = [[STIMKit sharedInstance] groupPushState:self.groupId];
        [_switchBtn setOn:!swicthOn];
        [_switchBtn addTarget:self action:@selector(onSwitchClicked:)
            forControlEvents:UIControlEventValueChanged];
        if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
            [self setAccessoryView:_switchBtn];
        }
        
        _line = [[UIView alloc] initWithFrame:CGRectMake(10, _rootView.height - 0.5, _rootView.width - 10, 0.5)];
        [_line setBackgroundColor:[UIColor qtalkTableDefaultColor]];
        [_rootView addSubview:_line];
        
    }
    return self;
}

- (void)onSwitchClicked:(UISwitch *) sender {
    BOOL swicthOn = [[STIMKit sharedInstance] groupPushState:self.groupId];
    [[STIMKit sharedInstance] updatePushState:self.groupId withOn:!swicthOn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshUI{
    
    _titleLabel.frame = CGRectMake(10, 0, 200, [self.class getCellHeight]);
    _titleLabel.font = [UIFont boldSystemFontOfSize:[[STIMCommonFont sharedInstance] currentFontSize] - 2];
    
    _line.frame = CGRectMake(10, [self.class getCellHeight] - 0.5, _rootView.width - 10, 0.5);
    BOOL switchOn = [[STIMKit sharedInstance] groupPushState:self.groupId];
    [_switchBtn setOn:!switchOn];
}

@end

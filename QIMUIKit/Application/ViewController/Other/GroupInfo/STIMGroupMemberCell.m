//
//  STIMGroupMemberCell.m
//  STChatIphone
//
//  Created by haibin.li on 15/11/19.
//
//

#import "STIMGroupMemberCell.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMGroupMemberCell () {
    GroupMemberIDType   _idType;
    UILabel         * _idLabel;
}

@end

@implementation STIMGroupMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.image = [UIImage imageWithData:[STIMKit defaultUserHeaderImage]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10, (self.contentView.height - 30) / 2, 30, 30);
    self.textLabel.frame = CGRectMake(self.imageView.right + 10, 0, self.contentView.width - self.imageView.right - 10, self.contentView.height);
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.width - 100, (self.contentView.height - 30) / 2.0, 70, 20)];
        _idLabel.layer.cornerRadius = 3;
        _idLabel.clipsToBounds = YES;
        _idLabel.textAlignment = NSTextAlignmentCenter;
        _idLabel.textColor = [UIColor whiteColor];
        _idLabel.font = [UIFont systemFontOfSize:12];

        [self.contentView addSubview:_idLabel];
    }
    if  (_idType > GroupMemberIDTypeNone) {
        if (_idType == GroupMemberIDTypeOwner) {
            _idLabel.backgroundColor = [UIColor stimDB_colorWithHex:0xf0ac37 alpha:1.0];
            _idLabel.text = [NSBundle stimDB_localizedStringForKey:@"group_owner"];
            CGSize size = [_idLabel.text sizeWithFont:_idLabel.font constrainedToSize:CGSizeMake(INT32_MAX, 16) lineBreakMode:NSLineBreakByCharWrapping];
            [_idLabel setWidth:size.width + 10];
            [_idLabel setCenter:CGPointMake(self.contentView.width - _idLabel.width / 2.0 - 15, self.contentView.height / 2)];
            [_idLabel setHidden:NO];
        }else if (_idType == GroupMemberIDTypeAdmin){
            _idLabel.backgroundColor = [UIColor stimDB_colorWithHex:0x70d03f alpha:1.0];
            _idLabel.text = [NSBundle stimDB_localizedStringForKey:@"group_admin"];
            CGSize size = [_idLabel.text sizeWithFont:_idLabel.font constrainedToSize:CGSizeMake(INT32_MAX, 16) lineBreakMode:NSLineBreakByCharWrapping];
            [_idLabel setWidth:size.width + 10];
            [_idLabel setCenter:CGPointMake(self.contentView.width - _idLabel.width / 2.0 - 15, self.contentView.height / 2)];
            [_idLabel setHidden:NO];
        }
    }else{
        _idLabel.backgroundColor = [UIColor qtalkIconSelectColor];
        _idLabel.text = @"在线";
        CGSize size = [_idLabel.text sizeWithFont:_idLabel.font constrainedToSize:CGSizeMake(INT32_MAX, 16) lineBreakMode:NSLineBreakByCharWrapping];
        [_idLabel setWidth:size.width + 10];
        [_idLabel setCenter:CGPointMake(self.contentView.width - _idLabel.width / 2.0 - 15, self.contentView.height / 2)];
        if (self.isOnLine) {
            [_idLabel setHidden:NO];
        } else {
            [_idLabel setHidden:YES];
        }
    }
}

- (void)setMemberIDType:(GroupMemberIDType)idType
{
    _idType = idType;
}

@end

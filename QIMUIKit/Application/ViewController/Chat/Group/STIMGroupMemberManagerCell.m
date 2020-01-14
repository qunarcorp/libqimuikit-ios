//
//  STIMGroupMemberManagerCell.m
//  STChatIphone
//
//  Created by haibin.li on 15/8/17.
//
//

#define kHeadImageWidth   30.0f
#define kIdentityLabelWidth   70.0f
#define kIdentityLabelHeight   17.0f

#import "STIMGroupMemberManagerCell.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMGroupMemberManagerCell()
{
    UIImageView             * _headImageView;
    UILabel                 * _identityLabel;//管理员等。。
    UILabel                 * _nickNameLabel;
    UILabel                 * _flagLabel;//我
    
    UIView                  * _sepLine;
}

@end
@implementation STIMGroupMemberManagerCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headImageView.layer.cornerRadius = kHeadImageWidth / 2;
        _headImageView.clipsToBounds = YES;
        _headImageView.contentMode = UIViewContentModeScaleAspectFit;
        _headImageView.image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"singleHeaderDefault"];
        [self.contentView addSubview:_headImageView];
        
        _identityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _identityLabel.textColor = [UIColor whiteColor];
        _identityLabel.font = [UIFont systemFontOfSize:12];
        _identityLabel.textAlignment = NSTextAlignmentCenter;
        _identityLabel.layer.cornerRadius = 5;
        _identityLabel.clipsToBounds = YES;
        [self.contentView addSubview:_identityLabel];
        
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nickNameLabel.backgroundColor = [UIColor clearColor];
        _nickNameLabel.tintColor = [UIColor whiteColor];
        _nickNameLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.contentView addSubview:_nickNameLabel];
        
        _flagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flagLabel.backgroundColor = [UIColor clearColor];
        _flagLabel.tintColor = [UIColor lightGrayColor];
        _flagLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_flagLabel];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_sepLine];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    /*
    UIImage *headImage = [[STIMKit sharedInstance] getUserHeaderImageByUserId:[_memberInfo objectForKey:@"xmppjid"]];
    if (headImage) {
        _headImageView.image = headImage;
    }
    */
    if ([[_memberInfo objectForKey:@"affiliation"] isEqualToString:@"owner"]) {
        _identityLabel.backgroundColor = [UIColor orangeColor];
        _identityLabel.text = [NSBundle stimDB_localizedStringForKey:@"contact_tab_group"];
    } else if ([[_memberInfo objectForKey:@"affiliation"] isEqualToString:@"admin"] ) {
        _identityLabel.backgroundColor = [UIColor greenColor];
        _identityLabel.text = [NSBundle stimDB_localizedStringForKey:@"Administrator"];
    }else{
        _identityLabel.backgroundColor = [UIColor blueColor];
        _identityLabel.text = [NSBundle stimDB_localizedStringForKey:@"Member"];
    }

    _nickNameLabel.text = [_memberInfo objectForKey:@"name"];
    
    if ([[_memberInfo objectForKey:@"xmppjid"] isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
        _flagLabel.hidden = NO;
        _flagLabel.text = @"我";
    }else{
        _flagLabel.hidden = YES;
    }
    
    _headImageView.frame = CGRectMake(10, (self.contentView.height - kHeadImageWidth) / 2, kHeadImageWidth, kHeadImageWidth);
    [_headImageView stimDB_setImageWithJid:[_memberInfo objectForKey:@"xmppjid"]];

    _identityLabel.frame = CGRectMake(_headImageView.right + 10, (self.contentView.height - kIdentityLabelHeight) / 2, kIdentityLabelWidth, kIdentityLabelHeight);
    
    
    _nickNameLabel.frame = CGRectMake(_identityLabel.right + 10, 0, self.contentView.width - _identityLabel.right - 10 -10 -30, self.contentView.height);
    
    _flagLabel.frame = CGRectMake(self.contentView.width - 30, 0, 20, self.contentView.height);
    
    _sepLine.frame = CGRectMake(_headImageView.left, self.contentView.bottom - 0.5, self.contentView.width - _headImageView.left, 0.5);
}

@end
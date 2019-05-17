//
//  QIMBuddyItemCell.m
//  qunarChatIphone
//
//  Created by May on 14/11/20.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMBuddyItemCell.h"

@interface QIMBuddyItemCell () {
    UIImageView *_headerView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
}

@end

@implementation QIMBuddyItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)initSubControls {
    
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
        
    _headerView = [[UIImageView alloc] init];
    _headerView.layer.masksToBounds = YES;
    _headerView.layer.cornerRadius  = 20.0f;
    _headerView.layer.borderWidth   = 0.01f;
    [self.contentView addSubview:_headerView];

    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
    [_nameLabel setTextColor:[UIColor qtalkTextBlackColor]];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_nameLabel];
}

- (void)refrash {

    CGFloat addtionWidth  = self.nLevel * 25;
    
    [_headerView setFrame:CGRectMake(addtionWidth + 10, 10, 40, 40)];
    [_nameLabel setFrame:CGRectMake(addtionWidth + 60, 10, 200, 20)];
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:_jid];
    NSString *userName = [userInfo objectForKey:@"Name"];
    [_nameLabel setText:userName];
    
    [_headerView qim_setImageWithJid:_jid];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor qim_colorWithHex:0xeaeaea alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(60, rect.size.height - 1, rect.size.width, 0.5));
}

@end

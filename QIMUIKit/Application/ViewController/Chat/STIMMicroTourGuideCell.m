//
//  STIMMicroTourGuideCell.m
//  STChatIphone
//
//  Created by admin on 16/4/15.
//
//

#import "STIMMicroTourGuideCell.h"
#import "STIMMenuImageView.h"

@interface STIMMicroTourGuideCell()<STIMMenuImageViewDelegate>

@end
@implementation STIMMicroTourGuideCell{
    
    STIMMenuImageView *_backView;
    UILabel *_contentLabel;
    
}

+ (CGFloat)getCellHeigthWithMessage:(STIMMessageModel *)message{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _backView = [[STIMMenuImageView alloc] initWithFrame:CGRectZero];
        [_backView setDelegate:self];
        [_backView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_backView];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_backView addSubview:_contentLabel];
        
    }
    return self;
}

@end

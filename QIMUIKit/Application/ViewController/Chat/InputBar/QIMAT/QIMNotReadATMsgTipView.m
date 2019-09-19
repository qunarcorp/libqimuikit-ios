//
//  QIMNotReadATMsgTipView.m
//  QIMUIKit
//
//  Created by lilu on 2019/5/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMNotReadATMsgTipView.h"

@implementation QIMNotReadATMsgTipView
{
    UIView *_backView;
    UIView *_leftView;
    UIImageView *_leftArrowImageView;
    UILabel *_titleLabel;
    int _notReadCount;
    NSString *_title;
}

- (CGFloat)getHeight {
    return 40;
}

- (CGFloat)getWidthForNotReadCount:(int)notReadCount{
    NSString *titleStr = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"%ldn mentioned"],notReadCount];
    _title = titleStr;
    CGSize titleSize = [titleStr sizeWithFont:[UIFont systemFontOfSize:13] forWidth:INT8_MAX lineBreakMode:NSLineBreakByCharWrapping];
    return titleSize.width + [self getHeight] / 2.0 - 5 + 10 + 17 + 8;
}

- (instancetype)initWithNotReadAtMsgCount:(int)notReadAtMsgCount {
    _notReadCount = notReadAtMsgCount;
    return [self initWithFrame:CGRectMake(0, 0, [self getWidthForNotReadCount:notReadAtMsgCount], [self getHeight])];
}

- (void)updateNotReadAtMsgCount:(int)notReadAtMsgCount {
    _title = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"%ldn mentioned"],notReadAtMsgCount];
    [_titleLabel setText:_title];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self getHeight], [self getHeight])];
        [_leftView setBackgroundColor:[UIColor whiteColor]];
        [_leftView.layer setCornerRadius:_leftView.height / 2.0];
        [self addSubview:_leftView];
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(_leftView.height/2.0, 0, self.width - _leftView.height/2.0, [self getHeight])];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_backView];
        
        _leftArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_backView.left - 5, ([self getHeight] - 17)/2.0, 17, 17)];
        [_leftArrowImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"up_arrow"]];
        [self addSubview:_leftArrowImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_leftArrowImageView.right + 8, 0, self.width - 10 - (_backView.left - 5), [self getHeight])];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:qim_notReadAtMessageUpArrowTextColor];
        [_titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_titleLabel setText:_title];
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)onClick{
    if (self.notReadAtMsgDelegate && [self.notReadAtMsgDelegate respondsToSelector:@selector(moveToLastNotReadAtMsg)]) {
        [self.notReadAtMsgDelegate moveToLastNotReadAtMsg];
    }
}
@end

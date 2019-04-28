//
//  QIMBuddyTitleCell.m
//  qunarChatIphone
//
//  Created by wangshihai on 15/1/4.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMBuddyTitleCell.h"

@interface QIMBuddyTitleCell(){

    UILabel *_nameLabel;
    UILabel *_contentLabel;
    BOOL   _isExpand;
    
    CALayer * parentLayer;
}

@end

@implementation QIMBuddyTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        parentLayer = [CALayer layer];
        [self.contentView.layer addSublayer:parentLayer];
    }
    return self;
}

-(void) initSubControls {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
    [_nameLabel setTextColor:[UIColor qtalkTextLightColor]];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_nameLabel];
}

- (void)refresh {
    [_nameLabel setText:self.userName];
    
    CGFloat addionWidth  = 22 * (self.nLevel-1);
    
    [_nameLabel  setFrame:CGRectMake(addionWidth + 50, 10, 200, 20)];
    [parentLayer setFrame:CGRectMake(addionWidth+28, 8, 24, 24)];
    parentLayer.contents = (id)[UIImage qim_imageNamedFromQIMUIKitBundle:@"triangleSmall"].CGImage;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor spectralColorLightColor].CGColor);
    CGContextStrokeRect(context, CGRectMake(12, rect.size.height - 1, rect.size.width, 0.2));
}


- (void) setExpanded:(BOOL)flag{
    if (_isExpand!= flag) {
        _isExpand = flag;
        
        CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"transform"];
        [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [ani setDuration:0.2];
        [ani setRepeatCount:1.0];
        [ani setAutoreverses:NO];
        [ani setFillMode:kCAFillModeForwards];	//needed so animated object won't go back to its original value after animation
        [ani setRemovedOnCompletion:NO];		//needed so animated object won't go back to its original value after animation

        CATransform3D transform = _isExpand?CATransform3DRotate(parentLayer.transform, M_PI/2, 0, 0, 1.0):CATransform3DIdentity;
        [ani setToValue:[NSValue valueWithCATransform3D:transform]];
        
        NSString *animationKey = _isExpand?@"expandingTransform":@"collapsingTransform";
        [parentLayer addAnimation:ani forKey:animationKey];
    }
}

@end

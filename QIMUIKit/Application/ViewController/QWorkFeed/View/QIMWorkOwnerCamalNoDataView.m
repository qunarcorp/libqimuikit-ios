//
//  QIMWorkOwnerCamalNoDataView.m
//
//  Created by Kamil on 2019/5/17.
//
//myCamalNoMoreData

#import "QIMCommonUIFramework.h"
#import "QIMWorkOwnerCamalNoDataView.h"

@implementation QIMWorkOwnerCamalNoDataView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self makeUI];
    }
    return self;
}

- (void)makeUI{
    
    UIImageView * imageView = [[UIImageView alloc]init];
    
    UIImage * image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"myCamalNoMoreData"];
    imageView.image = image;
    
    [imageView setFrame:CGRectMake((self.width - image.size.width)/2, 170, image.size.width, image.size.height)];
    
    [self addSubview:imageView];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.height + imageView.y + 20, self.width, 15)];
    label.textColor = [UIColor colorWithRGBHex:0x888888];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSBundle qim_localizedStringForKey:@"No_Moments"] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Regular" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0]}];
    label.attributedText = string;
    label.alpha = 1.0;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

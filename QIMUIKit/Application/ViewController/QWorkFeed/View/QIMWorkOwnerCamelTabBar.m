//
//  QIMWorkOwnerCamelTabBar.m
//  QIMUIKit
//
//  Created by Kamil on 2019/5/15.
//

#import "QIMWorkOwnerCamelTabBar.h"
#import "UIScreen+QIMIpad.h"
#import "QIMCommonUIFramework.h"

@interface QIMWorkOwnerCamelTabBar()
@property (nonatomic ,strong) UIView * lineView;
@property (nonatomic, assign) BOOL scrollEnable;
@end
@implementation QIMWorkOwnerCamelTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollEnable = YES;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    NSArray * array = [NSArray arrayWithObjects:@"我的帖子",@"我的回复",@"@提到我", nil];
    for(int i = 0;i<3;i++)
    {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].qim_rightWidth/3 * i, 0, [UIScreen mainScreen].qim_rightWidth/3, self.height)];
        label.userInteractionEnabled = YES;
        label.text = array[i];
        label.textColor = [UIColor qim_colorWithHex:0x999999];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = i + 29314;
        if (i == 0) {
            label.textColor = [UIColor qim_colorWithHex:0x00CABE];
        }
        label.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelClicked:)];
        [label addGestureRecognizer:tap];
        [self addSubview:label];
        
        [label addGestureRecognizer:tap];
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake( [UIScreen mainScreen].qim_rightWidth/3 * i + [UIScreen mainScreen].qim_rightWidth/3 - 1 , (label.height-14)/2, 1, 14)];
        
        lineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];

        if (i!=2) {
            [self addSubview:lineView];
        }
    }
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].qim_rightWidth/3 - 62)/2, 48 - 1, 62, 3)];
    self.lineView.backgroundColor = [UIColor qim_colorWithHex:0x00CABE];
    [self addSubview:self.lineView];
    
    
    UIView * grayLineView = [[UIView alloc]initWithFrame:CGRectMake(14, 50, [UIScreen mainScreen].qim_rightWidth - 28, 1)];
    grayLineView.backgroundColor = [UIColor colorWithRGBHex:0xDDDDDD];
    [self addSubview:grayLineView];
}

-(void)viewXOffset:(CGFloat)offset{
    
    CGFloat x =offset/[UIScreen mainScreen].qim_rightWidth * [UIScreen mainScreen].qim_rightWidth/3;
    
    [self.lineView setFrame:CGRectMake(x+([UIScreen mainScreen].qim_rightWidth/3 - 62)/2,48, 62, 3)];
    
    if (x/([UIScreen mainScreen].qim_rightWidth/3) == 0 || x/([UIScreen mainScreen].qim_rightWidth/3) == 1 || x/([UIScreen mainScreen].qim_rightWidth/3) == 2) {
        [self setLabelColorWithIndex:x/([UIScreen mainScreen].qim_rightWidth/3)];
    }
}
- (void)setLabelColorWithIndex:(NSInteger)index{
    for (int i = 0; i<3; i++) {
        UILabel * tlabel = [self viewWithTag:i + 29314];
        tlabel.textColor = [UIColor qim_colorWithHex:0x999999];
    }
    UILabel * label = [self viewWithTag:index + 29314];
    label.textColor = [UIColor qim_colorWithHex:0x00CABE];
}

- (void)labelClicked:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(tabBarBtnClickedIndex:)]) {
        [self.delegate tabBarBtnClickedIndex:tap.view.tag - 29314];
    }
    self.scrollEnable = NO;
    [self setLabelColorWithIndex:tap.view.tag - 29314];
    
//    [self.lineView setFrame:CGRectMake((tap.view.tag - 29314) * ([UIScreen mainScreen].qim_rightWidth/3 - 62)/2,48, 62, 3)];

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    for (UIView * subView in self.subviews) {
        CGPoint buttonPoint = [subView convertPoint:point fromView:self];
        if ([subView pointInside:buttonPoint withEvent:event]) {
            return subView;
        }
    }
    return result;
}

@end

//
//  QIMWorkMomentHeaderListCollectionViewCell.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/24.
//

#import "QIMWorkMomentHeaderListCollectionViewCell.h"
#import "UIImage+QIMIconFont.h"
#import "QIMImageUtil.h"
#import "UIImage+QIMIconFont.h"
@interface QIMWorkMomentHeaderListCollectionViewCell()
@end

@implementation QIMWorkMomentHeaderListCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setViewWithFrame:frame];
    }
    return self;
}

- (void)setViewWithFrame:(CGRect)frame{
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = frame.size.width/2;
    [self.contentView addSubview:self.imageView];
}
@end

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
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 42, 42)];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 42/2;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

@end

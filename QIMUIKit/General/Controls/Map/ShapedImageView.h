//
//  ShapedImageView.h
//  JJTest
//
//  Created by haibin.li on 16/1/4.
//  Copyright © 2016年 chenjie. All rights reserved.
//

#import "STIMCommonUIFramework.h"

typedef enum {
    ShapedImageViewDirectionLeft,
    ShapedImageViewDirectionRight,
}ShapedImageViewDirection;

@interface ShapedImageView : UIImageView

@property (nonatomic,assign) ShapedImageViewDirection   direction;

- (void)setup;

@end

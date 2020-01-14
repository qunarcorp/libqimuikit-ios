//
//  STIMButton.h
//  STIMUIVendorKit
//
//  Created by 李海彬 on 11/9/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    STIMButtonImageAlignmentLeft = 0,
    STIMButtonImageAlignmentTop,
    STIMButtonImageAlignmentBottom,
    STIMButtonImageAlignmentRight,
} STIMButtonImageAlignment;

@interface STIMButton : UIButton

/**
 *  按钮中图片的位置
 */
@property(nonatomic,assign) STIMButtonImageAlignment imageAlignment;
/**
 *  按钮中图片与文字的间距
 */
@property(nonatomic,assign)CGFloat spaceBetweenTitleAndImage;

@end

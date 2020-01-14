//
//  STIMMarginLabel.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/2/12.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMMarginLabel.h"

@interface STIMMarginLabel ()

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation STIMMarginLabel

#pragma mark -
#pragma mark - Init Methods & Superclass Overriders

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.width += self.edgeInsets.left + self.edgeInsets.right;
    sizeThatFits.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return sizeThatFits;
}

@end

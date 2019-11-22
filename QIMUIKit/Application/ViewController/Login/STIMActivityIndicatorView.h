//
//  DGActivityIndicatorView.h
//  DGActivityIndicatorExample
//
//  Created by Danil Gontovnik on 5/23/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@interface STIMActivityIndicatorView : UIView

- (id)initWithTintColor:(UIColor *)tintColor;
- (id)initWithTintColor:(UIColor *)tintColor size:(CGFloat)size;

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) CGFloat size;

@property (nonatomic, readonly) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;

@end

//
//  UIViewTap.h
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@protocol STIMMWTapDetectingViewDelegate;

@interface STIMMWTapDetectingView : UIView {}

@property (nonatomic, weak) id <STIMMWTapDetectingViewDelegate> tapDelegate;

@end

@protocol STIMMWTapDetectingViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end

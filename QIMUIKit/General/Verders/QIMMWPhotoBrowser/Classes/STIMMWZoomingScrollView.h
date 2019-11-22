//
//  ZoomingScrollView.h
//  STIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMWPhotoProtocol.h"
#import "STIMMWTapDetectingImageView.h"
#import "STIMMWTapDetectingView.h"

@class STIMMWPhotoBrowser, STIMMWPhoto, STIMMWCaptionView;

@interface STIMMWZoomingScrollView : UIScrollView <UIScrollViewDelegate, STIMMWTapDetectingImageViewDelegate, STIMMWTapDetectingViewDelegate> {

}

@property () NSUInteger index;
@property (nonatomic) id <STIMMWPhoto> photo;
@property (nonatomic, weak) STIMMWCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;

- (id)initWithPhotoBrowser:(STIMMWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

@end

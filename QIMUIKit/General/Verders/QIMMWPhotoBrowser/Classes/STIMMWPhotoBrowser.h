//
//  STIMMWPhotoBrowser.h
//  STIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMWPhoto.h"
#import "STIMMWPhotoProtocol.h"
#import "STIMMWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define STIMMWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define STIMMWLog(x, ...)
#endif

@class STIMMWPhotoBrowser;

@protocol STIMMWPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(STIMMWPhotoBrowser *)photoBrowser;
- (id <STIMMWPhoto>)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <STIMMWPhoto>)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (STIMMWCaptionView *)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser currentDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(STIMMWPhotoBrowser *)photoBrowser;

@end

@interface STIMMWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic, assign) BOOL notAutoHidenControls;
@property (nonatomic, weak) IBOutlet id<STIMMWPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableGrid;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL startOnGrid;
@property (nonatomic) BOOL autoPlayOnAppear;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, strong) UILabel   * indexLabel;//显示图片位置 如1/4
@property (nonatomic, strong) UIActivity *customActivity;

// Customise image selection icons as they are the only icons with a colour tint
// Icon should be located in the app's main bundle
@property (nonatomic, strong) NSString *customImageSelectedIconName;
@property (nonatomic, strong) NSString *customImageSelectedSmallIconName;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <STIMMWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end

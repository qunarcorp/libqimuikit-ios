//
//  STIMMWGridViewController.h
//  STIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import "STIMCommonUIFramework.h"
#import "STIMMWPhotoBrowser.h"

@interface STIMMWGridViewController : UICollectionViewController {}

@property (nonatomic, assign) STIMMWPhotoBrowser *browser;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint initialContentOffset;

- (void)adjustOffsetsAsRequired;

@end

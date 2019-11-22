//
//  STIMMWGridCell.h
//  STIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import "STIMCommonUIFramework.h"
#import "STIMMWPhoto.h"
#import "STIMMWGridViewController.h"

@interface STIMMWGridCell : UICollectionViewCell {}

@property (nonatomic, weak) STIMMWGridViewController *gridController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) id <STIMMWPhoto> photo;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL isSelected;

- (void)displayImage;

@end

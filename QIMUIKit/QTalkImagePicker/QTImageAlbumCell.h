//
//  QTImageAlbumCell.h
//  STChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "STIMCommonUIFramework.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface QTImageAlbumCell : UITableViewCell

+ (CGFloat)getCellHeight;

- (void)bind:(ALAssetsGroup *)assetsGroup;

@end

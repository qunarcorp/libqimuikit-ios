//
//  STIMCollectionViewCell.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/6/1.
//
//

#import "STIMCommonUIFramework.h"
#import "STIMEmotionTipDelegate.h"

@interface STIMCollectionViewCell : UICollectionViewCell <STIMEmotionTipDelegate>

- (void)refreshUIWithFlag:(BOOL)flag ;

- (void)setRefreshCount:(BOOL)refreshed;

@end

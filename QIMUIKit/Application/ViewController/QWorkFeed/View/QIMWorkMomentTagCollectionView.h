//
//  QIMWorkMomentTagCollectionView.h
//  QIMUIKit
//
//  Created by lilu on 2019/3/12.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentTagCollectionView : UICollectionView

@property (nonatomic, assign) NSInteger momentTag;

- (CGFloat)getWorkMomentTagCollectionViewHeight;

@end

NS_ASSUME_NONNULL_END

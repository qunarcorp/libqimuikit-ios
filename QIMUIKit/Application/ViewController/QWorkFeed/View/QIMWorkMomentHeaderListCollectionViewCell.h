//
//  QIMWorkMomentHeaderListCollectionViewCell.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^clickActBlock)(void);

@interface QIMWorkMomentHeaderListCollectionViewCell : UICollectionViewCell
@property (nonatomic , strong) UIImageView * imageView;

@property (nonatomic , copy) clickActBlock clickBlock;
@end

NS_ASSUME_NONNULL_END

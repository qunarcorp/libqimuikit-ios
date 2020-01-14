//
//  STIMEmotionTip.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/2/8.
//

#import "STIMCommonUIFramework.h"
#import "STIMFaceViewCell.h"
#import "STIMCollectionViewCell.h"

@interface QTalkShowAllEmojiTip : UIView

@property (nonatomic) STIMFaceViewCell *cell;

+ (instancetype)sharedTip;

- (void)showTipOnCell:(STIMFaceViewCell *)cell;

@end

@interface QTalkGifEmojiTip : UIView

@property (nonatomic) UICollectionViewCell *cell;

+ (instancetype)sharedTip;

- (void)showTipOnCell:(UICollectionViewCell *)cell;

@end

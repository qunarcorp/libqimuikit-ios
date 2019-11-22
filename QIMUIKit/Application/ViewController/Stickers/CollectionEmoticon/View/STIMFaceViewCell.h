//
//  STIMFaceViewCell.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "STIMCommonUIFramework.h"
#import "STIMEmotionView.h"
#import "STIMEmotionTipDelegate.h"

@interface STIMFaceViewCell : UICollectionViewCell <STIMEmotionTipDelegate>

@property (nonatomic, strong) UIImageView *emojiView;

@property (nonatomic, assign) QTalkEmotionType emotionType;

@property (nonatomic, copy) NSString *emojiPath;

- (CGPoint)tipFloatPoint;

@end

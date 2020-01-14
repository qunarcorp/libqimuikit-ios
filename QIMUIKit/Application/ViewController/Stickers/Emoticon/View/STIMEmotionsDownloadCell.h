//
//  STIMEmotionsDownloadCell.h
//  STChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "STIMCommonUIFramework.h"
#import "STIMEmotion.h"

@class STIMMyEmotionsManagerViewController;
@interface STIMEmotionsDownloadCell : UITableViewCell

@property (nonatomic, strong) STIMEmotion *emotion;
//@property (nonatomic, strong) STIMMyEmotionsManagerViewController *superVC;

//cell状态
- (void)setEmotionState:(EmotionState )state;

@end

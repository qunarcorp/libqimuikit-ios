//
//  STIMEmotionManagerView.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/7.
//

#import "STIMCommonUIFramework.h"

@protocol QTalkSTIMEmotionManagerDelegate <NSObject>

- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId isDelete:(BOOL)dele;

- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId;

- (void)SendTheCollectionFaceStr:(NSString *)faceStr;

- (void)didSelectFaildCollectionFace;

- (void)segmentBtnDidClickedAtIndex : (NSInteger)index;

@end

@interface STIMEmotionManagerView : UIView

@property (nonatomic, weak) id <QTalkSTIMEmotionManagerDelegate> delegate;

@property (nonatomic, copy) NSString *packageId;

- (instancetype)initWithFrame:(CGRect)frame WithPkId:(NSString *)packageId;

@end

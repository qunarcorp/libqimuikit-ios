//
//  QIMWorkMomentVideoView.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/31.
//

#import "QIMCommonUIFramework.h"
@class QIMVideoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol QIMWorkMomentVideoViewTapDelegate <NSObject>

- (void)didTapWorkMomentVideo:(QIMVideoModel *)videoModel;

@end

@interface QIMWorkMomentVideoView : UIView

@property (nonatomic, strong) QIMVideoModel *videoModel;

@property (nonatomic, weak) id <QIMWorkMomentVideoViewTapDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

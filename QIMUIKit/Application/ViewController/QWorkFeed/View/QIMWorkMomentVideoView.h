//
//  QIMWorkMomentVideoView.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/31.
//

#import "QIMCommonUIFramework.h"
@class QIMWorkMomentContentVideoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol QIMWorkMomentVideoViewTapDelegate <NSObject>

- (void)didTapWorkMomentVideo:(QIMWorkMomentContentVideoModel *)videoModel;

@end

@interface QIMWorkMomentVideoView : UIView

@property (nonatomic, strong) QIMWorkMomentContentVideoModel *videoModel;

@property (nonatomic, weak) id <QIMWorkMomentVideoViewTapDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

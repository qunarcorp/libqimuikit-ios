//
//  STIMWorkMomentVideoView.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/7/31.
//

#import "STIMCommonUIFramework.h"
@class STIMVideoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol STIMWorkMomentVideoViewTapDelegate <NSObject>

- (void)didTapWorkMomentVideo:(STIMVideoModel *)videoModel;

@end

@interface STIMWorkMomentVideoView : UIView

@property (nonatomic, strong) STIMVideoModel *videoModel;

@property (nonatomic, weak) id <STIMWorkMomentVideoViewTapDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

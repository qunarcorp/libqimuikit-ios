//
//  QIMWorkMomentLinkView.h
//  QIMUIKit
//
//  Created by lilu on 2019/5/19.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
@class QIMWorkMomentContentLinkModel;

NS_ASSUME_NONNULL_BEGIN

@protocol QIMWorkMomentLinkViewTapDelegate <NSObject>

- (void)didTapWorkMomentShareLinkUrl:(QIMWorkMomentContentLinkModel *)linkModel;

@end

@interface QIMWorkMomentLinkView : UIView

@property (nonatomic, strong) QIMWorkMomentContentLinkModel *linkModel;

@property (nonatomic, weak) id <QIMWorkMomentLinkViewTapDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

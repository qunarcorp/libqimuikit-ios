//
//  STIMWorkMomentLinkView.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/5/19.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
@class STIMWorkMomentContentLinkModel;

NS_ASSUME_NONNULL_BEGIN

@protocol STIMWorkMomentLinkViewTapDelegate <NSObject>

- (void)didTapWorkMomentShareLinkUrl:(STIMWorkMomentContentLinkModel *)linkModel;

@end

@interface STIMWorkMomentLinkView : UIView

@property (nonatomic, strong) STIMWorkMomentContentLinkModel *linkModel;

@property (nonatomic, weak) id <STIMWorkMomentLinkViewTapDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

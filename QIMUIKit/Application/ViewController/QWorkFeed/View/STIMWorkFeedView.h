//
//  STIMWorkFeedView.h
//  STIMUIKit
//
//  Created by lilu on 2019/4/29.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkFeedView : UIView

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, strong) UIViewController *rootVC;

-(instancetype)initWithFrame:(CGRect)frame
                      userId:(NSString *)userId
            showNewMomentBtn:(BOOL)showBtn
               showNoticView:(BOOL)showNtc;

- (void)updateMomentView;

@end

NS_ASSUME_NONNULL_END

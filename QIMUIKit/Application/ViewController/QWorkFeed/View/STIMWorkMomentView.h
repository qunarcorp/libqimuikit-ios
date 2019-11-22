//
//  STIMWorkMomentView.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/29.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMWorkMomentModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MomentViewDelegate <NSObject>

@optional

- (void)didClickSmallImage:(STIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag;

@end



@interface STIMWorkMomentView : UIView

@property (nonatomic, weak) id <MomentViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withMomentModel:(STIMWorkMomentModel *)model;

@property (nonatomic, strong) STIMWorkMomentModel *momentModel;

@end

NS_ASSUME_NONNULL_END

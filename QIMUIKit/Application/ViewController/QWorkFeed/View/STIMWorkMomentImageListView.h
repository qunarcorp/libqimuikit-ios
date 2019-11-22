//
//  STIMWorkMomentImageListView.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMWorkMomentContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkMomentImageListView : UIView

@property (nonatomic, strong) STIMWorkMomentContentModel *momentContentModel;

@property (nonatomic, copy) void (^tapSmallImageView)(STIMWorkMomentContentModel *momentContentModel, NSInteger currentTag);

@end

//### 单个小图显示视图
@interface STIMWorkMomentImageView : STIMImageView

- (void)downLoadImageWithModel:(NSString *)imageUrl withFitRect:(CGRect)frame withTotalCount:(NSInteger)totalCount;

// 点击小图
@property (nonatomic, copy) void (^tapSmallView)(STIMWorkMomentImageView *imageView);

@end

NS_ASSUME_NONNULL_END

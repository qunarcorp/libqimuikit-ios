//
//  STIMQuickReplyGroupCollectionView.h
//  STIMUIKit
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@protocol STIMQuickReplyGroupCollectionViewDelegate <NSObject>

@required
- (void)didSelectQuickReplyGroupItemAtIndex:(NSInteger)index;

@end

@interface STIMQuickReplyGroupCollectionView : UIView 

@property (nonatomic, weak) id <STIMQuickReplyGroupCollectionViewDelegate> quickReplyGroupDelegate;

@property (nonatomic, strong) NSArray *quickReplyGroup;

- (void)updateSelectItemAtIndexPath:(NSInteger)index;

@end

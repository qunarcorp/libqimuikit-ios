//
//  STIMWorkMomentPushViewFlowLayout.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/3.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentPushViewFlowLayout.h"

@implementation STIMWorkMomentPushViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        // 水平间隔
        self.minimumInteritemSpacing = kEmotionItemLineSpacing;
        
        // 上下垂直间隔
        self.minimumLineSpacing = kEmotionItemLineSpacing;
    }
    return self;
}

@end

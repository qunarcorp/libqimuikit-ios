//
//  STIMMWPhotoSectionBrowserLayout.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2018/12/12.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMMWPhotoSectionBrowserLayout.h"

@implementation STIMMWPhotoSectionBrowserLayout

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = CGSizeMake(SCREEN_WIDTH / 4.0, SCREEN_WIDTH / 4.0);
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.headerReferenceSize=CGSizeMake(SCREEN_WIDTH, 30);//头视图的大小
        self.sectionHeadersPinToVisibleBounds = YES;
    }
    return self;
}

@end

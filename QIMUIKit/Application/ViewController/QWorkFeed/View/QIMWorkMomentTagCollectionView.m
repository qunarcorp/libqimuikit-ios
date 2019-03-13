//
//  QIMWorkMomentTagCollectionView.m
//  QIMUIKit
//
//  Created by lilu on 2019/3/12.
//

#import "QIMWorkMomentTagCollectionView.h"

@interface QIMWorkMomentTagCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation QIMWorkMomentTagCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    }
    return self;
}

- (CGFloat)getWorkMomentTagCollectionViewHeight {
    [self layoutIfNeeded];
    return self.contentSize.height;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self getTrueValueIndexPaths] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *number = [[self getTrueValueIndexPaths] objectAtIndex:indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    if ([number integerValue] == 1) {
        [label setText:@"置顶"];
        [label setTextColor:[UIColor qim_colorWithHex:0x00CABE]];
        label.layer.borderColor = [UIColor qim_colorWithHex:0x00CABE].CGColor;
    } else if ([number integerValue] == 2) {
        [label setText:@"热帖"];
        [label setTextColor:[UIColor qim_colorWithHex:0xF9A539]];
        label.layer.borderColor = [UIColor qim_colorWithHex:0xF9A539].CGColor;
    } else {
        
    }
    [label setFont:[UIFont systemFontOfSize:11]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.layer.borderWidth = 1.0f;
    [cell addSubview:label];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (NSInteger)getValueAtBit {
    NSInteger n = self.momentTag;
    NSInteger count = 0;
    while (n > 0) {
        n = n & (n - 1);
        count ++;
    }
    return count;
}

- (NSArray *)getTrueValueIndexPaths {
    NSInteger n = self.momentTag;
    NSInteger count = 0;
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
    NSInteger num = [self getBitWidth];
    while (n > 0) {
        num --;
        if (n > 0 && num > 0) {
            [data addObject:@(num)];
        }
        n = n & (n - 1);
        count ++;
    }
    return data;
}

- (NSInteger)getBitWidth {
    NSInteger i = 0;
    NSInteger n = self.momentTag;
    do {
        ++i;
    } while ((n >> i));
    return i;
}

@end

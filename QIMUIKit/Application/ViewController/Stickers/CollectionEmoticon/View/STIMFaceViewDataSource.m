//
//  STIMFaceViewDataSource.m
//  STChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "STIMFaceViewDataSource.h"
#import "STIMFaceViewCell.h"
#import "STIMFaceView.h"
#import "STIMEmotionManager.h"

static NSString *cellID = @"cellID";

@interface STIMFaceViewDataSource ()

@end

@implementation STIMFaceViewDataSource

- (NSMutableArray *)devideEmojiList {
    
    if (!_devideEmojiList) {
        
        _devideEmojiList = [NSMutableArray array];
    }
    return _devideEmojiList;
}

+ (void)setInstanceCellIdentifier:(NSString *)cellIdentifier {
    
    cellID = cellIdentifier;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.devideEmojiList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 24;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STIMFaceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    /**
     *  计算cell排列方式让collectionView横向滚动，一行一行地去排列
     */
    NSInteger column = indexPath.row / kEmotionFaceLines;
    NSInteger newRow = (indexPath.row - column * kEmotionFaceLines) * kEmotionFaceNumPerLine + column;
    
    if (!cell.userInteractionEnabled) {
        
        cell.userInteractionEnabled = YES;
    }
    //如果不是最后一组并且row == 23时为删除按钮
    if ((indexPath.section!= self.devideEmojiList.count - 1) && newRow == (kEmotionFaceNumPerLine * kEmotionFaceLines - 1)) {
        
        cell.emojiView.image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"DeleteEmoticonBtn"];
        cell.tag = -1;
        [cell setAccessibilityIdentifier:@"-1"];
    } else if (indexPath.section == self.devideEmojiList.count - 1 && newRow == [self.devideEmojiList[indexPath.section] count]) {
        
        //如果是最后一组并且newRow = 该组最后一张时为删除按钮
        cell.emojiView.image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"DeleteEmoticonBtn"];
        cell.tag = -1;
        [cell setAccessibilityIdentifier:@"-1"];
    }   else {
        
        //
        if ([self.devideEmojiList[indexPath.section] count] > newRow) {
            
            NSString *imageStr = self.devideEmojiList[indexPath.section][newRow];
            
            imageStr = [[STIMEmotionManager sharedInstance] getImageAbsolutePathForRelativePath:imageStr];
            
            cell.emojiView.image = [[STIMEmotionManager sharedInstance] getEmotionThumbIconWithImageStr:imageStr BySize:CGSizeMake(FaceSize, FaceSize)];
            cell.tag = indexPath.section * (kEmotionFaceNumPerLine * kEmotionFaceLines - 1) + newRow ;
            [cell setAccessibilityIdentifier:[NSString stringWithFormat:@"%ld", indexPath.section * (kEmotionFaceNumPerLine * kEmotionFaceLines - 1) + newRow]];
        } else {
            
            cell.emojiView.image = [UIImage new];
            cell.userInteractionEnabled = NO;
        }
    }
    return cell;
}

/*
- (void)longPressAction:(UILongPressGestureRecognizer *)longPressGesture {
    
    STIMFaceViewCell *cell = (STIMFaceViewCell *)longPressGesture.view;
    if (cell.tag >= 0) {
        
        NSString * faceImagePath = [[[ STIMEmotionManager sharedInstance] getEmotionImagePathListForPackageId:[[STIMEmotionManager sharedInstance] currentPackageId]] objectAtIndex:cell.tag];
        switch (longPressGesture.state) {
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
                //移除Emoji预览框
                [self.popView removeFromSuperview];
                break;
            case UIGestureRecognizerStateChanged:
            case UIGestureRecognizerStateBegan:
                
                [self.popView showFrom:cell emojiGifPath:faceImagePath];
            default:
                break;
        }
    }
}
*/

@end

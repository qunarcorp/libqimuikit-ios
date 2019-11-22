//
//  STIMCollectionEmotionEditorViewCell.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/14.
//
//

#define kEmotionItemTagFrom     1000
#define kImageViewCap           15

#import "STIMCommonUIFramework.h"

@class STIMCollectionEmotionEditorViewCell;
@protocol STIMCollectionEmotionEditorViewDelegate <NSObject>

- (void)collectionEmotionEditorCell:(STIMCollectionEmotionEditorViewCell *)cell didClickedItemAtIndex:(NSInteger)index selected:(BOOL)selected;

@end

@interface STIMCollectionEmotionEditorViewCell : UICollectionViewCell

@property (nonatomic,assign) id <STIMCollectionEmotionEditorViewDelegate> editDelegate;

/**
 *  收藏的表情List
 */

@property (nonatomic, copy) id emotionItem;

@property (nonatomic, assign) BOOL canSelect;

@property (nonatomic, assign) NSInteger section;

@end

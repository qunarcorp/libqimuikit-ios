//
//  STIMFaceViewDataSource.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMFaceViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *devideEmojiList;

+ (void)setInstanceCellIdentifier:(NSString *)cellIdentifier;

@end

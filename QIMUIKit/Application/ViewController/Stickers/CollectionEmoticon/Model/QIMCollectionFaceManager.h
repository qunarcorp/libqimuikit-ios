//
//  QIMCollectionFaceManager.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/6.
//
//

#import "QIMCommonUIFramework.h"

#define kCollectionFaceListUpdateNotification @"kCollectionFaceListUpdateNotification"
#define kCollectionEmotionUpdateHandleFailedNotification @"kCollectionEmotionUpdateHandleFailedNotification"
#define kCollectionEmotionUpdateHandleSuccessNotification @"kCollectionEmotionUpdateHandleSuccessNotification"

#define CollectionFaceWidth 90
#define CollectionFaceHeight 90

@interface QIMCollectionFaceManager : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) NSMutableArray *collectionFaceList;

- (NSString *)getCollectionFaceHttpUrlWithIndex: (NSInteger) index;

- (NSArray *)getCollectionFaceList;

- (void)insertCollectionEmojiWithEmojiUrl:(NSString *)emojiUrl;

- (void) delCollectionFaceArr:(NSArray *)delAr;

- (void)resetCollectionItems:(NSArray *)items WithUpdate:(BOOL)updateFlag;

- (void)updateConfig;

- (void)checkForUploadLocalCollectionFace;

@end

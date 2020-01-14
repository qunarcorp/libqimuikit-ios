//
//  STIMEmotionSave.h
//  STChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#define kEmotionPathResource    @"EmotionPackageIdList"

#import "STIMCommonUIFramework.h"

@interface STIMEmotionSave : NSObject

+ (instancetype)sharedInstance;

- (void)saveEmotionDownloadData:(id)data;

/**
 *  字典转NSData
 *
 */
- (NSData *)returnDataWithDictionary:(NSDictionary *)dict;

- (NSString *)getEmotionInfoDataPath;

@end

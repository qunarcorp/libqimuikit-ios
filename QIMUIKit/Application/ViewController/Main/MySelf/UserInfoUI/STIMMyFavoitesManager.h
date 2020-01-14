//
//  STIMMyFavoitesManager.h
//  STChatIphone
//
//  Created by Qunar-Lu on 16/6/27.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMMyFavoitesManager : NSObject

+ (instancetype) sharedMyFavoritesManager;

- (void)setMyFavoritesArrayWithMsg:(STIMMessageModel *)message;

- (NSMutableArray *)myFavoritesArray;

@end

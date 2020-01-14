//
//  STIMEmotionSpirits.h
//  STChatIphone
//
//  Created by admin on 15/8/24.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMEmotionSpirits : NSObject
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) int dataCount;
+ (STIMEmotionSpirits *)sharedInstance;

- (void)playSTIMEmotionSpiritsWithMessage:(NSString *)message;

@end

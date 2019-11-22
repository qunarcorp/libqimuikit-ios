//
//  STIMNavBackBtn.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/16.
//

#import "STIMCommonUIFramework.h"

@interface STIMNavBackBtn : UIButton

+ (instancetype)sharedInstance;

- (void)updateNotReadCount:(NSInteger)appCount;

@end

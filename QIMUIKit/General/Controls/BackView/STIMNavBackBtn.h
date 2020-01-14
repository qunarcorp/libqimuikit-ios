//
//  STIMNavBackBtn.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/1/16.
//

#import "STIMCommonUIFramework.h"

@interface STIMNavBackBtn : UIButton

+ (instancetype)sharedInstance;

- (void)updateNotReadCount:(NSInteger)appCount;

@end

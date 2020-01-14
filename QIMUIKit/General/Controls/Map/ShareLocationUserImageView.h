//
//  ShareLocationUserImageView.h
//  STChatIphone
//
//  Created by haibin.li on 16/1/28.
//
//

#import "STIMCommonUIFramework.h"

@interface ShareLocationUserImageView :UIView

-(instancetype)initWithUserId:(NSString *)userId;

- (void)updateDirectionTo:(double)degrees;

@end

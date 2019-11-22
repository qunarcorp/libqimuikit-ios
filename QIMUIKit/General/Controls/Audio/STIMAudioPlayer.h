//
//  STIMAudioPlayer.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMAudioPlayer : UIView

@property (nonatomic, strong) NSString *audioPath;
@property (nonatomic, strong) NSString *audioName;

- (void)play;

@end

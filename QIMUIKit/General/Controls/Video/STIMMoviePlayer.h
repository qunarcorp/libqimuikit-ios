//
//  STIMMoviePlayer.h
//  STChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "STIMCommonUIFramework.h"

@class AVPlayerLayer;
@interface VideoView : UIView
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@end

@interface STIMMoviePlayer : UIView

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoName;

- (void) play;
- (void) stop;
- (void) resume;

@end

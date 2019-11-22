//
//  STIMRemoteAudioPlayer.h
//  QunarUGC
//
//  Created by 赵岩 on 12-10-25.
//
//

#import <AVFoundation/AVFoundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "STIMCommonUIFramework.h"

typedef enum
{
    STIMRemoteAudioPlayerLoadingFailure,
    STIMRemoteAudioPlayerPlayingFailure,
}STIMRemoteAudioPlayerErrorCode;

@class STIMRemoteAudioPlayer;

@protocol STIMRemoteAudioPlayerDelegate<NSObject>

- (void)downloadProgress:(float)newProgress;

- (void)remoteAudioPlayerReady:(STIMRemoteAudioPlayer *)player;

- (void)remoteAudioPlayerDidStartPlaying:(STIMRemoteAudioPlayer *)player;

- (void)remoteAudioPlayerDidFinishPlaying:(STIMRemoteAudioPlayer *)player;

- (void)remoteAudioPlayerErrorOccured:(STIMRemoteAudioPlayer *)player withErrorCode:(STIMRemoteAudioPlayerErrorCode)errorCode;

@end

@interface STIMRemoteAudioPlayer : NSObject <ASIHTTPRequestDelegate, AVAudioPlayerDelegate>

@property (nonatomic, assign) id<STIMRemoteAudioPlayerDelegate> delegate;

- (BOOL)ready;

- (BOOL)playing;

- (BOOL)play;

- (void)stop;

- (void)pause;

- (NSTimeInterval)currentTime;

- (void)prepareForURL:(NSString *)url playAfterReady:(BOOL)playAfterReady;

- (void)prepareForFilePath:(NSString *)filePath playAfterReady:(BOOL)playAfterReady;

- (void)prepareForWavFilePath:(NSString *)filePath playAfterReady:(BOOL)playAfterReady;

- (void)prepareForFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl playAfterReady:(BOOL)playAfterReady;

@end

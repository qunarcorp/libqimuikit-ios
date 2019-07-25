//
//  QIMVideoMediaPlayerVC.m
//  QIMUIKit
//
//  Created by lilu on 2019/7/19.
//

#import "QIMVideoMediaPlayerVC.h"

//#import "MobileVLCKit.h"

@interface QIMVideoMediaPlayerVC () /*<VLCMediaPlayerDelegate>*/
/*
@property (nonatomic, strong) VLCMediaPlayer *player; //播放器
@property (nonatomic, strong) UIView *playView;   //展示的View
*/
@end

@implementation QIMVideoMediaPlayerVC

    /*
- (UIView *)playView
    {
        if(!_playView){
            _playView = [[UIView alloc] initWithFrame:CGRectMake(30, 100, 300, 300)];
            _playView.backgroundColor = [UIColor yellowColor];
            [self.view addSubview:_playView];
        }
        return _playView;
    }
    
- (VLCMediaPlayer *)player
    {
        if(!_player){
            _player = [[VLCMediaPlayer alloc]init];
            _player.delegate = self;
        }
        return _player;
    }
 */
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    /*
    VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:@"http://qim.qunar.com/file/v2/download/temp/new/ef867ffde25e68a6f75a95124172507e?name=ef867ffde25e68a6f75a95124172507e.mp4"]];
    self.player.drawable = self.playView;
    self.player.media = media;
    [self.player play];
    */
    // Do any additional setup after loading the view.
}

@end

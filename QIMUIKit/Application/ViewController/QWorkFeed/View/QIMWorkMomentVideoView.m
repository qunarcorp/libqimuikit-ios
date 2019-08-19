//
//  QIMWorkMomentVideoView.m
//  QIMUIKit
//
//  Created by lilu on 2019/7/31.
//

#import "QIMWorkMomentVideoView.h"
#import "QIMVideoModel.h"

@interface QIMWorkMomentVideoView ()

@property (nonatomic, strong) UIImageView *thubImgView;

@property (nonatomic, strong) UIImageView *playImgView;

@property (nonatomic, strong) UILabel *videoDurationLabel;

@end

@implementation QIMWorkMomentVideoView

#pragma mark - setter and getter

- (UIImageView *)thubImgView {
    if (!_thubImgView) {
        _thubImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thubImgView.backgroundColor = [UIColor whiteColor];
//        _thubImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _thubImgView;
}

- (UIImageView *)playImgView {
    if (!_playImgView) {
        _playImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _playImgView.frame = CGRectMake(0, 0, 36, 36);
        _playImgView.layer.cornerRadius = 18.0f;
        _playImgView.layer.masksToBounds = YES;
        _playImgView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"q_work_video_play"];
    }
    return _playImgView;
}

- (UILabel *)videoDurationLabel {
    if (!_videoDurationLabel) {
        _videoDurationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _videoDurationLabel.text = @"02:30";
    }
    return _videoDurationLabel;
}

- (void)setVideoModel:(QIMVideoModel *)videoModel {
    _videoModel = videoModel;
    [self.thubImgView qim_setImageWithURL:[NSURL URLWithString:videoModel.ThumbUrl] placeholderImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"PhotoDownloadPlaceHolder"]];
}

#pragma mark - initUI

- (void)initUI {
    [self addSubview:self.thubImgView];
    [self.thubImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(144);
        make.top.left.mas_equalTo(0);
    }];
    [self addSubview:self.playImgView];

    [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.width.mas_equalTo(36);
        make.centerX.mas_equalTo(self.thubImgView.mas_centerX);
        make.centerY.mas_equalTo(self.thubImgView.mas_centerY);
    }];
    
//    [self addSubview:self.videoDurationLabel];
//    [self.videoDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.thubImgView.mas_right).mas_offset(-20);
//        make.width.mas_equalTo(60);
//        make.height.mas_equalTo(20);
//        make.bottom.mas_equalTo(self.thubImgView.mas_bottom).mas_offset(-20);
//    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWorkMomentVideo)];
    [self addGestureRecognizer:tap];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        self.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
        
    }
    return self;
}

- (void)tapWorkMomentVideo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapWorkMomentVideo:)]) {
        [self.delegate didTapWorkMomentVideo:self.videoModel];
    }
}

@end

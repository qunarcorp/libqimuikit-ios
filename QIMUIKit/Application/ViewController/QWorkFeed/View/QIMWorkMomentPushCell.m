//
//  QIMWorkMomentPushCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentPushCell.h"

@interface QIMWorkMomentPushCell ()

//上传图片进度条
@property (nonatomic, strong) UIView    *uploadPropressView;
@property (nonatomic, strong) UILabel   *uploadProgressLabel;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIButton *playButton;

@end

@implementation QIMWorkMomentPushCell

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 5 - 18, 5, 18, 18);
        _deleteBtn.layer.cornerRadius = 9;
        _deleteBtn.layer.masksToBounds = YES;
        [_deleteBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e33c" size:18 color:[UIColor qim_colorWithHex:0x000000 alpha:0.5]]] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(removePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(0, 0, 36, 36);
        _playButton.layer.cornerRadius = 18.0f;
        _playButton.layer.masksToBounds = YES;
        [_playButton setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"q_work_video_play"] forState:UIControlStateNormal];
//        [_playButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e33c" size:18 color:[UIColor qim_colorWithHex:0x000000 alpha:0.5]]] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)setCanDelete:(BOOL)canDelete {
    if (canDelete == NO) {
        self.deleteBtn.hidden = YES;
    } else {
        self.deleteBtn.hidden = NO;
        [self.contentView addSubview:self.deleteBtn];
    }
}

- (void)setMediaType:(QIMWorkMomentMediaType)mediaType {
    if (mediaType == QIMWorkMomentMediaTypeVideo) {
        self.playButton.hidden = NO;
        [self.contentView addSubview:self.playButton];
        self.playButton.center = self.contentView.center;
    } else {
        _playButton.hidden = YES;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        self.canDelete = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listUploadProgress:) name:kQIMUploadImageProgress object:nil];
    }
    return self;
}

- (void)removePhoto:(id)sender {
    if (self.dDelegate && [self.dDelegate respondsToSelector:@selector(removeSelectPhoto:)]) {
        [self.dDelegate removeSelectPhoto:self];
    }
}

- (void)playVideo:(id)sender {
    if (self.dDelegate && [self.dDelegate respondsToSelector:@selector(playSelectVideo:)]) {
        [self.dDelegate playSelectVideo:self];
    }
}

- (void)initUploadProgressView {
    self.uploadPropressView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.left, self.contentView.top, self.contentView.width, self.contentView.height)];
    self.uploadPropressView.backgroundColor = [UIColor lightGrayColor];
    self.uploadPropressView.alpha = 0.5;
    self.uploadPropressView.hidden = YES;
    [self.contentView addSubview:self.uploadPropressView];
    
    self.uploadProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _uploadPropressView.width, _uploadPropressView.height)];
    [self.uploadProgressLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.uploadProgressLabel setBackgroundColor:[UIColor clearColor]];
    [self.uploadProgressLabel setText:@""];
    [self.uploadProgressLabel setTextAlignment:NSTextAlignmentCenter];
    [self.uploadProgressLabel setTextColor:[UIColor whiteColor]];
    [self.uploadPropressView addSubview:self.uploadProgressLabel];
}

- (void)listUploadProgress:(NSNotification *)notify {
    NSDictionary *imageUploadProgressDic = notify.object;
    //    @{@"ImageUploadKey":localImageKey, @"ImageUploadProgress":@(1.0)}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *imageUploadKey = [imageUploadProgressDic objectForKey:@"ImageUploadKey"];
        if ([imageUploadKey isEqualToString:self.mediaMd5]) {
            if (!_uploadPropressView) {
                [self initUploadProgressView];
            }
            NSLog(@"upload Notify : %@", notify);
            float progressValue = [[imageUploadProgressDic objectForKey:@"ImageUploadProgress"] floatValue];
            if (progressValue < 1.0 && progressValue > 0.0) {
                self.uploadPropressView.frame = CGRectMake(self.contentView.left, self.contentView.top, self.contentView.width, self.contentView.height * (1 - progressValue));
                NSString *str = [NSString stringWithFormat:@"%d%%",(int)(progressValue * 100)];
                [self.uploadProgressLabel setText:str];
                [self.uploadPropressView setHidden:NO];
            } else {
                [self.uploadPropressView setHidden:YES];
            }
        }
    });
}

@end

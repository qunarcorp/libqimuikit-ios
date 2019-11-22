//
//  STIMWorkMomentPushCell.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentPushCell.h"

@interface STIMWorkMomentPushCell ()

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIButton *playButton;

@end

@implementation STIMWorkMomentPushCell

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 5 - 18, 5, 18, 18);
        _deleteBtn.layer.cornerRadius = 9;
        _deleteBtn.layer.masksToBounds = YES;
        [_deleteBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e33c" size:18 color:[UIColor stimDB_colorWithHex:0x000000 alpha:0.5]]] forState:UIControlStateNormal];
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
        [_playButton setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"q_work_video_play"] forState:UIControlStateNormal];
//        [_playButton setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e33c" size:18 color:[UIColor stimDB_colorWithHex:0x000000 alpha:0.5]]] forState:UIControlStateNormal];
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

- (void)setMediaType:(STIMWorkMomentMediaType)mediaType {
    if (mediaType == STIMWorkMomentMediaTypeVideo) {
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

@end

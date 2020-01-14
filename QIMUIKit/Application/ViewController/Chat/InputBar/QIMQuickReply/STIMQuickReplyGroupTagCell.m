//
//  STIMQuickReplyGroupTagCell.m
//  STIMUIKit
//
//  Created by 李海彬 on 2018/8/8.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import "STIMQuickReplyGroupTagCell.h"

@implementation STIMQuickReplyGroupTagCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        self.tagLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.tagLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    
    if (selected) {
        self.contentView.backgroundColor = [UIColor stimDB_colorWithHex:0x15b0f9 alpha:1.0];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

@end

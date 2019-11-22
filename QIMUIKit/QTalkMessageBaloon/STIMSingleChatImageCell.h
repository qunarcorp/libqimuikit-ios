//
//  STIMSingleChatImageCell.h
//  DangDiRen
//
//  Created by ping.xue on 14-3-27.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMsgBaloonBaseCell.h"
@class STIMMessageModel;

@protocol STIMSingleChatImageCellDelegate <NSObject>
@optional
- (void)openBigPhoto:(UIImage *)image FromRect:(CGRect)rect;
- (void)openBigPhotoUrl:(NSString *)imageUrl FromRect:(CGRect)rect;
@end

@interface STIMSingleChatImageCell : STIMMsgBaloonBaseCell
 
@property (nonatomic, weak) id<STIMSingleChatImageCellDelegate, STIMMsgBaloonBaseCellDelegate> delegate;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end

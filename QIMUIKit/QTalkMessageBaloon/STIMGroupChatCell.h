//
//  STIMGroupChatCell.h
//  STChatIphone
//
//  Created by wangshihai on 14/12/17.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMsgBaloonBaseCell.h"
#define kTextLabelTag       9999

@class STIMMessageModel;

@protocol STIMGroupChatCellDelegate <NSObject>
@required

- (void)processEvent:(int) event withMessage:(id) message;

- (NSUInteger)getColorHex:(NSString *)text;

@end

@interface STIMGroupChatCell : STIMMsgBaloonBaseCell

@property (nonatomic, weak) id <STIMGroupChatCellDelegate, STIMMsgBaloonBaseCellDelegate> delegate;

- (NSInteger)indexForCellImagesAtLocation:(CGPoint)location;

@end

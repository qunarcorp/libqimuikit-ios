//
//  STIMWorkMessageCell.h
//  STIMUIKit
//
//  Created by lilu on 2019/1/17.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMWorkNoticeMessageModel.h"
#import "STIMWorkMomentContentModel.h"

typedef enum : NSUInteger {
    STIMWorkMomentCellTypeMyMessage = 0,
    STIMWorkMomentCellTypeMyPOST = 1,
    STIMWorkMomentCellTypeMyREPLY,
    STIMWorkMomentCellTypeMyAT,
} STIMWorkMomentCellType;

NS_ASSUME_NONNULL_BEGIN

@interface STIMWorkMessageCell : UITableViewCell

@property (nonatomic, strong) STIMWorkNoticeMessageModel *noticeMsgModel;

@property (nonatomic, strong) STIMWorkMomentContentModel *contentModel;

@property (nonatomic, assign) STIMWorkMomentCellType cellType;

@end

NS_ASSUME_NONNULL_END

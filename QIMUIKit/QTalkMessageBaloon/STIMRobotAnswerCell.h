//
//  STIMRobotAnswerCell.h
//  STIMUIKit
//
//  Created by 李海彬 on 11/9/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMsgBaloonBaseCell.h"

@protocol STIMRobotAnswerCellLoadDelegate <NSObject>

- (void)refreshRobotAnswerMessageCell:(STIMMsgBaloonBaseCell *)cell;

- (void)reTeachRobot;

@end

@interface STIMRobotAnswerCell : STIMMsgBaloonBaseCell

@property (nonatomic, weak) id<STIMRobotAnswerCellLoadDelegate,STIMMsgBaloonBaseCellDelegate> delegate;

@end

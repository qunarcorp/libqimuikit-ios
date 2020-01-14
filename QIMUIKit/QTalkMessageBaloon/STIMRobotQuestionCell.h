//
//  QCIMConsultCell.h
//  IMSDK
//
//  Created by haibin.li on 2017/08/08.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMMsgBaloonBaseCell.h"

@protocol STIMRobotQuestionCellDelegate <NSObject>

/* 发送文本消息 */
- (void) sendTextMessageForText:(NSString *)messageContent isSendToServer:(BOOL)isSendToServer userType:(NSString *)userType;

/* 刷新该语音消息cell */
- (void) refreshRobotQuestionMessageCell:(STIMMsgBaloonBaseCell *)cell;

@end

@interface STIMRobotQuestionCell : STIMMsgBaloonBaseCell

@property (nonatomic, weak) id<STIMRobotQuestionCellDelegate,STIMMsgBaloonBaseCellDelegate> delegate;

+ (float)cellHeightForMessage:(STIMMessageModel *)msg chatType:(ChatType)chatType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithChatType:(ChatType)chatType;


@end

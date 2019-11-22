//
//  STIMChatRobotQuestionListTableViewCell.h
//  STIMUIKit
//
//  Created by qitmac000645 on 2019/8/28.
//

#import "STIMCommonUIFramework.h"
#import "STIMMsgBaloonBaseCell.h"


NS_ASSUME_NONNULL_BEGIN

@protocol STIMChatRobotQuestionListCellDelegate <NSObject>

/* 发送文本消息 */
- (void) sendSTIMChatRobotQusetionListTextMessageForText:(NSString *)messageContent isSendToServer:(BOOL)isSendToServer userType:(NSString *)userType;

/* 刷新该语音消息cell */
- (void) refreshSTIMChatRobotListQuestionMessageCell:(STIMMsgBaloonBaseCell *)cell;

@end

@interface STIMChatRobotQuestionListTableViewCell : STIMMsgBaloonBaseCell


@property (nonatomic, weak) id<STIMChatRobotQuestionListCellDelegate,STIMMsgBaloonBaseCellDelegate> delegate;

+ (float)cellHeightForMessage:(STIMMessageModel *)msg chatType:(ChatType)chatType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithChatType:(ChatType)chatType;


@end

NS_ASSUME_NONNULL_END

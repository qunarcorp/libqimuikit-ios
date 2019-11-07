//
//  QtalkSessionModel.h
//
//  Created by qitmac000645 on 2019/5/27.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QtalkSessionModel : NSObject
@property (nonatomic, copy) NSNumber * MsgDirection;
@property (nonatomic, copy) NSString * Content;
@property (nonatomic, copy) NSString * Name;
@property (nonatomic, copy) NSString * LastMsgId;
@property (nonatomic, copy) NSString * HeaderSrc;
@property (nonatomic, copy) NSString * UserId;
@property (nonatomic, copy) NSString * XmppId;
@property (nonatomic, copy) NSNumber * Reminded;
@property (nonatomic, copy) NSNumber * MsgDateTime;
@property (nonatomic, copy) NSString * MsgFrom;
@property (nonatomic, copy) NSNumber * MsgType;
@property (nonatomic, copy) NSNumber * MsgState;
@property (nonatomic, copy) NSNumber * ChatType;
@property (nonatomic, copy) NSNumber * UnreadCount;
@property (nonatomic, copy) NSNumber * StickState;
@property (nonatomic, copy) NSString * RealJid;


//UI property
@property (nonatomic, copy) NSString * combineJid;
@property (nonatomic, copy) NSString * headerImgUrl;
@property (nonatomic, copy) NSString * chatTitle;
@property (nonatomic, copy) NSString * contentMsg;
@property (nonatomic, copy) NSString * redDoteCount;
@property (nonatomic, copy) NSString * time;
@property (nonatomic, assign) BOOL topPut;
@property (nonatomic, assign) NSInteger notReadCount;

- (void)generateCombineJidWithChatType:(ChatType)chatType;
@end

NS_ASSUME_NONNULL_END

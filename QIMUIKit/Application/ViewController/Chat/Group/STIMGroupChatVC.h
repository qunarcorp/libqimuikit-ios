//
//  STIMGroupChatVC.h
//  STChatIphone
//
//  Created by wangshihai on 14/12/13.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//
 
#import "STIMCommonUIFramework.h"

@interface STIMGroupChatVC : QTalkViewController

@property (nonatomic, strong) NSDictionary *groupCardDic;
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *bindId;
@property (nonatomic, assign) ChatType chatType;
@property (nonatomic, assign) BOOL netWorkSearch;   //网络搜索聊天记录会话VC
@property (nonatomic, assign) BOOL needShowNewMsgTagCell;
@property (nonatomic, assign) long long readedMsgTimeStamp;
@property (nonatomic, assign) long long fastMsgTimeStamp;   //搜索时候快速点击跳转的消息时间戳
@property (nonatomic, assign) int notReadCount;

- (void)sendImageData:(NSData *)imageData;

- (void)refreshTableViewCell:(UITableViewCell * )cell;

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType;
- (void)sendText:(NSString *)text;
@end
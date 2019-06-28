//
//  QTalkSessionDataManager.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/5/27.
//

#import "QTalkSessionDataManager.h"
#import "QtalkSessionModel.h"
#import "QIMNewSessionScrollDelegate.h"

@interface QTalkSessionDataManager() <QIMNewSessionScrollDelegate>

@property (nonatomic , strong) NSMutableArray * dataSource;

@end

@implementation QTalkSessionDataManager


static QTalkSessionDataManager * manager = nil;
+(instancetype)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray array];
        [self registerSessionViewNotification];//[self registerCellNotification];
       
    }
    return self;
}

-(void)registCellNotification{
     [self registerCellNotification];
}

- (void)registerSessionViewNotification{
    //刷新数据源
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeRefreshDataSource:) name:kNotificationSessionListUpdate object:nil];
    //刷新数据源
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeRefreshDataSource:) name:kNotificationSessionListRemove object:nil];
    //刷新数据源
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeRefreshDataSource:) name:kNotificationCurrentFontUpdate object:nil];
}


//cell 刷新数据源
- (void)registerCellNotification
{
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellNotReadCount:) name:kMsgNotReadCountChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRemindState:) name:kRemindStateChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellHeaderImage:) name:kUserHeaderImgUpdate object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellUserStatusChange:) name:kUserStatusChange object:nil];
    
//    todo 这个userStatusChange 通知没有找到发通知的源头
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellMessage:) name:kNotificationMessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupNickName:) name:kGroupNickNameChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState:) name:kNotifyUserOnlineStateUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revokeMsgNotificationHandle:) name:kRevokeMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markNameUpdate:) name:kMarkNameUpdate object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(atallChangeHandle:) name:kAtALLChange object:nil];
    //此通知未找到发出源，暂不作处理
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(atallChangeHandle:) name:kAtMeChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupNotMindState:) name:kGroupMsgRemindDic object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupNickName:) name:kCollectionGroupNickNameChanged object:nil];
    
// 代收群名称
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:kUserVCardUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:kCollectionUserVCardUpdate object:nil];
}

- (NSInteger)count{
    return self.dataSource.count;
}

-(void)addDataModel:(QtalkSessionModel *)model{
    [self.dataSource addObject:model];
}

-(void)removeAllData{
    [self.dataSource removeAllObjects];
}

-(NSMutableArray *)getSessionList{
    return self.dataSource;
}

- (void)deleteModelFromSessionListWithIndex:(NSInteger)index{
    [self.dataSource removeObjectAtIndex:index];
}

-(void)setListWithModels:(NSMutableArray *)modelArrs{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:modelArrs.mutableCopy];
}

#pragma mark  通知方法
//刷新数据源
- (void)noticeRefreshDataSource:(NSNotification *)notifi{
    if (self.qtBlock) {
        self.qtBlock();
    }
}

//更新未读数
- (void)updateCellNotReadCount:(NSNotification *)notify{
    if (notify) {

        if (self.qtBlock) {
            self.qtBlock();
        }
//        NSDictionary *notifyDic = notify.object;
//        BOOL ForceRefresh = [[notifyDic objectForKey:@"ForceRefresh"] boolValue];
//        NSString *xmppId = [notifyDic objectForKey:@"XmppId"];
//        NSString *notifyRealJid = [notifyDic objectForKey:@"RealJid"];
//        if (ForceRefresh) {
//            if (self.qtBlock) {
//                self.qtBlock();
//            }
//        }
//        else if(xmppId && xmppId.length > 0 && notifyRealJid && notifyRealJid.length>0){
//            QtalkSessionModel * model = [QtalkSessionModel yy_modelWithDictionary:notify.object];
//            [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                QtalkSessionModel * tempModel = obj;
//                if ([model.XmppId isEqualToString:tempModel.XmppId]) {
//                    tempModel.notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:tempModel.XmppId WithRealJid:tempModel.RealJid withChatType:tempModel.ChatType.integerValue];
//                    //refresh 操作
//
//                    stop = YES;
//                }
//            }];
//        }
//    }
//    else{
//
    }
}

- (void)updateRemindState:(NSNotification *)notify{
    if (notify) {
        if (self.qtBlock) {
            self.qtBlock();
        }
    }
}

//刷新某个cell的头像
- (void)updateCellHeaderImage:(NSNotification *)notify{
    if (notify) {
        NSString *xmppId = [notify object];
        if (self.qtBlock) {
            self.qtBlock();
        }
//        if (self.delegate && [self.delegate respondsToSelector:@selector(updateModelAtIndexPath:)]) {
//            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//            [self.delegate updateModelAtIndexPath:indexPath];
//        }
//        if (xmppId && xmppId.length >0)
//        {
//            [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                QtalkSessionModel * model =obj;
//                if ([model.XmppId isEqualToString:xmppId]) {
//                    //todo refresh Cell header;
//
//                    stop = YES;
//                }
//            }];
//        }
    }
}

//刷新单个cell
- (void)updateCellMessage:(NSNotification *)notify{
    if (notify) {
        if (self.qtBlock) {
            self.qtBlock();
        }
//        NSString * xmppId = notify.object;
//        QIMMessageModel *msg = (QIMMessageModel *)[notify.userInfo objectForKey:@"message"];
//        if (xmppId && xmppId.length > 0 && msg) {
//            [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                QtalkSessionModel * model = obj;
//                if ([model.XmppId isEqualToString:xmppId]) {
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(updateModelAtIndexPath:)]) {
//                        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//                        [self.delegate updateModelAtIndexPath:indexPath];
//                    }
//                    stop = YES;
//                }
//            }];
            //todo refresh DataSourceCell;
//            if (self.delegate && [self.delegate respondsToSelector:@selector(updateModelAtIndexPath:)]) {
//                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//                [self.delegate updateModelAtIndexPath:indexPath];
//            }
//        }
    }
}

//更新群昵称
- (void)updateGroupNickName:(NSNotification *)notify{
    if (notify) {
        NSArray *groupIds = [notify object];
        if (groupIds && [groupIds isKindOfClass:[NSArray class]]) {
            //更新cell的群名称
            if (self.qtBlock) {
                self.qtBlock();
            }
        }
    }
}


//更新在线时间
- (void)updateOnlineState:(NSNotification *)notify{
    if (notify) {
        NSArray *userIds = notify.object;
        //更新cell的在线状态
        if (self.qtBlock) {
            self.qtBlock();
        }
    }
}

//销毁一个消息
- (void)revokeMsgNotificationHandle:(NSNotification *)notify{
    if (notify) {
        NSString *xmppID = notify.object;
        if (self.qtBlock) {
            self.qtBlock();
        }
//        [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            QtalkSessionModel * tempModel = obj;
//            if ([tempModel.XmppId isEqualToString:xmppID]) {
//                //todo fefresh the Cell;
//                stop = YES;
//            }
//        }];
//        if ([jid isEqualToString:self.jid]) {
//            NSString *revokeMsg = [notify.userInfo objectForKey:@"Content"];
//            NSDictionary *revokeMsgDic = [[QIMJSONSerializer sharedInstance] deserializeObject:revokeMsg error:nil];
//            if (revokeMsgDic.count > 0) {
//                NSString *messageId = [revokeMsgDic objectForKey:@"messageId"];
//                NSString *userJid = [revokeMsgDic objectForKey:@"fromId"];
//                NSString *message = [revokeMsgDic objectForKey:@"message"];
//                message = @"撤回了一条消息";
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//                    NSDictionary * userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userJid];
//                    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userJid];
//                    if (!remarkName) {
//                        remarkName = [userInfo objectForKey:@"Name"];
//                    }
//                    NSString *newContent = nil;
//                    if ([userJid isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
//                        newContent = [NSString stringWithFormat:@"你%@", message];
//                    } else {
//                        newContent = [NSString stringWithFormat:@"\"%@\"%@", remarkName ? remarkName : [[userJid componentsSeparatedByString:@"@"] firstObject], message];
//                    }
//                    if (newContent.length > 0) {
//                        NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithDictionary:_infoDic];
//                        [tempDic setQIMSafeObject:newContent forKey:@"Content"];
//                        [tempDic setQIMSafeObject:messageId forKey:@"LastMsgId"];
//                        [tempDic setQIMSafeObject:@(QIMMessageType_Revoke) forKey:@"MsgType"];
//                        _infoDic = tempDic;
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.contentLabel setText:newContent];
//                        });
//                    }
//                });
//            }
//        }
    }
}


- (void)markNameUpdate:(NSNotification *)notify
{
    if (notify) {
        if (self.qtBlock) {
            self.qtBlock();
        }
//        NSDictionary * info = notify.object;
//        [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            QtalkSessionModel * model = obj;
//            if ([info[@"jid"] isEqualToString:model.XmppId]) {
//                //to do refreshCell;
//
//            }
//        }];
    }
}

- (void)atallChangeHandle:(NSNotification *)notify{
    if (notify) {
        NSString * xmppid = notify.object;
        if (self.qtBlock) {
            self.qtBlock();
        }
//        [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            QtalkSessionModel * model = obj;
//            if ([notify.object isEqualToString:model.XmppId]) {
//                //todo refresh UI;
//                if (self.delegate && [self.delegate respondsToSelector:@selector(updateModelAtIndexPath:)]) {
//                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//                    [self.delegate updateModelAtIndexPath:indexPath];
//                }
//                stop = YES;
//            }
//        }];
    }
}

//更新群未读数
- (void)updateGroupNotMindState:(NSNotification *)notify{
    if (notify) {
        if (self.qtBlock) {
            self.qtBlock();
        }
//        NSString *groupJid = notify.object;
//        [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            QtalkSessionModel * model =obj;
//            if ([model.XmppId isEqualToString:groupJid]) {
//                //refresh cell;
////                if (self.delegate && [self.delegate respondsToSelector:@selector(updateModelAtIndexPath:)]) {
////                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
////                    [self.delegate updateModelAtIndexPath:indexPath];
////                }
//                stop = YES;
//            }
//        }];
    }
}

//更新Cell全部内容
- (void)updateUI:(NSNotification *)notify{
  
    if (notify) {
        if (self.qtBlock) {
            self.qtBlock();
        }
//        NSArray *array = notify.object;
//        [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            QtalkSessionModel * model = obj;
//            for (int i = 0; i<array.count; i++) {
//                if ([model.XmppId isEqualToString:array[i]]) {
//                     //刷新cell
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(updateModelAtIndexPath:)]) {
//                        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//                        [self.delegate updateModelAtIndexPath:indexPath];
//                    }
//                }
//            }
//        }];
    }
}

- (NSString *)gsswithCHatType:(ChatType)chatType WithXmppId:(NSString *)xmppJid withRealJid:(NSString *)realJid {
    NSString *combineJid = nil;
    switch (chatType) {
        case ChatType_ConsultServer: {
            combineJid = [NSString stringWithFormat:@"%@<>%@", xmppJid, realJid];
        }
            break;
        default: {
            combineJid = [NSString stringWithFormat:@"%@<>%@", xmppJid, xmppJid];
        }
            break;
    }
    return combineJid;
}

#pragma mark - QIMSessionScrollDelegate

//置顶会话
- (void)qimStickySession:(NSIndexPath *)indexPath {
    
    QtalkSessionModel *sessionModel = [self.dataSource objectAtIndex:indexPath.row];
    ChatType chatType = [sessionModel.ChatType integerValue];
    NSString *xmppJid =  sessionModel.XmppId;
    NSString *realJid = sessionModel.RealJid;
    NSString *combineJid = [self gsswithCHatType:chatType WithXmppId:xmppJid withRealJid:realJid];
    NSDictionary *dict = @{@"topType":@(![[QIMKit sharedInstance] isStickWithCombineJid:combineJid]), @"chatType":@(chatType)};
    NSString *value = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    [[QIMKit sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:value WithDel:[[QIMKit sharedInstance] isStickWithCombineJid:combineJid]];
}

- (void)deleteStick:(NSIndexPath *)indexPath {
    QtalkSessionModel *sessionModel = [self.dataSource objectAtIndex:indexPath.row];
    ChatType chatType = [sessionModel.ChatType integerValue];
    NSString *xmppJid =  sessionModel.XmppId;
    NSString *realJid = sessionModel.RealJid;
    NSString *combineJid = [self gsswithCHatType:chatType WithXmppId:xmppJid withRealJid:realJid];
    
    NSDictionary *dict = @{@"topType":@(NO), @"chatType":@(chatType)};
    NSString *value = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    [[QIMKit sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:value WithDel:YES];
}

//删除会话
- (void)qimDeleteSession:(NSIndexPath *)indexPath {
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataSource];
    if (indexPath.row < [tempArray count]) {
        QtalkSessionModel *sessionModel = [self.dataSource objectAtIndex:indexPath.row];
        ChatType chatType = [sessionModel.ChatType integerValue];
        NSString *sid =  sessionModel.XmppId;
        NSString *realJid = sessionModel.RealJid;
        if (sid && (chatType != ChatType_Consult && chatType != ChatType_ConsultServer)) {
            [self deleteStick:indexPath];
            [[QIMKit sharedInstance] removeSessionById:sid];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.qtBlock) {
                    self.qtBlock();
                }
            });
        } else {
            [[QIMKit sharedInstance] removeConsultSessionById:sid RealId:realJid];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.qtBlock) {
                    self.qtBlock();
                }
            });
        }
    }
}

@end

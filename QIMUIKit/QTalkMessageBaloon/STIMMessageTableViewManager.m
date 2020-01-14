//
//  STIMMessageTableViewManager.m
//  STChatIphone
//
//  Created by 李海彬 on 2018/2/5.
//

#import "STIMMessageTableViewManager.h"
#import "STIMJSONSerializer.h"
//Message parser
#import "STIMTextContainer.h"
#import "STIMMessageParser.h"
#import "STIMEmotionSpirits.h"
//Cell
#import "STIMMsgBaloonBaseCell.h"
#import "STIMExtensibleProductCell.h"
#import "STIMPNRichTextCell.h"
#import "STIMPNActionRichTextCell.h"
#import "STIMPublicNumberNoticeCell.h"
#import "STIMChatNotifyInfoCell.h"
#import "STIMProductInfoCell.h"
#import "STIMC2BGrabSingleCell.h"
#import "STIMSingleChatCell.h"
#import "STIMCommonTrdInfoCell.h"
#import "STIMForecastCell.h"
#import "STIMSingleChatVoiceCell.h"
#import "STIMNewMessageTagCell.h"
#import "STIMPublicNumberOrderMsgCell.h"
#import "STIMRobotQuestionCell.h"
#import "STIMRobotAnswerCell.h"
#import "STIMMeetingRemindCell.h"
#import "STIMHintTableViewCell.h"
#import "STIMChatRobotQuestionListTableViewCell.h"

#import "STIMUserMedalRemindCell.h"
//#import "TransferInfoCell.h"
#import "STIMGroupChatCell.h"
#import "STIMPublicNumberNoticeCell.h"
#import "STIMVoiceNoReadStateManager.h"

//UI
#import "STIMRedPackageView.h"
#import "STIMWebView.h"
#import "STIMOriginMessageParser.h"

#if __has_include("STIMWebRTCClient.h")
#import "STIMWebRTCClient.h"
#import "STIMWebRTCMeetingClient.h"
#endif

#if __has_include("STIMNoteManager.h")
#import "STIMEncryptChat.h"
#endif

#import "STIMFileCell.h"
#import "STIMRTCChatCell.h"

@interface STIMMessageTableViewManager () 

@property (nonatomic, copy) NSString *chatId;
@property (nonatomic, assign) ChatType chatType;
@property (nonatomic, assign) BOOL editing;

@property (nonatomic, weak) QTalkViewController *ownerVc;

@property(nonatomic, strong) NSMutableArray *canForwardMsgTypeArray;

@end

@implementation STIMMessageTableViewManager


#pragma mark - setter and getter

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:20];
    }
    return _dataSource;
}

//用户已经选择的将要转发消息
- (NSMutableSet *)forwardSelectedMsgs {
    if (!_forwardSelectedMsgs) {
        _forwardSelectedMsgs = [NSMutableSet setWithCapacity:5];
    }
    return _forwardSelectedMsgs;
}

//支持转发的消息类型
- (NSMutableArray *)canForwardMsgTypeArray {
    if (!_canForwardMsgTypeArray) {
        _canForwardMsgTypeArray = [NSMutableArray arrayWithCapacity:5];
        [_canForwardMsgTypeArray addObjectsFromArray:@[@(STIMMessageType_Text), @(STIMMessageType_Image), @(STIMMessageType_NewAt), @(STIMMessageType_ImageNew), @(STIMMessageType_Voice), @(STIMMessageType_File), @(STIMMessageType_LocalShare), @(STIMMessageType_SmallVideo), @(STIMMessageType_CommonTrdInfo), @(STIMMessageType_CommonTrdInfoPer)]];
    }
    return _canForwardMsgTypeArray;
}

- (instancetype)initWithChatId:(NSString *)chatId ChatType:(ChatType)chatType OwnerVc:(QTalkViewController *)ownerVc {
    self = [super init];
    if (self) {
        self.chatId = chatId;
        self.chatType = chatType;
        self.ownerVc = ownerVc;
        self.width = self.ownerVc.view.width;
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) {
        return 0;
    }
    id temp = [self.dataSource objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[NSString class]]) {
        
    } else if (![temp isKindOfClass:[STIMMessageModel class]]) {
        
    } else {
       STIMMessageModel *message = temp;
        NSString *msgContent = message.message;
        NSString *extendInfo = message.extendInformation;
        switch (message.messageType) {
            case STIMMessageType_PNote:
            case STIMMessageType_CNote: {
                NSDictionary *productDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
                NSDictionary *infoDic = [productDic objectForKey:@"data"];
                NSString *url = [productDic objectForKey:@"url"];
                if (infoDic.count > 0) {
                    if (STIMMessageDirection_Received == message.messageType || STIMMessageType_CNote == message.messageType) {
                        return [STIMProductInfoCell getCellHeight];
                    } else {
                        message.message = [NSString stringWithFormat:@"[obj type=\"url\" value=\"%@\"]", url];
                        message.messageType = STIMMessageType_Text;
                        STIMTextContainer *textContaner = [STIMMessageParser textContainerForMessage:message];
                        return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 55;
                    }
                } else {
                    message.message = [NSString stringWithFormat:@"[obj type=\"url\" value=\"%@\"]", url];
                    message.messageType = STIMMessageType_Text;
                    STIMTextContainer *textContaner = [STIMMessageParser textContainerForMessage:message];
                    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 55;
                }
            }
                break;
            case STIMMessageType_ExProduct: {
                return [STIMExtensibleProductCell getCellHeightForProductInfo:message.extendInformation.length ? message.extendInformation : message.message];
            }
                break;
            case STIMMessageType_product: {
                
                NSDictionary *productDic = nil;
                if (message.extendInformation.length > 0) {
                    productDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
                } else {
                    productDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
                }
                NSDictionary *infoDic = [productDic objectForKey:@"data"];
                if (infoDic == nil) {
                    message.messageType = STIMMessageType_Text;
                    STIMTextContainer *textContaner = [STIMMessageParser textContainerForMessage:message];
                    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 55;
                }
                if (infoDic.count > 0) {
                    return [STIMProductInfoCell getCellHeight];
                }
                return 0;
            }
                break;
            case STIMMessageType_CommonTrdInfoPer:
            case STIMMessageType_CommonTrdInfo: {
                
                CGFloat height = [STIMCommonTrdInfoCell getCellHeightWithMessage:message chatType:self.chatType] + 30;
                return height;
            }
                break;
            case STIMMessageType_Forecast: {
                return [STIMForecastCell getCellHeightWithMessage:message chatType:self.chatType] + 30;
            }
            case STIMMessageType_GroupNotify: {
                return [STIMChatNotifyInfoCell getCellHeightWithMessage:message chatType:self.chatType] + 20;
            }
                break;
            case STIMMessageType_Text:
            case STIMMessageType_Image:
            case STIMMessageType_ImageNew:{
                
                STIMTextContainer *textContaner = [STIMMessageParser textContainerForMessage:message];
                return MAX([textContaner getHeightWithFramesetter:nil width:textContaner.textWidth], 20) + 60;
            }
                break;
            case STIMMessageType_NewAt: {
                STIMTextContainer *textContaner = [STIMMessageParser textContainerForMessage:message];
                return MAX([textContaner getHeightWithFramesetter:nil width:textContaner.textWidth], 20) + 60;
            }
                break;
            case STIMMessageType_NewMsgTag: {
                
                return [STIMNewMessageTagCell getCellHeight];
            }
                break;
            case STIMMessageType_TransChatToCustomerService:{
                // 不显示
                return 0;
            }
                break;
            case STIMMessageType_TransChatToCustomer:{
                if (self.chatType == ChatType_Consult) {
                    return 0;
                } else {
                    return [TransferInfoCell getCellHeightWithMessage:message chatType:self.chatType];
                }
            }
                break;
            case STIMMessageType_TransChatToCustomer_Feedback:
            case STIMMessageType_TransChatToCustomerService_Feedback:{
                return [TransferInfoCell getCellHeightWithMessage:message chatType:self.chatType];
            }
                break;
            case PublicNumberMsgType_Notice: {
                
                return [STIMPublicNumberNoticeCell getCellHeightByContent:message.message] + 15;
            }
                break;
            case PublicNumberMsgType_OrderNotify: {
                
                return [STIMPublicNumberOrderMsgCell getCellHeightByContent:message.message] + 15;
            }
                break;
            case MessageType_C2BGrabSingle: {
                return [STIMC2BGrabSingleCell getCellHeight];
            }
                break;
            case MessageType_C2BGrabSingleFeedBack: {
                return 0.01;
            }
                break;
            case STIMMessageTypeMeetingRemind: {
                return [STIMMeetingRemindCell getCellHeightWithMessage:temp chatType:self.chatType] + 45;
            }
                break;
            case STIMMessageTypeWorkMomentRemind: {
                return [STIMMeetingRemindCell getCellHeightWithMessage:temp chatType:self.chatType] + 45;
            }
                break;
            case STIMMessageTypeQChatRobotQuestionList:{
                return [STIMChatRobotQuestionListTableViewCell getCellHeightWithMessage:temp chatType:self.chatType] + 45;
            }
                break;
            case STIMMessageTypeRobotTurnToUser:{
                return [STIMHintTableViewCell getCellHeightWihtMessage:temp chatType:self.chatType] + 15;
            }
                break;
            case STIMMessageTypeUserMedalRemind: {
                return [STIMUserMedalRemindCell getCellHeightWithMessage:temp chatType:self.chatType] + 45;
            }
                break;
//            case STIMMessageTypeWebRtcMsgTypeVideoMeeting:{
//                return [STIMRTCChatCell]
//            }
            default: {
                
                Class someClass = [[STIMKit sharedInstance] getRegisterMsgCellClassForMessageType:message.messageType];
                if (someClass) {
                    CGFloat height = [someClass getCellHeightWithMessage:temp chatType:self.chatType] + 5;
                    return height;
                } else {
                    STIMTextContainer *textContaner = [STIMMessageParser textContainerForMessage:message];
                    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 70;
                }
            }
                break;
        }
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing == YES) {
        if (!self.forwardSelectedMsgs) {
            self.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
        }
       STIMMessageModel *msg = [self.dataSource objectAtIndex:indexPath.row];
        if ([self.canForwardMsgTypeArray containsObject:@(msg.messageType)]) {
            [self.forwardSelectedMsgs addObject:msg];
        }
        [self updateForwardBtnState];
        return;
    }
   STIMMessageModel *msg = [self.dataSource objectAtIndex:indexPath.row];
    
    switch (msg.messageType) {
        case STIMMessageType_RedPack:
        case STIMMessageType_RedPackInfo:
        case STIMMessageType_AA:
        case STIMMessageType_AAInfo: {
            NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
            if (infoStr.length > 0) {
                
                NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                if ([[[STIMKit getLastUserName] lowercaseString] isEqualToString:@"appstore"] || [[[STIMKit getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                        message:@"该消息已过期。"
                                                                       delegate:nil
                                                              cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"]
                                                              otherButtonTitles:nil];
                    [alertView show];
                } else {
                    if (self.chatType == ChatType_GroupChat) {
#pragma mark 00d8c4642c688fd6bfa9a41b523bdb6b PHP那边加的key
                        if (msg.messageType == STIMMessageType_RedPack || msg.messageType == STIMMessageType_AA) {
                            [STIMRedPackageView showSTRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&group_"@"id=%@&rk=%@&q_d=%@", infoDic[@"url"], [STIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [STIMKit getLastUserName]] stimDB_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey], [[STIMKit sharedInstance] getDomain]]];
                        } else if (msg.messageType == STIMMessageType_RedPackInfo || msg.messageType == STIMMessageType_AAInfo) {
                            [STIMRedPackageView showSTRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&group_"@"id=%@&rk=%@&q_d=%@", infoDic[@"Url"], [STIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b",                                                                                                                    [STIMKit getLastUserName]] stimDB_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey], [[STIMKit sharedInstance] getDomain]]];
                        }
                    } else {
                        if (msg.messageType == STIMMessageType_RedPack || msg.messageType == STIMMessageType_AA) {
                            [STIMRedPackageView showSTRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", infoDic[@"url"], [STIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [STIMKit getLastUserName]] stimDB_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey], [[STIMKit sharedInstance] getDomain]]];
                        } else {
                            [STIMRedPackageView showSTRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", infoDic[@"Url"], [STIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [STIMKit getLastUserName]] stimDB_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey],  [[STIMKit sharedInstance] getDomain]]];
                        }
                    }
                }
            }
        }
            break;
        case STIMMessageType_CNote:
        case STIMMessageType_PNote: {
            NSDictionary *proDic = [[STIMJSONSerializer sharedInstance] deserializeObject:msg.message error:nil];
            proDic = [proDic objectForKey:@"data"];
            NSString *touchUrl = [proDic objectForKey:@"touchDtlUrl"];
            if (touchUrl.length > 0) {
                [STIMFastEntrance openWebViewForUrl:touchUrl showNavBar:YES];
            }
        }
            break;
        case STIMMessageType_shareLocation: {
             /*
             STIMMsgBaloonBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
             if (cell.message.extendInformation) {
             
             cell.message.message = cell.message.extendInformation;
             }
             NSDictionary *dic = [[CJSONDeserializer deserializer] deserializeAsDictionary:[cell.message.message dataUsingEncoding:NSUTF8StringEncoding]
             error:nil];
             NSString *shareId = [dic objectForKey:@"shareId"];
             
             if ([[STIMKit sharedInstance] getShareLocationUsersByShareLocationId:shareId].count) {
             
             if (_shareLctVC == nil || ![_shareLctId isEqualToString:shareId]) {
                 _shareLctVC = [[ShareLocationViewController alloc] init];
                 _shareLctVC.userId = self.groupID;
                 _shareLctVC.shareLocationId = shareId;
             }
             [[self navigationController] presentViewController:_shareLctVC animated:YES completion:nil];
             } else {
             
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"哎呀呀~~"
                 message:@"这个位置共享已经关闭啦~"
                 delegate:nil
                 cancelButtonTitle:@"俺 Know!"
                 otherButtonTitles:nil, nil];
                 [alertView show];
             }
             */
        }
            break;
        case STIMMessageType_CardShare: {
            if (self.ownerVc) {
                NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:msg.message error:nil];
                NSString *userId = [infoDic objectForKey:@"userId"];
                NSString * suff = [NSString stringWithFormat:@"@%@",[[STIMKit sharedInstance] getDomain]];
                if ([userId rangeOfString:@"@"].location == NSNotFound) {
                    userId = [userId stringByAppendingString:suff];
                }
                [STIMFastEntrance openUserCardVCByUserId:userId];
            }
        }
            break;
        case STIMMessageType_activity: {
            NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
            if (infoStr.length > 0) {
                NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                STIMWebView *webView = [[STIMWebView alloc] init];
                webView.url = infoDic[@"url"];
                webView.navBarHidden = YES;
                [webView setFromRegPackage:YES];
                [self.ownerVc.navigationController pushViewController:webView animated:YES];
            }
        }
            break;
            case STIMMessageType_CommonTrdInfo:
            case STIMMessageType_CommonTrdInfoPer:
            case STIMMessageType_Forecast: {

                NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
                if (infoStr.length > 0) {
                    NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                    if ([STIMFastEntrance handleOpsasppSchema:infoDic] == NO) {
                        STIMWebView *webView = [[STIMWebView alloc] init];
                        if ([infoDic objectForKey:@"showbar"]) {
                            webView.navBarHidden = [[infoDic objectForKey:@"showbar"] boolValue] == NO;
                        }
                        if ([infoDic objectForKey:@"auth"]) {
                            webView.needAuth = [[infoDic objectForKey:@"auth"] boolValue];
                        }
                        NSString *url = infoDic[@"linkurl"];
                        if (webView.needAuth == YES) {
                            
                            if ([url rangeOfString:@"qunar.com"].location != NSNotFound) {
                                if (self.chatType == ChatType_GroupChat) {
                                    url = [url stringByAppendingFormat:@"%@username=%@&company=qunar&group_id=%@&rk=%@", ([url rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[STIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey]];
                                } else {
                                    url = [url stringByAppendingFormat:@"%@username=%@&company=qunar&user_id=%@&rk=%@", ([url rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[STIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey]];
                                }
                            }
                        }
                        webView.url = url;
                        [self.ownerVc.navigationController pushViewController:webView animated:YES];
                    }
                }
            }
            break;
        case STIMWebRTC_MsgType_Audio: {
            
        }
            break;
        case STIMMessageTypeWebRtcMsgTypeVideoMeeting: {
#if __has_include("STIMWebRTCClient.h")

            NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
            if (infoStr.length > 0) {
                NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                if (infoDic.count) {
                    [[STIMWebRTCMeetingClient sharedInstance] joinRoomByMessage:infoDic];
                }
            }
#endif
        }
            break;
        case STIMMessageTypeWebRtcMsgTypeVideoGroup: {
#if __has_include("STIMWebRTCClient.h")

            [[STIMWebRTCMeetingClient sharedInstance] setGroupId:self.chatId];
            NSDictionary *groupCardDic = [[STIMKit sharedInstance] getGroupCardByGroupId:self.chatId];
            NSString *groupName = [groupCardDic objectForKey:@"Name"];
            [[STIMWebRTCMeetingClient sharedInstance] joinRoomById:self.chatId WithRoomName:groupName];

//            NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
//            if (infoStr.length > 0) {
//                NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
//                if (infoDic.count) {
////                    [[STIMWebRTCMeetingClient sharedInstance] joinRoomByMessage:infoDic];
//
//                }
//            }
#endif
        }
            break;
        case STIMWebRTC_MsgType_Video: {
#if __has_include("STIMWebRTCClient.h")
            [[STIMWebRTCClient sharedInstance] setRemoteJID:self.chatId];
//            [[STIMWebRTCClient sharedInstance] setHeaderImage:[[STIMKit sharedInstance] getUserHeaderImageByUserId:self.chatId]];
            [[STIMWebRTCClient sharedInstance] showRTCViewByXmppId:self.chatId isVideo:YES isCaller:YES];
#endif
        }
            break;
        case STIMMessageType_WebRTC_Vedio:{
#if __has_include("STIMWebRTCClient.h")
            [[STIMWebRTCClient sharedInstance] setRemoteJID:self.chatId];
            //            [[STIMWebRTCClient sharedInstance] setHeaderImage:[[STIMKit sharedInstance] getUserHeaderImageByUserId:self.chatId]];
            [[STIMWebRTCClient sharedInstance] showRTCViewByXmppId:self.chatId isVideo:YES isCaller:YES];
#endif
        }
            break;
        case STIMMessageType_WebRTC_Audio:{
            [[STIMWebRTCClient sharedInstance] setRemoteJID:self.chatId];
            //            [[STIMWebRTCClient sharedInstance] setHeaderImage:[[STIMKit sharedInstance] getUserHeaderImageByUserId:self.chatId]];
            [[STIMWebRTCClient sharedInstance] showRTCViewByXmppId:self.chatId isVideo:NO isCaller:YES];
        }
            break;

        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
       STIMMessageModel *msg = [self.dataSource objectAtIndex:indexPath.row];
        if (!self.forwardSelectedMsgs) {
            self.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
        }
        [self.forwardSelectedMsgs removeObject:msg];
#warning 回调转发消息按钮状态
        [self updateForwardBtnState];
//        STIMVerboseLog(@"cellIndexPath : %@", indexPath);
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        STIMVerboseLog(@"cell.indexPath : %@", cell);
//        STIMVerboseLog(@"cell.editing : %d", cell.editing);
//        STIMVerboseLog(@"cell.selecting : %d", cell.selected);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
   STIMMessageModel *msg = [self.dataSource objectAtIndex:indexPath.row];
    if (tableView.editing) {
        if (!self.forwardSelectedMsgs) {
            self.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
        }
        if ([self.forwardSelectedMsgs containsObject:msg]) {
            [cell setSelected:YES animated:NO];
        } else {
            [cell setSelected:NO animated:NO];
        }
    }
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (row >= self.dataSource.count || self.dataSource.count < 1 || self.dataSource == nil) {
        return [[UITableViewCell alloc] init];
    }
    BOOL isvisable = [[tableView indexPathsForVisibleRows] containsObject:indexPath];
    id temp = [self.dataSource objectAtIndex:row];
    
   STIMMessageModel *message = temp;
//    STIMVerboseLog(@"解密会话状态 : %lu,   %d", (unsigned long)[[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId], message.messageType);
#if __has_include("STIMNoteManager.h")
    if (([[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId] > STIMEncryptChatStateNone) && message.messageType == STIMMessageType_Encrypt) {
        
        NSInteger msgType = [[STIMEncryptChat sharedInstance] getMessageTypeWithEncryptMsg:message WithUserId:self.chatId];
        NSString *originBody = [[STIMEncryptChat sharedInstance] getMessageBodyWithEncryptMsg:message WithUserId:self.chatId];
        NSString *originExtendInfo = [[STIMEncryptChat sharedInstance] getMessageExtendInfoWithEncryptMsg:message WithUserId:self.chatId];
        if (originBody.length > 0) {
            message.message = originBody;
        }
        NSArray *msgTypeList = [[STIMKit sharedInstance] getSupportMsgTypeList];
        if ([msgTypeList containsObject:@(msgType)] && originExtendInfo.length > 0) {
            message.message = originExtendInfo;
        }
        if (originBody.length <= 0 && originExtendInfo.length <= 0) {
            message.extendInformation = @"[解密失败]";
        } else {
            message.messageType = (STIMMessageType)msgType;
        }
    }
#endif
    switch ((int) message.messageType) {
        case STIMMessageType_ExProduct: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_ExProduct Cell %@", message.messageId];
            STIMExtensibleProductCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMExtensibleProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            cell.chatType = self.chatType;
            NSDictionary *proDic = nil;
            if (message.extendInformation.length > 0) {
                proDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
            } else {
                proDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
            }
            if (proDic == nil) {
                message.messageType = STIMMessageType_Text;
                NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_ExProduct->STIMMessageType_Text Cell %@", message.messageId];
                STIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[STIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                }
                [cell setMessage:message];
                [cell refreshUI];
                return cell;
            }
            [cell setProDcutInfoDic:proDic];
            cell.owner = self.ownerVc;
            [cell refreshUI];
            
            return cell;
        }
            break;
        case STIMMessageType_PNote:
        case STIMMessageType_CNote: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_CNote Cell %@", message.messageId];
            STIMProductInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMProductInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setMessage:message];
            }
            [cell setMessage:message];
            [cell setChatType:self.chatType];
            if (isvisable) {
                NSDictionary *proDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
                proDic = [proDic objectForKey:@"data"];
                NSString *tag = [proDic objectForKey:@"tag"];
                NSString *type = [proDic objectForKey:@"type"];
                [cell setHeaderUrl:[proDic objectForKey:@"imageUrl"]];
                [cell setTitle:[proDic objectForKey:@"title"]];
                [cell setSubTitle:tag];
                [cell setTypeStr:type];
                [cell setPriceStr:[proDic objectForKey:@"price"]];
                [cell setTouchUrl:[proDic objectForKey:@"touchDtlUrl"]];
                [cell setOwner:self.ownerVc];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case MessageType_C2BGrabSingle: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"MessageType_C2BGrabSingle Cell %@", message.messageId];
            STIMC2BGrabSingleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMC2BGrabSingleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            [cell setChatType:self.chatType];
            if (isvisable) {
                [cell setMessage:message];
                [cell setOwner:self.ownerVc];
            }
            return cell;
        }
            break;
        case STIMMessageType_product: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_product Cell %@", message.messageId];
            STIMProductInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[STIMProductInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            cell.message = message;
            cell.chatType = self.chatType;
            NSDictionary *proDic = nil;
            if (message.extendInformation.length > 0) {
                proDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
            } else {
                proDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
            }
            proDic = [proDic objectForKey:@"data"];
            if (proDic == nil) {
                message.messageType = STIMMessageType_Text;
                NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_product->STIMMessageType_Text Cell %@", message.messageId];
                STIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    
                    cell = [[STIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                }
                [cell setMessage:message];
                [cell refreshUI];
                return cell;
            }
            NSString *tag = [[proDic objectForKey:@"tag"] isKindOfClass:[NSNull class]] ? @"" : [proDic objectForKey:@"tag"];
            NSString *type = [proDic objectForKey:@"type"];
            [cell setHeaderUrl:[proDic objectForKey:@"imageUrl"]];
            [cell setTitle:[proDic objectForKey:@"title"]];
            [cell setSubTitle:tag];
            [cell setTypeStr:type];
            [cell setPriceStr:[proDic objectForKey:@"price"]];
            [cell setTouchUrl:[proDic objectForKey:@"touchDtlUrl"]];
            [cell setOwner:self.ownerVc];
            [cell refreshUI];
            return cell;
        }
            break;
        case STIMMessageType_CommonTrdInfoPer:
        case STIMMessageType_CommonTrdInfo: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_CommonTrdInfo Cell %@", message.messageId];
            STIMCommonTrdInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[STIMCommonTrdInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
                cell.chatType = self.chatType;
//                if (message.extendInformation.length > 0) {
//                    
//                    message.message = message.extendInformation;
//                }
                [cell setMessage:message];
                [cell setChatType:self.chatType];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case STIMMessageType_Forecast: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_Forecast Cell %@", message.messageId];
            STIMForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMForecastCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            cell.chatType = self.chatType;
            if (isvisable) {
                if (message.extendInformation.length > 0) {
                    message.message = message.extendInformation;
                }
                [cell setMessage:message];
                [cell setChatType:self.chatType];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case STIMMessageType_Text:
        case STIMMessageType_Image:
        case STIMMessageType_ImageNew:{
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_Text Cell %@", message.messageId];
            STIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                
                cell = [[STIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIdentifier];
                cell.chatType = self.chatType;
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
                [cell setMessage:message];
            }
            [cell refreshUI];
            return cell;
        }
            break;
            case STIMMessageType_NewAt: {
                NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_NewAt Cell %@", message.messageId];
                STIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[STIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier];
                    cell.chatType = self.chatType;
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                    NSString *backupInfo = [[STIMOriginMessageParser shareParserOriginMessage]
                                            getOriginMsgBackupInfoWithMsgRaw:message.msgRaw WithMsgId:message.messageId];
                    NSString *msg = message.message;
                    NSArray *array = [[STIMJSONSerializer sharedInstance] deserializeObject:backupInfo error:nil];
                    if ([array isKindOfClass:[NSArray class]]) {
                        NSDictionary *groupAtDic = [array firstObject];
                        for (NSDictionary *someOneAtDic in [groupAtDic objectForKey:@"data"]) {
                            NSString *someOneJid = [someOneAtDic objectForKey:@"jid"];
                            if (someOneJid.length) {
                                NSString *someOneText = [someOneAtDic objectForKey:@"text"];
                                NSString *replaceText = [NSString stringWithFormat:@"@%@", someOneText];
                                NSString *remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:someOneJid];
                                NSString *newReplaceName = [NSString stringWithFormat:@"@%@", remarkName];
                                if(remarkName.length) {
                                    msg = [msg stringByReplacingOccurrencesOfString:replaceText withString:newReplaceName];
                                } else {
                                }
                            } else {
                                continue;
                            }
                        }
                    } else {
                        
                    }
                    message.message = msg;
                    [cell setMessage:message];
                    [cell refreshUI];
                }
                return cell;
            }
            break;
        case STIMMessageType_Voice: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_Voice Cell %@", message.messageId];
            STIMSingleChatVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[STIMSingleChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:cellIdentifier];
                cell.chatType = self.chatType;
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
                [cell setMessage:message];
                BOOL isRead = [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] isReadWithMsgId:message.messageId ChatId:self.chatId];
                if (message.messageDirection == STIMMessageDirection_Received) {
                    [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:message.messageId ChatId:self.chatId withState:isRead];
                }
                cell.isGroupVoice = YES;
                cell.chatId = self.chatId;
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case STIMMessageType_GroupNotify: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_GroupNotify_Cell"];
            STIMChatNotifyInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMChatNotifyInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:cellIdentifier];
                cell.chatType = self.chatType;
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
            }
            [cell setMessage:message];
            [cell refreshUI];
            return cell;
        }
            break;
        case STIMMessageType_NewMsgTag: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_NewMsgTag Cell %@", message.messageId];
            STIMNewMessageTagCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMNewMessageTagCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier];
            }
            if (isvisable) {
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case STIMMessageType_TransChatToCustomerService:{
            // 不显示
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_TransChatToCustomerService Cell %@", message.messageId];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
            break;
        case STIMMessageType_TransChatToCustomer:{
            if (self.chatType == ChatType_Consult) {
                // 不显示
                NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_TransChatToCustomer Empty Cell %@", message.messageId];
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                return cell;
            } else {
                NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_TransChatToCustomer Cell %@", message.messageId];
                TransferInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[TransferInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                }
                [cell setChatType:ChatType_SingleChat];
                [cell setMessage:message];
                [cell refreshUI];
                return cell;
            }
        }
            break;
        case STIMMessageType_TransChatToCustomerService_Feedback:{
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_TransChatToCustomerService_Feedback Cell %@", message.messageId];
            TransferInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[TransferInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
            }
            [cell setChatType:self.chatType];
            [cell setMessage:message];
            [cell refreshUI];
            return cell;
        }
            break;
        case STIMMessageType_TransChatToCustomer_Feedback:{
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"STIMMessageType_TransChatToCustomer_Feedback Cell %@", message.messageId];
            TransferInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[TransferInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
            }
            [cell setChatType:self.chatType];
            [cell setMessage:message];
            [cell refreshUI];
            return cell;
        }
            break;
        case PublicNumberMsgType_RichText: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"PublicNumberMsgType_RichText Cell %@", message.messageId];
            STIMPNRichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[STIMPNRichTextCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                
                [cell setContent:message.message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case PublicNumberMsgType_ActionRichText: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"PublicNumberMsgType_ActionRichText Cell %@", message.messageId];
            STIMPNActionRichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[STIMPNActionRichTextCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                
                [cell setContent:message.message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case PublicNumberMsgType_Notice: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"PublicNumberMsgType_Notice Cell %@", message.messageId];
            STIMPublicNumberNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMPublicNumberNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                [cell setContent:message.message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case PublicNumberMsgType_OrderNotify:{
            static NSString *cellIdentifier = @"Cell Order Notify ";
            STIMPublicNumberOrderMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMPublicNumberOrderMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                [cell setMessage:message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case MessageType_C2BGrabSingleFeedBack: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"C2B GrabSingle FeedBack Cell %@", @(message.messageDirection)];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.backgroundColor = [UIColor qtalkChatBgColor];
            }
            return cell;
        }
            break;
        case STIMMessageTypeRobotQuestionList: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"%d Cell %@", message.messageType, message.messageId];
            STIMMsgBaloonBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMRobotQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                cell.chatType = self.chatType;
                cell.delegate = self.ownerVc;
            }
            [cell setOwerViewController:self.ownerVc];
            [cell setMessage:message];
            [cell setChatType:self.chatType];
            [cell refreshUI];
            return cell;
        }
            break;
        case STIMMessageType_RobotAnswer: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"%d Cell %@", message.messageType, message.messageId];
            STIMRobotAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMRobotAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                cell.chatType = self.chatType;
                cell.delegate = self.ownerVc;
            }
            [cell setOwerViewController:self.ownerVc];
            [cell setMessage:message];
            [cell setChatType:self.chatType];
            [cell refreshUI];
            return cell;
        }
            break;
            
        case STIMMessageTypeQChatRobotQuestionList:{
            NSString * cellIdentifier = @"STIMMessageTypeQChatRobotQuestionList";
            STIMChatRobotQuestionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMChatRobotQuestionListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                cell.chatType = self.chatType;
                cell.delegate = self.ownerVc;
                [cell setOwerViewController:self.ownerVc];
            }
            
            [cell setMessage:message];
            [cell setChatType:self.chatType];
            [cell refreshUI];
            return cell;
        }
            break;
        case STIMMessageTypeRobotTurnToUser:{
            NSString * cellIdentfier = @"STIMMEssageTypeQChatRobotTurnToUser";
            STIMHintTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
            if (cell == nil) {
                cell = [[STIMHintTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfier];
                //                [cell setFrameWidth:_chatView.width];
                cell.delegate = self.ownerVc;
                cell.hintDelegate = self.ownerVc;
            }
            cell.chatType = self.chatType;
            //            [cell setOwerViewController:self];
            [cell setMessage:message];
            [cell refreshUI];
            return cell;
            
        }
            break;
            break;
        default: {
            Class someClass = [[STIMKit sharedInstance] getRegisterMsgCellClassForMessageType:message.messageType];
            if (someClass) {
                
                NSString *cellIdentifier = [NSString stringWithFormat:@"%d Cell %@", message.messageType, message.messageId];
                STIMMsgBaloonBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[someClass alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    cell.chatType = self.chatType;
                    cell.delegate = self.ownerVc;
                    [cell setOwerViewController:self.ownerVc];
                    [cell setMessage:message];
                    [cell refreshUI];
                }
                return cell;
            } else {
                NSString *cellIdentifier = [NSString stringWithFormat:@"No Found MessageType(%d) Cell %@", message.messageType, message.messageId];
                STIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[STIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                    cell.chatType = self.chatType;
                    [cell setMessage:message];
                    [cell refreshUI];
                }
                return cell;
            }
        }
            break;
    }
 }

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) {
        return NO;
    }
    if (tableView.editing) {
        id temp = [self.dataSource objectAtIndex:indexPath.row];
       STIMMessageModel *message = temp;
        if ([self.canForwardMsgTypeArray containsObject:@(message.messageType)]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    id temp = [self.dataSource objectAtIndex:indexPath.row];
   STIMMessageModel *message = temp;
    STIMVerboseLog(@"commit msg : %@", message);
}

#pragma mark - ScrollViewDelegate

- (void)updateForwardBtnState {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageUpdateForwardBtnState:)]) {
        [self.delegate QTalkMessageUpdateForwardBtnState:(self.forwardSelectedMsgs.count >= 1)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageScrollViewDidScroll:)]) {
        [self.delegate QTalkMessageScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageScrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate QTalkMessageScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageScrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate QTalkMessageScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

@end

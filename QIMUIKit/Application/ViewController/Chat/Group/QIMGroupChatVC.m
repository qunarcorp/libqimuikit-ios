//
//  QIMGroupChatVC.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/13.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import <AlipaySDK/AlipaySDK.h>
#import "QIMGroupChatVC.h"
#import "QIMUUIDTools.h"
#import "QIMIconInfo.h"
#import "QIMCommonFont.h"
#import "QIMEmotionManager.h"
#import "QIMDataController.h"
#import "QIMJSONSerializer.h"
#import "QIMSingleChatVoiceCell.h"
#import "QIMNavTitleView.h"
#import "QIMMessageTextAttachment.h"
#import "QIMContactSelectionViewController.h"
#import "QIMCollectionFaceManager.h"
#import "MBProgressHUD.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMRedMindView.h"
#import "QIMTapGestureRecognizer.h"
#import "QIMOriginMessageParser.h"
#import "QIMOrganizationalVC.h"
#import "QIMMenuImageView.h"
#import "YYModel.h"
#import "QIMChatBgManager.h"
#import "QIMVoiceRecordingView.h"
#import "QIMVoicePathManage.h"
#import "QIMStringTransformTools.h"
#import "QIMVoiceTimeRemindView.h"

#import <AVFoundation/AVFoundation.h>

#import "QIMMessageRefreshHeader.h"

#import "QIMRemoteAudioPlayer.h"

#import "QIMGroupChatCell.h"

#import "QIMGroupCardVC.h"

#import "QIMDisplayImage.h"

#import "QIMPhotoBrowserNavController.h"

#import "QIMMessageBrowserVC.h"
#import "QIMChatBGImageSelectController.h"
#import "QIMFileManagerViewController.h"

#import "QIMPreviewMsgVC.h"

#import "QIMEmotionSpirits.h"
#import "QIMWebView.h"

#import "QIMMsgBaloonBaseCell.h"
#import "QIMChatNotifyInfoCell.h"
#import "QIMCollectionEmotionEditorVC.h"
#import "QIMNewMessageTagCell.h"
#import "QIMNotReadMsgTipViews.h"
#import "QIMNotReadATMsgTipView.h"
#import "QIMPushProductViewController.h"
#import "QIMRedPackageView.h"
#import "ShareLocationViewController.h"
#import "UserLocationViewController.h"
#import "QIMTextBar.h"
#import "QIMMyFavoitesManager.h"
#import "QIMPlayVoiceManager.h"
#import "QIMPNActionRichTextCell.h"
#import "QIMPNRichTextCell.h"
#import "QIMPublicNumberNoticeCell.h"
#import "QIMVoiceNoReadStateManager.h"
#import "QIMMessageParser.h"
#import "QIMAttributedLabel.h"
#import "QIMExtensibleProductCell.h"
#import "QIMMessageCellCache.h"
#import "QIMExportMsgManager.h"
#import "QIMContactSelectVC.h"
#import "QIMContactManager.h"
#import "QIMGroupCardVC.h"
#import "QIMNavBackBtn.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMMessageTableViewManager.h"
#import "QIMMessageRefreshFooter.h"
#if __has_include("QIMWebRTCMeetingClient.h")
    #import "QIMWebRTCMeetingClient.h"
#endif
#import "QIMAuthorizationManager.h"
#import "QIMSearchRemindView.h"
#if __has_include("QIMIPadWindowManager.h")
#import "QIMIPadWindowManager.h"
#endif

#define kPageCount 20

#define kReSendMsgAlertViewTag 10000
#define kForwardMsgAlertViewTag 10001

static NSMutableDictionary *__checkGroupMembersCardDic = nil;

@interface QIMGroupChatVC () <UIGestureRecognizerDelegate, QIMGroupChatCellDelegate, QIMSingleChatVoiceCellDelegate, QIMMWPhotoBrowserDelegate, QIMRemoteAudioPlayerDelegate, QIMMsgBaloonBaseCellDelegate, QIMChatBGImageSelectControllerDelegate, QIMContactSelectionViewControllerDelegate, QIMPushProductViewControllerDelegate, UIActionSheetDelegate, UserLocationViewControllerDelegate, PNNoticeCellDelegate, QIMPNRichTextCellDelegate, QIMPNActionRichTextCellDelegate, QIMChatNotifyInfoCellDelegate, QIMTextBarDelegate, QIMNotReadMsgTipViewsDelegate, QIMNotReadAtMsgTipViewsDelegate, QIMPNRichTextCellDelegate, PlayVoiceManagerDelegate, UIViewControllerPreviewingDelegate, QTalkMessageTableScrollViewDelegate, QIMOrganizationalVCDelegate> {
    
    bool _isReloading;
    
    BOOL _isOnline;
    
    NSMutableDictionary *_cellSizeDic;
    
    float _currentDownloadProcess;
    
    UIButton *_AddToGroupBtn;
    
    CGRect _rootViewFrame;
    
    CGRect _tableViewFrame;
    
    BOOL _notIsFirstChangeTableViewFrame;
    
    BOOL _playStop;
    
    UIView *notificationView;
    
    UILabel *commentCountLabel;
    
    UIImageView *backImageView;
    
    QIMTapGestureRecognizer *_tap;
    
    NSMutableDictionary *_photos;
    NSMutableArray *_imagesArr;
    
    UIImageView *_chatBGImageView;
    
    NSMutableDictionary *_gUserNameColorDic;
    QIMMessageModel *_resendMsg;
    
    NSString *_replyMsgId;
    NSString *_replyUser;
    QIMTextBarExpandViewItemType _expandViewItemType;
    
    ShareLocationViewController *_shareLctVC;
    UIView *_joinShareLctView;
    NSString *_shareLctId;
    NSString *_shareFromId;
    
    QIMNotReadMsgTipViews *_readMsgTipView;
    QIMNotReadATMsgTipView *_notReadAtMsgTipView;
    QIMPlayVoiceManager *_playVoiceManager;
    
    dispatch_queue_t _update_members_headimg;
    NSMutableArray *_hasGetHeadImgUsers;
    
    UIView *_forwardNavTitleView;
    UIView *_maskRightTitleView;
    NSString *_jsonFilePath;
    
    UIWindow * _referMsgwindow;
}

@property(nonatomic, strong) QIMTextBar *textBar;

@property(nonatomic, strong) UIView *loadAllMsgView;

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) QIMVoiceRecordingView *voiceRecordingView;

@property(nonatomic, strong) QIMVoiceTimeRemindView *voiceTimeRemindView;

@property(nonatomic, strong) QIMNavTitleView *titleView;

@property(nonatomic, strong) UILabel *descLabel;

@property(nonatomic, strong) UIButton *addGroupMember;

@property(nonatomic, assign) NSInteger currentPlayVoiceIndex;

@property(nonatomic, copy) NSString *currentPlayVoiceMsgId;

@property(nonatomic, strong) NSIndexPath *currentPlayVoiceMsgIndexPath;

@property(nonatomic, assign) BOOL isNoReadVoice;

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@property(nonatomic, strong) UIButton *forwardBtn;

@property(nonatomic, strong) QIMMessageTableViewManager *messageManager;

@property(nonatomic, strong) QIMRemoteAudioPlayer *remoteAudioPlayer;

@property(nonatomic, assign) NSInteger currentMsgIndexs;

@property(nonatomic, assign) NSInteger loadCount;

@property(nonatomic, assign) BOOL reloadSearchRemindView;

@property(nonatomic, strong) QIMSearchRemindView *searchRemindView;

@property(nonatomic, strong) NSMutableArray *fixedImageArray;

@end

@implementation QIMGroupChatVC

- (void)updateGroupMemberCards {
    if (__checkGroupMembersCardDic == nil) {
        __checkGroupMembersCardDic = [NSMutableDictionary dictionary];
    }
    double prepCheckTime = [[__checkGroupMembersCardDic objectForKey:self.chatId] longLongValue];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime - prepCheckTime > 10 * 60) {
        
        [__checkGroupMembersCardDic setObject:@(currentTime) forKey:self.chatId];
        dispatch_async(
                       
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           
                           // 频度控制？
                           [[QIMKit sharedInstance] updateQChatGroupMembersCardForGroupId:self.chatId];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               [_tableView reloadData];
                           });
                       });
    }
}

- (void)setBackBtn {
    QIMNavBackBtn *backBtn = [QIMNavBackBtn sharedInstance];
    [backBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //将宽度设为负值
    spaceItem.width = -15;
    //将两个BarButtonItem都返回给N
    self.navigationItem.leftBarButtonItems = @[spaceItem,backBarBtn];
}

- (QIMTextBar *)textBar {
    
    if (!_textBar) {
        _textBar = [QIMTextBar sharedIMTextBarWithBounds:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) WithExpandViewType:QIMTextBarExpandViewTypeGroup];
        _textBar.associateTableView = self.tableView;
        [_textBar setDelegate:self];
        [_textBar setAllowSwitchBar:NO];
        [_textBar setAllowVoice:YES];
        [_textBar setAllowFace:YES];
        [_textBar setAllowMore:YES];
        [_textBar setChatId:self.chatId];
//        [_textBar needFirstResponder:NO];
//        [_textBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
//        [_textBar setPlaceHolder:@"文本信息"];
        __weak QIMTextBar *weakTextBar = _textBar;
        
        [_textBar setSelectedEmotion:^(NSString *faceStr) {
            if ([faceStr length] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *text = [[QIMEmotionManager sharedInstance] getEmotionTipNameForShortCut:faceStr withPackageId:weakTextBar.currentPKId];
                    text = [NSString stringWithFormat:@"[%@]", text];
                    [weakTextBar insertEmojiTextWithTipsName:text shortCut:faceStr];
                });
            }
        }];
        
        [_textBar.layer setBorderColor:[UIColor qim_colorWithHex:0xadadad alpha:1].CGColor];
        [_textBar setIsRefer:NO];
        NSDictionary *notSendDic = [[QIMKit sharedInstance] getNotSendTextByJid:self.chatId];
        [_textBar setQIMAttributedTextWithItems:notSendDic[@"inputItems"]];
    }
    return _textBar;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        if (self.chatType == ChatType_CollectionChat) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        } else {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 49 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        }
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        _tableView.delegate = self.messageManager;
        _tableView.dataSource = self.messageManager;
        [_tableView setBackgroundColor:qim_chatBgColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
#endif
        _tableViewFrame = _tableView.frame;
        [self.view addSubview:_tableView];
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        [_tableView setAccessibilityIdentifier:@"MessageTableView"];
        _tableView.mj_header = [QIMMessageRefreshHeader messsageHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewGroupMsgList)];
        if (self.netWorkSearch == YES) {
            _tableView.mj_footer = [QIMMessageRefreshFooter messsageFooterWithRefreshingTarget:self refreshingAction:@selector(loadFooterRemoteSearchMsgList)];
        }
        [self refreshChatBGImageView];
    }
    return _tableView;
}

- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _titleLabel.text = self.title;
        _titleLabel.textColor = qim_groupchat_title_color;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:qim_groupchat_title_size];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _titleLabel;
}

- (QIMVoiceRecordingView *)voiceRecordingView {
    
    if (!_voiceRecordingView) {
        
        _voiceRecordingView = [[QIMVoiceRecordingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, 150, 150, 150)];
        [self.view addSubview:_voiceRecordingView];
        _voiceRecordingView.hidden = YES;
        _voiceRecordingView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceRecordingView];
    }
    return _voiceRecordingView;
}

- (QIMVoiceTimeRemindView *)voiceTimeRemindView {
    
    if (!_voiceTimeRemindView) {
        
        _voiceTimeRemindView = [[QIMVoiceTimeRemindView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, 150, 150, 150)];
        _voiceTimeRemindView.hidden = YES;
        _voiceTimeRemindView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceTimeRemindView];
    }
    return _voiceTimeRemindView;
}

- (UILabel *)descLabel {
    
    if (!_descLabel) {
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 200, 12)];
        _descLabel.textColor = [UIColor blackColor];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.font = [UIFont systemFontOfSize:10];
        _descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _descLabel;
}

- (QIMNavTitleView *)titleView {
    
    if (!_titleView) {
        
        _titleView = [[QIMNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _titleView.autoresizesSubviews = YES;
        _titleView.backgroundColor = [UIColor clearColor];
    }
    return _titleView;
}

- (UIButton *)addGroupMember {
    
    if (!_addGroupMember) {
        
        _addGroupMember = [[UIButton alloc] initWithFrame:CGRectMake(40, 2, 37, 37)];
        [_addGroupMember setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_groupchat_rightCard_font size:qim_groupchat_rightCard_TextSize color:qim_groupchat_rightCard_Color]] forState:UIControlStateNormal];
        [_addGroupMember setAccessibilityIdentifier:@"QIMGroupCard"];
        [_addGroupMember addTarget:self action:@selector(addPersonToPgrup:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addGroupMember;
}

- (QIMRemoteAudioPlayer *)remoteAudioPlayer {
    if (!_remoteAudioPlayer) {
        _remoteAudioPlayer = [[QIMRemoteAudioPlayer alloc] init];
        _remoteAudioPlayer.delegate = self;
    }
    return _remoteAudioPlayer;
}

- (void)setupNav {
    [self setBackBtn];
    NSDictionary *memoryGroupCardDic = [[QIMKit sharedInstance] getMemoryGroupCardByGroupId:self.chatId];
    if (memoryGroupCardDic.count > 0) {
        [self updateGroupChatTitleWithCardDic:memoryGroupCardDic];
    } else {
        dispatch_async([[QIMKit sharedInstance] getLoadGroupCardFromDBQueue], ^{
            NSDictionary *groupCardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.chatId];
            self.groupCardDic = groupCardDic;
            [self updateGroupChatTitleWithCardDic:groupCardDic];
            if (!self.bindId) {
                NSInteger groupCardVersion = [[self.groupCardDic objectForKey:@"LastUpdateTime"] integerValue];
                if (groupCardVersion <= 0) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        [[QIMKit sharedInstance] updateGroupCardByGroupId:self.chatId];
                    });
                }
            }
        });
    }
}

- (void)updateGroupChatTitleWithCardDic:(NSDictionary *)groupCardDic {
    NSString *titleName = [groupCardDic objectForKey:@"Name"];
    NSString *topic = [groupCardDic objectForKey:@"Topic"];
    if (self.chatType == ChatType_CollectionChat) {
        NSDictionary *groupCardDic = [[QIMKit sharedInstance] getCollectionGroupCardByGroupId:self.chatId];
        self.groupCardDic = groupCardDic;
        if (groupCardDic) {
            NSString *groupName = [groupCardDic objectForKey:@"Name"];
            if (groupName) {
                titleName = groupName;
            } else {
                titleName = self.chatId;
            }
        }
    }
    if (!titleName) {
        titleName = [[self.chatId componentsSeparatedByString:@"@"] firstObject];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (titleName.length > 0) {
            self.title = titleName;
            self.titleLabel.text = titleName;
            [self.titleView addSubview:self.titleLabel];
        }
        if (topic.length > 0) {
            self.descLabel.text = topic;
//            [self.titleView addSubview:self.descLabel];
            self.navigationItem.titleView = self.titleView;
        } else {
            
            [self.titleView addSubview:self.titleLabel];
            self.navigationItem.titleView = self.titleView;
        }
        if (self.chatType == ChatType_GroupChat) {
            UIView *rightBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
            [rightBarView addSubview:self.addGroupMember];
            /* 暂时取消右上角红点
             if (![[[QIMKit sharedInstance] userObjectForKey:kRightCardRemindNotification] boolValue]) {
             QIMRedMindView *redMindView = [[QIMRedMindView alloc] initWithBroView:self.addGroupMember withRemindNotificationName:kRightCardRemindNotification];
             [rightBarView addSubview:redMindView];
             }
             */
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarView];
        } else {
            
        }
    });
}

- (void)initUI {
    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
        [self.view setFrame:CGRectMake(0, 0, [[QIMWindowManager shareInstance] getDetailWidth], [[UIScreen mainScreen] height])];
    }
    self.view.backgroundColor = qim_chatBgColor;
  
    [[QIMEmotionSpirits sharedInstance] setTableView:_tableView];
    [self loadData];
//    添加整个view的点击事件，当点击页面空白地方时，输入框收回
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    gesture.delegate = self;
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:gesture];

    _shareLctId = [[QIMKit sharedInstance] getShareLocationIdByJid:self.chatId];
    if (_shareLctId.length > 0 && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count > 0) {
        
        _shareFromId = [[QIMKit sharedInstance] getShareLocationFromIdByShareLocationId:_shareLctId];
        [self initJoinShareView];
    }
    if (self.needShowNewMsgTagCell) {
        
        //未读消息按钮
        _readMsgTipView = [[QIMNotReadMsgTipViews alloc] initWithNotReadCount:self.notReadCount];
        [_readMsgTipView setFrame:CGRectMake(self.view.width, 10, _readMsgTipView.width, _readMsgTipView.height)];
        [_readMsgTipView setNotReadMsgDelegate:self];
        [self.view addSubview:_readMsgTipView];
        [UIView animateWithDuration:0.3 animations:^{
            [UIView setAnimationDelay:0.1];
            [_readMsgTipView setFrame:CGRectMake(self.view.width - _readMsgTipView.width, _readMsgTipView.top, _readMsgTipView.width, _readMsgTipView.height)];
        }];
    }
    
    [self.textBar performSelector:@selector(keyBoardDown) withObject:nil afterDelay:0.5];
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    [self.textBar keyBoardDown];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.textBar keyBoardDown];
}

- (UIView *)getForwardNavView {
    if (_forwardNavTitleView == nil) {
        _forwardNavTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.bounds.size.height)];
        _forwardNavTitleView.backgroundColor = [UIColor whiteColor];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelForwardHandle:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.frame = CGRectMake(20, 0, 50, _forwardNavTitleView.height);
        [_forwardNavTitleView addSubview:cancelBtn];
    }
    return _forwardNavTitleView;
}

- (UIView *)getMaskRightTitleView {
    if (_maskRightTitleView == nil) {
        _maskRightTitleView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width - 100, 0, 100, self.navigationController.navigationBar.bounds.size.height)];
        _maskRightTitleView.backgroundColor = [UIColor whiteColor];
    }
    return _maskRightTitleView;
}

- (UIButton *)forwardBtn {
    if (!_forwardBtn) {
        _forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forwardBtn.frame = CGRectMake(0, self.view.height - 50 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], self.view.width, 50);
        [_forwardBtn setTitle:[NSBundle qim_localizedStringForKey:@"Forward"] forState:UIControlStateNormal];
        [_forwardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_forwardBtn addTarget:self action:@selector(forwardBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_forwardBtn setEnabled:NO];
        [self.textBar setUserInteractionEnabled:NO];
    }
    if (_forwardBtn.enabled) {
        [_forwardBtn setBackgroundColor:[UIColor qtalkIconSelectColor]];
    } else {
        [_forwardBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _forwardBtn;
}

- (QIMMessageTableViewManager *)messageManager {
    if (!_messageManager) {
        _messageManager = [[QIMMessageTableViewManager alloc] initWithChatId:self.chatId ChatType:self.chatType OwnerVc:self];
        _messageManager.delegate = self;
    }
    return _messageManager;
}

- (void)forwardBtnHandle:(id)sender {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && ![[QIMKit sharedInstance] getIsIpad]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *quickForwardAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"One-by-One Forward"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            
            NSArray *forwardIndexpaths = [self.messageManager.forwardSelectedMsgs.allObjects sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return [(QIMMessageModel *)obj1 messageDate] > [(QIMMessageModel *)obj2 messageDate];
            }];
            
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (QIMMessageModel *message in forwardIndexpaths) {
                [msgList addObject:[QIMMessageParser reductionMessageForMessage:message]];
            }
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            [controller setMessageList:msgList];
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [self cancelForwardHandle:nil];
                                                    }];
        }];
        UIAlertAction *mergerForwardAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"Combine and Forward"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            if (!self.messageManager.forwardSelectedMsgs) {
                self.messageManager.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
            }
            NSArray *msgList = [self.messageManager.forwardSelectedMsgs.allObjects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [(QIMMessageModel *)obj1 messageDate] > [(QIMMessageModel *)obj2 messageDate];
            }];
            _jsonFilePath = [QIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@的聊天记录", self.title]];
            self.tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [_forwardBtn removeFromSuperview];
            [_textBar setUserInteractionEnabled:YES];
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            controller.delegate = self;
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [self cancelForwardHandle:nil];
                                                    }];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
            
        }];
        
        [alertController addAction:quickForwardAction];
        [alertController addAction:mergerForwardAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle qim_localizedStringForKey:@"One-by-One Forward"], [NSBundle qim_localizedStringForKey:@"Combine and Forward"], nil];
        alertView.tag = kForwardMsgAlertViewTag;
        [alertView show];
    }
}

- (void)cancelForwardHandle:(id)sender {
    
    self.tableView.editing = NO;
    [_forwardNavTitleView removeFromSuperview];
    [_maskRightTitleView removeFromSuperview];
    [_forwardBtn removeFromSuperview];
    [_textBar setUserInteractionEnabled:YES];
    [self.messageManager.forwardSelectedMsgs removeAllObjects];
    self.fd_interactivePopDisabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadCount = 0;
    if (self.bindId) {
        self.chatType = ChatType_CollectionChat;
    } else {
        self.chatType = ChatType_GroupChat;
    }
    [self setupNav];
    [self initNotifications];
    _playVoiceManager = [QIMPlayVoiceManager defaultPlayVoiceManager];
    _playVoiceManager.playVoiceManagerDelegate = self;
    _playVoiceManager.chatId = self.chatId;
    _photos = [[NSMutableDictionary alloc] init];
    _rootViewFrame = self.view.frame;
    _cellSizeDic = [NSMutableDictionary dictionary];
    /* Mark DBUpdate
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) { // 检查群成员名片变更
        
        [self updateGroupMemberCards];
    }
    */
    [self initUI];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self synchronizeChatSession];
    });
}

- (void)synchronizeChatSession {
    [[QIMKit sharedInstance] synchronizeChatSessionWithUserId:self.chatId WithChatType:self.chatType WithRealJid:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (![[QIMKit sharedInstance] getIsIpad]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
        [self.view setFrame:CGRectMake(0, 0, [[QIMWindowManager shareInstance] getDetailWidth], [[UIScreen mainScreen] height])];
    }
    [[QIMKit sharedInstance] setCurrentSessionUserId:self.chatId];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.chatType == ChatType_GroupChat) {
        [self.view addSubview:self.textBar];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_forwardNavTitleView.superview) {
        [_forwardNavTitleView.superview bringSubviewToFront:_forwardNavTitleView];
    }
    if (_maskRightTitleView.superview) {
        [_maskRightTitleView.superview bringSubviewToFront:_maskRightTitleView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (_shareLctId && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count == 0) {
        
        [_joinShareLctView removeFromSuperview];
        _joinShareLctView = nil;
    }
    
    [_remoteAudioPlayer stop];
    _currentPlayVoiceMsgId = nil;
    
    for (int i = 0; i < (int) self.messageManager.dataSource.count - kPageCount * 2; i++) {
        
        [[QIMMessageCellCache sharedInstance] removeObjectForKey:[(QIMMessageModel *) self.messageManager.dataSource[i] messageId]];
    }
}

- (void)updateGroupUsersHeadImgForMsgs:(NSArray *)msgs {
    return;
}

- (void)initNotifications {
 
    //键盘弹出，消息自动滑动最底
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillShow:)
                                                 name:kQIMTextBarIsFirstResponder
                                               object:nil];
    //更新群昵称
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGroupNickName:)
                                                 name:kGroupNickNameChanged
                                               object:nil];
    
    if (self.netWorkSearch == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(expandViewItemHandleNotificationHandle:)
                                                     name:kExpandViewItemHandleNotification
                                                   object:nil];
        

        
        //消息发送成功
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(msgDidSendNotificationHandle:)
                                                     name:kXmppStreamDidSendMessage
                                                   object:nil];
        
        //消息发送失败
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(msgSendFailedNotificationHandle:)
                                                     name:kXmppStreamSendMessageFailed
                                                   object:nil];
        //重发消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(msgReSendNotificationHandle:)
                                                     name:kXmppStreamReSendMessage
                                                   object:nil];
        
        //阅后即焚消息销毁
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(beginShareLocationMsg:)
                                                     name:kBeginShareLocation
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(endShareLocationMsg:)
                                                     name:kEndShareLocation
                                                   object:nil];
        
        //消息被撤回
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(revokeMsgNotificationHandle:)
                                                     name:kRevokeMsg
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadFileFinished:)
                                                     name:KDownloadFileFinishedNotificationName
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(WillSendRedPackNotificationHandle:)
                                                     name:WillSendRedPackNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMessageList:)
                                                     name:kNotificationMessageUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionMessageList:) name:kNotificationCollectionMessageUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateHistoryMessageList:)
                                                     name:kNotificationOfflineMessageUpdate
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshTableView)
                                                     name:@"refreshTableView"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onChatRoomDestroy:)
                                                     name:kChatRoomDestroy
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onFileDidUpload:)
                                                     name:kNotificationFileDidUpload
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionImageDidLoad:) name:kNotificationEmotionImageDidLoad object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceFailed:) name:kCollectionEmotionUpdateHandleFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceSuccess:) name:kCollectionEmotionUpdateHandleSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceReloadGroupMessages:) name:kGroupChatMsgReloadNotification object:nil];
        
        //发送快捷回复
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendQuickReplyContent:) name:kNotificationSendQuickReplyContent object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadIPadViewFrame:) name:@"reloadIPadViewFrame" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        //红包
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAlipay:) name:kSendRedPack object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAuth:) name:kAlipayAuth object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoSendRedPackRnView:) name:kSendRedPackRNView object:nil];
    }
}

#pragma mark - 重新修改frame
- (void)reloadFrame {
    
    _tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.view.height - 59);
    QIMVerboseLog(@"%@",NSStringFromCGRect(_tableView.frame));
    _tableViewFrame = _tableView.frame;
    _rootViewFrame = self.view.frame;
    [[QIMMessageCellCache sharedInstance] clearUp];
    [_tableView setValue:nil forKey:@"reusableTableCells"];
    [self.textBar removeAllSubviews];
    [self.textBar removeFromSuperview];
    self.textBar = nil;
    [QIMTextBar clearALLTextBar];
    [self.view addSubview:self.textBar];
    [self refreshTableView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadIPadLeftView" object:nil];
    });
}

#pragma mark - 监听屏幕旋转

- (void)statusBarOrientationChange:(NSNotification *)notification {
    QIMVerboseLog(@"屏幕发送旋转 : %@", notification);
    if ([[QIMKit sharedInstance] getIsIpad]) {
        [self reloadIPadViewFrame:notification];
    }
}

- (void)reloadIPadViewFrame:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.preferredContentSize = CGSizeMake([[QIMWindowManager shareInstance] getDetailWidth], [[UIScreen mainScreen] height]);
        [self reloadFrame];
    });
}

- (void)forceReloadGroupMessages:(NSNotification *)notify {
    long long currentMaxGroupTime = [[QIMKit sharedInstance] getMaxMsgTimeStampByXmppId:self.chatId];
   QIMMessageModel *msg = [self.messageManager.dataSource lastObject];
    long long currentGroupTime = msg.messageDate;
    if (currentGroupTime < currentMaxGroupTime) {
        QIMVerboseLog(@"重新Reload 群组聊天会话框");
        [self setProgressHUDDetailsLabelText:@"重新加载消息中..."];
        [self loadData];
        [self closeHUD];
        QIMVerboseLog(@"重新Reload 群组聊天会话框结束");
    }
}

//lilu 9.19表情收藏成功通知
- (MBProgressHUD *)progressHUD {
    
    if (!_progressHUD) {
        
        _progressHUD = [[MBProgressHUD alloc] initWithFrame:self.view.bounds];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.center = self.view.center;
        _progressHUD.minShowTime = 0.7;
        [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    }
    [_progressHUD show:YES];
    return _progressHUD;
}

- (void)setProgressHUDDetailsLabelText:(NSString *)text {
    
    [self.progressHUD setDetailsLabelText:text];
}

- (void)closeHUD {
    if (self.progressHUD) {
        [self.progressHUD hide:YES];
    }
}

// 跳转rn发红包页面
- (void)gotoSendRedPackRnView:(NSNotificationCenter *)notify {
    [QIMFastEntrance openSendRedPacket:self.chatId isRoom:true];
}

- (void)showAlipayAlterMessage:(NSString *) msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Reminder"] message:msg delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
        [alertView show];
    });
}
//唤起支付宝支付
- (void)callAlipay:(NSNotification *)notify {
    //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
    NSString *payParams = [notify.object objectForKey:@"payParams"];
    NSString *appScheme = @"impay";
    dispatch_async(dispatch_get_main_queue(), ^{
        if(payParams && payParams.length > 0){
            [[AlipaySDK defaultService] payOrder:payParams fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
                NSInteger statusCode = [[resultDic objectForKey:@"resultStatus"] intValue];
                if(statusCode == 9000){//支付成功
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAlipaySuccess object:nil];
                }else if(statusCode == 6001){//用户取消
                    [self showAlipayAlterMessage:@"支付取消！"];
                }else{//支付失败
                    [self showAlipayAlterMessage:@"支付失败！"];
                }
            }];
        }else{
            [self showAlipayAlterMessage:@"支付失败！"];
        }
    });
}

//唤起支付宝认证
- (void)callAuth:(NSNotification *)notify {
    NSString *appScheme = @"impay";
    NSString *authInfoStr = [notify.object objectForKey:@"authInfo"];
    if(authInfoStr && authInfoStr.length > 0){
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfoStr
                                         fromScheme:appScheme
                                           callback:^(NSDictionary *resultDic) {
                                               NSLog(@"result = %@",resultDic);
                                               // 解析 auth code
                                               NSString *result = resultDic[@"result"];
                                               NSString *openid = nil;
                                               NSString *aliuid = nil;
                                               if (result.length>0) {
                                                   NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                                                   for (NSString *subResult in resultArr) {
                                                       if (subResult.length > 15 && [subResult hasPrefix:@"alipay_open_id="]) {
                                                           openid = [subResult substringFromIndex:15];
                                                           continue;
                                                       } else if(subResult.length > 8 && [subResult hasPrefix:@"user_id="]){
                                                           aliuid = [subResult substringFromIndex:8];
                                                           continue;
                                                       }
                                                   }
                                               }
                                               NSLog(@"授权结果 openid = %@", openid?:@"");
                                               if(openid && aliuid){
                                                   [[QIMKit sharedInstance] bindAlipayAccount:openid withAliUid:aliuid userId:[QIMKit getLastUserName]];
                                               }
                                           }];
    }else{
        //获取绑定关系失败
        [self showAlipayAlterMessage:@"获取绑定关系失败！"];
    }
}

- (void)collectEmojiFaceSuccess:(NSNotification *)notify {
    
    [self setProgressHUDDetailsLabelText:[NSBundle qim_localizedStringForKey:@"Added"]];
    [self closeHUD];
}

- (void)collectEmojiFaceFailed:(NSNotification *)notify {
    [self setProgressHUDDetailsLabelText:[NSBundle qim_localizedStringForKey:@"Failed to add to stickers"]];
    [self closeHUD];
}

- (void)keyBoardWillShow:(NSNotification *)notify {
    if (self.netWorkSearch == YES) {
        self.netWorkSearch = NO;
        self.fastMsgTimeStamp = 0;
        [self initNotifications];
        self.tableView.mj_footer = nil;
        [self loadData];
    }
    [self scrollToBottom_tableView];
}

- (void)onChatRoomDestroy:(NSNotification *)notify {
    id obj = [notify object];
    if([obj isKindOfClass:[NSString class]]){
        if ([self.chatId isEqualToString:obj]) {
            [self goBack:nil];
        }
    } else {
        // 目前只有上边两种可能
    }
}

- (void)initJoinShareView {
    
    if (_joinShareLctView == nil) {
        
        _joinShareLctView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _joinShareLctView.backgroundColor = [UIColor qim_colorWithHex:0x808e94 alpha:0.85];
        [self.view addSubview:_joinShareLctView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onJoinShareViewClick)];
        [_joinShareLctView addGestureRecognizer:tap];
        
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:_shareFromId];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, _joinShareLctView.width - 100, _joinShareLctView.height)];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [tipsLabel setFont:[UIFont systemFontOfSize:14]];
        tipsLabel.textColor = [UIColor whiteColor];
        [tipsLabel setText:[NSString stringWithFormat:@"%@%@", [userInfo objectForKey:@"Name"],[NSBundle qim_localizedStringForKey:@"Location sharing"]]];
        [_joinShareLctView addSubview:tipsLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"Arrow"]];
        [arrowImageView setFrame:CGRectMake(_joinShareLctView.right - 40, (_joinShareLctView.height - arrowImageView.width) / 2.0, arrowImageView.width, arrowImageView.height)];
        [_joinShareLctView addSubview:arrowImageView];
        
        [self.view addSubview:_joinShareLctView];
    }
}

- (void)updateGroupNickName:(NSNotification *)notify {
    
    NSArray *groupIds = notify.object;
    if ([groupIds isKindOfClass:[NSArray class]] && [groupIds containsObject:self.chatId]) {
        
        NSDictionary *cardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.chatId];
        [self setTitle:[cardDic objectForKey:@"Name"]];
        [self.navigationItem setTitle:self.title];
        [self.titleLabel setText:self.title];
    }
}

- (void)checkAddNewMsgTag {
    
   QIMMessageModel *firstMsg = [self.messageManager.dataSource firstObject];
    if (firstMsg.messageDate > _readedMsgTimeStamp) {
        
        return;
    }
    int index = 0;
    BOOL needAdd = NO;
    for (QIMMessageModel *msg in self.messageManager.dataSource) {
        
        if (msg.messageDate >= _readedMsgTimeStamp) {
            
            needAdd = YES;
            break;
        }
        index++;
    }
    if (needAdd) {
        
        QIMMessageModel *msg = [QIMMessageModel new];
        [msg setMessageType:QIMMessageType_NewMsgTag];
        [self.messageManager.dataSource insertObject:msg atIndex:index + 1];
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
        [self setNeedShowNewMsgTagCell:NO];
    }
}

- (void)hiddenNotReadTipView {
    
    if (_readMsgTipView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [_readMsgTipView setFrame:CGRectMake(self.view.width, _readMsgTipView.top, _readMsgTipView.width, _readMsgTipView.height)];
        }                completion:^(BOOL finished) {
            
            _readMsgTipView = nil;
        }];
    }
}

- (void)moveToFirstNotReadMsg {
    
   self.readedMsgTimeStamp = [[QIMKit sharedInstance] getReadedTimeStampForUserId:self.chatId WithRealJid:self.chatId WithMsgDirection:QIMMessageDirection_Received withUnReadCount:self.notReadCount];
    __weak __typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] getMsgListByUserId:self.chatId
                                    WithRealJid:self.chatId
                                        FromTimeStamp:_readedMsgTimeStamp
                                         WithComplete:^(NSArray *list) {
                                             [weakSelf updateGroupUsersHeadImgForMsgs:list];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 weakSelf.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                                                 [weakSelf checkAddNewMsgTag];
                                                 [weakSelf.tableView reloadData];
                                                 [weakSelf hiddenNotReadTipView];
                                                 [weakSelf hiddenNotReadAtMsgTipView];
                                                 [weakSelf addImageToImageList];
                                                 [[QIMKit sharedInstance] clearAtMeMessageWithJid:weakSelf.chatId];
                                                 if (weakSelf.messageManager.dataSource.count > 0) {
                                                     
                                                     [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(0) inSection:0]
                                                                           atScrollPosition:UITableViewScrollPositionTop
                                                                                   animated:YES];
                                                 }
                                             });
                                         }];
}

- (void)showNotReadAtMsgView {
    //未读消息按钮
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *atMeMessageArray = [[QIMKit sharedInstance] getHasAtMeByJid:self.chatId];
        if (atMeMessageArray.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _notReadAtMsgTipView = [[QIMNotReadATMsgTipView alloc] initWithNotReadAtMsgCount:atMeMessageArray.count];
                [_notReadAtMsgTipView setFrame:CGRectMake(self.view.width, 60, _notReadAtMsgTipView.width, _notReadAtMsgTipView.height)];
                [_notReadAtMsgTipView setNotReadAtMsgDelegate:self];
                [self.view addSubview:_notReadAtMsgTipView];
                [UIView animateWithDuration:0.3 animations:^{
                    [UIView setAnimationDelay:0.1];
                    [_notReadAtMsgTipView setFrame:CGRectMake(self.view.width - _notReadAtMsgTipView.width, _notReadAtMsgTipView.top, _notReadAtMsgTipView.width, _notReadAtMsgTipView.height)];
                }];
            });
        }
    });
}

- (void)updateNotAtReadAtMsgWithMsgArray:(NSArray *)array {
    NSMutableArray *msgIds = [NSMutableArray arrayWithCapacity:3];
    for (QIMMessageModel *msg in array) {
        [msgIds addObject:msg.messageId];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [[QIMKit sharedInstance] updateAtMeMessageWithJid:self.chatId withMsgIds:msgIds withReadState:QIMAtMsgHasReadState];
    });
}

- (void)updateNotReadAtMsgTipView {
    NSArray *atMsgArray = [[QIMKit sharedInstance] getHasAtMeByJid:self.chatId];
    if (atMsgArray.count > 0) {
        [_notReadAtMsgTipView updateNotReadAtMsgCount:atMsgArray.count];
    } else {
        [self hiddenNotReadAtMsgTipView];
    }
}

- (void)hiddenNotReadAtMsgTipView {
    
    if (_notReadAtMsgTipView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [_notReadAtMsgTipView setFrame:CGRectMake(self.view.width, _notReadAtMsgTipView.top, _notReadAtMsgTipView.width, _notReadAtMsgTipView.height)];
        }                completion:^(BOOL finished) {
            
            _notReadAtMsgTipView = nil;
        }];
    }
}

- (void)moveToLastNotReadAtMsg {
    __weak __typeof(self) weakSelf = self;
    NSArray *atMsgArray = [[QIMKit sharedInstance] getHasAtMeByJid:self.chatId];
    if (atMsgArray.count > 0) {
        QIMVerboseLog(@"atMsgArray : %@", atMsgArray);
        NSDictionary *groupAtMsgDic = [atMsgArray lastObject];
        long long messageDate = [[groupAtMsgDic objectForKey:@"MsgDate"] longLongValue];
        NSString *msgId = [groupAtMsgDic objectForKey:@"MsgId"];
        if (messageDate <= 0) {
            QIMMessageModel *msgModel = [[QIMKit sharedInstance] getMsgByMsgId:msgId];
            messageDate = msgModel.messageDate;
        }
        [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:self.chatId FromTimeStamp:messageDate WithComplete:^(NSArray *list) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                BOOL editing = weakSelf.tableView.editing;
                [weakSelf.tableView reloadData];
                weakSelf.tableView.editing = editing;
                [weakSelf addImageToImageList];
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                [[QIMEmotionSpirits sharedInstance] setDataCount:(int) weakSelf.messageManager.dataSource.count];
                [[QIMKit sharedInstance] updateAtMeMessageWithJid:self.chatId withMsgIds:@[msgId] withReadState:QIMAtMsgHasReadState];
                [weakSelf updateNotReadAtMsgTipView];
                //标记已读
                [weakSelf markReadedForChatRoom];
            });
        }];
    } else {
        [self hiddenNotReadAtMsgTipView];
    }
}

- (void)loadNetWorkData {
    __weak __typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] getRemoteSearchMsgListByUserId:self.chatId WithRealJid:self.chatId withVersion:self.fastMsgTimeStamp withDirection:QIMGetMsgDirectionUp WithLimit:20 WithOffset:0 WithComplete:^(NSArray *list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageManager.dataSource removeAllObjects];
            [self.messageManager.dataSource addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [weakSelf addImageToImageList];
        });
    }];
}

- (void)reloadTableData {
    if (self.netWorkSearch) {
        [self loadNetWorkData];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    if (self.chatType == ChatType_CollectionChat) {
        NSArray *list = [[QIMKit sharedInstance] getCollectionMsgListForUserId:self.bindId originUserId:self.chatId];
            self.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL editing = self.tableView.editing;
            [weakSelf.tableView reloadData];
            weakSelf.tableView.editing = editing;
            [weakSelf scrollToBottom_tableView];
            [weakSelf addImageToImageList];
            [[QIMEmotionSpirits sharedInstance] setDataCount:(int)weakSelf.messageManager.dataSource.count];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            if (weakSelf.fastMsgTimeStamp > 0) {
                [[QIMKit sharedInstance] getMsgListByUserId:weakSelf.chatId WithRealJid:weakSelf.chatId FromTimeStamp:weakSelf.fastMsgTimeStamp WithComplete:^(NSArray *list) {
                        weakSelf.messageManager.dataSource = [NSMutableArray arrayWithArray:list];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL editing = weakSelf.tableView.editing;
                        [weakSelf.tableView reloadData];
                        weakSelf.tableView.editing = editing;
                        [weakSelf addImageToImageList];
                        [[QIMEmotionSpirits sharedInstance] setDataCount:(int) weakSelf.messageManager.dataSource.count];
                        //标记已读
                        [weakSelf markReadedForChatRoom];
                    });
                }];
            } else {
                [[QIMKit sharedInstance] getMsgListByUserId:weakSelf.chatId
                                                WithRealJid:weakSelf.chatId
                                                  WithLimit:kPageCount
                                                 WithOffset:0
                                               withLoadMore:NO
                                               WithComplete:^(NSArray *list) {
                                                       weakSelf.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       BOOL editing = weakSelf.tableView.editing;
                                                       [weakSelf.tableView reloadData];
                                                       weakSelf.tableView.editing = editing;
                                                       [weakSelf scrollBottom];
                                                       [weakSelf addImageToImageList];
                                                       dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(0.5 * NSEC_PER_SEC));
                                                       dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                                         [[QIMEmotionSpirits sharedInstance] setDataCount:(int) weakSelf.messageManager.dataSource.count];
                                                         //标记艾特消息已读
                                                         [weakSelf updateNotAtReadAtMsgWithMsgArray:list];
                                                         [weakSelf showNotReadAtMsgView];
                                                         //标记已读
                                                         [weakSelf markReadedForChatRoom];
                                                       });
                                                   });
                                               }];
            }
        });
    }
}

- (void)loadData {

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(reloadTableData)
                                               object:nil];
    [self performSelector:@selector(reloadTableData) withObject:nil afterDelay:0.05];
}

- (void)markReadedForChatRoom {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        if (self.messageManager.dataSource.count > 0) {
            [[QIMKit sharedInstance] clearNotReadMsgByGroupId:self.chatId];
        }
    });
}

- (void)leftBarBtnClicked:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
    // Mark by OldiPad
    if ([[QIMKit sharedInstance] getIsIpad] == NO) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
#if __has_include("QIMIPadWindowManager.h")
        [[QIMIPadWindowManager sharedInstance] showOriginLaunchDetailVC];
#endif
    }
    //Mark by newipad
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    QIMVerboseLog(@"didReceiveMemoryWarning");
}

- (void)selfPopedViewController {
    
    [super selfPopedViewController];
    [[QIMKit sharedInstance] setNotSendText:[self.textBar getSendAttributedText]
                                 inputItems:[self.textBar getAttributedTextItems]
                                     ForJid:self.chatId];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
}

- (void)goBack:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)refreshChatBGImageView {
    
    if (!_chatBGImageView) {
        
        _chatBGImageView = [[UIImageView alloc] initWithFrame:_tableView.bounds];
        _chatBGImageView.contentMode = UIViewContentModeScaleAspectFill;
        _chatBGImageView.clipsToBounds = YES;
    }
    if ([[QIMKit sharedInstance] waterMarkState] == YES) {
        [[QIMChatBgManager sharedInstance] getChatBgById:[QIMKit getLastUserName] ByName:[[QIMKit sharedInstance] getMyNickName] WithReset:NO Complete:^(UIImage * _Nonnull bgImage) {
            _chatBGImageView.image = bgImage;
            _tableView.backgroundView = _chatBGImageView;
        }];
    }
}

- (void)onFileDidUpload:(NSNotification *)notify {
}

- (void)expandViewItemHandleNotificationHandle:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *trId = notify.object;
        if ([trId isEqualToString:QIMTextBarExpandViewItem_VideoCall]) {
#if __has_include("QIMWebRTCMeetingClient.h")
            [[QIMWebRTCMeetingClient sharedInstance] setGroupId:self.chatId];
            NSDictionary *groupCardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.chatId];
            NSString *groupName = [groupCardDic objectForKey:@"Name"];
            [[QIMWebRTCMeetingClient sharedInstance] createRoomById:self.chatId WithRoomName:groupName];
#endif
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_MyFiles]) {
            
            QIMFileManagerViewController *fileManagerVC = [[QIMFileManagerViewController alloc] init];
            fileManagerVC.isSelect = YES;
            fileManagerVC.userId = self.chatId;
            fileManagerVC.messageSaveType = ChatType_GroupChat;
            
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:fileManagerVC];
            //mark by oldipad
            if ([[QIMKit sharedInstance] getIsIpad] == YES) {
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
#if __has_include("QIMIPadWindowManager.h")
                [[[QIMIPadWindowManager sharedInstance] detailVC] presentViewController:nav animated:YES completion:nil];
#endif
            } else {
                [self presentViewController:nav animated:YES completion:nil];
            }
        
            /* mark by newipad
             [self presentViewController:nav animated:YES completion:nil];
             */
            
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_ShareCard]) {
            
            QIMOrganizationalVC *listVc = [[QIMOrganizationalVC alloc] init];
            [listVc setShareCard:YES];
            [listVc setShareCardDelegate:self];
            //        listVC.isTransfer = YES;
            _expandViewItemType = QIMTextBarExpandViewItemType_ShareCard;
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:listVc];
            [[self navigationController] presentViewController:nav animated:YES completion:^{
            }];
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_RedPack]) {
            
            QIMVerboseLog(@"我是 群红包，点我 干哈？");
            if ([QIMKit getQIMProjectType] == QIMProjectTypeStartalk || (![[[QIMKit sharedInstance] getDomain] isEqualToString:@"ejabhost1"] && ![[[QIMKit sharedInstance] getDomain] isEqualToString:@"ejabhost2"])) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[QIMKit sharedInstance] getBindPayAccount:[QIMKit getLastUserName] withCallBack:^(BOOL successed){
                        if(successed){
                            [QIMFastEntrance openSendRedPacket:self.chatId isRoom:true];
                        }else{
                            
                        }
                    }];
                });
            } else {
                if ([[QIMKit sharedInstance] redPackageUrlHost]) {
                    QIMWebView *webView = [[QIMWebView alloc] init];
                    webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&group_id=%@&rk=%@&q_d=%@", [[QIMKit sharedInstance] redPackageUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey],  [[QIMKit sharedInstance] getDomain]];
                    //        webView.navBarHidden = YES;
                    [webView setFromRegPackage:YES];
                    [self.navigationController pushViewController:webView animated:YES];
                } else {
                    QIMVerboseLog(@"当前红包URLHost为空，不支持该功能");
                }
            }
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_AACollection]) {
            
            if ([[QIMKit sharedInstance] aaCollectionUrlHost]) {
                QIMWebView *webView = [[QIMWebView alloc] init];
                webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&group_id=%@&rk=%@&q_d=%@", [[QIMKit sharedInstance] aaCollectionUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey],  [[QIMKit sharedInstance] getDomain]];
                webView.navBarHidden = YES;
                [webView setFromRegPackage:YES];
                [self.navigationController pushViewController:webView animated:YES];
            } else {
                QIMVerboseLog(@"当前AA收款URLHost为空，不支持该功能");
            }
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_SendActivity]) {
            if ([[QIMKit sharedInstance] redPackageUrlHost]) {
                //发活动
                QIMWebView *webView = [[QIMWebView alloc] init];
                webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&group_id=%@&rk=%@&action="@"event", [[QIMKit sharedInstance] redPackageUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey]];
                [webView setFromRegPackage:YES];
                webView.navBarHidden = YES;
                [self.navigationController pushViewController:webView animated:YES];
            } else {
                QIMVerboseLog(@"当前发活动URLHost为空，不支持该功能");
            }
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_SendProduct]) {
            
            QIMPushProductViewController *pushProVC = [[QIMPushProductViewController alloc] init];
            pushProVC.delegate = self;
            [self.navigationController pushViewController:pushProVC animated:YES];
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_Location]) {
            [QIMAuthorizationManager sharedManager].authorizedBlock = ^{
                UserLocationViewController *userLct = [[UserLocationViewController alloc] init];
                userLct.delegate = self;
                //mark by oldipad
                if ([[QIMKit sharedInstance] getIsIpad] == YES) {
                    userLct.modalPresentationStyle = UIModalPresentationCurrentContext;
#if __has_include("QIMIPadWindowManager.h")
                    [[[QIMIPadWindowManager sharedInstance] detailVC] presentViewController:userLct animated:YES completion:nil];
#endif
                } else {
                    [self.navigationController presentViewController:userLct animated:YES completion:nil];
                }
                /* mark by newipad
                [self.navigationController presentViewController:userLct animated:YES completion:nil];
                 */
            };
            [[QIMAuthorizationManager sharedManager] requestAuthorizationWithType:ENUM_QAM_AuthorizationTypeLocation];
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_TouPiao]) {
            NSDictionary *trdExtendDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
            NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
            if (linkUrl.length > 0) {
                if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@username=%@&company=qunar&group_id=%@&rk=%@", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [QIMKit getLastUserName], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] remoteKey]];
                } else {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[QIMKit sharedInstance] getLastJid],  [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
                }
                [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
            }
        } else if ([trId isEqualToString:QIMTextBarExpandViewItem_Task_list]) {
            NSDictionary *trdExtendDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
            NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
            if (linkUrl.length > 0) {
                if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@username=%@&company=qunar&group_id=%@&rk=%@", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [QIMKit getLastUserName], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] remoteKey]];
                } else {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[QIMKit sharedInstance] getLastJid], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
                }
                [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
            }
        } else {
            NSDictionary *trdExtendDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
            int linkType = [[trdExtendDic objectForKey:@"linkType"] intValue];
            BOOL openQIMRN = linkType & 4;
            BOOL openRequeset = linkType & 2;
            BOOL openWebView = linkType & 1;
            NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
            if (openQIMRN) {
                [QIMFastEntrance openQIMRNWithScheme:linkUrl withChatId:self.chatId withRealJid:nil withChatType:self.chatType];
            } else if (openRequeset) {
                [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:linkUrl withChatId:self.chatId withRealJid:nil withChatType:self.chatType];
            } else {
                if (linkUrl.length > 0) {
                    if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                        linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[QIMKit sharedInstance] getLastJid], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
                    } else {
                        linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", ([linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[QIMKit sharedInstance] getLastJid], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
                    }
                    [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
                }
            }
        }
    });
}

- (void)msgDidSendNotificationHandle:(NSNotification *)notify {
    
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    //消息发送成功，更新消息状态，刷新tableView
    for (QIMMessageModel *msg in self.messageManager.dataSource) {
        
        if ([[msg messageId] isEqualToString:msgID]) {
            
            if (msg.messageSendState < QIMMessageSendState_Success) {
                
                msg.messageSendState = QIMMessageSendState_Success;
                
            }
            break;
        }
    }
}

- (void)msgSendFailedNotificationHandle:(NSNotification *)notify {
    
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    
    //消息发送失败，更新消息状态，刷新tableView
    for (QIMMessageModel *msg in self.messageManager.dataSource) {
        //找到对应的msg
        if ([[msg messageId] isEqualToString:msgID]) {
            
            if (msg.messageSendState < QIMMessageSendState_Faild) {
                
                msg.messageSendState = QIMMessageSendState_Faild;
            }
            break;
        }
    }
}

- (void)removeFailedMsg {
    
    QIMMessageModel *message = _resendMsg;
    for (QIMMessageModel *msg in self.messageManager.dataSource) {
        
        if ([msg isEqual:message]) {
            
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            
            [self.messageManager.dataSource removeObject:msg];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [[QIMKit sharedInstance] deleteMsg:message ByJid:self.chatId];
            break;
        }
    }
}

- (void)reSendMsg {
    QIMMessageModel *message = _resendMsg;
    [self removeFailedMsg];
    if (message.messageType == QIMMessageType_LocalShare) {
        [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
    } else if (message.messageType == QIMMessageType_Voice) {

        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSString *fileName = [infoDic objectForKey:@"FileName"];
        NSNumber *Seconds = [infoDic objectForKey:@"Seconds"];
        NSString *filePath = [QIMVoicePathManage getPathByFileName:fileName ofType:@"amr"];
        [self sendVoiceWithDuration:[Seconds intValue] WithFileName:fileName AndFilePath:filePath];
    } else if (message.messageType == QIMMessageType_Text) {
        if ([self isImageMessage:message.message]) {
            
            QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessage:message];
            QIMImageStorage *imageStorage = textContainer.textStorages.lastObject;
            NSString *imagePath = imageStorage.imageURL.absoluteString;
            if ([imagePath containsString:@"LocalFileName"]) {
                imagePath = [[imagePath componentsSeparatedByString:@"LocalFileName="] lastObject];
                [self qim_textbarSendImageWithImagePath:imagePath];
            } else {
                //图片上传成功，发消息失败
                [[QIMKit sharedInstance] sendMessage:message ToUserId:message.to];
            }
        } else {
            
            message = [[QIMKit sharedInstance] createMessageWithMsg:message.message extenddInfo:message.extendInformation userId:self.chatId userType:ChatType_GroupChat msgType:message.messageType forMsgId:_resendMsg.messageId];
            
            [self.messageManager.dataSource addObject:message];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            message = [[QIMKit sharedInstance] sendMessage:message ToUserId:self.chatId];
            [self scrollToBottomWithCheck:YES];
        }
    } else if (message.messageType == QIMMessageType_CardShare) {
        [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
    } else if (message.messageType == QIMMessageType_SmallVideo) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSString *filePath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:[infoDic objectForKey:@"ThumbName"] ? [infoDic objectForKey:@"ThumbName"] : @""];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        
        NSString *videoPath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingFormat:@"/%@", [infoDic objectForKey:@"FileName"]];
        
        [self sendVideoPath:videoPath WithThumbImage:image WithFileSizeStr:[infoDic objectForKey:@"FileSize"] WithVideoDuration:[[infoDic objectForKey:@"Duration"] floatValue] forMsgId:_resendMsg.messageId];
    } else if (message.messageType == QIMMessageType_File) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSString *HttpUrl = [infoDic objectForKey:@"HttpUrl"];
        NSString *FileName = [infoDic objectForKey:@"FileName"];
        if (HttpUrl.length > 0) {
            //文件上传成功了，消息发送失败
            [[QIMKit sharedInstance] sendMessage:message ToUserId:message.to];
        } else {
            //文件上传失败了
            [self qim_textbarSendFileWithFileName:FileName];
        }
    } else {
        
    }
    _resendMsg = nil;
}

- (void)msgReSendNotificationHandle:(NSNotification *)notify {
    _resendMsg = notify.object;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Resend the message?"] message:nil delegate:self cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle qim_localizedStringForKey:@"Delete"], [NSBundle qim_localizedStringForKey:@"Resend"], nil];
    
    alertView.tag = kReSendMsgAlertViewTag;
    alertView.delegate = self;
    [alertView show];
    return;
}

- (void)revokeMsgNotificationHandle:(NSNotification *)notify {
    
    NSString *jid = notify.object;
    NSString *msgID = [notify.userInfo objectForKey:@"MsgId"];
    NSString *content = [notify.userInfo objectForKey:@"Content"];
    for (QIMMessageModel *msg in self.messageManager.dataSource) {
        
        if ([msg.messageId isEqualToString:msgID]) {
            
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            [(QIMMessageModel *) msg setMessageType:QIMMessageType_Revoke];
            [self.messageManager.dataSource replaceObjectAtIndex:index withObject:msg];
            [[QIMKit sharedInstance] updateMsg:msg ByJid:self.chatId];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[self.tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [self.tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

- (void)WillSendRedPackNotificationHandle:(NSNotification *)noti {
    NSString *infoStr = [NSString qim_stringWithBase64EncodedString:noti.object];
   QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"【红包】请升级最新版本客户端查看红包~"
                                                           extenddInfo:infoStr
                                                                userId:self.chatId
                                                              userType:ChatType_GroupChat
                                                               msgType:QIMMessageType_RedPack];
    
    [self.messageManager.dataSource addObject:msg];
    [self updateGroupUsersHeadImgForMsgs:@[msg]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    [self addImageToImageList];
    msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
}

- (BOOL)isImageMessage:(NSString *)msg {
    
    NSString *regulaStr = @"\\[obj type=\"(.*?)\" value=\"(.*?)\"(.*?)\\]";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:msg options:0 range:NSMakeRange(0, [msg length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        
        NSRange firstRange = [match rangeAtIndex:1];
        NSString *type = [msg substringWithRange:firstRange];
        if ([type isEqualToString:@"image"]) {
            
            return YES;
        }
    }
    return NO;
}

#pragma mark - QIMContactSelectionViewControllerDelegate

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC chatVC:(QIMChatVC *)vc {
    
   QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:QIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:[NSString stringWithFormat:@"%@的聊天记录", self.title] forKey:@"title"];
    [infoDic setQIMSafeObject:@"" forKey:@"desc"];
    [infoDic setQIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    [[QIMKit sharedInstance] qim_uploadFileWithFilePath:_jsonFilePath forMessage:msg];
}

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC groupChatVC:(QIMGroupChatVC *)vc {
   QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:QIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:[NSString stringWithFormat:@"%@的聊天记录", self.title] forKey:@"title"];
    [infoDic setQIMSafeObject:@"" forKey:@"desc"];
    [infoDic setQIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    
    [[QIMKit sharedInstance] qim_uploadFileWithFilePath:_jsonFilePath forMessage:msg];
}


#pragma mark - QIMOrganizationalVCDelegate

- (void)selectShareContactWithJid:(NSString *)jid {
    NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    if (_expandViewItemType == QIMTextBarExpandViewItemType_ShareCard) {
        //分享名片 选择的user
        [self sendMessage:[NSString stringWithFormat:@"分享名片：\n昵称：%@\n部门：%@", [infoDic objectForKey:@"Name"], [infoDic objectForKey:@"DescInfo"]] WithInfo:[NSString stringWithFormat:@"{\"userId\":\"%@\"}", [infoDic objectForKey:@"XmppId"]] ForMsgType:QIMMessageType_CardShare];
    }
}

#pragma mark - navbar delegate

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[QIMNavBackBtn sharedInstance] removeTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

#if kHasVoice

#pragma mark - Audio Method

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId {
    
    return [msgId isEqualToString:self.currentPlayVoiceMsgId];
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFilePath:(NSString *)filePath {
    
    self.currentPlayVoiceMsgId = msgId;
    self.isNoReadVoice = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] playVoiceIsNoReadWithMsgId:msgId ChatId:self.chatId];
    if (msgId && filePath) {
        self.currentPlayVoiceIndex = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getIndexOfMsgIdWithChatId:self.chatId msgId:msgId];
        // 开始播放
        if ([filePath qim_hasPrefixHttpHeader]) {
            [self.remoteAudioPlayer prepareForURL:filePath playAfterReady:YES];
        } else {
            [self.remoteAudioPlayer prepareForFilePath:filePath playAfterReady:YES];
        }
    } else {
        // 结束播放
        [self.remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    NSString *messageId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBeginToPlay
                                                        object:messageId];
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl {
    
    self.currentPlayVoiceMsgId = msgId;
    self.isNoReadVoice = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] playVoiceIsNoReadWithMsgId:msgId ChatId:self.chatId];
    if (msgId) {
        self.currentPlayVoiceIndex = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getIndexOfMsgIdWithChatId:self.chatId msgId:msgId];
        [self.remoteAudioPlayer prepareForFileName:fileName andVoiceUrl:voiceUrl playAfterReady:YES];
    } else {
        [self.remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    NSString *messageId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBeginToPlay
                                                        object:messageId];
}

- (void)remoteAudioPlayerReady:(QIMRemoteAudioPlayer *)player {
    
    NSString *msgId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:msgId ChatId:self.chatId withState:YES];
}

- (void)remoteAudioPlayerErrorOccured:(QIMRemoteAudioPlayer *)player
                        withErrorCode:(QIMRemoteAudioPlayerErrorCode)errorCode {
}

- (void)remoteAudioPlayerDidStartPlaying:(QIMRemoteAudioPlayer *)player {
    
    [self updateCurrentPlayVoiceTime];
}

- (void)remoteAudioPlayerDidFinishPlaying:(QIMRemoteAudioPlayer *)player {
    // 1. 告诉播放者，我播放完毕了
    NSString *msgId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyEndPlay
                                                        object:msgId];
    self.currentPlayVoiceMsgId = nil;
    NSInteger count = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getVisibleNoReadSoundsCountWithChatId:self.chatId];
    if (self.isNoReadVoice) {
        if (count) {
            if (self.currentPlayVoiceIndex <= count - 1 && self.currentPlayVoiceIndex >= 0 && self.currentPlayVoiceIndex != NSNotFound) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kAutoPlayNextVoiceMsgHandleNotification object:@(self.currentPlayVoiceIndex)];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPlayAllVoiceMsgFinishHandleNotification object:nil];
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPlayAllVoiceMsgFinishHandleNotification object:nil];
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayAllVoiceMsgFinishHandleNotification object:nil];
    }
}

- (void)updateCurrentPlayVoiceTime {
    
    if (_currentPlayVoiceMsgId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPlayVoiceTime object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:self.remoteAudioPlayer.currentTime], kNotifyPlayVoiceTimeTime, _currentPlayVoiceMsgId, kNotifyPlayVoiceTimeMsgId, nil]];
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(updateCurrentPlayVoiceTime)
                                                   object:nil];
        [self performSelector:@selector(updateCurrentPlayVoiceTime) withObject:nil afterDelay:0.5];
    }
}

- (int)playCurrentTime {
    
    return self.remoteAudioPlayer.currentTime;
}

- (void)downloadProgress:(float)newProgress {
    
    if (_currentPlayVoiceMsgId) {
        
        _currentDownloadProcess = newProgress;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDownloadProgress object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:_currentDownloadProcess], kNotifyDownloadProgressProgress, _currentPlayVoiceMsgId, kNotifyDownloadProgressMsgId, nil]];
    } else {
        _currentDownloadProcess = 1;
    }
}

- (double)getCurrentDownloadProgress {
    
    return _currentDownloadProcess;
}

#endif

#pragma mark - Cell Delegate

- (void)openWebUrl:(NSString *)url {
    QIMWebView *webVC = [[QIMWebView alloc] init];
    [webVC setUrl:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)refreshTableViewCell:(UITableViewCell *)cell {
    if (cell && [cell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        QIMMessageModel *message = [self.messageManager.dataSource objectAtIndex:indexPath.row];
        [_cellSizeDic removeObjectForKey:message.messageId];
        if (indexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)processEvent:(int)event withMessage:(id)message {
    QIMMessageModel *eventMsg = (QIMMessageModel *)message;
    if (self.tableView.editing) {
        [self cancelForwardHandle:nil];
    }
    
    if (event == MA_Repeater) {
        QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
        [controller setMessage:[QIMMessageParser reductionMessageForMessage:eventMsg]];
        [[self navigationController] presentViewController:nav animated:YES completion:nil];
        
    } else if (event == MA_Delete) {
        
        for (QIMMessageModel *msg in self.messageManager.dataSource) {
            
            if ([msg.messageId isEqualToString:[(QIMMessageModel *) eventMsg messageId]]) {
                
                if ([msg.messageId isEqualToString:[(QIMMessageModel *) eventMsg messageId]]) {
                    
                    NSMutableArray *deleteIndexs = [NSMutableArray array];
                    NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
                    [deleteIndexs addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                   QIMMessageModel *timeMsg = nil;
                    if (index > 0) {
                        
                       QIMMessageModel *tempMsg = [self.messageManager.dataSource objectAtIndex:index - 1];
                        if (tempMsg.messageType == QIMMessageType_Time) {
                            
                            timeMsg = tempMsg;
                            if (index + 1 < self.messageManager.dataSource.count) {
                                
                               QIMMessageModel *nMsg = [self.messageManager.dataSource objectAtIndex:index + 1];
                                if (nMsg.messageType != QIMMessageType_Time) {
                                    
                                    timeMsg = nil;
                                }
                            }
                        }
                    }
                    if (timeMsg) {
                        
                        [deleteIndexs addObject:[NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:timeMsg]
                                                                   inSection:0]];
                        [self.messageManager.dataSource removeObject:timeMsg];
                        [[QIMKit sharedInstance] deleteMsg:timeMsg
                                                           ByJid:self.chatId];
                    }
                    
                    [self.messageManager.dataSource removeObject:msg];
                    [self.tableView deleteRowsAtIndexPaths:deleteIndexs withRowAnimation:UITableViewRowAnimationAutomatic];
                    [[QIMKit sharedInstance] deleteMsg:eventMsg ByJid:self.chatId];
                    
                }
                break;
            }
        }
        
    } else if (event == MA_ToWithdraw) {
        
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setQIMSafeObject:[[QIMKit sharedInstance] getLastJid] forKey:@"fromId"];
        [dicInfo setQIMSafeObject:[(QIMMessageModel *) eventMsg messageId] forKey:@"messageId"];
        [dicInfo setQIMSafeObject:[(QIMMessageModel *) eventMsg message] forKey:@"message"];
        NSString *msgInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
        
        [[QIMKit sharedInstance] revokeGroupMessageWithMessageId:[(QIMMessageModel *) eventMsg messageId]
                                                               message:msgInfo
                                                                 ToJid:self.chatId];
    } else if (event == MA_Favorite) {
        
        for (QIMMessageModel *msg in self.messageManager.dataSource) {
            
            if ([msg.messageId isEqualToString:[(QIMMessageModel *) eventMsg messageId]]) {
                
                [[QIMMyFavoitesManager sharedMyFavoritesManager] setMyFavoritesArrayWithMsg:eventMsg];
                
                break;
            }
        }
    } else if (event == MA_Forward) {
        self.tableView.editing = YES;
        [self.navigationController.navigationBar addSubview:[self getForwardNavView]];
        [self.navigationController.navigationBar addSubview:[self getMaskRightTitleView]];
        [self.view addSubview:self.forwardBtn];
        self.fd_interactivePopDisabled = YES;
    }else if (event == MA_Refer) {
        //引用消息
        self.textBar.isRefer = YES;
        self.textBar.referMsg = eventMsg;
    } else if (event == MA_CopyOriginMsg) {
        for (QIMMessageModel *msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(QIMMessageModel *) eventMsg messageId]]) {
                QIMVerboseLog(@"原始消息为 : %@", msg);
                NSString *originMsg = [[QIMOriginMessageParser shareParserOriginMessage] getOriginPBMessageWithMsgId:msg.messageId];
                if (originMsg.length > 0) {
                    [[UIPasteboard generalPasteboard] setString:originMsg];
                } else {
                    NSString *modelStr = [msg yy_modelToJSONString];
                    [[UIPasteboard generalPasteboard] setString:modelStr];
                }
            }
        }
    }
}

static CGPoint tableOffsetPoint;

#pragma mark - QIMAttributedLabelDelegate

- (void)attributedLabel:(QIMAttributedLabel *)attributedLabel textStorageClicked:(id <QIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    //链接link
    if ([textStorage isMemberOfClass:[QIMLinkTextStorage class]]) {
        
        QIMLinkTextStorage *storage = (QIMLinkTextStorage *) textStorage;
        if (![storage.linkData length]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Wrong_Interface"] message:[NSBundle qim_localizedStringForKey:@"Wrong_URL"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] otherButtonTitles:nil];
            [alertView show];
        } else {
            
            QIMWebView *webView = [[QIMWebView alloc] init];
            [webView setUrl:storage.linkData];
            [[self navigationController] pushViewController:webView animated:YES];
        }
    } else if ([textStorage isMemberOfClass:[QIMPhoneNumberTextStorage class]]) {
        QIMPhoneNumberTextStorage *storage = (QIMPhoneNumberTextStorage *) textStorage;
        if (storage.phoneNumData) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                
                [self presentViewController:[QIMContactManager showAlertViewControllerWithPhoneNum:storage.phoneNumData rootVc:self] animated:YES completion:nil];
            }
        }
    } else if ([textStorage isMemberOfClass:[QIMImageStorage class]]) {
        
        QIMImageStorage *storage = (QIMImageStorage *) textStorage;
        //图片
        if (storage.imageURL) {
            
            //纪录当前的浏览位置
            tableOffsetPoint = self.tableView.contentOffset;
            
            //初始化图片浏览控件
            QIMMWPhotoBrowser *browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = YES;
            browser.zoomPhotosToFill = YES;
            browser.enableSwipeToDismiss = NO;
            NSUInteger index = -1;
            for (NSUInteger i = 0; i < _imagesArr.count; i++) {
                if ([(QIMImageStorage *) _imagesArr[i] isEqual:storage]) {
                    index = i;
                    //                    browser.imageUrl = storage.imageURL;
                    break;
                }
            }
            if (index == -1 && storage.imageURL.absoluteString.length > 0) {
                if (!self.fixedImageArray) {
                    self.fixedImageArray = [NSMutableArray arrayWithCapacity:2];
                }
                [self.fixedImageArray addObject:storage.imageURL];
                index = 0;
                
            } else {
                
            }
            [browser setCurrentPhotoIndex:index];
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            
            //初始化navigation
            QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
            return;
        } else {
            
            //表情
        }
    }
}

#pragma mark - QIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser {
    if (self.fixedImageArray.count > 0) {
        return self.fixedImageArray.count;
    }
    return _imagesArr.count;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    if (self.fixedImageArray.count > 0) {
        NSString *imageUrl = [self.fixedImageArray[0] absoluteString];
        if ([imageUrl containsString:@"LocalFileName"]) {
            imageUrl = [[imageUrl componentsSeparatedByString:@"LocalFileName="] lastObject];
            imageUrl = [[QIMImageManager sharedInstance] defaultCachePathForKey:imageUrl];
            NSURL *url = [NSURL fileURLWithPath:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            return url ? [[QIMMWPhoto alloc] initWithURL:url] : nil;
        } else {
            NSURL *url = [NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            return url ? [[QIMMWPhoto alloc] initWithURL:url] : nil;
        }
    }
    
    if (index > _imagesArr.count) {
        return nil;
    }

    QIMImageStorage *storage = [_imagesArr objectAtIndex:index];
    NSString *imageHttpUrl = storage.imageURL.absoluteString;

    if ([imageHttpUrl containsString:@"LocalFileName"]) {
        imageHttpUrl = [[imageHttpUrl componentsSeparatedByString:@"LocalFileName="] lastObject];
        imageHttpUrl = [[QIMImageManager sharedInstance] defaultCachePathForKey:imageHttpUrl];
        NSURL *url = [NSURL fileURLWithPath:[imageHttpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return url ? [[QIMMWPhoto alloc] initWithURL:url] : nil;
    } else {
        if (![imageHttpUrl containsString:@"?"]) {
            imageHttpUrl = [imageHttpUrl stringByAppendingString:@"?"];
        } else {

        }
        if (![imageHttpUrl containsString:@"platform"]) {
            imageHttpUrl = [imageHttpUrl stringByAppendingString:@"&platform=touch"];
        }
        if (![imageHttpUrl containsString:@"imgtype"]) {
            imageHttpUrl = [imageHttpUrl stringByAppendingString:@"&imgtype=origin"];
        }
        if (![imageHttpUrl containsString:@"webp="]) {
            imageHttpUrl = [imageHttpUrl stringByAppendingString:@"&webp=true"];
        }
        NSURL *url = [NSURL URLWithString:[imageHttpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        return url ? [[QIMMWPhoto alloc] initWithURL:url] : nil;
    }
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        // tableView 回滚到上次浏览的位置
        [_tableView setContentOffset:tableOffsetPoint animated:YES];
        [self.fixedImageArray removeAllObjects];
    }];
}

#pragma mark - notification

- (void)emotionImageDidLoad:(NSNotification *)notify {
    for (QIMMessageModel *msg in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:notify.object]) {
            QIMTextContainer *container = [QIMMessageParser textContainerForMessage:msg fromCache:NO];
            if (container) {
                [[QIMMessageCellCache sharedInstance] setObject:container forKey:msg.messageId];
            }
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[self.tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [self.tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)downloadFileFinished:(NSNotification *)notify {
    
    [self refreshTableView];
}

- (void)shareLocationCancelBtnHandle:(id)sender {
    
    [_joinShareLctView removeFromSuperview];
    _joinShareLctView = nil;
    _shareLctId = nil;
    _shareFromId = nil;
}

- (void)shareLocationJoinBtnHandle:(id)sender {
    
    if (_shareLctVC == nil) {
        _shareLctVC = [[ShareLocationViewController alloc] init];
        _shareLctVC.shareLocationId = _shareLctId;
        _shareLctVC.userId = self.chatId;
    }
    [[self navigationController] presentViewController:_shareLctVC animated:YES completion:nil];
}

- (void)onJoinShareViewClick {
    
    [_joinShareLctView removeAllSubviews];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, self.view.width - 80, 40)];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setFont:[UIFont systemFontOfSize:14]];
    [contentLabel setText:@"加"@"入"@"位"@"置共享，聊天中其他人也能看到你的位置，确定加入"@"？"];
    [contentLabel setNumberOfLines:2];
    [contentLabel setTextColor:[UIColor whiteColor]];
    [_joinShareLctView addSubview:contentLabel];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor qim_colorWithHex:0x53676f alpha:1]];
    [cancelBtn setClipsToBounds:YES];
    [cancelBtn.layer setCornerRadius:2.5];
    [cancelBtn addTarget:self action:@selector(shareLocationCancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(contentLabel.left, contentLabel.bottom + 10, 80, 30);
    [_joinShareLctView addSubview:cancelBtn];
    
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setTitle:@"加入" forState:UIControlStateNormal];
    [joinBtn setBackgroundColor:[UIColor qim_colorWithHex:0x9fb7be alpha:1]];
    [joinBtn setClipsToBounds:YES];
    [joinBtn.layer setCornerRadius:2.5];
    [joinBtn addTarget:self
                action:@selector(shareLocationJoinBtnHandle:)
      forControlEvents:UIControlEventTouchUpInside];
    joinBtn.frame = CGRectMake(contentLabel.right - 80, cancelBtn.top, 80, 30);
    [_joinShareLctView addSubview:joinBtn];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [_joinShareLctView setFrame:CGRectMake(0, 0, self.view.width, joinBtn.bottom + 10)];
    }];
}

- (void)beginShareLocationMsg:(NSNotification *)notify {
    
    if ([notify.object isEqualToString:self.chatId]) {
        
        _shareLctId = notify.userInfo[@"shareId"];
        _shareFromId = notify.userInfo[@"fromId"];
        if (_shareLctId == nil) {
            
            return;
        }
        [self initJoinShareView];
    }
}

- (void)endShareLocationMsg:(NSNotification *)notify {
    
    if (_shareLctId && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count == 0) {
        
        [_joinShareLctView removeFromSuperview];
        _joinShareLctView = nil;
    }
    _shareLctVC = nil;
    _shareLctId = nil;
}

- (void)updateHistoryMessageList:(NSNotification *)notify {
    
    if ([self.chatId isEqualToString:notify.object]) {
        [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil WithLimit:kPageCount WithOffset:0 withLoadMore:NO WithComplete:^(NSArray *list) {
            [self updateGroupUsersHeadImgForMsgs:list];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                [self.tableView reloadData];
                [self addImageToImageList];
                [self scrollToBottomWithCheck:YES];
            });
            
        }];
    }
}

- (void)updateCollectionMessageList:(NSNotification *)notify {
    NSDictionary *msgDic = notify.object;
    NSString *originFrom = [msgDic objectForKey:@"Originfrom"];
    NSString *originTo = [msgDic objectForKey:@"Originto"];
    if ([originFrom isEqualToString:self.chatId] && [originTo isEqualToString:self.bindId]) {
        NSString *msgId = [msgDic objectForKey:@"MsgId"];
       QIMMessageModel *msg = [[QIMKit sharedInstance] getCollectionMsgListForMsgId:msgId];
        if (msg) {
            if (!self.messageManager.dataSource) {
                self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:10];
                [self.messageManager.dataSource addObject:msg];
                [self.tableView reloadData];
            } else if ([self.messageManager.dataSource count] != [self.tableView numberOfRowsInSection:0]) {
                [self.messageManager.dataSource addObject:msg];
                [self.tableView reloadData];
            } else {
                [self.messageManager.dataSource addObject:msg];
                [self updateGroupUsersHeadImgForMsgs:@[msg]];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self addImageToImageList];
            [self scrollToBottomWithCheck:NO];
            if ([msg isKindOfClass:[QIMMessageModel class]] && msg.messageDirection == QIMMessageDirection_Received) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[QIMKit sharedInstance] sendReadstateWithGroupLastMessageTime:msg.messageDate
                                                                             withGroupId:self.chatId];
                });
            }
        }
    }
}

- (void)updateMessageList:(NSNotification *)notify {
    
    if ([self.chatId isEqualToString:notify.object]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexpath = [[self.tableView indexPathsForVisibleRows] lastObject];
            self.currentMsgIndexs = indexpath.row;
            QIMMessageModel *msg = [notify.userInfo objectForKey:@"message"];
//            @{@"message":msg, @"frontInsert":@(frontInsert)}
            BOOL frontInsert = [[notify.userInfo objectForKey:@"frontInsert"] boolValue];
            NSInteger numbers = [self.tableView numberOfRowsInSection:0];
            if (msg) {
                if (!self.messageManager.dataSource) {
                    self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:20];
                    if (frontInsert == YES) {
                        [self.messageManager.dataSource insertObject:msg atIndex:self.messageManager.dataSource.count - 1];
                    } else {
                        [self.messageManager.dataSource addObject:msg];
                    }
                    [self.tableView reloadData];
                } else if ([self.messageManager.dataSource count] != [_tableView numberOfRowsInSection:0]) {
                    if (frontInsert == YES) {
                        [self.messageManager.dataSource insertObject:msg atIndex:self.messageManager.dataSource.count - 1];
                    } else {
                        [self.messageManager.dataSource addObject:msg];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                } else {
                    [self updateGroupUsersHeadImgForMsgs:@[msg]];
                    if (frontInsert == YES) {
                        [self.messageManager.dataSource insertObject:msg atIndex:self.messageManager.dataSource.count - 1];
                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    } else {
                        [self.messageManager.dataSource addObject:msg];
                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                [self addImageToImageList];
                [self scrollToBottomWithCheck:NO];
                if ([msg isKindOfClass:[QIMMessageModel class]] && msg.messageDirection == QIMMessageDirection_Received) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[QIMKit sharedInstance] sendReadstateWithGroupLastMessageTime:msg.messageDate
                                                                           withGroupId:self.chatId];
                    });
                }
            }
        });
    }
}

- (void)scrollBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    if (offset.y > self.tableView.height / 2.0f) {
        [self.tableView setContentOffset:offset animated:NO];
    }
}

- (void)scrollToBottom:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.messageManager.dataSource.count == 0) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            CGFloat offsetY = self.tableView.contentSize.height + self.tableView.contentInset.bottom - CGRectGetHeight(self.tableView.frame);
            if (offsetY < -self.tableView.contentInset.top) {
                offsetY = -self.tableView.contentInset.top;
            }
            [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:animated];
        } else {
            if([self.tableView numberOfSections] > 0 ){
                NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
                NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex ]-1;
                if(lastRowIndex > 0){
                    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
                }
            } else {
                CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
                [self.tableView setContentOffset:offset animated:NO];
            }
        }
    });
}

- (BOOL)shouldScrollToBottomForNewMessage {
    CGFloat _h = self.tableView.contentSize.height - self.tableView.contentOffset.y - (CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom);
    return (self.messageManager.dataSource.count - self.currentMsgIndexs) <= 3;
}

- (void)scrollToBottomWithCheck:(BOOL)flag {
    
   QIMMessageModel *message = self.messageManager.dataSource.lastObject;
    QIMMessageDirection messageDirection = message.messageDirection;
    if (messageDirection == QIMMessageDirection_Sent) {
        [self scrollToBottom:flag];
        [self hidePopView];
    } else {
        if ([self shouldScrollToBottomForNewMessage]) {
            [self scrollToBottom:flag];
        } else {
            [self showPopView];
        }
    }
}

#pragma mark - QIMIMTextBarDelegate
- (void)textBarReferBtnDidClicked:(QIMTextBar *)textBar {
    if (_referMsgwindow == nil) {
        _referMsgwindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _referMsgwindow.backgroundColor = [UIColor clearColor];
        _referMsgwindow.windowLevel = UIWindowLevelAlert - 1;
        _referMsgwindow.rootViewController = [[UIViewController alloc] init];
    }
    _referMsgwindow.hidden = NO;
    
    UIScrollView * referMsgScrlView = [[UIScrollView alloc] initWithFrame:_referMsgwindow.rootViewController.view.bounds];
    referMsgScrlView.backgroundColor = [UIColor qim_colorWithHex:0x000000 alpha:0.5];
    [_referMsgwindow.rootViewController.view addSubview:referMsgScrlView];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5;
    bgView.clipsToBounds = YES;
    [referMsgScrlView addSubview:bgView];
    
    QIMAttributedLabel * msgLabel = [[QIMAttributedLabel alloc] init];
    msgLabel.textContainer = [QIMMessageParser textContainerForMessage:textBar.referMsg fromCache:NO];
    msgLabel.textColor = [UIColor blackColor];
    [bgView addSubview:msgLabel];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(referViewTapHandlel:)];
    [referMsgScrlView addGestureRecognizer:tap];
    
    
    float originX = (referMsgScrlView.width - msgLabel.textContainer.textWidth - 40) / 2.0f;
    float originY = (referMsgScrlView.height - msgLabel.textContainer.textHeight - 40) / 2.0f;
    
    [msgLabel setFrameWithOrign:CGPointMake(20,20) Width:msgLabel.textContainer.textWidth];
    bgView.frame = CGRectMake(originX, originY, msgLabel.width + 40, msgLabel.height +  40);
}

- (void)referViewTapHandlel:(UITapGestureRecognizer *)tap {
    _referMsgwindow.hidden = YES;
    _referMsgwindow = nil;
}

#pragma mark - text bar delegate

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType {
    if (msgType == QIMMessageType_LocalShare) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:info error:nil];
        NSString *localPath = [infoDic objectForKey:@"LocalScreenShotImagePath"];
        QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_LocalShare forMsgId:_resendMsg.messageId];
        [msg setOriginalMessage:[msg message]];
        [msg setOriginalExtendedInfo:[msg extendInformation]];
        
        
        [self.messageManager.dataSource addObject:msg];
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        [self addImageToImageList];
        [self scrollToBottomWithCheck:YES];

        [[QIMKit sharedInstance] qim_uploadImageWithImageKey:localPath forMessage:msg];
    } else {
        
        QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:ChatType_GroupChat msgType:msgType forMsgId:_resendMsg.messageId];
        [self.messageManager.dataSource addObject:msg];
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
    }
}

- (void)sendCollectionFaceStr:(NSString *)faceStr {
    if ([faceStr isEqualToString:kImageFacePageViewAddFlagName]) {
        //添加按钮点击
        QIMCollectionEmotionEditorVC *emotionEditor = [[QIMCollectionEmotionEditorVC alloc] init];
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:emotionEditor];
        [self presentViewController:nav animated:YES completion:nil];
        
    } else {
        if (![faceStr qim_hasPrefixHttpHeader] && faceStr.length > 0) {
            faceStr = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], faceStr];
        }
        QIMMessageModel *msg = nil;
        if (faceStr.length) {
            NSString *msgText = nil;
            NSString *fileCachePath = [[QIMImageManager sharedInstance] defaultCachePathForKey:faceStr];
            BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:fileCachePath];
            if (isFileExist) {
                UIImage *faceStrImage = [UIImage imageWithContentsOfFile:fileCachePath];
                //                NSData *imgData = [[QIMKit sharedInstance] getFileDataFromUrl:faceStr forCacheType:QIMFileCacheTypeColoction];
                //                CGSize size = [[QIMKit sharedInstance] getFitSizeForImgSize:[QIMImage imageWithData:imgData].size];
                CGSize size = faceStrImage.size;
                msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", faceStr, size.width, size.height];
            } else {
                msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", faceStr, 0, 0];
            }
            msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_Text];
            [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            
            [self.messageManager.dataSource addObject:msg];
            [self updateGroupUsersHeadImgForMsgs:@[msg]];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
        }
    }
}

- (void)clickFaildCollectionFace {
    
    UIAlertController *notFoundEmojiAlertVc = [UIAlertController alertControllerWithTitle:[NSBundle qim_localizedStringForKey:@"Reminder"] message:@"该表情已失效" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:nil];
    [notFoundEmojiAlertVc addAction:okAction];
    [self presentViewController:notFoundEmojiAlertVc animated:YES completion:nil];
}

- (void)sendNormalEmotion:(NSString *)faceStr WithPackageId:(NSString *)packageId {
    if (faceStr && packageId) {
        NSString *text = [NSString stringWithFormat:@"[obj type=\"%@\" value=\"%@\" width=%@ height=0 ]", @"emoticon",[NSString stringWithFormat:@"[%@]", faceStr], packageId];
        NSDictionary *normalEmotionExtendInfoDic = @{@"height": @(0), @"pkgid":packageId, @"shortcut":faceStr, @"url":@"", @"width": @(0)};
        NSString *normalEmotionExtendInfoStr = [[QIMJSONSerializer sharedInstance] serializeObject:normalEmotionExtendInfoDic];
        if ([text length] > 0) {
           QIMMessageModel *msg = nil;
            text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
            if (self.textBar.isRefer) {
                NSDictionary *referMsgUserInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.textBar.referMsg.from];
                NSString *referMsgNickName = [referMsgUserInfo objectForKey:@"Name"];
                text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n", (referMsgNickName.length > 0) ? referMsgNickName : self.textBar.referMsg.from,self.textBar.referMsg.message] stringByAppendingString:text];
                self.textBar.isRefer = NO;
                self.textBar.referMsg = nil;
            }
                
            msg = [[QIMKit sharedInstance] createMessageWithMsg:text
                                                          extenddInfo:normalEmotionExtendInfoStr
                                                               userId:self.chatId
                                                             userType:ChatType_GroupChat
                                                              msgType:QIMMessageType_ImageNew];
            
            [self.messageManager.dataSource addObject:msg];
            [self updateGroupUsersHeadImgForMsgs:@[msg]];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
            msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
        }
    }
}

- (void)sendQuickReplyContent:(NSNotification *)notify {
    NSString *text = notify.object;
    if (text.length > 0) {
        [self sendText:text];
    }
}

- (void)sendText:(NSString *)text {
    
    NSMutableArray *outATInfoArray = [NSMutableArray arrayWithCapacity:3];
    NSString *attributedText = [[QIMMessageTextAttachment sharedInstance] getStringFromAttributedString:[self.textBar getTextBarAttributedText] WithOutAtInfo:&outATInfoArray];
    if (attributedText.length > 0) {
        text = attributedText;
    }
    
    if ([text length] > 0) {
       QIMMessageModel *msg = nil;
        text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
        if (self.textBar.isRefer) {
            NSDictionary *referMsgUserInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.textBar.referMsg.from];
            NSString *referMsgNickName = [referMsgUserInfo objectForKey:@"Name"];
            text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n",(referMsgNickName.length > 0) ? referMsgNickName : self.textBar.referMsg.from,self.textBar.referMsg.message] stringByAppendingString:text];
            self.textBar.isRefer = NO;
            self.textBar.referMsg = nil;
        }
        NSString *backInfo = nil;
        if (outATInfoArray) {
            backInfo = [[QIMJSONSerializer sharedInstance] serializeObject:outATInfoArray];
        }
            
        msg = [[QIMKit sharedInstance] createMessageWithMsg:text
                                                      extenddInfo:nil
                                                           userId:self.chatId
                                                         userType:ChatType_GroupChat
                                                          msgType:QIMMessageType_Text
                                                         backinfo:backInfo];
        [self.messageManager.dataSource addObject:msg];
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
    }
}

- (void)emptyText:(NSString *)text {
    //    UIAlertController *emptyTextVc = [UIAlertController alertControllerWithTitle:@"不能发送空白消息" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    //        QIMVerboseLog(@"不能发送空白消息");
    //    }];
    //    [emptyTextVc addAction:okAction];
    //    [self presentViewController:emptyTextVc animated:YES completion:nil];
}

#pragma mark - 发送图片

- (void)qim_textbarSendImageWithImagePath:(NSString *)imagePath {
    if (!imagePath) {
        return;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);

    NSString *msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"LocalFileName=%@\" width=%f height=%f]", imagePath, width, height];
    QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_Text];

    [self.messageManager.dataSource addObject:msg];
    [self updateGroupUsersHeadImgForMsgs:@[msg]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [self addImageToImageList];
    [self scrollToBottomWithCheck:YES];
    [[QIMKit sharedInstance] qim_uploadImageWithImageKey:imagePath forMessage:msg];
}

#pragma mark - 发送文件
- (void)qim_textbarSendFileWithFileName:(NSString *)fileName {
    NSString *filePath = [[QIMKit sharedInstance] qim_getLocalFileDataWithFileName:fileName];
    if (filePath) {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        long long fileLength = fileData.length;
        NSString *fileSize = [QIMStringTransformTools qim_CapacityTransformStrWithSize:fileLength];
        NSString *fileMd5 = [fileData qim_md5String];
        NSDictionary *jsonObject = @{
                                     @"FileName": fileName,
                                     @"FileSize": fileSize,
                                     @"FileLength": @(fileLength),
                                     @"FileMd5": fileMd5 ? fileMd5 : @"",
                                     @"IPLocalPath": fileName,
                                     @"Uploading": @(1)
                                     };
        NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:jsonObject];
        QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:extendInfo extenddInfo:extendInfo userId:self.chatId userType:self.chatType msgType:QIMMessageType_File];
        
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [[QIMKit sharedInstance] qim_uploadFileWithFilePath:filePath forMessage:msg];
    }
}

#pragma mark - 视频

- (void)sendVideoPath:(NSString *)videoPath WithThumbImage:(UIImage *)thumbImage WithFileSizeStr:(NSString *)fileSizeStr WithVideoDuration:(float)duration {
    [self sendVideoPath:videoPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:duration forMsgId:nil];
}

- (void)sendVideoPath:(NSString *)videoPath WithThumbImage:(UIImage *)thumbImage WithFileSizeStr:(NSString *)fileSizeStr WithVideoDuration:(float)duration forMsgId:(NSString *)mId {
    
    BOOL VideoConfigUseAble = [[[QIMKit sharedInstance] userObjectForKey:@"VideoConfigUseAble"] boolValue];
    [self.view setFrame:_rootViewFrame];
    NSString *msgId = mId.length ? mId : [QIMUUIDTools UUID];
    CGSize size = thumbImage.size;
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.8);
    NSString *pathExtension = [[videoPath lastPathComponent] pathExtension];
    NSString *fileName = [[videoPath lastPathComponent] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    NSString *thumbFilePath = [videoPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    [thumbData writeToFile:thumbFilePath atomically:YES];
    
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setQIMSafeObject:thumbFilePath forKey:@"LocalVideoThumbPath"];
    [dicInfo setQIMSafeObject:thumbFilePath forKey:@"ThumbUrl"];
    [dicInfo setQIMSafeObject:fileName forKey:@"ThumbName"];
    [dicInfo setQIMSafeObject:[videoPath lastPathComponent] forKey:@"FileName"];
    [dicInfo setQIMSafeObject:@(size.width) forKey:@"Width"];
    [dicInfo setQIMSafeObject:@(size.height) forKey:@"Height"];
    [dicInfo setQIMSafeObject:fileSizeStr forKey:@"FileSize"];
    [dicInfo setQIMSafeObject:@(duration) forKey:@"Duration"];
    [dicInfo setQIMSafeObject:videoPath forKey:@"LocalVideoOutPath"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
    
    QIMMessageModel *msg = [QIMMessageModel new];
    [msg setMessageId:msgId];
    [msg setMessageDirection:QIMMessageDirection_Sent];
    [msg setChatType:ChatType_GroupChat];
    [msg setMessageType:QIMMessageType_SmallVideo];
    [msg setMessageDate:([[NSDate date] timeIntervalSince1970] - [[QIMKit sharedInstance] getServerTimeDiff]) * 1000];
    [msg setFrom:[[QIMKit sharedInstance] getLastJid]];
    [msg setTo:self.chatId];
    [msg setRealJid:self.chatId];
    [msg setPlatform:IMPlatform_iOS];
    [msg setMessageSendState:QIMMessageSendState_Waiting];
    [msg setMessage:msgContent];
    
    [[QIMKit sharedInstance] saveMsg:msg ByJid:self.chatId];
    
    [self.messageManager.dataSource addObject:msg];
    [self updateGroupUsersHeadImgForMsgs:@[msg]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    
    [[QIMKit sharedInstance] qim_uploadVideoPath:videoPath forMessage:msg];
}

- (void)sendVoiceData:(NSData *)voiceData WithDuration:(int)duration {
    
}

- (void)setKeyBoardHeight:(CGFloat)height WithScrollToBottom:(BOOL)flag {
    
    CGFloat animaDuration = 0.2;
    
    CGRect frame = _tableViewFrame;
    frame.origin.y -= height;
    [UIView animateWithDuration:animaDuration animations:^{
        
        [self.tableView setFrame:frame];
        if (self.tableView.contentSize.height - self.tableView.tableHeaderView.frame.size.height + 10 < self.tableView.frame.size.height && height > 0) {
            
            if (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10 < _tableViewFrame.size.height - height) {
                
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height + 10)];
                [self.tableView setTableHeaderView:headerView];
            } else {
                
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.tableView.frame.size.height - (self.tableView.contentSize.height - self.tableView.tableHeaderView.frame.size.height + 10) + 10)];
                [self.tableView setTableHeaderView:headerView];
            }
        } else {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
            [self.tableView setTableHeaderView:headerView];
            //             if (flag) {
            //                 [self scrollToBottomWithCheck:YES];
            //             }
        }
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if (_shareLctVC == nil) {
            _shareLctVC = [[ShareLocationViewController alloc] init];
            _shareLctVC.userId = self.chatId;
        }
        [[self navigationController] presentViewController:_shareLctVC animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        
        UserLocationViewController *userLct = [[UserLocationViewController alloc] init];
        userLct.delegate = self;
        [self.navigationController presentViewController:userLct animated:YES completion:nil];
    } else if (buttonIndex == 2) {
    }
}

#pragma mark - Action Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer isKindOfClass:[QIMTapGestureRecognizer class]]) {
        NSInteger index = gestureRecognizer.view.tag;
        CGPoint location = [touch locationInView:[gestureRecognizer.view viewWithTag:kTextLabelTag]];
        NSInteger imageIndex = [(QIMGroupChatCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] indexForCellImagesAtLocation:location];
        if (imageIndex < 0) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    //当点击table空白处时，输入框自动回收
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.textBar.frame, point)) {
        [self.textBar needFirstResponder:NO];
    }
    
    [QIMMenuImageView cancelHighlighted];
    
    return NO;
}

#pragma mark - UIScrollView的代理函数

// =======================================================================

// UIScrollView的代理函数

// =======================================================================

- (void)QTalkMessageUpdateForwardBtnState:(BOOL)enable {
    self.forwardBtn.enabled = enable;
    QIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)QTalkMessageScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat h1 = self.tableView.contentOffset.y + self.tableView.frame.size.height;
    CGFloat h2 = self.tableView.contentSize.height - 250;
    CGFloat tempOffY = (self.tableView.contentSize.height - self.tableView.frame.size.height);
    if ((h1 > h2) && tempOffY > 0) {
        [self hidePopView];
    }
}

- (void)QTalkMessageScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

// =======================================================================

// MJRefresh的代理函数

// =======================================================================

- (void)loadNewRemoteSearchGroupMsgList {
    __weak typeof(self) weakSelf = self;
    
    QIMMessageModel *msgModel = [self.messageManager.dataSource firstObject];
    [[QIMKit sharedInstance] getRemoteSearchMsgListByUserId:self.chatId WithRealJid:self.chatId withVersion:msgModel.messageDate withDirection:QIMGetMsgDirectionDown WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
        if (list.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CGFloat offsetY = _tableView.contentSize.height - _tableView.contentOffset.y;
                NSRange range = NSMakeRange(0, [list count]);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                
                [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                [_tableView reloadData];
                _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - offsetY);
                //重新获取一次大图展示的数组
                [weakSelf addImageToImageList];
                [weakSelf.tableView.mj_header endRefreshing];
            });
        } else {
            [weakSelf.tableView.mj_header endRefreshing];
        }
    }];
}

- (void)loadNewGroupMsgList {
    if (self.netWorkSearch == YES) {
        
        [self loadNewRemoteSearchGroupMsgList];
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.loadCount += 1;
    [[QIMKit sharedInstance] getMsgListByUserId:weakSelf.chatId
                                    WithRealJid:weakSelf.chatId
                                      WithLimit:kPageCount
                                     WithOffset:(int) weakSelf.messageManager.dataSource.count
                                   withLoadMore:YES
                                   WithComplete:^(NSArray *list) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           CGFloat offsetY = weakSelf.tableView.contentSize.height - weakSelf.tableView.contentOffset.y;
                                           NSRange range = NSMakeRange(0, [list count]);
                                           NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                           
                                           [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                                           [weakSelf updateGroupUsersHeadImgForMsgs:list];
                                           [weakSelf.tableView reloadData];
                                           weakSelf.tableView.contentOffset = CGPointMake(0, weakSelf.tableView.contentSize.height - offsetY - 30);
                                           //重新获取一次大图展示的数组
                                           [weakSelf addImageToImageList];
                                           [weakSelf.tableView.mj_header endRefreshing];
                                           //标记已读
                                           [weakSelf markReadedForChatRoom];
                                       });
                                   }];
#if __has_include("QimRNBModule.h")
    if (self.loadCount >= 3 && !self.reloadSearchRemindView && !self.bindId) {
        self.searchRemindView = [[QIMSearchRemindView alloc] initWithChatId:self.chatId withRealJid:nil withChatType:self.chatType];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToConverstaionSearch)];
        [self.searchRemindView addGestureRecognizer:tap];
        [self.view addSubview:self.searchRemindView];
    }
#endif
}

- (UIView *)loadAllMsgView {
    if (!_loadAllMsgView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 54)];
        view.backgroundColor = [UIColor qim_colorWithHex:0xF8F8F9];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 21)];
        label.text = [NSBundle qim_localizedStringForKey:@"All_Messages_Above"];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor redColor]];
        label.font = [UIFont systemFontOfSize:15];
        [view addSubview:label];
        label.center = view.center;
        
        UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(label.left - 50, 1, 40, 0.5f)];
        leftLineView.backgroundColor = [UIColor qim_colorWithHex:0xBFBFBF];
        [view addSubview:leftLineView];
        leftLineView.centerY = label.centerY;
        
        UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(label.right + 10, 1, 40, 0.5f)];
        rightLineView.backgroundColor = [UIColor qim_colorWithHex:0xBFBFBF];
        [view addSubview:rightLineView];
        rightLineView.centerY = label.centerY;
        
        _loadAllMsgView = view;
    }
    return _loadAllMsgView;
}

- (void)loadFooterRemoteSearchMsgList {
    __weak typeof(self) weakSelf = self;
    
    QIMMessageModel *msgModel = [self.messageManager.dataSource lastObject];
    [[QIMKit sharedInstance] getRemoteSearchMsgListByUserId:self.chatId WithRealJid:self.chatId withVersion:msgModel.messageDate+1 withDirection:QIMGetMsgDirectionUp WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
        if (list.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.messageManager.dataSource addObjectsFromArray:list];
                [_tableView reloadData];
                //重新获取一次大图展示的数组
                [weakSelf addImageToImageList];
                [weakSelf.tableView.mj_footer endRefreshing];
            });
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
            weakSelf.tableView.mj_footer = nil;
            weakSelf.tableView.tableFooterView = [weakSelf loadAllMsgView];
        }
    }];
}

- (void)jumpToConverstaionSearch {
    self.reloadSearchRemindView = YES;
    [self.searchRemindView removeFromSuperview];
    [[QIMFastEntrance sharedInstance] openLocalSearchWithXmppId:self.chatId withRealJid:nil withChatType:self.chatType];
}

- (void)addPersonToPgrup:(id)sender {
    if (![[[QIMKit sharedInstance] userObjectForKey:@"kRightCardRemindNotification"] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRightCardRemindNotification object:nil];
        [[QIMKit sharedInstance] setUserObject:@(YES) forKey:kRightCardRemindNotification];
    }
    [QIMFastEntrance openQIMGroupCardVCByGroupId:self.chatId];
}

- (void)scrollToBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    [self.tableView setContentOffset:offset animated:NO];
}

- (void)scrollToBottom_tableView {
    if (self.messageManager.dataSource.count == 0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self scrollToBottom:YES];
    }else {
        [self scrollToBottom:NO];
    }
}

- (void)updateForwardBtnState {
    self.forwardBtn.enabled = self.messageManager.forwardSelectedMsgs.count;
    QIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)refreshTableView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self.tableView
                                                 selector:@selector(reloadData)
                                                   object:nil];
        [self.tableView performSelector:@selector(reloadData)
                             withObject:nil
                             afterDelay:DEFAULT_DELAY_TIMES];
    });
}

#pragma mark - show pop view

- (void)showPopView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (notificationView == nil) {
        
        notificationView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110, self.textBar.frame.origin.y - 50, 100, 40)];
        backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [backImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"notificationToast"]];
        [notificationView addSubview:backImageView];
        
        UIImageView *messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 7, 20, 20)];
        [messageImageView setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"notificationToastCommentIcon"]];
        
        [notificationView addSubview:messageImageView];
        if (commentCountLabel == nil) {
            commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 70, 20)];
            [commentCountLabel setTextColor:[UIColor whiteColor]];
            [commentCountLabel setText:[NSBundle qim_localizedStringForKey:@"New_Messages_Below"]];
            [commentCountLabel setFont:[UIFont boldSystemFontOfSize:10]];
            [notificationView addSubview:commentCountLabel];
        }
        
        [self.view addSubview:notificationView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToFoot)];
        [notificationView addGestureRecognizer:tap];
        notificationView.userInteractionEnabled = YES;
        [notificationView setHidden:NO];
        notificationView.alpha = 1.0;
    }
    [notificationView setHidden:NO];
    notificationView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)hidePopView {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    notificationView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)moveViewToFoot {
    [self scrollToBottom_tableView];
}

- (void)addImageToImageList {
    if (!_imagesArr) {
        _imagesArr = [NSMutableArray arrayWithCapacity:1];
    } else {
        [_imagesArr removeAllObjects];
    }
    NSArray *tempDataSource = [NSArray arrayWithArray:self.messageManager.dataSource];
    for (QIMMessageModel *msg in tempDataSource) {
        if (msg.messageType == QIMMessageType_Image || msg.messageType == QIMMessageType_Text || msg.messageType == QIMMessageType_NewAt) {
            QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessage:msg];
            for (id storage in textContainer.textStorages) {
                if ([storage isMemberOfClass:[QIMImageStorage class]] && ([(QIMImageStorage *) storage storageType] == QIMImageStorageTypeImage || [(QIMImageStorage *) storage storageType] == QIMImageStorageTypeGif)) {
                    [_imagesArr addObject:storage];
                }
            }
        }
    }
    
}

#pragma mark - 语音

- (void)beginDoVoiceRecord {
    self.voiceRecordingView.hidden = NO;
    [self.voiceRecordingView beginDoRecord];
}

- (void)updateVoiceViewHeightInVCWithPower:(float)power {
    [self.voiceRecordingView doImageUpdateWithVoicePower:power];
}

- (void)voiceRecordWillFinishedIsTrue:(BOOL)isTrue
                      andCancelByUser:(BOOL)isCancelByUser {
    
    [self.voiceRecordingView setHidden:YES];
    if (!isTrue && !isCancelByUser) {
        //录音时间太短，出错提示
        [self.voiceTimeRemindView setHidden:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hiddenQIMVoiceTimeRemindView) userInfo:nil repeats:NO];
    }
    [self.voiceRecordingView voiceMaybeCancelWithState:0];
}

- (void)hiddenQIMVoiceTimeRemindView {
    [self.voiceTimeRemindView setHidden:YES];
}

- (void)voiceMaybeCancelWithState:(BOOL)ifMaybeCancel {
    [self.voiceRecordingView voiceMaybeCancelWithState:ifMaybeCancel];
}

- (void)sendVoiceWithDuration:(int)duration WithFileName:(NSString *)filename AndFilePath:(NSString *)filepath {
    
    NSDictionary *msgBodyDic = @{@"HttpUrl": filepath, @"FileName" : filename, @"Seconds": [NSNumber numberWithInt:duration], @"filepath": filepath};
    NSString *msgBodyStr = [[QIMJSONSerializer sharedInstance] serializeObject:msgBodyDic];
    QIMMessageModel *msg = [[QIMKit sharedInstance] createMessageWithMsg:msgBodyStr extenddInfo:nil userId:self.chatId userType:self.chatType msgType:QIMMessageType_Voice forMsgId:[QIMUUIDTools UUID]];

    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    [self addImageToImageList];
    [[QIMKit sharedInstance] qim_uploadFileWithFilePath:filepath forMessage:msg];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kReSendMsgAlertViewTag) {
        if (buttonIndex == 1) {
            [self processEvent:MA_Delete withMessage:_resendMsg];
        } else if (buttonIndex == 2) {
            [self reSendMsg];
        } else {
        }
    } else if (alertView.tag == kForwardMsgAlertViewTag) {
        if (buttonIndex == 2) {
            NSArray *forwardIndexpaths = [self.tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[self.messageManager.dataSource objectAtIndex:indexPath.row]];
            }
            NSString *jsonFilePath = [QIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@的聊天记录", self.title]];
            self.tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [self.forwardBtn removeFromSuperview];
            [_textBar setUserInteractionEnabled:YES];
            
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            if ([[QIMKit sharedInstance] getIsIpad] == YES) {
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            controller.delegate = self;
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [self cancelForwardHandle:nil];
            }];
        } else if (buttonIndex == 1) {
            NSArray *forwardIndexpaths = [self.tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[QIMMessageParser reductionMessageForMessage:[self.messageManager.dataSource objectAtIndex:indexPath.row]]];
            }
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            [controller setMessageList:msgList];
            if ([[QIMKit sharedInstance] getIsIpad] == YES) {
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [self cancelForwardHandle:nil];
            }];
        } else {
            
        }
    } else {
        if (buttonIndex == 1) {
            QIMChatBGImageSelectController *chatBGImageSelectVC = [[QIMChatBGImageSelectController alloc] initWithCurrentBGImage:_chatBGImageView.image];
            chatBGImageSelectVC.userID = self.chatId;
            chatBGImageSelectVC.delegate = self;
            chatBGImageSelectVC.isFromChat = YES;
            [self.navigationController pushViewController:chatBGImageSelectVC
                                                 animated:YES];
        }
    }
}

#pragma mark - QIMChatBGImageSelectControllerDelegate

- (void)ChatBGImageDidSelected:(QIMChatBGImageSelectController *)chatBGImageSelectVC {
    [self refreshChatBGImageView];
}

#pragma mark - QIMPushProductViewControllerDelegate

- (void)sendProductInfoStr:(NSString *)infoStr
          productDetailUrl:(NSString *)detlUrl {
    [self sendMessage:detlUrl WithInfo:infoStr ForMsgType:QIMMessageType_product];
}

@end

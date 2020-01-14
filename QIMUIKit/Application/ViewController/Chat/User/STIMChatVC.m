//

//  STIMChatVC.m

//  STChatIphone

//

//  Created by wangshihai on 14/12/2.

//  Copyright (c) 2014年 ping.xue. All rights reserved.

#import "STIMTapGestureRecognizer.h"
#import "STIMChatVC.h"
#import "STIMIconInfo.h"
#import "STIMEmotionManager.h"
#import "STIMDataController.h"
#import "STIMJSONSerializer.h"
#import "STIMUUIDTools.h"
#import "STIMSingleChatCell.h"
#import "STIMSingleChatVoiceCell.h"
#import "STIMNavTitleView.h"
#import "STIMMenuImageView.h"
#import "STIMGroupCreateVC.h"
#import "STIMCollectionFaceManager.h"
#import "STIMVoiceRecordingView.h"
#import "MBProgressHUD.h"
#import "STIMVoiceTimeRemindView.h"
#import "STIMOriginMessageParser.h"
#import "STIMChatBgManager.h"
#import "STIMCommonUIFramework.h"
#import <AVFoundation/AVFoundation.h>
#import "NSBundle+STIMLibrary.h"
#import "STIMRemoteAudioPlayer.h"
#import "STIMMWPhotoBrowser.h"
#import "STIMRedPackageView.h"
#if __has_include("STIMIPadWindowManager.h")
#import "STIMIPadWindowManager.h"
#endif
#import "STIMOrganizationalVC.h"

#define kPageCount 20
#define kReSendMsgAlertViewTag 10000
#define kForwardMsgAlertViewTag 10001

#import "STIMDisplayImage.h"
#import "STIMPhotoBrowserNavController.h"
#import "STIMContactSelectionViewController.h"

#import "STIMChatBGImageSelectController.h"

#import "STIMMessageBrowserVC.h"
#import "STIMInputPopView.h"

#import "STIMFileManagerViewController.h"
#import "STIMPreviewMsgVC.h"

#import "STIMEmotionSpirits.h"
#import "STIMWebView.h"


#import "STIMCollectionEmotionEditorVC.h"
#import "STIMPushProductViewController.h"

#import "ShareLocationViewController.h"

#import "UserLocationViewController.h"

#import "STIMOpenPlatformCell.h"

#import "STIMNewMessageTagCell.h"
#import "STIMRobotQuestionCell.h"

#import "STIMNotReadMsgTipViews.h"
#import "STIMTextBar.h"
#import "STIMPNRichTextCell.h"
#import "STIMPNActionRichTextCell.h"
#import "STIMPublicNumberNoticeCell.h"
#import "STIMVoiceNoReadStateManager.h"
#import "STIMPlayVoiceManager.h"
#import "STIMMyFavoitesManager.h"
#import "STIMMessageParser.h"
#import "STIMAttributedLabel.h"
#import "STIMExtensibleProductCell.h"
#import "STIMMessageCellCache.h"
#import "STIMNavBackBtn.h"
#import "STIMNotifyView.h"
#import "STIMRedMindView.h"
#import "STIMHintTableViewCell.h"
#import "STIMChatRobotQuestionListTableViewCell.h"

#if __has_include("STIMNotifyManager.h")
    #import "STIMNotifyManager.h"
#endif

#import "STIMExportMsgManager.h"
#import "STIMContactManager.h"

#if __has_include("STIMWebRTCClient.h")
    #import "STIMWebRTCClient.h"
#endif

#if __has_include("STIMNoteManager.h")
    #import "STIMNoteManager.h"
    #import "STIMEncryptChat.h"
    #import "STIMNoteModel.h"
#endif

#import "STIMProgressHUD.h"
#import "STIMAuthorizationManager.h"
#import "STIMMessageTableViewManager.h"
#import "STIMMessageRefreshHeader.h"
#import "STIMMessageRefreshFooter.h"
#import "MJRefreshNormalHeader.h"
#import "STIMRobotAnswerCell.h"
#import "STIMSearchRemindView.h"
#import "YYModel.h"

#if __has_include("STIMNotifyManager.h")

@interface STIMChatVC () <STIMNotifyManagerDelegate>

@end

#endif

#if __has_include("STIMNoteManager.h")

@interface STIMChatVC () <STIMEncryptChatReloadViewDelegate>

@end

#endif

@interface STIMChatVC () <UIGestureRecognizerDelegate, STIMSingleChatCellDelegate, STIMSingleChatVoiceCellDelegate, STIMMWPhotoBrowserDelegate, STIMRemoteAudioPlayerDelegate, STIMMsgBaloonBaseCellDelegate, STIMChatBGImageSelectControllerDelegate, STIMContactSelectionViewControllerDelegate, STIMInputPopViewDelegate, STIMPushProductViewControllerDelegate, UIActionSheetDelegate, UserLocationViewControllerDelegate, STIMNotReadMsgTipViewsDelegate, STIMTextBarDelegate, STIMPNActionRichTextCellDelegate, STIMPNRichTextCellDelegate, PNNoticeCellDelegate, PlayVoiceManagerDelegate, STIMAttributedLabelDelegate, UIViewControllerPreviewingDelegate, QTalkMessageTableScrollViewDelegate, STIMRobotQuestionCellDelegate, STIMRobotAnswerCellLoadDelegate, STIMOrganizationalVCDelegate,STIMHintCellDelegate,STIMChatRobotQuestionListCellDelegate> {
    
    bool _isReloading;
    
    float _currentDownloadProcess;
    
    CGRect _rootViewFrame;
    CGRect _tableViewFrame;
    
    BOOL _notIsFirstChangeTableViewFrame;
    BOOL _playStop;
    
    NSMutableArray *_imagesArr;
    
    
    
   STIMMessageModel *_resendMsg;
    NSData *_willSendImageData;
    
    NSString *_transferReason;
    BOOL _inputPopViewIsShow;
    STIMTextBarExpandViewItemType _expandViewItemType;
    
    NSString *_shareLctId;
    NSString *_shareFromId;
    
    
    UIView *_maskRightTitleView;
    NSString *_jsonFilePath;
    
    
    BOOL _hasServerTransferFeedback;
    BOOL _hasUserTransferFeedback;
    
}
@property(nonatomic, strong) STIMTextBar *textBar;

@property(nonatomic, strong) UIButton *encryptBtn;

@property(nonatomic, strong) STIMVoiceRecordingView *voiceRecordingView;

@property(nonatomic, strong) STIMVoiceTimeRemindView *voiceTimeRemindView;

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) UIView *loadAllMsgView;

@property(nonatomic, strong) NSDate *dataNow;

@property(nonatomic, assign) NSInteger currentPlayVoiceIndex;

@property(nonatomic, copy) NSString *currentPlayVoiceMsgId;

@property(nonatomic, assign) BOOL isNoReadVoice;

#if __has_include("STIMNoteManager.h")

@property(nonatomic, assign) STIMEncryptChatState encryptChatState;   //加密状态
#endif

@property(nonatomic, assign) BOOL isEncryptChat;    //是否正在加密

@property(nonatomic, copy) NSString *pwd;           //加密会话内存密码

@property(nonatomic, strong) NSMutableDictionary *photos;   //图片

@property(nonatomic, strong) NSMutableDictionary *cellSizeDic;  //Cell缓存

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@property(nonatomic, strong) UIButton *forwardBtn;

@property(nonatomic, strong) STIMMessageTableViewManager *messageManager;

@property(nonatomic, strong) STIMPlayVoiceManager *playVoiceManager;

@property(nonatomic, strong) UIView *notificationView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) STIMNotReadMsgTipViews *readMsgTipView;

@property(nonatomic, strong) UIWindow *referMsgwindow;

@property(nonatomic, strong) UIView *joinShareLctView;

@property(nonatomic, strong) ShareLocationViewController *shareLctVC;

@property(nonatomic, strong) UIImageView *chatBGImageView;

@property(nonatomic, strong) UIView *forwardNavTitleView;

@property(nonatomic, strong) STIMRemoteAudioPlayer *remoteAudioPlayer;

@property(nonatomic, assign) NSInteger currentMsgIndexs;

@property(nonatomic, assign) NSInteger loadCount;
@property(nonatomic, assign) NSInteger reloadSearchRemindView;
@property(nonatomic, strong) STIMSearchRemindView *searchRemindView;

@property(nonatomic, strong) NSMutableArray *fixedImageArray;

@end

@implementation STIMChatVC


#pragma mark - setter and getter

- (STIMTextBar *)textBar {
    
    if (!_textBar) {
        
        STIMTextBarExpandViewType textBarType = STIMTextBarExpandViewTypeSingle;
        if (self.chatType == ChatType_Consult) {
            textBarType = STIMTextBarExpandViewTypeConsult;
        } else if (self.chatType == ChatType_ConsultServer) {
            textBarType = STIMTextBarExpandViewTypeConsultServer;
        } else if ([[STIMKit sharedInstance] isMiddleVirtualAccountWithJid:self.chatId]) {
            textBarType = STIMTextBarExpandViewTypeRobot;
        } else if ([self.chatId isEqualToString:[[STIMKit sharedInstance] getLastJid]]) {
            textBarType = STIMTextBarExpandViewTypeRobot;
        } else {
            textBarType = STIMTextBarExpandViewTypeSingle;
        }
    
        _textBar = [STIMTextBar sharedIMTextBarWithBounds:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) WithExpandViewType:textBarType];
        _textBar.associateTableView = self.tableView;
        [_textBar setDelegate:self];
        [_textBar setAllowSwitchBar:NO];
        [_textBar setAllowVoice:YES];
        [_textBar setAllowFace:YES];
        [_textBar setAllowMore:YES];
        [_textBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
        [_textBar setChatId:self.chatId];
        __weak STIMTextBar *weakTextBar = _textBar;
        
        [_textBar setSelectedEmotion:^(NSString *faceStr) {
            if ([faceStr length] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *text = [[STIMEmotionManager sharedInstance] getEmotionTipNameForShortCut:faceStr withPackageId:weakTextBar.currentPKId];
                    text = [NSString stringWithFormat:@"[%@]", text];
                    [weakTextBar insertEmojiTextWithTipsName:text shortCut:faceStr];
                });
            }
        }];
        
        [_textBar.layer setBorderColor:[UIColor stimDB_colorWithHex:0xadadad alpha:1].CGColor];
        [_textBar setIsRefer:NO];
        NSDictionary *notSendDic = [[STIMKit sharedInstance] getNotSendTextByJid:self.chatId];
        [_textBar setSTIMAttributedTextWithItems:notSendDic[@"inputItems"]];
    }
    if (self.chatType == ChatType_System) {
        return nil;
    }
    return _textBar;
}

- (STIMMessageTableViewManager *)messageManager {
    if (!_messageManager) {
        _messageManager = [[STIMMessageTableViewManager alloc] initWithChatId:self.chatId ChatType:self.chatType OwnerVc:self];
        _messageManager.delegate = self;
    }
    return _messageManager;
}
 
- (NSMutableDictionary *)photos {
    if (!_photos) {
        _photos = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return _photos;
}

- (STIMVoiceRecordingView *)voiceRecordingView {
    
    if (!_voiceRecordingView) {
        
        _voiceRecordingView = [[STIMVoiceRecordingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, self.navigationController.navigationBar.height + 150, 150, 150)];
        _voiceRecordingView.hidden = YES;
        _voiceRecordingView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceRecordingView];
    }
    return _voiceRecordingView;
}

- (STIMVoiceTimeRemindView *)voiceTimeRemindView {
    
    if (!_voiceTimeRemindView) {
        
        _voiceTimeRemindView = [[STIMVoiceTimeRemindView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, self.navigationController.navigationBar.height + 150, 150, 150)];
        _voiceTimeRemindView.hidden = YES;
        _voiceTimeRemindView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceTimeRemindView];
    }
    return _voiceTimeRemindView;
}

- (STIMPlayVoiceManager *)playVoiceManager {
    if (!_playVoiceManager) {
        _playVoiceManager = [STIMPlayVoiceManager defaultPlayVoiceManager];
        _playVoiceManager.playVoiceManagerDelegate = self;
    }
    return _playVoiceManager;
}

- (UIView *)notificationView {
    if (!_notificationView) {
        _notificationView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110, _textBar.frame.origin.y - 50, 100, 40)];
        
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [backImageView setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"notificationToast"]];
        [_notificationView addSubview:backImageView];
        
        UIImageView *messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 7, 20, 20)];
        [messageImageView setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"notificationToastCommentIcon"]];
        [_notificationView addSubview:messageImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToBottom_tableView)];
        [_notificationView addGestureRecognizer:tap];
        _notificationView.userInteractionEnabled = YES;
        
        UILabel *commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 70, 20)];
        [commentCountLabel setTextColor:[UIColor whiteColor]];
        [commentCountLabel setText:[NSBundle stimDB_localizedStringForKey:@"New_Messages_Below"]];
        [commentCountLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [_notificationView addSubview:commentCountLabel];
        [self.view addSubview:_notificationView];
    }
    return _notificationView;
}

- (STIMRemoteAudioPlayer *)remoteAudioPlayer {
    if (!_remoteAudioPlayer) {
        _remoteAudioPlayer = [[STIMRemoteAudioPlayer alloc] init];
        _remoteAudioPlayer.delegate = self;
    }
    return _remoteAudioPlayer;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = stimDB_singlechat_title_color;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:stimDB_singlechat_title_size];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _titleLabel;
}

- (STIMNotReadMsgTipViews *)readMsgTipView {
    if (!_readMsgTipView) {
        //未读消息按钮
        _readMsgTipView = [[STIMNotReadMsgTipViews alloc] initWithNotReadCount:self.notReadCount];
        [_readMsgTipView setFrame:CGRectMake(self.view.width, 10, _readMsgTipView.width, _readMsgTipView.height)];
        [_readMsgTipView setNotReadMsgDelegate:self];
    }
    return _readMsgTipView;
}

- (UIWindow *)referMsgwindow {
    if (!_referMsgwindow) {
        
    }
    return _referMsgwindow;
}

- (UIView *)joinShareLctView {
    if (!_joinShareLctView) {
        
    }
    return _joinShareLctView;
}

- (ShareLocationViewController *)shareLctVC {
    if (!_shareLctVC) {
        _shareLctVC = [[ShareLocationViewController alloc] init];
        _shareLctVC.shareLocationId = _shareLctId;
        _shareLctVC.userId = self.chatId;
    }
    return _shareLctVC;
}

- (UIImageView *)chatBGImageView {
    if (!_chatBGImageView) {
        _chatBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        _chatBGImageView.contentMode = UIViewContentModeScaleAspectFill;
        _chatBGImageView.clipsToBounds = YES;
    }
    return _chatBGImageView;
}

- (UIView *)getForwardNavView {
    if (_forwardNavTitleView == nil) {
        _forwardNavTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.bounds.size.height)];
        _forwardNavTitleView.backgroundColor = [UIColor whiteColor];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelForwardHandle:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.frame = CGRectMake(20, 0, 50, _forwardNavTitleView.height);
        [_forwardNavTitleView addSubview:cancelBtn];
    }
    return _forwardNavTitleView;
}

- (UIView *)getMaskRightTitleView {
    if (_maskRightTitleView == nil) {
        _maskRightTitleView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width - 130, 0, 130, self.navigationController.navigationBar.bounds.size.height)];
        _maskRightTitleView.backgroundColor = [UIColor whiteColor];
    }
    return _maskRightTitleView;
}

- (UIButton *)forwardBtn {
    if (!_forwardBtn) {
        _forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forwardBtn.frame = CGRectMake(0, self.view.height - 50 - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], self.view.width, 50);
        [_forwardBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Forward"] forState:UIControlStateNormal];
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

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        if (self.chatType == ChatType_CollectionChat || self.chatType == ChatType_System) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        } else {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 49 - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        }
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        _tableView.delegate = self.messageManager;
        _tableView.dataSource = self.messageManager;
        [_tableView setBackgroundColor:stimDB_chatBgColor];
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
        _tableView.mj_header = [STIMMessageRefreshHeader messsageHeaderWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessageData)];
        if (self.netWorkSearch == YES) {
            _tableView.mj_footer = [STIMMessageRefreshFooter messsageFooterWithRefreshingTarget:self refreshingAction:@selector(loadFooterRemoteSearchMsgList)];
        }
        [self refreshChatBGImageView];
    }
    return _tableView;
}

- (void)setBackBtn {
    STIMNavBackBtn *backBtn = [STIMNavBackBtn sharedInstance];
    [backBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //将宽度设为负值
    spaceItem.width = -15;
    //将两个BarButtonItem都返回给 
    self.navigationItem.leftBarButtonItems = @[spaceItem,backBarBtn];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textBar keyBoardDown];
}

- (void)forwardBtnHandle:(id)sender {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && ![[STIMKit sharedInstance] getIsIpad]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *quickForwardAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"One-by-One Forward"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            NSArray *forwardIndexpaths = [self.messageManager.forwardSelectedMsgs.allObjects sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return [(STIMMessageModel *)obj1 messageDate] > [(STIMMessageModel *)obj2 messageDate];
            }];
            
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (STIMMessageModel *message in forwardIndexpaths) {
                [msgList addObject:[STIMMessageParser reductionMessageForMessage:message]];
            }
            STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
            STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
            [controller setMessageList:msgList];
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [weakSelf cancelForwardHandle:nil];
                                                    }];
        }];
        UIAlertAction *mergerForwardAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Combine and Forward"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            NSArray *forwardIndexpaths = [_tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[self.messageManager.dataSource objectAtIndex:indexPath.row]];
            }
            
            NSDictionary *userInfoDic = [[STIMKit sharedInstance] getUserInfoByUserId:[[STIMKit sharedInstance] getLastJid]];
            NSString *userName = [userInfoDic objectForKey:@"Name"];
            
            _jsonFilePath = [STIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [STIMKit getLastUserName], self.title]];
            _tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [self.forwardBtn removeFromSuperview];
            [self.textBar setUserInteractionEnabled:YES];
            
            STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
            STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
            controller.delegate = self;
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [weakSelf cancelForwardHandle:nil];
                                                    }];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
            
        }];
        
        [alertController addAction:quickForwardAction];
        [alertController addAction:mergerForwardAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle stimDB_localizedStringForKey:@"One-by-One Forward"], [NSBundle stimDB_localizedStringForKey:@"Combine and Forward"], nil];
        alertView.tag = kForwardMsgAlertViewTag;
        [alertView show];
    }
}

- (void)cancelForwardHandle:(id)sender {
    
    _tableView.editing = NO;
    [_forwardNavTitleView removeFromSuperview];
    [_maskRightTitleView removeFromSuperview];
    [self.forwardBtn removeFromSuperview];
    [self.textBar setUserInteractionEnabled:YES];
    [self.messageManager.forwardSelectedMsgs removeAllObjects];
    self.fd_interactivePopDisabled = NO;
}


- (void)setupNavBar {
    [self setBackBtn];
    if (self.chatType != ChatType_System) {
        UIView *rightItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        UIButton *cardButton = [[UIButton alloc] initWithFrame:CGRectMake(rightItemView.right - 30, 9, 30, 30)];
        [cardButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [cardButton setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:stimDB_singlechat_rightCard_font size:stimDB_singlechat_rightCard_TextSize color:stimDB_singlechat_rightCard_Color]] forState:UIControlStateNormal];
        [cardButton setAccessibilityIdentifier:@"rightUserCardBtn"];
        [cardButton addTarget:self action:@selector(onCardClick) forControlEvents:UIControlEventTouchUpInside];
        [rightItemView addSubview:cardButton];
        /* 暂时取消右上角红点
         if (![[[STIMKit sharedInstance] userObjectForKey:kRightCardRemindNotification] boolValue]) {
         STIMRedMindView *redMindView = [[STIMRedMindView alloc] initWithBroView:cardButton withRemindNotificationName:kRightCardRemindNotification];
         [rightItemView addSubview:redMindView];
         }
         */
        if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
            
            UIButton *encryptBtn = nil;
            NSString *qCloudHost = [[STIMKit sharedInstance] qimNav_QCloudHost];
            if (qCloudHost.length > 0 && ![[STIMKit sharedInstance] isMiddleVirtualAccountWithJid:self.chatId] && self.chatType == ChatType_SingleChat) {
                encryptBtn = [[UIButton alloc] initWithFrame:CGRectMake(rightItemView.left, 9, 30, 30)];
                if (self.isEncryptChat) {
                    [encryptBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f1ad" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
                } else {
                    [encryptBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f1af" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
                }
                [encryptBtn addTarget:self action:@selector(encryptChat:) forControlEvents:UIControlEventTouchUpInside];
                //            [rightItemView addSubview:encryptBtn];
                self.encryptBtn = encryptBtn;
            }
            if (self.chatType == ChatType_ConsultServer && [[[STIMKit sharedInstance] getMyhotLinelist] containsObject:self.virtualJid]) {
                UIButton *endChatBtn = [[UIButton alloc] initWithFrame:CGRectMake(cardButton.left - 30 - 5, 9, 30, 30)];
                [endChatBtn setAccessibilityIdentifier:@"endChatBtn"];
                [endChatBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e0b5" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
                [endChatBtn addTarget:self action:@selector(endChatSession) forControlEvents:UIControlEventTouchUpInside];
                if (self.chatType == ChatType_ConsultServer) {
                    [rightItemView addSubview:endChatBtn];
                }
            }
            UIButton *createGrouButton = [[UIButton alloc] initWithFrame:CGRectMake(cardButton.left - 30 - 5, 9, 30, 30)];
            [createGrouButton setAccessibilityIdentifier:@"rightCreateGroupBtn"];
            [createGrouButton setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f0ca" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
            [createGrouButton addTarget:self action:@selector(onCreateGroupClcik) forControlEvents:UIControlEventTouchUpInside];
            //        [rightItemView addSubview:createGrouButton];
        } else {
            
        }
        if (self.chatType != ChatType_CollectionChat) {
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
            [self.navigationItem setRightBarButtonItem:rightItem];
        }
        
        [self initTitleView];
    } else {
        [self setupSystemChatNav];
    }
}

- (void)setupSystemChatNav {
    [self.navigationItem setTitle:self.title];
}

- (void)initUI {
    if ([[STIMKit sharedInstance] getIsIpad] == YES) {
        [self.view setFrame:CGRectMake(0, 0, [[STIMWindowManager shareInstance] getDetailWidth], [[UIScreen mainScreen] height])];
    }
    self.view.backgroundColor = stimDB_chatBgColor;
 
    [[STIMEmotionSpirits sharedInstance] setTableView:_tableView];
    [self loadData];
    
    //添加整个view的点击事件，当点击页面空白地方时，输入框收回
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    gesture.delegate = self;
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:gesture];
    
    _shareLctId = [[STIMKit sharedInstance] getShareLocationIdByJid:self.chatId];
    if (_shareLctId.length > 0 && [[STIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count > 0) {
        _shareFromId = [[STIMKit sharedInstance] getShareLocationFromIdByShareLocationId:_shareLctId];
        [self initJoinShareView];
    }
    
    if (self.needShowNewMsgTagCell) {
        
        [self.view addSubview:self.readMsgTipView];
        [UIView animateWithDuration:0.3 animations:^{
            [UIView setAnimationDelay:0.1];
            [self.readMsgTipView setFrame:CGRectMake(self.view.width - _readMsgTipView.width, _readMsgTipView.top, _readMsgTipView.width, _readMsgTipView.height)];
        }];
    }
    [self.textBar performSelector:@selector(keyBoardDown) withObject:nil afterDelay:0.5];
}

- (void)updateTitleView:(NSNotification *)notify {

    NSDictionary *dic = notify.object;
    if (dic.count) {
        NSString *jid = [dic objectForKey:@"jid"];
        NSString *nickName = [dic objectForKey:@"nickName"];
        if ([jid isEqualToString:self.chatId]) {
            self.title = nickName;
            [self initTitleView];
        }
    }
}

- (void)initTitleView {
    STIMNavTitleView *titleView = [[STIMNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleView.autoresizesSubviews = YES;
    titleView.backgroundColor = [UIColor clearColor];
    
    if (self.chatType == ChatType_ConsultServer) {
        NSDictionary *infoDic = [[STIMKit sharedInstance] getUserInfoByUserId:self.chatId];
        NSString *userName = [infoDic objectForKey:@"Name"];
        if (userName.length <= 0) {
            userName = [self.chatId componentsSeparatedByString:@"@"].firstObject;
        }
        self.title = userName;
    } else if (self.chatType == ChatType_Consult) {
        NSDictionary *consultUserInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.virtualJid];
        NSString *userName = [consultUserInfo objectForKey:@"Name"];
        if (userName.length <= 0) {
            userName = [self.virtualJid componentsSeparatedByString:@"@"].firstObject;
        }
        if (userName) {
            self.title = userName;
        }
    } else if (self.chatType == ChatType_CollectionChat) {
        NSDictionary *collectionUserInfo = [[STIMKit sharedInstance] getCollectionUserInfoByUserId:self.chatId];
        NSString *userName = [collectionUserInfo objectForKey:@"Name"];
        if (userName) {
            self.title = userName;
        }
    }
    if (self.title.length <= 0 || !self.title) {
        NSString *xmppId = [self.chatInfoDict objectForKey:@"XmppId"];
        NSString *userId = [self.chatInfoDict objectForKey:@"UserId"];
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:xmppId];
        if (userInfo.count) {
            self.title = [userInfo objectForKey:@"Name"];
        }
        if (!self.title) {
            self.title = userId;
        }
    }
    self.titleLabel.text = self.title;
    if (self.isEncryptChat) {
        self.titleLabel.text = [self.titleLabel.text stringByAppendingString:@"【加密中】"];
    }
    [titleView addSubview:self.titleLabel];
    if (self.chatType != ChatType_Consult) {
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 200, 12)];
        descLabel.textColor = stimDB_singlechat_desc_color;
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.backgroundColor = [UIColor clearColor];
        descLabel.font = [UIFont systemFontOfSize:11];
        descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (self.chatType == ChatType_ConsultServer) {
            NSDictionary *consultUserInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.virtualJid];
            NSString *virtualName = [consultUserInfo objectForKey:@"Name"];
            if (virtualName.length <= 0) {
                virtualName = [self.virtualJid componentsSeparatedByString:@"@"].firstObject;
            }
            descLabel.text = [NSString stringWithFormat:@"来自%@的咨询用户",virtualName];
        } else if (self.chatType == ChatType_CollectionChat) {
            
        } else {
            if (![[STIMKit sharedInstance] moodshow]) {
                NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.chatId];
                
                descLabel.text = [userInfo objectForKey:@"DescInfo"];
                
            } else {
                NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.chatId];
                NSString *mood = [userInfo objectForKey:@"Mood"];
                if (mood.length > 0) {
                    [descLabel setText:mood];
                } else {
                    descLabel.text = [userInfo objectForKey:@"DescInfo"];
                }
            }
        }
        [titleView addSubview:descLabel];
    }
    self.navigationItem.titleView = titleView;
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    [self.textBar keyBoardDown];
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (![[STIMKit sharedInstance] getIsIpad]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.chatType != ChatType_CollectionChat) {
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
    [_remoteAudioPlayer stop];
    _currentPlayVoiceMsgId = nil;
    if (_shareLctId && [[STIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count == 0) {
        [_joinShareLctView removeFromSuperview];
        _joinShareLctView = nil;
    }
    
    for (int i = 0; i < (int) self.messageManager.dataSource.count - kPageCount * 2; i++) {
        [[STIMMessageCellCache sharedInstance] removeObjectForKey:[(STIMMessageModel *) self.messageManager.dataSource[i] messageId]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNotifications];
    [self setupNavBar];
    self.loadCount = 0;
#warning 通知会话
#if __has_include("STIMNotifyManager.h")

    [[STIMNotifyManager shareNotifyManager] setNotifyManagerSpecifiedDelegate:self];
#endif
    if (self.bindId) {
        self.chatType = ChatType_CollectionChat;
    }
#warning 加密会话
#if __has_include("STIMNoteManager.h")
    [STIMEncryptChat sharedInstance].delegate = self;

    self.isEncryptChat = [[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    self.encryptChatState = [[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    NSInteger securitySettingTime = [[[STIMKit sharedInstance] userObjectForKey:@"securityMinute"] integerValue];
    if (securitySettingTime == 0) {
        //15分钟安全时间
        [[STIMKit sharedInstance] setUserObject:@(15 * 60) forKey:@"securityMinute"];
    }
    NSTimeInterval leftTime = [[STIMEncryptChat sharedInstance] getEncryptChatLeaveTimeWithUserId:self.chatId];
    NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
    //超过安全时间 或 密码不正确
    if (nowTime - leftTime > securitySettingTime) {
        
        if (self.encryptChatState == STIMEncryptChatStateDecrypted) {
            [[STIMEncryptChat sharedInstance] cancelDescrpytChat];
        } else if (self.encryptChatState == STIMEncryptChatStateEncrypting) {
            [[STIMEncryptChat sharedInstance] closeEncrypt];
        } else {
            
        }
        self.isEncryptChat = NO;
        self.encryptChatState = [[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    } else {
        self.isEncryptChat = [[STIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    }
#endif
    _photos = [[NSMutableDictionary alloc] init];
    _currentPlayVoiceIndex = 0;
    [[STIMKit sharedInstance] setCurrentSessionUserId:self.chatId];
    _rootViewFrame = self.view.frame;
    self.playVoiceManager.chatId = self.chatId;
    self.messageManager.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
    [self initUI];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self synchronizeChatSession];
    });
    if ([self.chatId containsString:@"dujia_warning"]) {
        [self performSelector:@selector(synchronizeDujiaWarning) withObject:nil afterDelay:1.5];
    }
    if (self.chatType == ChatType_Consult) {
        [self requestRobotConsult];
    }
}

-(void)requestRobotConsult{
    NSString *  rexian_id= [self.chatId componentsSeparatedByString:@"@"].firstObject;
    NSString * urlStr = [NSString stringWithFormat:@"%@/robot/qtalk_robot/sendtips?rexian_id=%@&m_from=%@&m_to=%@",[[STIMKit sharedInstance] qimNav_NewHttpUrl],rexian_id,self.chatId,[[STIMKit sharedInstance] getLastJid]];
    
    [[STIMKit sharedInstance] sendTPGetRequestWithUrl:urlStr withSuccessCallBack:^(NSData *responseData) {
        NSDictionary * responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        NSLog(@"转人工 %@",responseDic);
    } withFailedCallBack:^(NSError *error) {
        NSLog(@"%@",error);
    }];
//    [[STIMKit sharedInstance] sendTPPOSTRequestWithUrl:urlStr withSuccessCallBack:^(NSData *responseData) {
//        NSDictionary * responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
//        NSLog(@"转人工 %@",responseDic);
//    } withFailedCallBack:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
}

- (void)initNotifications {
    
    //键盘弹出，消息自动滑动最底
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:kSTIMTextBarIsFirstResponder object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTyping:) name:kTyping object:nil];
    
    if (self.netWorkSearch == NO) {
        //发送快捷回复
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendQuickReplyContent:) name:kNotificationSendQuickReplyContent object:nil];
        
        //点击机器人问题列表
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRobotQuestionText:) name:kNotificationSendRobotQuestion object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageList:) name:kNotificationMessageUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionMessageList:) name:kNotificationCollectionMessageUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHistoryMessageList:) name:kNotificationOfflineMessageUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expandViewItemHandleNotificationHandle:) name:kExpandViewItemHandleNotification object:nil];
        //消息发送成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgDidSendNotificationHandle:) name:kXmppStreamDidSendMessage object:nil];
        //消息发送失败
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgSendFailedNotificationHandle:) name:kXmppStreamSendMessageFailed object:nil];
        //重发消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgReSendNotificationHandle:) name:kXmppStreamReSendMessage object:nil];
        //消息被撤回
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revokeMsgNotificationHandle:) name:kRevokeMsg object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillSendRedPackNotificationHandle:) name:WillSendRedPackNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFileFinished:) name:KDownloadFileFinishedNotificationName object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:@"refreshTableView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginShareLocationMsg:) name:kBeginShareLocation object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endShareLocationMsg:) name:kEndShareLocation object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionImageDidLoad:) name:kNotificationEmotionImageDidLoad object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFileDidUpload:) name:kNotificationFileDidUpload object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceSuccess:) name:kCollectionEmotionUpdateHandleSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceFailed:) name:kCollectionEmotionUpdateHandleFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeNotifyView:) name:kNotifyViewCloseNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceReloadSingleMessages:) name:kSingleChatMsgReloadNotification object:nil];
        
        //刷新个人备注
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitleView:) name:kMarkNameUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadIPadViewFrame:) name:@"reloadIPadViewFrame" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}

#pragma mark - 重新修改frame
- (void)reloadFrame {
    
    _tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.view.height - 59);
    STIMVerboseLog(@"%@",NSStringFromCGRect(_tableView.frame));
    _tableViewFrame = _tableView.frame;
    _rootViewFrame = self.view.frame;
    [[STIMMessageCellCache sharedInstance] clearUp];
    [_tableView setValue:nil forKey:@"reusableTableCells"];
    [self.textBar removeAllSubviews];
    [self.textBar removeFromSuperview];
    self.textBar = nil;
    [STIMTextBar clearALLTextBar];
    [self.view addSubview:self.textBar];
    [self refreshTableView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadIPadLeftView" object:nil];
    });
}

#pragma mark - 监听屏幕旋转

- (void)statusBarOrientationChange:(NSNotification *)notification {
    STIMVerboseLog(@"屏幕发送旋转 : %@", notification);
    if ([[STIMKit sharedInstance] getIsIpad]) {
        [self reloadIPadViewFrame:notification];
    }
}

- (void)reloadIPadViewFrame:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.preferredContentSize = CGSizeMake([[STIMWindowManager shareInstance] getDetailWidth], [[UIScreen mainScreen] height]);
        [self reloadFrame];
    });
}

- (void)synchronizeDujiaWarning {
    [[STIMKit sharedInstance] synchronizeDujiaWarningWithJid:self.chatId];
}

- (void)synchronizeChatSession {
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
    }
    [[STIMKit sharedInstance] synchronizeChatSessionWithUserId:userId WithChatType:self.chatType WithRealJid:realJid];
}

- (void)forceReloadSingleMessages:(NSNotification *)notify {
    long long currentMaxSingleMsgTime = [[STIMKit sharedInstance] getMaxMsgTimeStampByXmppId:self.chatId];
   STIMMessageModel *msg = [self.messageManager.dataSource lastObject];
    long long currentSingleTime = msg.messageDate;
    if (currentSingleTime < currentMaxSingleMsgTime) {
        STIMVerboseLog(@"重新Reload 单人聊天会话框");
        [self setProgressHUDDetailsLabelText:@"重新加载消息中..."];
        [self loadData];
        [self closeHUD];
        STIMVerboseLog(@"重新Reload 单人聊天会话框结束");
    }
}

- (void)showChatNotifyWithView:(STIMNotifyView *)view WithMessage:(NSDictionary *)message{
    
    NSString *from = [message objectForKey:@"from"];
    NSString *realFrom = [message objectForKey:@"realFrom"];
    NSString *realTo = [message objectForKey:@"realTo"];
    NSString *to = [message objectForKey:@"to"];
    BOOL isConsult = [[message objectForKey:@"isConsult"] boolValue];
    NSInteger consult = [[message objectForKey:@"consult"] integerValue];
    if (isConsult) {
        //客人端展示条，只判断to
        if (consult == ChatType_Consult) {
            if ([self.virtualJid isEqualToString:to]) {
                [self.view addSubview:view];
            }
        } else {
            //客服端展示条，判断to与realto
            if ([self.virtualJid isEqualToString:to] && [self.chatId isEqualToString:realTo]) {
                [self.view addSubview:view];
            }
        }
    } else {
        if ([from isEqualToString:self.chatId] || [to isEqualToString:self.chatId]) {
            [self.view addSubview:view];
        }
    }
}

- (void)closeNotifyView:(NSNotification *)nofity {
    STIMNotifyView *notifyView = nofity.object;
    [notifyView removeFromSuperview];
}
#if __has_include("STIMNoteManager.h")

- (void)reloadBaseViewWithUserId:(NSString *)userId WithEncryptChatState:(STIMEncryptChatState)encryptChatState {
    if ([self.chatId isEqualToString:userId]) {
        self.encryptChatState = encryptChatState;
        switch (self.encryptChatState) {
            case STIMEncryptChatStateNone: {
                self.isEncryptChat = NO;
                _titleLabel.text = self.title;
                [self.encryptBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"apt-kaisuokongxin-f"] forState:UIControlStateNormal];
            }
                break;
            case STIMEncryptChatStateEncrypting: {
                self.isEncryptChat = YES;
                STIMNoteModel *model = [[STIMNoteManager sharedInstance] getEncrptPwdBox];
                self.pwd = [[STIMNoteManager sharedInstance] getChatPasswordWithUserId:self.chatId WithCid:model.c_id];
                _titleLabel.text = [_titleLabel.text stringByAppendingString:@"【加密中】"];
                [self.encryptBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"apt-suokongxin-f"] forState:UIControlStateNormal];
            }
                break;
            case STIMEncryptChatStateDecrypted: {
                self.isEncryptChat = YES;
                STIMNoteModel *model = [[STIMNoteManager sharedInstance] getEncrptPwdBox];
                self.pwd = [[STIMNoteManager sharedInstance] getChatPasswordWithUserId:self.chatId WithCid:model.c_id];
                _titleLabel.text = [_titleLabel.text stringByAppendingString:@"【解密中】"];
                [self.encryptBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"apt-suokongxin-f"] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        [[STIMMessageCellCache sharedInstance] clearUp];
        [self loadData];
    }
}
#endif

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

//lilu 9.22 3DTouch
- (NSArray<id <UIPreviewActionItem>> *)previewActionItems {
    BOOL isStick = [[STIMKit sharedInstance] isStickWithCombineJid:self.chatId];
    NSString *title = isStick ? [NSBundle stimDB_localizedStringForKey:@"chat_remove_sticky"] : [NSBundle stimDB_localizedStringForKey:@"chat_Sticky_Top"];
    
    UIPreviewAction *p1 = [UIPreviewAction actionWithTitle:title style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatSessionStick object:self.chatInfoDict];
    }];
    UIPreviewAction *p3 = [UIPreviewAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Delete"] style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatSessionDelete object:self.chatInfoDict];
    }];
    return @[p1, p3];
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

- (void)collectEmojiFaceFailed:(NSNotification *)notify {
    [self setProgressHUDDetailsLabelText:@"收藏表情失败"];
    [self closeHUD];
    [self.tableView.mj_header endRefreshing];
}

- (void)collectEmojiFaceSuccess:(NSNotification *)notify {
    
    [self setProgressHUDDetailsLabelText:[NSBundle stimDB_localizedStringForKey:@"Added"]];
    [self closeHUD];
}

- (void)cancelTyping {
    if (self.isEncryptChat == YES) {
        _titleLabel.text = [self.title stringByAppendingString:@"【加密中】"];
    } else {
        [_titleLabel setText:self.title];
    }
}

- (void)onTyping:(NSNotification *)notify {
    if ([notify.object isEqualToString:self.chatId]) {
        [_titleLabel setText:@"对方正在输入..."];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelTyping) object:nil];
        [self performSelector:@selector(cancelTyping) withObject:nil afterDelay:5];
    }
}

- (void)checkAddNewMsgTag {
   STIMMessageModel *firstMsg = [self.messageManager.dataSource firstObject];
    if (firstMsg.messageDate > _readedMsgTimeStamp) {
        return;
    }
    int index = 0;
    BOOL needAdd = NO;
    for (STIMMessageModel *msg in self.messageManager.dataSource) {
        if (msg.messageDate >= _readedMsgTimeStamp) {
            needAdd = YES;
            break;
        }
        index++;
    }
    if (needAdd) {
        STIMMessageModel *msg = [STIMMessageModel new];
        [msg setMessageType:STIMMessageType_NewMsgTag];
        [self.messageManager.dataSource insertObject:msg atIndex:index + 1];
        
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
    __weak id weakSelf = self;
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
        realJid = self.chatId;
    }
    [[STIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:realJid FromTimeStamp:_readedMsgTimeStamp WithComplete:^(NSArray *list) {
        if (list.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.messageManager.dataSource removeAllObjects];
                [self.messageManager.dataSource addObjectsFromArray:list];
                [weakSelf checkAddNewMsgTag];
                [_tableView reloadData];
                [weakSelf hiddenNotReadTipView];
                [weakSelf addImageToImageList];
                if (self.messageManager.dataSource.count > 0) {
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(0) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            });
        } else {
            [weakSelf hiddenNotReadTipView];
        }
    }];
}

-(void)loadSystemData
{
    [self.messageManager.dataSource removeAllObjects];
    __weak __typeof(self) weakSelf = self;
    if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
        
        NSString *domain = [[STIMKit sharedInstance] getDomain];
        [[STIMKit sharedInstance] getSystemMsgLisByUserId:self.chatId WithFromHost:domain WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count withLoadMore:NO WithComplete:^(NSArray *list) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.messageManager.dataSource addObjectsFromArray:list];
                [weakSelf.tableView reloadData];
                [weakSelf scrollBottom];
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(0.5 * NSEC_PER_SEC));
                dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    //标记已读
                    [[STIMKit sharedInstance] clearSystemMsgNotReadWithJid:weakSelf.chatId];
                });
            });
        }];
    } else {
        [[STIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:self.chatId WithLimit:kPageCount WithOffset:0 withLoadMore:NO WithComplete:^(NSArray *list) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.messageManager.dataSource addObjectsFromArray:list];
                [weakSelf.tableView reloadData];
                [weakSelf scrollBottom];
            });
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(0.5 * NSEC_PER_SEC));
            dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                //标记已读
                [[STIMKit sharedInstance] clearSystemMsgNotReadWithJid:weakSelf.chatId];
            });
        }];
    }
}

- (void)loadData {
    if (self.netWorkSearch) {
        [self loadNetWorkData];
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_CollectionChat) {
        NSArray *collectionMsgs = [[STIMKit sharedInstance] getCollectionMsgListForUserId:self.bindId originUserId:self.chatId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageManager.dataSource removeAllObjects];
            [self.messageManager.dataSource addObjectsFromArray:collectionMsgs];
            [_tableView reloadData];
            [weakSelf scrollBottom];
            [weakSelf addImageToImageList];
            //标记已读
            [weakSelf markReadFlag];
        });
    } else {
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
            realJid = self.chatId;
        }
        if (self.fastMsgTimeStamp > 0) {
            [[STIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid FromTimeStamp:self.fastMsgTimeStamp WithComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    CGFloat offsetY = _tableView.contentSize.height - _tableView.contentOffset.y;
                    NSRange range = NSMakeRange(0, [list count]);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    
                    [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                    [_tableView reloadData];
                    //重新获取一次大图展示的数组
                    [weakSelf addImageToImageList];
                    [weakSelf.tableView.mj_header endRefreshing];
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(0.5 * NSEC_PER_SEC));
                    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                });
            }];
        } else {
            if (self.chatType == ChatType_ConsultServer) {
                [[STIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:0 withLoadMore:NO WithComplete:^(NSArray *list) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageManager.dataSource removeAllObjects];
                        [self.messageManager.dataSource addObjectsFromArray:list];
                        [_tableView reloadData];
                        
                        [weakSelf scrollBottom];
                        [weakSelf addImageToImageList];
                        if (_willSendImageData) {
                            [weakSelf sendImageData:_willSendImageData];
                            _willSendImageData = nil;
                        }
                        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(0.5 * NSEC_PER_SEC));
                        dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                            //标记已读
                            [weakSelf markReadFlag];
                        });
                    });
                }];
            } else if (self.chatType == ChatType_System) {
                
                [self loadSystemData];
            } else {
                [[STIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WithLimit:kPageCount WithOffset:0 withLoadMore:NO WithComplete:^(NSArray *list) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageManager.dataSource removeAllObjects];
                        [self.messageManager.dataSource addObjectsFromArray:list];
                        [_tableView reloadData];
                        [weakSelf scrollToBottom_tableView];
                        [weakSelf addImageToImageList];
                        if (_willSendImageData) {
                            [weakSelf sendImageData:_willSendImageData];
                            _willSendImageData = nil;
                        }
                        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(0.5 * NSEC_PER_SEC));
                        dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                            //标记已读
                            [weakSelf markReadFlag];
                        });
                    });
                }];
            }
        }
    }
}

- (void)loadNetWorkData {
    //搜索服务器消息
    __weak __typeof(self) weakSelf = self;
    [[STIMKit sharedInstance] getRemoteSearchMsgListByUserId:self.chatId WithRealJid:self.chatId withVersion:self.fastMsgTimeStamp withDirection:STIMGetMsgDirectionUp WithLimit:20 WithOffset:0 WithComplete:^(NSArray *list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageManager.dataSource removeAllObjects];
            [self.messageManager.dataSource addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [weakSelf addImageToImageList];
        });
    }];
}

- (void)markReadFlag {
    
    static int count = 0;
    NSString *userId = @"";
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
        realJid = self.chatId;
    }
    //取出数据库所有消息，置已读
    count ++;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *markReadMsgList = [[STIMKit sharedInstance] getNotReadMsgIdListByUserId:userId WithRealJid:realJid];
        STIMVerboseLog(@"markReadMsgList : %d", markReadMsgList);
        if (markReadMsgList.count > 0) {
            [[STIMKit sharedInstance] sendReadStateWithMessagesIdArray:markReadMsgList WithMessageReadFlag:STIMMessageReadFlagDidRead WithXmppId:self.chatId WithRealJid:realJid];
        }
    });
}

//右上角名片信息
- (void)onCardClick {
    if (![[[STIMKit sharedInstance] userObjectForKey:@"kRightCardRemindNotification"] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRightCardRemindNotification object:nil];
        [[STIMKit sharedInstance] setUserObject:@(YES) forKey:kRightCardRemindNotification];
    }
    NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.chatId];
    NSString *userId = [userInfo objectForKey:@"XmppId"];
    if (userId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [STIMFastEntrance openUserChatInfoByUserId:userId];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [STIMFastEntrance openUserChatInfoByUserId:self.chatId];
        });
    }
}

//右上角加密
- (void)encryptChat:(id)sender {
#if __has_include("STIMNoteManager.h")
    [[STIMEncryptChat sharedInstance] doSomeEncryptChatWithUserId:self.chatId];
#endif
}

//右上角创建群聊
- (void)onCreateGroupClcik {
    STIMGroupCreateVC *groupCreateVC = [[STIMGroupCreateVC alloc] init];
    groupCreateVC.userId = self.chatId;
    groupCreateVC.userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.chatId];
    [self.navigationController pushViewController:groupCreateVC animated:YES];
}

//右上角关闭咨询会话
- (void)endChatSession {
    UIAlertController *endChatSessionAlertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"您确认结束本次服务？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[STIMKit sharedInstance] closeSessionWithShopId:self.virtualJid WithVisitorId:self.chatId withBlock:^(NSString *closeMsg) {
            if (closeMsg.length > 0) {
                [[STIMProgressHUD sharedInstance] showProgressHUDWithTest:closeMsg];
                [[STIMProgressHUD sharedInstance] closeHUD];
                [self leftBarBtnClicked:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"结束本地会话失败" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }];
    [endChatSessionAlertVc addAction:cancelAction];
    [endChatSessionAlertVc addAction:okAction];
    [self.navigationController presentViewController:endChatSessionAlertVc animated:YES completion:nil];
}

//左上角返回按钮
- (void)leftBarBtnClicked:(id)sender {
    [self.view endEditing:YES];
    if ([[STIMKit sharedInstance] getIsIpad] == NO) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
#if __has_include("STIMIPadWindowManager.h")
        [[STIMIPadWindowManager sharedInstance] showOriginLaunchDetailVC];
#endif
    }
}

//SwipeBack
- (void)selfPopedViewController {
    [super selfPopedViewController];
    [[STIMKit sharedInstance] setNotSendText:[self.textBar getSendAttributedText] inputItems:[self.textBar getAttributedTextItems] ForJid:self.chatId];
    [[STIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshChatBGImageView {
    
    if (!_chatBGImageView) {
        
        _chatBGImageView = [[UIImageView alloc] initWithFrame:_tableView.bounds];
        _chatBGImageView.contentMode = UIViewContentModeScaleAspectFill;
        _chatBGImageView.clipsToBounds = YES;
    }
    //TODO Startalk start
//    if ([[STIMKit sharedInstance] waterMarkState] == YES) {
//        [STIMChatBgManager getChatBgById:[STIMKit getLastUserName] ByName:[[STIMKit sharedInstance] getMyNickName] WithReset:NO Complete:^(UIImage * _Nonnull bgImage) {
//            _chatBGImageView.image = bgImage;
//            _tableView.backgroundView = _chatBGImageView;
//        }];
//    }
    //TODO Startalk end
    /*
     //老版本带个性装扮时候的会话背景
    NSMutableDictionary *chatBGImageDic = [[STIMKit sharedInstance] userObjectForKey:@"chatBGImageDic"];
    if (chatBGImageDic) {
        
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        UIImage *image = [UIImage imageWithContentsOfFile:[[STIMDataController getInstance] getSourcePath:[NSString stringWithFormat:@"chatBGImageFor_%@", self.chatId]]];
        if (!image) {
            
            image = [UIImage imageWithContentsOfFile:[[STIMDataController getInstance] getSourcePath:@"chatBGImageFor_Common"]];
        }
        if (image) {
            _chatBGImageView.image = image;
            [self.view insertSubview:_chatBGImageView belowSubview:self.tableView];
        } else {
            if ([[STIMKit sharedInstance] waterMarkState] == YES) {
                [STIMChatBgManager getChatBgById:[STIMKit getLastUserName] ByName:[[STIMKit sharedInstance] getMyNickName] WithReset:NO Complete:^(UIImage * _Nonnull bgImage) {
                    _chatBGImageView.image = bgImage;
                    _tableView.backgroundView = _chatBGImageView;
                }];
            }
        }
    } else {
        if ([[STIMKit sharedInstance] waterMarkState] == YES) {
            [STIMChatBgManager getChatBgById:[STIMKit getLastUserName] ByName:[[STIMKit sharedInstance] getMyNickName] WithReset:NO Complete:^(UIImage * _Nonnull bgImage) {
                _chatBGImageView.image = bgImage;
                _tableView.backgroundView = _chatBGImageView;
            }];
        }
    }
     */
}

- (void)dealloc {
#if __has_include("STIMNoteManager.h")
    [[STIMEncryptChat sharedInstance] setEncryptChatLeaveTimeWithUserId:self.chatId WithTime:[NSDate timeIntervalSinceReferenceDate]];
#endif
    [[STIMNavBackBtn sharedInstance] removeTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if kHasVoice
    _remoteAudioPlayer = nil;
#endif
    _tableView.mj_header = nil;
    _chatId = nil;
    _chatInfoDict = nil;
    _notificationView = nil;
//    _textBar = nil;
    _photos = nil;
    _imagesArr = nil;
    _chatBGImageView = nil;
    _titleLabel = nil;
    _resendMsg = nil;
    _willSendImageData = nil;
    
    _transferReason = nil;
    _shareLctVC = nil;
    _joinShareLctView = nil;
    _shareLctId = nil;
    _shareFromId = nil;
    
    _readMsgTipView = nil;
    _playVoiceManager = nil;
    
    _forwardNavTitleView = nil;
    _maskRightTitleView = nil;
    _forwardBtn = nil;
    _jsonFilePath = nil;
    
    _voiceRecordingView = nil;
    _voiceTimeRemindView = nil;
    _tableView = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _messageManager = nil;
    _dataNow = nil;
    _currentPlayVoiceMsgId = nil;
//    [_textBar removeFromSuperview];
}

- (void)viewDidUnload {
    _tableView = nil;
    [super viewDidUnload];
}


#if kHasVoice

#pragma mark - Audio Method

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId {
    return [msgId isEqualToString:self.currentPlayVoiceMsgId];
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFilePath:(NSString *)filePath {
    
    self.currentPlayVoiceMsgId = msgId;
    self.isNoReadVoice = [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] playVoiceIsNoReadWithMsgId:msgId ChatId:self.chatId];
    if (msgId) {
        self.currentPlayVoiceIndex = [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getIndexOfMsgIdWithChatId:self.chatId msgId:msgId];
        // 开始播放
        if ([filePath stimDB_hasPrefixHttpHeader]) {
            
            [self.remoteAudioPlayer prepareForURL:filePath playAfterReady:YES];
        } else {
            [self.remoteAudioPlayer prepareForFilePath:filePath playAfterReady:YES];
        }
    } else {
        // 结束播放
        [self.remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    NSString *messageId = [[STIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBeginToPlay
                                                        object:messageId];
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl {
    
    self.currentPlayVoiceMsgId = msgId;
    self.isNoReadVoice = [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] playVoiceIsNoReadWithMsgId:msgId ChatId:self.chatId];
    if (msgId) {
        self.currentPlayVoiceIndex = [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getIndexOfMsgIdWithChatId:self.chatId msgId:msgId];
        [self.remoteAudioPlayer prepareForFileName:fileName andVoiceUrl:voiceUrl playAfterReady:YES];
    } else {
        [self.remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    NSString *messageId = [[STIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBeginToPlay
                                                        object:messageId];
}


- (void)remoteAudioPlayerReady:(STIMRemoteAudioPlayer *)player {
    
    NSString *msgId = [[STIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:msgId ChatId:self.chatId withState:YES];
}


- (void)remoteAudioPlayerErrorOccured:(STIMRemoteAudioPlayer *)player withErrorCode:(STIMRemoteAudioPlayerErrorCode)errorCode {
    
}

- (void)remoteAudioPlayerDidStartPlaying:(STIMRemoteAudioPlayer *)player {
    
    [self updateCurrentPlayVoiceTime];
}

- (void)remoteAudioPlayerDidFinishPlaying:(STIMRemoteAudioPlayer *)player {
    // 1. 告诉播放者，我播放完毕了
    NSString *msgId = [[STIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyEndPlay
                                                        object:msgId];
    self.currentPlayVoiceMsgId = nil;
    NSInteger count = [[STIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getVisibleNoReadSoundsCountWithChatId:self.chatId];
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
        [self performSelector:@selector(updateCurrentPlayVoiceTime) withObject:nil afterDelay:1];
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


- (void)shareLocationCancelBtnHandle:(id)sender {
    [_joinShareLctView removeAllSubviews];
    [UIView animateWithDuration:0.3 animations:^{
        [_joinShareLctView setFrame:CGRectMake(0, 0, self.view.width, 44)];
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:_shareFromId];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, _joinShareLctView.width - 100, _joinShareLctView.height)];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [tipsLabel setFont:[UIFont systemFontOfSize:14]];
        tipsLabel.textColor = [UIColor whiteColor];
        [tipsLabel setText:[NSString stringWithFormat:@"%@%@", [userInfo objectForKey:@"Name"],[NSBundle stimDB_localizedStringForKey:@"Location sharing"]]];
        [_joinShareLctView addSubview:tipsLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"iconfont-arrow"]];
        [arrowImageView setFrame:CGRectMake(_joinShareLctView.right - 40, (_joinShareLctView.height - arrowImageView.width) / 2.0, arrowImageView.width, arrowImageView.height)];
        [_joinShareLctView addSubview:arrowImageView];
    }];
}

- (void)shareLocationJoinBtnHandle:(id)sender {
    
    [[self navigationController] presentViewController:self.shareLctVC animated:YES completion:nil];
}

#pragma mark - notification

- (void)onFileDidUpload:(NSNotification *)notify {
    [self refreshCellForMsg:notify.object];
}

- (void)emotionImageDidLoad:(NSNotification *)notify {
    for (STIMMessageModel *msg in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:notify.object]) {
            STIMTextContainer *container = [STIMMessageParser textContainerForMessage:msg fromCache:NO];
            if (container) {
                [[STIMMessageCellCache sharedInstance] setObject:container forKey:msg.messageId];
            }
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)downloadFileFinished:(NSNotification *)notify {
    [self refreshTableView];
}

- (void)onJoinShareViewClick {
    
    [_joinShareLctView removeAllSubviews];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, self.view.width - 80, 40)];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setFont:[UIFont systemFontOfSize:14]];
    [contentLabel setText:@"加入位置共享，聊天中其他人也能看到你的位置，确定加入？"];
    [contentLabel setNumberOfLines:2];
    [contentLabel setTextColor:[UIColor whiteColor]];
    [_joinShareLctView addSubview:contentLabel];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor stimDB_colorWithHex:0x53676f alpha:1]];
    [cancelBtn setClipsToBounds:YES];
    [cancelBtn.layer setCornerRadius:2.5];
    [cancelBtn addTarget:self action:@selector(shareLocationCancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(contentLabel.left, contentLabel.bottom + 10, 80, 30);
    [cancelBtn setHidden:YES];
    [_joinShareLctView addSubview:cancelBtn];
    
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setTitle:@"加入" forState:UIControlStateNormal];
    [joinBtn setBackgroundColor:[UIColor stimDB_colorWithHex:0x9fb7be alpha:1]];
    [joinBtn setClipsToBounds:YES];
    [joinBtn.layer setCornerRadius:2.5];
    [joinBtn addTarget:self action:@selector(shareLocationJoinBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    joinBtn.frame = CGRectMake(contentLabel.right - 80, cancelBtn.top, 80, 30);
    [joinBtn setHidden:YES];
    [_joinShareLctView addSubview:joinBtn];
    [UIView animateWithDuration:0.1 animations:^{
        [_joinShareLctView setFrame:CGRectMake(0, 0, self.view.width, joinBtn.bottom + 10)];
    }                completion:^(BOOL finished) {
        [joinBtn setHidden:NO];
        [cancelBtn setHidden:NO];
    }];
    
}

- (void)initJoinShareView {
    if (_joinShareLctView == nil) {
        _joinShareLctView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _joinShareLctView.backgroundColor = [UIColor stimDB_colorWithHex:0x808e94 alpha:0.85];
        [self.view addSubview:_joinShareLctView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onJoinShareViewClick)];
        [_joinShareLctView addGestureRecognizer:tap];
        
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:_shareFromId];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, _joinShareLctView.width - 100, _joinShareLctView.height)];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [tipsLabel setFont:[UIFont systemFontOfSize:14]];
        tipsLabel.textColor = [UIColor whiteColor];
        [tipsLabel setText:[NSString stringWithFormat:@"%@%@", [userInfo objectForKey:@"Name"],[NSBundle stimDB_localizedStringForKey:@"Location sharing"]]];
        [_joinShareLctView addSubview:tipsLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"iconfont-arrow"]];
        [arrowImageView setFrame:CGRectMake(_joinShareLctView.right - 40, (_joinShareLctView.height - arrowImageView.width) / 2.0, arrowImageView.width, arrowImageView.height)];
        [_joinShareLctView addSubview:arrowImageView];
        
        [self.view addSubview:_joinShareLctView];
    }
    
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
    if (_shareLctId && [[STIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count == 0) {
        [_joinShareLctView removeFromSuperview];
        _joinShareLctView = nil;
    }
    _shareLctVC = nil;
    _shareLctId = nil;
}

- (void)expandViewItemHandleNotificationHandle:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *trId = notify.object;
        if ([trId isEqualToString:STIMTextBarExpandViewItem_Shock]) {
            
            NSDate *dateAgain = [NSDate date];
            NSTimeInterval timeInterval = [dateAgain timeIntervalSinceDate:self.dataNow];
            NSInteger isnanTimeInterval = isnan(timeInterval);
            //两次有效窗口抖动的时间间隔为10s，第一次timeInterval为nan，用isnan(timeInterval)判断
            if (timeInterval > 10 || isnanTimeInterval) {
                
                STIMMessageModel *msg = [[STIMKit sharedInstance] sendShockToUserId:self.chatId];
                
                [self.messageManager.dataSource addObject:msg];
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                [_tableView endUpdates];
                [self scrollToBottomWithCheck:YES];;
                self.dataNow = dateAgain;
            }
            
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_MyFiles]) {
            STIMFileManagerViewController *fileManagerVC = [[STIMFileManagerViewController alloc] init];
            fileManagerVC.isSelect = YES;
            fileManagerVC.userId = self.chatId;
            fileManagerVC.messageSaveType = ChatType_SingleChat;
            
            STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:fileManagerVC];
            if ([[STIMKit sharedInstance] getIsIpad] == YES) {
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
#if __has_include("STIMIPadWindowManager.h")
                [[[STIMIPadWindowManager sharedInstance] detailVC] presentViewController:nav animated:YES completion:nil];
#endif
            } else {
                [self presentViewController:nav animated:YES completion:nil];
            }
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_ChatTransfer]) {
            [STIMFastEntrance openTransferConversation:self.virtualJid withVistorId:self.chatId];
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_ShareCard]) {
            //分享名片
            STIMOrganizationalVC *listVc = [[STIMOrganizationalVC alloc] init];
            [listVc setShareCard:YES];
            [listVc setShareCardDelegate:self];
            _expandViewItemType = STIMTextBarExpandViewItemType_ShareCard;
            STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:listVc];
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                
            }];
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_RedPack]) {
            STIMVerboseLog(@"我是 单人红包，点我 干哈？");
            
            STIMWebView *webView = [[STIMWebView alloc] init];
            webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", [[STIMKit sharedInstance] redPackageUrlHost], [STIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [STIMKit getLastUserName]] stimDB_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey],  [[STIMKit sharedInstance] getDomain]];
            //        webView.navBarHidden = YES;
            [webView setFromRegPackage:YES];
            [self.navigationController pushViewController:webView animated:YES];
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_AACollection]) {
            STIMWebView *webView = [[STIMWebView alloc] init];
            webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", [[STIMKit sharedInstance] aaCollectionUrlHost], [STIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [STIMKit getLastUserName]] stimDB_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[STIMKit sharedInstance] myRemotelogginKey],  [[STIMKit sharedInstance] getDomain]];
            webView.navBarHidden = YES;
            [webView setFromRegPackage:YES];
            [self.navigationController pushViewController:webView animated:YES];
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_SendProduct]) {
            STIMPushProductViewController *pushProVC = [[STIMPushProductViewController alloc] init];
            pushProVC.delegate = self;
            [self.navigationController pushViewController:pushProVC animated:YES];
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_Location]) {
            [STIMAuthorizationManager sharedManager].authorizedBlock = ^{
                UserLocationViewController *userLct = [[UserLocationViewController alloc] init];
                userLct.delegate = self;
                if ([[STIMKit sharedInstance] getIsIpad] == YES) {
                    userLct.modalPresentationStyle = UIModalPresentationCurrentContext;
#if __has_include("STIMIPadWindowManager.h")
                    [[[STIMIPadWindowManager sharedInstance] detailVC] presentViewController:userLct animated:YES completion:nil];
#endif
                } else {
                    [self.navigationController presentViewController:userLct animated:YES completion:nil];
                }
            };
            [[STIMAuthorizationManager sharedManager] requestAuthorizationWithType:ENUM_QAM_AuthorizationTypeLocation];
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_VideoCall]) {
#if __has_include("STIMWebRTCClient.h")
            [[STIMWebRTCClient sharedInstance] setRemoteJID:self.chatId];
            [[STIMWebRTCClient sharedInstance] showRTCViewByXmppId:self.chatId isVideo:YES isCaller:YES];
#endif
        } else if ([trId isEqualToString:STIMTextBarExpandViewItem_Encryptchat]) {
#if __has_include("STIMNoteManager.h")
            [[STIMEncryptChat sharedInstance] doSomeEncryptChatWithUserId:self.chatId];
#endif
        } else {
            NSDictionary *trdExtendDic = [[STIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
            int linkType = [[trdExtendDic objectForKey:@"linkType"] intValue];
            BOOL openSTIMRN = linkType & 4;
            BOOL openRequeset = linkType & 2;
            BOOL openWebView = linkType & 1;
            NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
            NSString *userId = nil;
            NSString *realJid = nil;
            if (self.chatType == ChatType_Consult) {
                userId = self.virtualJid;
                realJid = self.virtualJid;
            } else if (self.chatType == ChatType_ConsultServer) {
                userId = self.virtualJid;
                realJid = self.chatId;
            } else {
                userId = self.chatId;
            }
            if (openSTIMRN) {
                [STIMFastEntrance openSTIMRNWithScheme:linkUrl withChatId:userId withRealJid:realJid withChatType:self.chatType];
            } else if (openRequeset) {
                [[STIMKit sharedInstance] sendTPPOSTRequestWithUrl:linkUrl withChatId:userId withRealJid:realJid withChatType:self.chatType];
            } else {
                if (linkUrl.length > 0) {
                    if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                        linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&realJid=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[STIMKit sharedInstance] getLastJid], userId, realJid, self.chatType];
                    } else {
                        linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&realJid=%@&chatType=%lld", ([linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[STIMKit sharedInstance] getLastJid], userId, realJid, self.chatType];
                    }
                    [STIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
                }
            }
        }
    });
}

- (void)msgDidSendNotificationHandle:(NSNotification *)notify {
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    
    //消息发送成功，更新消息状态，刷新tableView
    for (STIMMessageModel *msg in self.messageManager.dataSource) {
        //找到对应的msg，目前还不知道msgID
        if ([[msg messageId] isEqualToString:msgID]) {
            if (msg.messageSendState < STIMMessageSendState_Success) {
                msg.messageSendState = STIMMessageSendState_Success;
            }
            break;
        }
    }
}

- (void)msgSendFailedNotificationHandle:(NSNotification *)notify {
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    
    //消息发送失败，更新消息状态，刷新tableView
    for (STIMMessageModel *msg in self.messageManager.dataSource) {
        //找到对应的msg，目前还不知道msgID
        if ([[msg messageId] isEqualToString:msgID]) {
            if (msg.messageSendState < STIMMessageSendState_Faild) {
                msg.messageSendState = STIMMessageSendState_Faild;
            }
            break;
        }
    }
}

- (void)removeFailedMsg {
   STIMMessageModel *message = _resendMsg;
    for (STIMMessageModel *msg in self.messageManager.dataSource) {
        if ([msg isEqual:message]) {
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            
            [self.messageManager.dataSource removeObject:msg];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            [[STIMKit sharedInstance] deleteMsg:message ByJid:self.chatId];
            break;
        }
    }
}

- (void)reSendMsg {
   STIMMessageModel *message = _resendMsg;
    [self removeFailedMsg];
    if (message.messageType == STIMMessageType_LocalShare) {
        if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
            [[STIMKit sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:message.messageType];
        } else {
            [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
        }
    } else if (message.messageType == STIMMessageType_Voice) {
//        NSDictionary *infoDic = [message getMsgInfoDic];
        NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSString *fileName = [infoDic objectForKey:@"FileName"];
        NSString *filePath = [infoDic objectForKey:@"filepath"];
        NSNumber *Seconds = [infoDic objectForKey:@"Seconds"];
        NSData *amrData = [NSData dataWithContentsOfFile:filePath];
        //将armData文件上传，获取到相应的url
        NSString *httpUrl = [STIMKit updateLoadVoiceFile:amrData WithFilePath:filePath];
        [self sendVoiceUrl:httpUrl WithDuration:[Seconds intValue] WithSmallData:amrData WithFileName:fileName AndFilePath:filePath];
    } else if (message.messageType == STIMMessageType_Text) {
        if ([self isImageMessage:message.message]) {
            
            STIMTextContainer *textContainer = [STIMMessageParser textContainerForMessage:message];
            STIMImageStorage *imageStorage = textContainer.textStorages.lastObject;
            NSData *data = [[STIMKit sharedInstance] getFileDataFromUrl:[imageStorage.imageURL absoluteString] forCacheType:STIMFileCacheTypeColoction];
            [self sendImageData:data];
            
        } else {
            
            message = [[STIMKit sharedInstance] createMessageWithMsg:message.message extenddInfo:message.extendInformation userId:self.chatId userType:self.chatType msgType:message.messageType forMsgId:_resendMsg.messageId];
            
            [self.messageManager.dataSource addObject:message];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
                message = [[STIMKit sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:message.messageType];
            } else {
                message = [[STIMKit sharedInstance] sendMessage:message ToUserId:self.chatId];
            }
            [self scrollToBottomWithCheck:YES];
        }
    } else if (message.messageType == STIMMessageType_CardShare) {
        if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
            message = [[STIMKit sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:message.messageType];
        } else {
            [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
        }
    } else if (message.messageType == STIMMessageType_SmallVideo) {
//        NSDictionary *infoDic = [message getMsgInfoDic];
        NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSString *filePath = [[[STIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:[infoDic objectForKey:@"ThumbName"] ? [infoDic objectForKey:@"ThumbName"] : @""];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        
        NSString *videoPath = [[[STIMKit sharedInstance] getDownloadFilePath] stringByAppendingFormat:@"/%@", [infoDic objectForKey:@"FileName"]];
        
        [self sendVideoPath:videoPath WithThumbImage:image WithFileSizeStr:[infoDic objectForKey:@"FileSize"] WithVideoDuration:[[infoDic objectForKey:@"Duration"] floatValue] forMsgId:_resendMsg.messageId];
    }
    _resendMsg = nil;
}

- (void)msgReSendNotificationHandle:(NSNotification *)notify {
    _resendMsg = notify.object;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重发该消息？" message:nil delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle stimDB_localizedStringForKey:@"Delete"], [NSBundle stimDB_localizedStringForKey:@"Resend"], nil];
    
    alertView.tag = kReSendMsgAlertViewTag;
    alertView.delegate = self;
    [alertView show];
    return;
}

- (void)revokeMsgNotificationHandle:(NSNotification *)notify {
    //    NSString * jid = notify.object;
    NSString *msgID = [notify.userInfo objectForKey:@"MsgId"];
    //    NSString * content = [notify.userInfo objectForKey:@"Content"];
    for (STIMMessageModel *msg in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:msgID]) {
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            [(STIMMessageModel *) msg setMessageType:STIMMessageType_Revoke];
            [self.messageManager.dataSource replaceObjectAtIndex:index withObject:msg];
            [[STIMKit sharedInstance] updateMsg:msg ByJid:self.chatId];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}


- (void)WillSendRedPackNotificationHandle:(NSNotification *)noti {
    NSString *infoStr = [NSString stimDB_stringWithBase64EncodedString:noti.object];
   STIMMessageModel *msg = [[STIMKit sharedInstance] createMessageWithMsg:@"【红包】请升级最新版本客户端查看红包~" extenddInfo:infoStr userId:self.chatId userType:self.chatType msgType:STIMMessageType_RedPack];
    
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    [self addImageToImageList];
    if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
        msg = [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
    } else {
        msg = [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
    }
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

- (void)updateHistoryMessageList:(NSNotification *)notify {
    
    if ([self.chatId isEqualToString:notify.object]) {
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
            realJid = self.chatId;
        }
        __weak typeof(self) weakSelf = self;
        if (self.chatType == ChatType_ConsultServer) {
            
            [[STIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:0 withLoadMore:NO WithComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageManager.dataSource removeAllObjects];
                    [self.messageManager.dataSource addObjectsFromArray:list];
                    [weakSelf.tableView reloadData];
                    [weakSelf addImageToImageList];
                    [weakSelf scrollToBottomWithCheck:YES];
                });
            }];
        } else {
            [[STIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WithLimit:kPageCount WithOffset:0 withLoadMore:NO WithComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageManager.dataSource removeAllObjects];
                    [self.messageManager.dataSource addObjectsFromArray:list];
                    [weakSelf.tableView reloadData];
                    [weakSelf addImageToImageList];
                    [weakSelf scrollToBottomWithCheck:YES];
                });
            }];
        }
    }
}


- (void)updateCollectionMessageList:(NSNotification *)notify {
    NSDictionary *msgDic = notify.object;
    NSString *originFrom = [msgDic objectForKey:@"Originfrom"];
    NSString *originTo = [msgDic objectForKey:@"Originto"];
    if ([originFrom isEqualToString:self.chatId] && [originTo isEqualToString:self.bindId]) {
        NSString *msgId = [msgDic objectForKey:@"MsgId"];
       STIMMessageModel *msg = [[STIMKit sharedInstance] getCollectionMsgListForMsgId:msgId];
        if (msg) {
            if (!self.messageManager.dataSource) {
                self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:20];
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else if ([self.messageManager.dataSource count] != [_tableView numberOfRowsInSection:0]) {
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else {
                [self.messageManager.dataSource addObject:msg];
                NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]];
                [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            [self addImageToImageList];
            [self scrollToBottomWithCheck:NO];
            [self markReadFlag];
        }
    }
}

//
// 二人消息 是在这里收到的

- (void)updateMessageList:(NSNotification *)notify {
    NSString *userId = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexpath = [[self.tableView indexPathsForVisibleRows] lastObject];
        self.currentMsgIndexs = indexpath.row;
    });
    if (self.chatType == ChatType_Consult) {
        userId = [NSString stringWithFormat:@"%@-%@",self.virtualJid,self.virtualJid];
    } else if (self.chatType == ChatType_ConsultServer) {
        if (_hasServerTransferFeedback && _hasUserTransferFeedback) {
            [[STIMProgressHUD sharedInstance] closeHUD];
        }
        userId = [NSString stringWithFormat:@"%@-%@",self.virtualJid,self.chatId];
    } else {
        userId = self.chatId;
    }
    if ([userId isEqualToString:notify.object]) {
       STIMMessageModel *msg = [notify.userInfo objectForKey:@"message"];
        if (self.chatType == ChatType_ConsultServer) {
            if (msg.messageType == STIMMessageType_TransChatToCustomerService_Feedback) {
                _hasServerTransferFeedback = YES;
            }
            if (msg.messageType == STIMMessageType_TransChatToCustomer_Feedback) {
                _hasUserTransferFeedback = YES;
            }
            if (_hasServerTransferFeedback && _hasUserTransferFeedback) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endTransferChatSession) object:nil];
                [self endTransferChatSession];
            }
        }
        if (msg) {
            if (!self.messageManager.dataSource) {
                self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:20];
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else if ([self.messageManager.dataSource count] != [_tableView numberOfRowsInSection:0]) {
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else {
                [self.messageManager.dataSource addObject:msg];
                NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]];
                [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            [self addImageToImageList];
            [self scrollToBottomWithCheck:NO];
            [self markReadFlag];
        }
    }
}

- (void)scrollBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    STIMVerboseLog(@"IMChatVc %@ Offset : %f", self.chatId, offset.y);
    if (offset.y > self.tableView.height / 2.0f) {
        [self.tableView setContentOffset:offset animated:NO];
    }
}

- (void)scrollToBottom:(BOOL)animated {
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
    }else {
        if([self.tableView numberOfSections] > 0 ){
            NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
            NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex ]-1;
            UITableViewCell *lastRowCell = self.tableView.visibleCells.lastObject;
            if(lastRowIndex > 0 && lastRowCell){
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            }
        } else {
            CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:offset animated:NO];
        }
    }
}

- (BOOL)shouldScrollToBottomForNewMessage {
//    CGFloat _h = self.tableView.contentSize.height - self.tableView.contentOffset.y - (CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom);
    
    if ((self.messageManager.dataSource.count - self.currentMsgIndexs) == self.messageManager.dataSource.count) {
        return YES;
    }
    return (self.messageManager.dataSource.count - self.currentMsgIndexs) <= 3;
}

- (void)scrollToBottomWithCheck:(BOOL)flag {
    
   STIMMessageModel *message = self.messageManager.dataSource.lastObject;
    STIMMessageDirection messageDirection = message.messageDirection;
    if (messageDirection == STIMMessageDirection_Sent) {
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if (_shareLctVC == nil) {
            _shareLctVC = [[ShareLocationViewController alloc] init];
            _shareLctVC.userId = self.chatId;
        }
        [[self navigationController] presentViewController:_shareLctVC animated:YES completion:^{
            
        }];
    } else if (buttonIndex == 1) {
        
        UserLocationViewController *userLct = [[UserLocationViewController alloc] init];
        userLct.delegate = self;
        [self.navigationController presentViewController:userLct animated:YES completion:nil];
    } else if (buttonIndex == 2) {
    }
}


#pragma mark - STIMContactSelectionViewControllerDelegate

- (void)contactSelectionViewController:(STIMContactSelectionViewController *)contactVC chatVC:(STIMChatVC *)vc {
    
    NSDictionary *userInfoDic = [[STIMKit sharedInstance] getUserInfoByUserId:[[STIMKit sharedInstance] getLastJid]];
    NSString *userName = [userInfoDic objectForKey:@"Name"];
    
   STIMMessageModel *msg = [[STIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:STIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setSTIMSafeObject:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [STIMKit getLastUserName], self.title] forKey:@"title"];
    [infoDic setSTIMSafeObject:@"" forKey:@"desc"];
    [infoDic setSTIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[STIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    
    [[STIMKit sharedInstance] uploadFileForData:[NSData dataWithContentsOfFile:_jsonFilePath] forMessage:msg withJid:[contactVC getSelectInfoDic][@"userId"] isFile:YES];
}

- (void)contactSelectionViewController:(STIMContactSelectionViewController *)contactVC groupChatVC:(STIMGroupChatVC *)vc {
    NSDictionary *userInfoDic = [[STIMKit sharedInstance] getUserInfoByUserId:[[STIMKit sharedInstance] getLastJid]];
    NSString *userName = [userInfoDic objectForKey:@"Name"];
    
   STIMMessageModel *msg = [[STIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:STIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setSTIMSafeObject:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [STIMKit getLastUserName], self.title] forKey:@"title"];
    [infoDic setSTIMSafeObject:@"" forKey:@"desc"];
    [infoDic setSTIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[STIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    
    [[STIMKit sharedInstance] uploadFileForData:[NSData dataWithContentsOfFile:_jsonFilePath] forMessage:msg withJid:[contactVC getSelectInfoDic][@"userId"] isFile:YES];
}

#pragma mark -

#pragma mark - STIMOrganizationalVCDelegate

- (void)endTransferChatSession{
    [[STIMProgressHUD sharedInstance] closeHUD];
    _hasUserTransferFeedback = NO;
    _hasServerTransferFeedback = NO;
}

- (void)selectShareContactWithJid:(NSString *)jid {
    if (_expandViewItemType == STIMTextBarExpandViewItemType_ShareCard) {
        //分享名片 选择的user
        NSDictionary *infoDic = [[STIMKit sharedInstance] getUserInfoByUserId:jid];
        if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
            [[STIMKit sharedInstance] sendConsultMessageId:[STIMUUIDTools UUID] WithMessage:[NSString stringWithFormat:@"分享名片：\n昵称：%@\n部门：%@", [infoDic objectForKey:@"Name"], [infoDic objectForKey:@"DescInfo"]] WithInfo:[NSString stringWithFormat:@"{\"userId\":\"%@\"}", [infoDic objectForKey:@"UserId"]] toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:STIMMessageType_CardShare];
        } else {
            [self sendMessage:[NSString stringWithFormat:@"分享名片：\n昵称：%@\n部门：%@", [infoDic objectForKey:@"Name"], [infoDic objectForKey:@"DescInfo"]] WithInfo:[NSString stringWithFormat:@"{\"userId\":\"%@\"}", [infoDic objectForKey:@"UserId"]] ForMsgType:STIMMessageType_CardShare];
        }
    }
}

#pragma mark - STIMInputPopViewDelegate
/*
- (void)inputPopView:(STIMInputPopView *)view willBackWithText:(NSString *)text {
    _inputPopViewIsShow = NO;
    _transferReason = text;
    STIMUserListVC *listVC = [[STIMUserListVC alloc] init];
    [listVC setDelegate:self];
    listVC.isTransfer = YES;
    
    _expandViewItemType = STIMTextBarExpandViewItemType_ChatTransfer;
    STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:listVC];
    [[self navigationController] presentViewController:nav animated:YES completion:nil];
}

- (void)cancelForSTIMInputPopView:(STIMInputPopView *)view {
    _inputPopViewIsShow = NO;
}
*/

#pragma mark - text bar delegate

- (void)sendVideoPath:(NSString *)videoPath
       WithThumbImage:(UIImage *)thumbImage
      WithFileSizeStr:(NSString *)fileSizeStr
    WithVideoDuration:(float)duration {
    [self sendVideoPath:videoPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:duration forMsgId:nil];
}

- (void)sendVideoPath:(NSString *)videoPath
       WithThumbImage:(UIImage *)thumbImage
      WithFileSizeStr:(NSString *)fileSizeStr
    WithVideoDuration:(float)duration forMsgId:(NSString *)mId {
    [self.view setFrame:_rootViewFrame];
    NSString *msgId = mId.length ? mId : [STIMUUIDTools UUID];
    CGSize size = thumbImage.size;
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.8);
    NSString *pathExtension = [[videoPath lastPathComponent] pathExtension];
    NSString *fileName = [[videoPath lastPathComponent] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    NSString *thumbFilePath = [videoPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    [thumbData writeToFile:thumbFilePath atomically:YES];
    
    NSString *httpUrl = [STIMKit updateLoadFile:thumbData WithMsgId:msgId WithMsgType:STIMMessageType_Image WithPathExtension:@"jpg"];
    
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setSTIMSafeObject:httpUrl forKey:@"ThumbUrl"];
    [dicInfo setSTIMSafeObject:fileName forKey:@"ThumbName"];
    [dicInfo setSTIMSafeObject:[videoPath lastPathComponent] forKey:@"FileName"];
    [dicInfo setSTIMSafeObject:@(size.width) forKey:@"Width"];
    [dicInfo setSTIMSafeObject:@(size.height) forKey:@"Height"];
    [dicInfo setSTIMSafeObject:fileSizeStr forKey:@"FileSize"];
    [dicInfo setSTIMSafeObject:@(duration) forKey:@"Duration"];
    NSString *msgContent = [[STIMJSONSerializer sharedInstance] serializeObject:dicInfo];
    
    STIMMessageModel *msg = [STIMMessageModel new];
    [msg setMessageId:msgId];
    [msg setMessageDirection:STIMMessageDirection_Sent];
    [msg setChatType:self.chatType];
    [msg setMessageType:STIMMessageType_SmallVideo];
    [msg setMessageDate:([[NSDate date] timeIntervalSince1970] - [[STIMKit sharedInstance] getServerTimeDiff]) * 1000];
    [msg setFrom:[[STIMKit sharedInstance] getLastJid]];
    [msg setRealJid:self.chatId];
    [msg setMessage:msgContent];
    [msg setTo:self.chatId];
    [msg setPlatform:IMPlatform_iOS];
    [msg setMessageSendState:STIMMessageSendState_Waiting];
    
    [[STIMKit sharedInstance] saveMsg:msg ByJid:self.chatId];
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    [[STIMKit sharedInstance] uploadFileForPath:videoPath forMessage:msg withJid:self.chatId isFile:YES];
}

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType {
    if (msgType == STIMMessageType_LocalShare) {
        NSData *imageData = [[STIMKit sharedInstance] userObjectForKey:@"userLocationScreenshotImage"];
       STIMMessageModel *msg = nil;
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:STIMMessageType_LocalShare forMsgId:[STIMUUIDTools UUID] willSave:YES];
        } else {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:self.chatType msgType:STIMMessageType_LocalShare forMsgId:_resendMsg.messageId];
        }
        [msg setOriginalMessage:[msg message]];
        [msg setOriginalExtendedInfo:[msg extendInformation]];
        
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        [[STIMKit sharedInstance] uploadFileForData:imageData forMessage:msg withJid:self.chatId isFile:NO];
    } else {
       STIMMessageModel *msg = nil;
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:msgType forMsgId:_resendMsg.messageId willSave:YES];
        }
#if __has_include("STIMNoteManager.h")
        else if (self.encryptChatState == STIMEncryptChatStateEncrypting) {
            msg = [[STIMKit sharedInstance] sendMessage:message WithInfo:info ToUserId:self.chatId WithMsgType:STIMMessageType_Encrypt];
        }
#endif
        else {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:self.chatType msgType:msgType forMsgId:_resendMsg.messageId];
        }
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        if (self.chatId) {
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
            }
#if __has_include("STIMNoteManager.h")
            else if (self.encryptChatState == STIMEncryptChatStateEncrypting) {
                
            }
#endif
            else {
                msg = [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            }
        }
    }
}

- (void)sendTyping {
    [[STIMKit sharedInstance] sendTypingToUserId:self.chatId];
}

- (void)sendCollectionFaceStr:(NSString *)faceStr {
    if ([faceStr isEqualToString:kImageFacePageViewAddFlagName]) {
        //添加按钮点击
        STIMCollectionEmotionEditorVC *emotionEditor = [[STIMCollectionEmotionEditorVC alloc] init];
        STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:emotionEditor];
        [self presentViewController:nav animated:YES completion:nil];
        
    } else {
        if (![faceStr stimDB_hasPrefixHttpHeader]) {
            faceStr = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], faceStr];
        }
        if (faceStr.length > 0) {
            STIMMessageModel *msg = nil;
            NSString *msgText = nil;
            BOOL isFileExist = [[STIMKit sharedInstance] isFileExistForUrl:faceStr width:0 height:0 forCacheType:STIMFileCacheTypeColoction];
            if (isFileExist) {
                NSData *imgData = [[STIMKit sharedInstance] getFileDataFromUrl:faceStr forCacheType:STIMFileCacheTypeColoction];
                CGSize size = [[STIMKit sharedInstance] getFitSizeForImgSize:[STIMImage imageWithData:imgData].size];
                msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", faceStr, size.width, size.height];
            } else {
                msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", faceStr, 0, 0];
            }
            
            if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
                msg = [[STIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:self.chatType msgType:STIMMessageType_Text];
                [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
            }
#if __has_include("STIMNoteManager.h")
            else if(self.encryptChatState == STIMEncryptChatStateEncrypting) {
                NSString *content = [[STIMEncryptChat sharedInstance] encryptMessageWithMsgType:STIMMessageType_Text WithOriginBody:msgText WithOriginExtendInfo:nil WithUserId:self.chatId];
                msg = [[STIMKit sharedInstance] sendMessage:@"[加密收藏表情消息iOS]" WithInfo:content ToUserId:self.chatId WithMsgType:STIMMessageType_Encrypt];
            }
#endif
            else {
                msg = [[STIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:self.chatType msgType:STIMMessageType_Text];
                [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            }
            
            [self.messageManager.dataSource addObject:msg];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
        }
    }
}

- (void)clickFaildCollectionFace {
    UIAlertController *notFoundEmojiAlertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"该表情已失效" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:nil];
    [notFoundEmojiAlertVc addAction:okAction];
    [self presentViewController:notFoundEmojiAlertVc animated:YES completion:nil];
}

- (void)sendNormalEmotion:(NSString *)faceStr WithPackageId:(NSString *)packageId {
    if (faceStr && packageId) {
        NSString *text = [NSString stringWithFormat:@"[obj type=\"%@\" value=\"%@\" width=%@ height=0 ]", @"emoticon",[NSString stringWithFormat:@"[%@]", faceStr], packageId];
        NSDictionary *normalEmotionExtendInfoDic = @{@"height": @(0), @"pkgid":packageId, @"shortcut":faceStr, @"url":@"", @"width": @(0)};
        NSString *normalEmotionExtendInfoStr = [[STIMJSONSerializer sharedInstance] serializeObject:normalEmotionExtendInfoDic];
        if ([text length] > 0) {
           STIMMessageModel *msg = nil;
            if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
                NSDictionary *dict = [[STIMKit sharedInstance] conversationParamWithJid:self.chatId];
                NSString *param = [dict objectForKey:@"urlappend"];
                NSMutableArray *paramDict = [[STIMJSONSerializer sharedInstance] deserializeObject:param error:nil];
                text = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:text WithFilterAppendArray:paramDict];
            } else {
                text = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
            }
            if (self.textBar.isRefer) {
//                text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n",self.title,self.textBar.referMsg.message] stringByAppendingString:text];
                NSDictionary *referMsgUserInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.textBar.referMsg.from];
                NSString *referMsgNickName = [referMsgUserInfo objectForKey:@"Name"];
                text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n", (referMsgNickName.length > 0) ? referMsgNickName : self.textBar.referMsg.from,self.textBar.referMsg.message] stringByAppendingString:text];
                self.textBar.isRefer = NO;
                self.textBar.referMsg = nil;
            }
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                msg = [[STIMKit sharedInstance] createMessageWithMsg:text extenddInfo:normalEmotionExtendInfoStr userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:STIMMessageType_ImageNew forMsgId:[STIMUUIDTools UUID] willSave:YES];
            }
#if __has_include("STIMNoteManager.h")
            else if(self.encryptChatState == STIMEncryptChatStateEncrypting) {
                NSString *content = [[STIMEncryptChat sharedInstance] encryptMessageWithMsgType:STIMMessageType_ImageNew WithOriginBody:text WithOriginExtendInfo:normalEmotionExtendInfoStr WithUserId:self.chatId];
                msg = [[STIMKit sharedInstance] sendMessage:@"[加密表情消息iOS]" WithInfo:content ToUserId:self.chatId WithMsgType:STIMMessageType_Encrypt];
            }
#endif
            else {
                msg = [[STIMKit sharedInstance] createMessageWithMsg:text extenddInfo:normalEmotionExtendInfoStr userId:self.chatId userType:self.chatType msgType:STIMMessageType_ImageNew];
            }
            
            [self.messageManager.dataSource addObject:msg];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
            if (self.chatId) {
                if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                    msg = [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                }
#if __has_include("STIMNoteManager.h")
                else if (self.encryptChatState == STIMEncryptChatStateEncrypting) {
                    
                    if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                        if (self.chatId) {
                            msg = [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                        }
                    } else if (self.encryptChatState == STIMEncryptChatStateEncrypting) {
                        
                    } else {
                        msg = [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                    }
                }
#endif
                else {
                    msg = [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                }
            }
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
    
    NSString *attributedText = [self.textBar getSendAttributedText];
    if (attributedText.length > 0) {
        text = attributedText;
    }
    
    if ([text length] > 0) {
       STIMMessageModel *msg = nil;
        if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
            NSDictionary *dict = [[STIMKit sharedInstance] conversationParamWithJid:self.chatId];
            NSString *param = [dict objectForKey:@"urlappend"];
            NSMutableArray *paramDict = [[STIMJSONSerializer sharedInstance] deserializeObject:param error:nil];
            text = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:text WithFilterAppendArray:paramDict];
        } else {
            text = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
        }
        if (self.textBar.isRefer) {
//            text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n",self.title,self.textBar.referMsg.message] stringByAppendingString:text];
            NSDictionary *referMsgUserInfo = [[STIMKit sharedInstance] getUserInfoByUserId:self.textBar.referMsg.from];
            NSString *referMsgNickName = [referMsgUserInfo objectForKey:@"Name"];
            text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n", (referMsgNickName.length > 0) ? referMsgNickName : self.textBar.referMsg.from,self.textBar.referMsg.message] stringByAppendingString:text];
            self.textBar.isRefer = NO;
            self.textBar.referMsg = nil;
        }
        
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:STIMMessageType_Text forMsgId:[STIMUUIDTools UUID] willSave:YES];
        }
#if __has_include("STIMNoteManager.h")
        else if(self.encryptChatState == STIMEncryptChatStateEncrypting) {
            NSString *content = [[STIMEncryptChat sharedInstance] encryptMessageWithMsgType:STIMMessageType_Text WithOriginBody:text WithOriginExtendInfo:nil WithUserId:self.chatId];
            msg = [[STIMKit sharedInstance] sendMessage:@"[加密文本消息iOS]" WithInfo:content ToUserId:self.chatId WithMsgType:STIMMessageType_Encrypt];
            [[STIMKit sharedInstance] saveMsg:msg ByJid:self.chatId];
        }
#endif
        else {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.chatId userType:self.chatType msgType:STIMMessageType_Text];
        }
        
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        if (self.chatId) {
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                msg = [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
            }
#if __has_include("STIMNoteManager.h")
            else if (self.encryptChatState == STIMEncryptChatStateEncrypting) {
                
                if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                    if (self.chatId) {
                        msg = [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                    }
                } else if (self.encryptChatState == STIMEncryptChatStateEncrypting) {
                    
                } else {
                    msg = [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                }
            }
#endif
            else {
                msg = [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            }
        }
    }
}


- (void)emptyText:(NSString *)text {
    
}

- (void)willSendImageData:(NSData *)imageData {
    _willSendImageData = imageData;
}

- (void)sendFileData:(NSData *)fileData fileName:(NSString *)fileName {
   STIMMessageModel *msg = [[STIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:self.chatId userType:ChatType_SingleChat msgType:STIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setSTIMSafeObject:fileName forKey:@"title"];
    [infoDic setSTIMSafeObject:@"" forKey:@"desc"];
    [infoDic setSTIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[STIMJSONSerializer sharedInstance] serializeObject:infoDic];
    msg.extendInformation = msgContent;
    
    [[STIMKit sharedInstance] uploadFileForData:fileData forMessage:msg withJid:self.chatId isFile:YES];
    
    
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
}

- (void)sendImageData:(NSData *)imageData {
    if (imageData) {
        [self getStringFromAttributedString:imageData];
    }
}

- (void)sendimageText:(NSString *)text {
    
    if ([text length] > 0) {
       STIMMessageModel *msg = nil;
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.virtualJid realJid:self.chatId userType:self.chatId msgType:STIMMessageType_Text forMsgId:[STIMUUIDTools UUID] willSave:YES];
        } else {
            msg = [[STIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.chatId userType:self.chatType msgType:STIMMessageType_Text];
        }
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[STIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
        } else {
            msg = [[STIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
        }
    }
}

- (void)setKeyBoardHeight:(CGFloat)height WithScrollToBottom:(BOOL)flag {
    
    CGFloat animaDuration = 0.2;
    
    CGRect frame = _tableViewFrame;
    frame.origin.y -= height;
    [UIView animateWithDuration:animaDuration animations:^{
        [_tableView setFrame:frame];
        if (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10 < _tableView.frame.size.height && height > 0) {
            if (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10 < _tableViewFrame.size.height - height) {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height + 10)];
                [_tableView setTableHeaderView:headerView];
            } else {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, _tableView.frame.size.height - (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10) + 10)];
                [_tableView setTableHeaderView:headerView];
            }
        } else {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
            [_tableView setTableHeaderView:headerView];
            //            if (flag) {
            //                [self scrollToBottomWithCheck:YES];
            //            }
        }
    }];
}

#pragma mark - Cell Delegate

- (void)openWebUrl:(NSString *)url {
    STIMWebView *webVC = [[STIMWebView alloc] init];
    [webVC setUrl:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)refreshTableViewCell:(UITableViewCell *)cell {
    if (cell && [cell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        if (indexPath) {
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)refreshCellForMsg:(STIMMessageModel *)msg {
    for (STIMMessageModel *message in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:[message messageId]]) {
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            [self.messageManager.dataSource replaceObjectAtIndex:index withObject:msg];
            [self addImageToImageList];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

- (void)processEvent:(int)event withMessage:(id)message {
   STIMMessageModel *eventMsg = (STIMMessageModel *)message;
    eventMsg.chatType = self.chatType;
    if (_tableView.editing) {
        [self cancelForwardHandle:nil];
    }
    if (event == MA_Repeater) {
        
        STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
        STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
        [controller setMessage:[STIMMessageParser reductionMessageForMessage:eventMsg]];
        [[self navigationController] presentViewController:nav animated:YES completion:^{
            
        }];
    } else if (event == MA_Delete) {
        for (STIMMessageModel *msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(STIMMessageModel *) eventMsg messageId]]) {
                NSMutableArray *deleteIndexs = [NSMutableArray array];
                NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
                [deleteIndexs addObject:[NSIndexPath indexPathForRow:index inSection:0]];
               STIMMessageModel *timeMsg = nil;
                if (index > 0) {
                   STIMMessageModel *tempMsg = [self.messageManager.dataSource objectAtIndex:index - 1];
                    if (tempMsg.messageType == STIMMessageType_Time) {
                        timeMsg = tempMsg;
                        if (index + 1 < self.messageManager.dataSource.count) {
                           STIMMessageModel *nMsg = [self.messageManager.dataSource objectAtIndex:index + 1];
                            if (nMsg.messageType != STIMMessageType_Time) {
                                timeMsg = nil;
                            }
                        }
                    }
                }
                if (timeMsg) {
                    [deleteIndexs addObject:[NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:timeMsg] inSection:0]];
                    [self.messageManager.dataSource removeObject:timeMsg];
                    [[STIMKit sharedInstance] deleteMsg:timeMsg ByJid:self.chatId];
                }
                
                [self.messageManager.dataSource removeObject:msg];
                [_tableView deleteRowsAtIndexPaths:deleteIndexs withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [[STIMKit sharedInstance] deleteMsg:msg ByJid:self.chatId];
                break;
            }
        }
        
    } else if (event == MA_ToWithdraw) {
        for (STIMMessageModel *msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(STIMMessageModel *) eventMsg messageId]]) {
                NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
                [(STIMMessageModel *) eventMsg setMessageType:STIMMessageType_Revoke];
                [self.messageManager.dataSource replaceObjectAtIndex:index withObject:eventMsg];
                [[STIMKit sharedInstance] updateMsg:eventMsg ByJid:self.chatId];
                NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
                BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
                if (isVisable) {
                    [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                [dicInfo setObject:[[STIMKit sharedInstance] getLastJid] forKey:@"fromId"];
                [dicInfo setObject:[(STIMMessageModel *) eventMsg messageId] forKey:@"messageId"];
                [dicInfo setObject:[(STIMMessageModel *) eventMsg message] forKey:@"message"];
//                [dicInfo setObject:[(STIMMessageModel *) eventMsg messageDirection] forKey:@"messageDirection"];
                NSString *msgInfo = [[STIMJSONSerializer sharedInstance] serializeObject:dicInfo];
                if (self.chatType == ChatType_Consult) {
//                    [[STIMKit sharedInstance] revokeConsultMessageWithMessageId:[(STIMMessageModel *) eventMsg messageId] message:msgInfo ToJid:self.chatId];
                    [[STIMKit sharedInstance] revokeConsultMessageWithMessageId:[(STIMMessageModel *) eventMsg messageId] message:msgInfo ToJid:self.chatId realToJid:msg.realJid chatType:self.chatType];
                }
                else{
                    [[STIMKit sharedInstance] revokeMessageWithMessageId:[(STIMMessageModel *) eventMsg messageId] message:msgInfo ToJid:self.chatId];
                }
                
                break;
            }
        }
    } else if (event == MA_Favorite) {
        
        for (STIMMessageModel *msg in self.messageManager.dataSource) {
            
            if ([msg.messageId isEqualToString:[(STIMMessageModel *) eventMsg messageId]]) {
                
                
                [[STIMMyFavoitesManager sharedMyFavoritesManager] setMyFavoritesArrayWithMsg:eventMsg];
                
                break;
            }
        }
    } else if (event == MA_Forward) {
        _tableView.editing = YES;
        [self.navigationController.navigationBar addSubview:[self getForwardNavView]];
        [self.navigationController.navigationBar addSubview:[self getMaskRightTitleView]];
        [self.view addSubview:self.forwardBtn];
        self.fd_interactivePopDisabled = YES;
    } else if (event == MA_Refer) {
        //引用消息
        self.textBar.isRefer = YES;
        self.textBar.referMsg = eventMsg;
    } else if (event == MA_CopyOriginMsg) {
        for (STIMMessageModel *msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(STIMMessageModel *) eventMsg messageId]]) {
                STIMVerboseLog(@"原始消息为 : %@", msg);
                NSString *originMsg = [[STIMOriginMessageParser shareParserOriginMessage] getOriginPBMessageWithMsgId:msg.messageId];
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

#pragma mark - STIMAttributedLabelDelegate

- (void)attributedLabel:(STIMAttributedLabel *)attributedLabel textStorageClicked:(id <STIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    //链接link
    if ([textStorage isMemberOfClass:[STIMLinkTextStorage class]]) {
        STIMLinkTextStorage *storage = (STIMLinkTextStorage *) textStorage;
        if (![storage.linkData length]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Wrong_Interface"] message:[NSBundle stimDB_localizedStringForKey:@"Wrong_URL"] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_ok"] otherButtonTitles:nil];
            [alertView show];
        } else {
            STIMWebView *webView = [[STIMWebView alloc] init];
            [webView setUrl:storage.linkData];
            [[self navigationController] pushViewController:webView animated:YES];
        }
    } else if ([textStorage isMemberOfClass:[STIMPhoneNumberTextStorage class]]) {
        STIMPhoneNumberTextStorage *storage = (STIMPhoneNumberTextStorage *) textStorage;
        if (storage.phoneNumData) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                
                [self presentViewController:[STIMContactManager showAlertViewControllerWithPhoneNum:storage.phoneNumData rootVc:self] animated:YES completion:nil];
            }
        }
    } else if ([textStorage isMemberOfClass:[STIMImageStorage class]]) {
        self.fixedImageArray = [NSMutableArray arrayWithCapacity:3];
        STIMImageStorage *storage = (STIMImageStorage *) textStorage;
        //图片
        if (storage.imageURL) {
            //纪录当前的浏览位置
            tableOffsetPoint = _tableView.contentOffset;
            
            //初始化图片浏览控件
            STIMMWPhotoBrowser *browser = [[STIMMWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = NO;
            browser.zoomPhotosToFill = YES;
            browser.enableSwipeToDismiss = NO;
            NSUInteger index = -1;
            for (NSUInteger i = 0; i < _imagesArr.count; i++) {
                
                if ([(STIMImageStorage *) _imagesArr[i] isEqual:storage]) {
                    index = i;
                    //                    browser.imageUrl = storage.imageURL;
                    break;
                }
            }
            if (index == -1 && storage.imageURL.absoluteString.length <= 0) {
                return;
            } else if (index == -1 && storage.imageURL.absoluteString.length > 0) {
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
            STIMPhotoBrowserNavController *nc = [[STIMPhotoBrowserNavController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
            return;
        } else {
            //表情
        }
    }
}

#pragma mark - STIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(STIMMWPhotoBrowser *)photoBrowser {
    if (self.fixedImageArray.count > 0) {
        return self.fixedImageArray.count;
    }
    return _imagesArr.count;
}

- (id <STIMMWPhoto>)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (self.fixedImageArray.count > 0) {
        NSString *imageUrl = [self.fixedImageArray[0] absoluteString];
        if (![imageUrl containsString:@"platform"]) {
            imageUrl = [imageUrl stringByAppendingString:@"&platform=touch"];
        }
        if (![imageUrl containsString:@"imgtype"]) {
            imageUrl = [imageUrl stringByAppendingString:@"&imgtype=origin"];
        }
        if (![imageUrl containsString:@"webp="]) {
            imageUrl = [imageUrl stringByAppendingString:@"&webp=true"];
        }
        NSURL *url = [NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return url ? [[STIMMWPhoto alloc] initWithURL:url] : nil;
    }
    NSArray *tempImageArr = _imagesArr;
    if (index > tempImageArr.count)
        return nil;
    
    NSString *imageHttpUrl;
    STIMImageStorage *storage = [tempImageArr objectAtIndex:index];
    imageHttpUrl = storage.imageURL.absoluteString;
    NSData *imageData = [[STIMKit sharedInstance] getFileDataFromUrl:imageHttpUrl forCacheType:STIMFileCacheTypeColoction needUpdate:NO];
    imageData = nil;
    if (imageData.length) {
        STIMMWPhoto *photo = [[STIMMWPhoto alloc] initWithImage:[UIImage stimDB_animatedImageWithAnimatedGIFData:imageData]];
        photo.photoData = imageData;
        return photo;
    } else {
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
        return url ? [[STIMMWPhoto alloc] initWithURL:url] : nil;
    }
}

- (void)photoBrowserDidFinishModalPresentation:(STIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
        [_tableView setContentOffset:tableOffsetPoint animated:YES];
        [self.fixedImageArray removeAllObjects];
    }];
}

#pragma mark - Action Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[STIMTapGestureRecognizer class]]) {
        NSInteger index = gestureRecognizer.view.tag;
        CGPoint location = [touch locationInView:[gestureRecognizer.view viewWithTag:
                                                  kTextLabelTag]];
        STIMSingleChatCell *cell = (STIMSingleChatCell *) [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if ([cell respondsToSelector:@selector(indexForCellImagesAtLocation:)]) {
            NSInteger imageIndex = [cell indexForCellImagesAtLocation:location];
            if (imageIndex < 0) {
                return NO;
            } else {
                return YES;
            }
        }
    }
    if (_inputPopViewIsShow) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    CGPoint point = [touch locationInView:self.view];
    //当点击table空白处时，输入框自动回收
    if (!CGRectContainsPoint(self.textBar.frame, point)) {
        [self.textBar needFirstResponder:NO];
    }
    
    [STIMMenuImageView cancelHighlighted];
    return NO;
}

#pragma mark - UIScrollView的代理函数

- (void)QTalkMessageUpdateForwardBtnState:(BOOL)enable {
    self.forwardBtn.enabled = enable;
    STIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)QTalkMessageScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat h1 = _tableView.contentOffset.y + _tableView.frame.size.height;
    CGFloat h2 = _tableView.contentSize.height - 250;
    CGFloat tempOffY = (_tableView.contentSize.height - _tableView.frame.size.height);
    if ((h1 > h2) && tempOffY > 0) {
        [self hidePopView];
    }
}

- (void)loadRemoteSearchMoreMessageData {
    __weak typeof(self) weakSelf = self;

    STIMMessageModel *msgModel = [self.messageManager.dataSource firstObject];
    [[STIMKit sharedInstance] getRemoteSearchMsgListByUserId:self.chatId WithRealJid:self.chatId withVersion:msgModel.messageDate withDirection:STIMGetMsgDirectionDown WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
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

- (void)loadMoreMessageData {
    if (self.netWorkSearch == YES) {
        [self loadRemoteSearchMoreMessageData];
        return;
    }
    
    self.loadCount += 1;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
            realJid = self.chatId;
        }
        if (self.chatType == ChatType_ConsultServer) {
            [[STIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count withLoadMore:YES WithComplete:^(NSArray *list) {
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
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                } else {
                    [weakSelf.tableView.mj_header endRefreshing];
                }
            }];
        } else if (self.chatType == ChatType_System) {
            
            [self loadNewSystemMsgList];
        } else {

            [[STIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WithLimit:kPageCount WithOffset:(int) self.messageManager.dataSource.count withLoadMore:YES WithComplete:^(NSArray *list) {
                if (list.count > 0) {
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
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                } else {
                    [weakSelf.tableView.mj_header endRefreshing];
                }
            }];
        }
    });
#if __has_include("QimRNBModule.h")
    if (self.loadCount >= 3 && !self.reloadSearchRemindView && !self.bindId && self.chatType != ChatType_System && self.netWorkSearch == NO) {
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
        }
        self.searchRemindView = [[STIMSearchRemindView alloc] initWithChatId:userId withRealJid:realJid withChatType:self.chatType];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToConverstaionSearch)];
        [self.searchRemindView addGestureRecognizer:tap];
        [self.view addSubview:self.searchRemindView];
    }
#endif
}

- (void)loadNewSystemMsgList {
    if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
        [[STIMKit sharedInstance] getSystemMsgLisByUserId:self.chatId WithFromHost:[[STIMKit sharedInstance] getDomain] WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count withLoadMore:YES WithComplete:^(NSArray *list) {
            CGFloat offsetY = self.tableView.contentSize.height -  self.tableView.contentOffset.y;
            NSRange range = NSMakeRange(0, [list count]);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.messageManager.dataSource insertObjects:list atIndexes:indexSet];
            [self.tableView reloadData];
            
            self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY - 30);
            //重新获取一次大图展示的数组
            [self addImageToImageList];
            [_tableView.mj_header endRefreshing];
        }];
    } else {
        [[STIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count withLoadMore:YES WithComplete:^(NSArray *list) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat offsetY = self.tableView.contentSize.height -  self.tableView.contentOffset.y;
                NSRange range = NSMakeRange(0, [list count]);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                [self.tableView reloadData];
                
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY - 30);
                //重新获取一次大图展示的数组
                [self addImageToImageList];
                [_tableView.mj_header endRefreshing];
            });
        }];
    }
}

- (UIView *)loadAllMsgView {
    if (!_loadAllMsgView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 54)];
        view.backgroundColor = [UIColor stimDB_colorWithHex:0xF8F8F9];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 21)];
        label.text = @"以上为所有消息";
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor redColor]];
        label.font = [UIFont systemFontOfSize:15];
        [view addSubview:label];
        label.center = view.center;
        
        UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(label.left - 50, 1, 40, 0.5f)];
        leftLineView.backgroundColor = [UIColor stimDB_colorWithHex:0xBFBFBF];
        [view addSubview:leftLineView];
        leftLineView.centerY = label.centerY;
        
        UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(label.right + 10, 1, 40, 0.5f)];
        rightLineView.backgroundColor = [UIColor stimDB_colorWithHex:0xBFBFBF];
        [view addSubview:rightLineView];
        rightLineView.centerY = label.centerY;
        
        _loadAllMsgView = view;
    }
    return _loadAllMsgView;
}

- (void)loadFooterRemoteSearchMsgList {
    __weak typeof(self) weakSelf = self;
    
    STIMMessageModel *msgModel = [self.messageManager.dataSource lastObject];
    [[STIMKit sharedInstance] getRemoteSearchMsgListByUserId:self.chatId WithRealJid:self.chatId withVersion:msgModel.messageDate+1 withDirection:STIMGetMsgDirectionUp WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
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
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
    }
    self.reloadSearchRemindView = YES;
    [self.searchRemindView removeFromSuperview];
    [[STIMFastEntrance sharedInstance] openLocalSearchWithXmppId:userId withRealJid:realJid withChatType:self.chatType];
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
    STIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)refreshTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:_tableView
                                                 selector:@selector(reloadData)
                                                   object:nil];
        
        [_tableView performSelector:@selector(reloadData)
                         withObject:nil
                         afterDelay:DEFAULT_DELAY_TIMES];
    });
}

- (NSString *)getStringFromAttributedString:(NSData *)imageData {
    
    UIImage *image = [STIMImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    STIMMessageModel *msg = nil;
    if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
        msg = [[STIMKit sharedInstance] createMessageWithMsg:@"" extenddInfo:nil userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:STIMMessageType_Text forMsgId:nil willSave:YES];
    } else {
        STIMVerboseLog(@"普通图片消息");
        msg = [[STIMKit sharedInstance] createMessageWithMsg:@"" extenddInfo:nil userId:self.chatId userType:ChatType_SingleChat msgType:STIMMessageType_Text];
    }
    NSString *fileName = [[STIMKit sharedInstance] uploadFileForData:imageData forMessage:msg withJid:self.chatId isFile:NO];
    NSString *fileUrl = @"";
    if ([fileName stimDB_hasPrefixHttpHeader]) {
        fileUrl = fileName;
    } else {
        fileUrl = [NSString stringWithFormat:@"%@/LocalFileName=%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], fileName];
    }
    NSString *sdimageFileKey = [[STIMImageManager sharedInstance] defaultCachePathForKey:fileUrl];
    [imageData writeToFile:sdimageFileKey atomically:YES];
    NSString *msgText = nil;
    if ([fileName stimDB_hasPrefixHttpHeader]) {
        msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", fileName, width, height];
    } else {
        msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"LocalFileName=%@\" width=%f height=%f]", fileName, width, height];
    }
    
    msg.message = msgText;
    if (!(self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult)) {
        [[STIMKit sharedInstance] updateMsg:msg ByJid:self.chatId];
    }
    
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self addImageToImageList];
    [self scrollToBottomWithCheck:YES];
    return nil;
}

- (NSString *)getStringFromAttributedSourceString:(NSString *)sourceStr {
    return [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:sourceStr];
}

#pragma mark - show pop view

- (void)showPopView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [self.notificationView setHidden:NO];
    [UIView commitAnimations];
}


- (void)hidePopView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.notificationView setHidden:YES];
    [UIView commitAnimations];
}

//获取大图展示数组

- (void)addImageToImageList {
    if (!_imagesArr) {
        _imagesArr = [NSMutableArray arrayWithCapacity:1];
    } else {
        [_imagesArr removeAllObjects];
    }
    NSArray *tempDataSource = [NSArray arrayWithArray:self.messageManager.dataSource];
    for (STIMMessageModel *msg in tempDataSource) {
        if (msg.messageType == STIMMessageType_Image || msg.messageType == STIMMessageType_Text || msg.messageType == STIMMessageType_NewAt) {
            STIMTextContainer *textContainer = [STIMMessageParser textContainerForMessage:msg];
            for (id storage in textContainer.textStorages) {
                if ([storage isMemberOfClass:[STIMImageStorage class]] && ([(STIMImageStorage *) storage storageType] == STIMImageStorageTypeImage || [(STIMImageStorage *) storage storageType] == STIMImageStorageTypeGif)) {
                    [_imagesArr addObject:storage];
                }
            }
        }
    }
}

#pragma mark -IMTextBarDelegate voice record operator about -add by dan.zheng 15/4/24

- (void)beginDoVoiceRecord {
    self.voiceRecordingView.hidden = NO;
    [self.voiceRecordingView beginDoRecord];
}

- (void)updateVoiceViewHeightInVCWithPower:(float)power {
    [self.voiceRecordingView doImageUpdateWithVoicePower:power];
}

- (void)voiceRecordWillFinishedIsTrue:(BOOL)isTrue andCancelByUser:(BOOL)isCancelByUser {
    [self.voiceRecordingView setHidden:YES];
    if (!isTrue && !isCancelByUser) {
        //录音时间太短，出错提示
        [self.voiceTimeRemindView setHidden:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hiddenSTIMVoiceTimeRemindView) userInfo:nil repeats:NO];
        
    }
    [self.voiceRecordingView voiceMaybeCancelWithState:0];
}

- (void)hiddenSTIMVoiceTimeRemindView {
    [self.voiceTimeRemindView setHidden:YES];
}

- (void)voiceMaybeCancelWithState:(BOOL)ifMaybeCancel {
    [self.voiceRecordingView voiceMaybeCancelWithState:ifMaybeCancel];
}


//将解压前的数据添加到本地数据源中，再将已提交到网络上的压缩后的数据的信息提交到服务器
- (void)sendVoiceUrl:(NSString *)voiceUrl WithDuration:(int)duration WithSmallData:(NSData *)amrData WithFileName:(NSString *)filename AndFilePath:(NSString *)filepath {
    //    if ([voiceUrl length] > 0) {
    voiceUrl = voiceUrl ? voiceUrl : @"";
    STIMMessageModel *msg = nil;
    NSString *origintMsg = [NSString stringWithFormat:@"{\"%@\":\"%@\", \"%@\":\"%@\", \"%@\":%@,\"%@\":\"%@\"}", @"HttpUrl", voiceUrl, @"FileName", filename, @"Seconds", [NSNumber numberWithInt:duration], @"filepath", filepath];
        
#if __has_include("STIMNoteManager.h")
        if(self.encryptChatState == STIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[STIMEncryptChat sharedInstance] encryptMessageWithMsgType:STIMMessageType_Voice WithOriginBody:origintMsg WithOriginExtendInfo:nil WithUserId:self.chatId];
            [self sendMessage:@"iOS加密语音消息" WithInfo:encrypeMsg ForMsgType:STIMMessageType_Encrypt];
        } else {
#endif
            [self sendMessage:origintMsg WithInfo:nil ForMsgType:STIMMessageType_Voice];
#if __has_include("STIMNoteManager.h")
        }
#endif
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
            if (!self.messageManager.forwardSelectedMsgs) {
                self.messageManager.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
            }
            NSArray *msgList = [self.messageManager.forwardSelectedMsgs.allObjects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [(STIMMessageModel *)obj1 messageDate] > [(STIMMessageModel *)obj2 messageDate];
            }];
            NSDictionary *userInfoDic = [[STIMKit sharedInstance] getUserInfoByUserId:[[STIMKit sharedInstance] getLastJid]];
            NSString *userName = [userInfoDic objectForKey:@"Name"];
            
            _jsonFilePath = [STIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [STIMKit getLastUserName], self.title]];
            _tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [self.forwardBtn removeFromSuperview];
            
            STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
            STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
            if ([[STIMKit sharedInstance] getIsIpad]) {
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            controller.delegate = self;
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [weakSelf cancelForwardHandle:nil];
            }];
            
        } else if (buttonIndex == 1) {
            NSArray *forwardIndexpaths = [_tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[STIMMessageParser reductionMessageForMessage:[self.messageManager.dataSource objectAtIndex:indexPath.row]]];
            }
            STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
            STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
            if ([[STIMKit sharedInstance] getIsIpad]) {
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            [controller setMessageList:msgList];
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [weakSelf cancelForwardHandle:nil];
            }];
        } else {
            
        }
    } else {
        if (buttonIndex == 1) {
            STIMChatBGImageSelectController *chatBGImageSelectVC = [[STIMChatBGImageSelectController alloc] initWithCurrentBGImage:self.chatBGImageView.image];
            chatBGImageSelectVC.userID = self.chatId;
            chatBGImageSelectVC.delegate = self;
            chatBGImageSelectVC.isFromChat = YES;
            [self.navigationController pushViewController:chatBGImageSelectVC animated:YES];
        }
    }
}

#pragma mark - STIMChatBGImageSelectControllerDelegate

- (void)ChatBGImageDidSelected:(STIMChatBGImageSelectController *)chatBGImageSelectVC {
    [self refreshChatBGImageView];
}

#pragma mark - STIMIMTextBarDelegate

- (void)textBarReferBtnDidClicked:(STIMTextBar *)textBar {
    
    if (_referMsgwindow == nil) {
        _referMsgwindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _referMsgwindow.backgroundColor = [UIColor clearColor];
        _referMsgwindow.windowLevel = UIWindowLevelAlert - 1;
        _referMsgwindow.rootViewController = [[UIViewController alloc] init];
    }
    _referMsgwindow.hidden = NO;
    
    UIScrollView * referMsgScrlView = [[UIScrollView alloc] initWithFrame:_referMsgwindow.rootViewController.view.bounds];
    referMsgScrlView.backgroundColor = [UIColor stimDB_colorWithHex:0x000000 alpha:0.5];
    [_referMsgwindow.rootViewController.view addSubview:referMsgScrlView];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5;
    bgView.clipsToBounds = YES;
    [referMsgScrlView addSubview:bgView];
    
    STIMAttributedLabel * msgLabel = [[STIMAttributedLabel alloc] init];
    msgLabel.textContainer = [STIMMessageParser textContainerForMessage:textBar.referMsg fromCache:NO];
    msgLabel.textColor = [UIColor blackColor];
    [bgView addSubview:msgLabel];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(referViewTapHandlel:)];
    [referMsgScrlView addGestureRecognizer:tap];
    
    
    float originX = (referMsgScrlView.width - msgLabel.textContainer.textWidth - 40) / 2.0f;
    float originY = (referMsgScrlView.height - msgLabel.textContainer.textHeight - 40) / 2.0f;
    
    [msgLabel setFrameWithOrign:CGPointMake(20,20) Width:msgLabel.textContainer.textWidth];
    bgView.frame = CGRectMake(originX, originY, msgLabel.width + 40, msgLabel.height +  40);
    
    //    referMsgScrlView.contentSize = CGSizeMake(bgView,msgLabel.textContainer.textHeight);
}

- (void)referViewTapHandlel:(UITapGestureRecognizer *)tap {
    _referMsgwindow.hidden = YES;
    _referMsgwindow = nil;
}

#pragma mark - STIMPushProductViewControllerDelegate

- (void)sendProductInfoStr:(NSString *)infoStr productDetailUrl:(NSString *)detlUrl {
    [self sendMessage:detlUrl WithInfo:infoStr ForMsgType:STIMMessageType_product];
}

#pragma mark - STIMRobotQuestionCellDelegate

- (void)sendRobotQuestionText:(NSNotification *)notify {
    NSDictionary *notifyDic = notify.object;
    NSString *msgText = [notifyDic objectForKey:@"msgText"];
    BOOL isSendToServer = [[notifyDic objectForKey:@"isSendToServer"] boolValue];
    NSString *userType = [notifyDic objectForKey:@"userType"];
    if (msgText.length > 0) {
        [self sendTextMessageForText:msgText isSendToServer:isSendToServer userType:userType];
    }
}

#pragma mark - STIMRobotAnswerCellLoadDelegate

- (void)refreshRobotQuestionMessageCell:(STIMMsgBaloonBaseCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)refreshSTIMChatRobotListQuestionMessageCell:(STIMMsgBaloonBaseCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}


- (void)refreshRobotAnswerMessageCell:(STIMMsgBaloonBaseCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void)reTeachRobot {
    NSString *attributedText = [self.textBar getSendAttributedText];
    if (attributedText.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"请清空输入框之后再试" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        });
    } else {
        [self.textBar setText:@"教小拿 "];
    }
}

- (void)sendTextMessageForText:(NSString *)messageContent isSendToServer:(BOOL)isSendToServer userType:(NSString *)userType {
    [self sendText:messageContent];
}

-(void)sendSTIMChatRobotQusetionListTextMessageForText:(NSString *)messageContent isSendToServer:(BOOL)isSendToServer userType:(NSString *)userType{
    [self sendText:messageContent];
}

-(void)hintCell:(STIMHintTableViewCell *)cell linkClickedWithInfo:(NSDictionary *)infoFic {
    if (!(infoFic && infoFic.count > 0)) {
        return;
    }
    NSDictionary *linkData = infoFic[@"linkData"];
    NSDictionary *eventData = linkData[@"event"];
    NSString *eventType = [eventData objectForKey:@"type"];
    if ([eventType isEqualToString:@"extext"]) {
        NSString *msgText = [eventData  objectForKey:@"msgText"];
        NSString *extendJson = [eventData  objectForKey:@"extend"];
//        [self sendTextMessageForText:msgText isSendToServer:YES userType:@"usr" extendJson:extendJson WithMsgType:MessageType_ExText];
        [self sendTextMessageForText:msgText isSendToServer:YES userType:extendJson];
    } else {
        NSString * type = eventData[@"type"];
        if ([type isEqualToString:@"postInterface"]) {
            NSDictionary * params = eventData[@"params"];
            
            NSData *versionData = [[STIMJSONSerializer sharedInstance] serializeObject:params error:nil];
//            __block NSString * appendUrl = @"";
//
//
////            for (NSString * str in params.allKeys) {
////
////                appendUrl = [[appendUrl stringByAppendingString:@"%@=%@",str,params[@"str"]] ]
////            }
////            for (int i = 0; i<params.allKeys.count; i++) {
////                NSString * key = params.allKeys[i];
////                if (key.length > 0 && key) {
////                    NSString * value = [params objectForKey:key];
////                    if (!(value && value.length>0)) {
////                        value = @"";
////                    }
////                    if (i!=0) {
////                    appendUrl = [appendUrl stringByAppendingString:[NSString stringWithFormat:@"&",key,value]];
////                    }
////                    appendUrl =  [appendUrl stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
////                }
////
////            }
//            NSString * urlstr = [NSString stringWithFormat:@"%@?%@",eventData[@"url"],appendUrl];
//            [[STIMKit sharedInstance] sendTPGetRequestWithUrl:urlstr withSuccessCallBack:^(NSData *responseData) {
//                NSDictionary * responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
//                NSLog(@"转人工 %@",responseDic);
//            } withFailedCallBack:^(NSError *error) {
//
//            }];
            [[STIMKit sharedInstance] sendTPPOSTRequestWithUrl:eventData[@"url"] withRequestBodyData:versionData withSuccessCallBack:^(NSData *responseData) {
                NSDictionary * responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                NSLog(@"转人工 %@",responseDic);
            } withFailedCallBack:^(NSError *error) {
                
            }];
            
        }else{
            NSString * url = infoFic[@"linkData"][@"url"];
//            [STIMWebView showWebViewByUrl:url];
        }
    }
}

@end
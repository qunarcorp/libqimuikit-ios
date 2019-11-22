//
//  STIMTextBarExpandView.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/9.
//
//

#define kItemWidth      54
#define kItemTagFrom    1000
#import "STIMMsgBaseVC.h"
#import "STIMTextBarExpandView.h"
#import "UserLocationViewController.h"
#import "STIMChatVC.h"  
#import "NSBundle+STIMLibrary.h"
#import "UIApplication+STIMApplication.h"
#if __has_include("STIMAutoTracker.h")
#import "STIMAutoTracker.h"
#endif


static NSMutableDictionary *__trdExtendInfoDic = nil;

@interface STIMTextBarExpandView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *view;

@end

@implementation STIMTextBarExpandView
{
    UIScrollView            * _mainScrollView;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)addItems
{
    if ([[STIMKit sharedInstance] getMsgTextBarButtonInfoList].count) {
        [[STIMKit sharedInstance] removeAllExpandItems];
    }
    if (__trdExtendInfoDic == nil) {
        __trdExtendInfoDic = [[NSMutableDictionary alloc] init];
    }
    for (NSDictionary *trdEntendInfo in [[STIMKit sharedInstance] trdExtendInfo]) {
        NSString *trdEntendId = [trdEntendInfo objectForKey:@"trdextendId"];
        
        int client = [[trdEntendInfo objectForKey:@"client"] intValue];
        int support = [[trdEntendInfo objectForKey:@"support"] intValue];
        int scope = [[trdEntendInfo objectForKey:@"scope"] intValue];
        BOOL hasQchat = client & 1,hasQtalk = client & 2, hasSingle = support & 1,hasGroup = support & 2, hasVirtual = support & 4, hasConsult = support & 8, hasConsultServer = support & 16, hasPublicNumber = support & 32, hasNoMerchant = scope & 1,hasMerchant = scope & 2;
        int type = [[trdEntendInfo objectForKey:@"type"] intValue];
        NSString *title = [trdEntendInfo objectForKey:@"title"];
        [__trdExtendInfoDic setObject:trdEntendInfo forKey:trdEntendId];
        if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
            BOOL needShowForMerchant = ((hasNoMerchant &&![[STIMKit sharedInstance] isMerchant])||(hasMerchant &&[[STIMKit sharedInstance] isMerchant]));
            if (hasSingle && STIMTextBarExpandViewTypeSingle & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            if (hasGroup && STIMTextBarExpandViewTypeGroup & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            if (hasConsult && STIMTextBarExpandViewTypeConsult & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            
            if (needShowForMerchant && hasConsultServer && STIMTextBarExpandViewTypeConsultServer & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            if (hasVirtual && STIMTextBarExpandViewTypeRobot & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
        }
        if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
            if (hasSingle && STIMTextBarExpandViewTypeSingle & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            if (hasGroup && STIMTextBarExpandViewTypeGroup & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            if (hasConsult && STIMTextBarExpandViewTypeConsult & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            if (hasConsultServer && STIMTextBarExpandViewTypeConsultServer & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            if (hasVirtual && STIMTextBarExpandViewTypeRobot & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
            
            if (hasPublicNumber && STIMTextBarExpandViewTypePublicNumber & self.type) {
                [[STIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
            }
        }
    }
    if ([[STIMKit sharedInstance] trdExtendInfo].count <= 0) {
        [self defaultItems];
    }
}

- (void)defaultItems {
    
     [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_pic" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_album"] ForItemId:STIMTextBarExpandViewItem_Photo];
     
     [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_camera" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_camera"] ForItemId:STIMTextBarExpandViewItem_Camera];
    
     if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat & self.type == (STIMTextBarExpandViewTypeConsultServer)) {
     //快捷回复按钮只有在ConsultServer中展示
         [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_quickReply" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_quick_reply"] ForItemId:STIMTextBarExpandViewItem_QuickReply];
     }
#if __has_include("STIMWebRTCMeetingClient.h")
        if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {

         if (self.type & STIMTextBarExpandViewTypeSingle) {
             [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_videoCall" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_videoCall"] ForItemId:STIMTextBarExpandViewItem_VideoCall];
             [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_encryptchat" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_encryptchat"] ForItemId:STIMTextBarExpandViewItem_Encryptchat];
         }
         if (self.type & STIMTextBarExpandViewTypeGroup) {
             [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_videoCall" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_videoCall"] ForItemId:STIMTextBarExpandViewItem_VideoCall];
         }
    }
     #endif
    [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_location" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_position"] ForItemId:STIMTextBarExpandViewItem_Location];
    
     if (([STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) && (self.type & (STIMTextBarExpandViewTypeNomal | STIMTextBarExpandViewTypeSingle | STIMTextBarExpandViewTypeGroup))) {
     //        [[STIMKit sharedInstance] addMsgTextBarWithImage:@"iconfont-fire" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_burn_after_reading"] ForItemType:STIMTextBarExpandViewItemType_BurnAfterReading pushVC:nil];
     }
     if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
         if (self.type & (STIMTextBarExpandViewTypeConsultServer)) {
         //转移会话按钮只有在ConsultServer中展示
             [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_transfer" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_move_chat"] ForItemId:STIMTextBarExpandViewItem_ChatTransfer];
         }
         [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_sendProduct" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_send_product"] ForItemId:STIMTextBarExpandViewItem_SendProduct];
     }
    [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_red_pack" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_red_package"] ForItemId:STIMTextBarExpandViewItem_RedPack];
    
     if ([STIMKit getSTIMProjectType] != STIMProjectTypeQChat) {
         [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aa_collection_icon" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_aa"] ForItemId:STIMTextBarExpandViewItem_AACollection];
         [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_share_nameplate" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_share_card"] ForItemId:STIMTextBarExpandViewItem_ShareCard];
     }
    [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_folder" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_file"] ForItemId:STIMTextBarExpandViewItem_MyFiles];

     //ios 的发活动去掉吧，后台都快没了 by wz.wang 2017-12-06 15:42
     if (self.type & STIMTextBarExpandViewTypeGroup) {
         [[STIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_group_activity" WithTitle:[NSBundle stimDB_localizedStringForKey:@"textbar_button_activity"] ForItemId:STIMTextBarExpandViewItem_SendActivity];
     }
}

- (void)displayItems
{
    NSInteger i = 0;
    NSInteger page = 0;
    float  space = (self.width - kItemWidth * 4) / 5;
    
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_mainScrollView];
    }else{
        for (UIView * view in _mainScrollView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    NSArray * items = [[STIMKit sharedInstance] getMsgTextBarButtonInfoList];
    
    for (NSDictionary * itemDic in items) {
        NSString *trId = [itemDic objectForKey:@"trdextendId"];
        UIImageView *locationButton = [[UIImageView alloc] initWithFrame:CGRectMake(page * _mainScrollView.width + (space + kItemWidth) * (i % 4) + space, (i / 4) * (kItemWidth + 10 + 25) + 10, kItemWidth, kItemWidth)];
        NSString *icon = [itemDic objectForKey:@"icon"];
        [locationButton setAccessibilityIdentifier:trId];
        UIImage *defaultIcon = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"textbar_common_icon"];
        if (icon.length > 0) {
            [locationButton stimDB_setImageWithURL:[NSURL URLWithString:[icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:defaultIcon];
        } else {
            NSString *imageName = [itemDic objectForKey:@"ImageName"];
            [locationButton setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:imageName]];
        }
        [locationButton setUserInteractionEnabled:YES];
        [_mainScrollView addSubview:locationButton];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(page * _mainScrollView.width + (space + kItemWidth) * (i % 4) + space - 10, locationButton.bottom + 5, kItemWidth + 20, 20)];
        titleLabel.text = [itemDic objectForKey:@"title"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor stimDB_colorWithHex:0x666666];
        [titleLabel setUserInteractionEnabled:YES];
        [titleLabel setAccessibilityIdentifier:trId];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemBtnHandle:)];
        [locationButton setAccessibilityIdentifier:trId];
        [locationButton addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemBtnHandle:)];
        [titleLabel setAccessibilityIdentifier:trId];
        [titleLabel addGestureRecognizer:tap2];
        [_mainScrollView addSubview:titleLabel];
        page = page + (i + 1) / (2 * 4);
        i = (i + 1) % (2 * 4);
    }
    _mainScrollView.contentSize = CGSizeMake((ceilf((float)(items.count) / 8.0) * _mainScrollView.width), _mainScrollView.height);
}


- (void)itemBtnHandle:(UITapGestureRecognizer *)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIView *view = (UIView*) tap.view;
    NSString *sendId = [view accessibilityIdentifier];
    NSDictionary *trdDic = [[STIMKit sharedInstance] getExpandItemsForTrdextendId:sendId];
    NSString *trdId = [trdDic objectForKey:@"trdextendId"];
    NSString *trdName = [trdDic objectForKey:@"title"];

    NSArray *textBarOpenIds = @[STIMTextBarExpandViewItem_Photo, STIMTextBarExpandViewItem_Camera, STIMTextBarExpandViewItem_QuickReply];
#if __has_include("STIMAutoTracker.h")
    [[STIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:trdId withDescription:trdName?trdName:trdId];
#endif
    if ([textBarOpenIds containsObject:trdId] && self.delegate && [self.delegate respondsToSelector:@selector(didClickExpandItemForTrdextendId:)]) {
        //这里由TextBar打开
        [self.delegate didClickExpandItemForTrdextendId:trdId];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kExpandViewItemHandleNotification object:trdId];
        });
    }
}

#pragma mark - STIMMsgBaseVCDelegate

-(void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType
{
    
    //Comment by lilulucas.li 10.18
//    [(STIMChatVC *)self.parentVC sendMessage:message WithInfo:info ForMsgType:msgType];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger pageIndex = offsetX / self.width;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScrollToIndex:)]) {
        
        [self.delegate scrollViewDidScrollToIndex:pageIndex];
    }
}

@end

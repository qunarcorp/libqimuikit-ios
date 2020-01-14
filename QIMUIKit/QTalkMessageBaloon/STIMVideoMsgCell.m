//
//  STIMVideoMsgCell.m
//  STChatIphone
//
//  Created by xueping on 15/7/13.
//
//

#import "STIMMsgBaloonBaseCell.h"
#import "STIMVideoMsgCell.h"
#import "STIMMenuImageView.h"
#import "STIMJSONSerializer.h"
#import "STIMVideoModel.h"
#import "YYModel.h"
#import <MediaPlayer/MediaPlayer.h>

static NSMutableDictionary *__uploading_progress_dic = nil;
@interface STIMVideoMsgCell()<STIMMenuImageViewDelegate>
@end

@implementation STIMVideoMsgCell{
    UIImageView     * _imageView;
    UIView          * _infoView;
    UILabel         * _sizeLabel;
    UILabel         * _durationLabel;
    UIProgressView  * _progressView;
    UIImageView     * _playIconView;
    
}

+ (CGFloat)getCellHeightWithMessage:(STIMMessageModel *)message chatType:(ChatType)chatType {
    if (message.extendInformation.length > 0) {
        message.message = message.extendInformation;
    }
    NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
    CGSize size = CGSizeMake([[infoDic objectForKey:@"Width"] floatValue], [[infoDic objectForKey:@"Height"] floatValue]);
    
    if (size.width > 0) {
        size.height =  150 * size.height / size.width;
        size.width = 150;
    } else {
        size.height = 150;
        size.width = 150;
    }
    return size.height + 25;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        [self.backView setMenuViewHidden:YES];
//        [self.backView setAlpha:0.1];
        _imageView = [[UIImageView alloc] init];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView.layer setCornerRadius:3];
        [_imageView.layer setMasksToBounds:YES];
        _imageView.userInteractionEnabled = YES;
        [self.backView addSubview:_imageView];
        
        _playIconView = [[UIImageView alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"aio_short_video_icon_playable"]];
        [_imageView addSubview:_playIconView];
        
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        [_infoView setBackgroundColor:[UIColor stimDB_colorWithHex:0x0 alpha:0.5]];
        [_imageView addSubview:_infoView];
        
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 20)];
        [_sizeLabel setTextAlignment:NSTextAlignmentLeft];
        _sizeLabel.numberOfLines = 0;
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        [_sizeLabel setTextColor:[UIColor whiteColor]];
        [_infoView addSubview:_sizeLabel];
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 20)];
        [_durationLabel setTextAlignment:NSTextAlignmentRight];
        _durationLabel.numberOfLines = 0;
        _durationLabel.font = [UIFont systemFontOfSize:12];
        _durationLabel.backgroundColor = [UIColor clearColor];
        [_durationLabel setTextColor:[UIColor whiteColor]];
        [_infoView addSubview:_durationLabel];
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, _infoView.height - 2, _infoView.width, 2)];
        _progressView.backgroundColor = [UIColor yellowColor];
        [_infoView addSubview:_progressView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [_imageView addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:kNotifyFileManagerUpdate object:nil];
        
    }
    return self;
}

- (void)updateProgress:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *infoDic = [notify object];
        STIMMessageModel *message = [infoDic objectForKey:@"message"];
        float progress = [[infoDic objectForKey:@"propress"] floatValue];
        NSString * status = [infoDic objectForKey:@"status"];
        if (__uploading_progress_dic == nil) {
            __uploading_progress_dic = [NSMutableDictionary dictionary];
        }
        if (progress > 1) {
            [__uploading_progress_dic removeObjectForKey:message.messageId];
        } else {
            [__uploading_progress_dic setObject:@(progress) forKey:message.messageId];
        }
        if ([message.messageId isEqualToString:self.message.messageId]) {
            if (progress > 1) {
                [_progressView setHidden:YES];
            } else {
                [_progressView setHidden:NO];
                [_progressView setProgress:progress];
            }
            if ([status isEqualToString:@"failed"]) {
                self.message.messageSendState = STIMMessageSendState_Faild;
                [self refreshUI];
            }
        }
    });
}


- (void)tapHandle:(UITapGestureRecognizer *)tap {
    if (self.owerViewController) {
        if (self.message.extendInformation.length > 0) {
            self.message.message = self.message.extendInformation;
        }
        NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
        STIMVideoModel *videoModel = [STIMVideoModel yy_modelWithDictionary:infoDic];
        [STIMFastEntrance openVideoPlayerForVideoModel:videoModel];
        /*
        BOOL newVideo = [[infoDic objectForKey:@"newVideo"] boolValue];
        if (newVideo == YES) {
            
            //新版视频
            STIMVideoModel *videoModel = [STIMVideoModel yy_modelWithDictionary:infoDic];
            [STIMFastEntrance openVideoPlayerForVideoModel:videoModel];
        } else {
            
            //老版本视频
            STIMVideoPlayerVC *videoPlayVC = [[STIMVideoPlayerVC alloc] init];
            [videoPlayVC setVideoMessageModel:self.message];
            [self.owerViewController.navigationController pushViewController:videoPlayVC animated:YES];
        }
        */
    }
}

#pragma mark - ui

- (void)refreshUI {
    
    [super refreshUI];
    self.selectedBackgroundView.frame = self.contentView.frame;
    self.backView.message = self.message;
    NSNumber *progressNum = [__uploading_progress_dic objectForKey:self.message.messageId];
    if (progressNum) {
        [_progressView setHidden:NO];
        [_progressView setProgress:progressNum.floatValue];
    } else {
        [_progressView setHidden:YES];
    }
    if (self.message.extendInformation.length > 0) {
        self.message.message = self.message.extendInformation;
    }
    NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    
    CGSize size = CGSizeMake(150, [STIMVideoMsgCell getCellHeightWithMessage:self.message chatType:1] - 40);
    
    [_sizeLabel setText:[NSString stringWithFormat:@"%ld", [infoDic objectForKey:@"FileSize"]]];
    [_durationLabel setText:[NSString stringWithFormat:@"%@s",[infoDic objectForKey:@"Duration"]]];
    if (self.message.messageDirection == STIMMessageDirection_Received) {
        [_imageView setFrame:CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 5, size.width, size.height)];
    } else {
        [_imageView setFrame:CGRectMake(self.HeadView.left - 5 - size.width, self.nameLabel.bottom + 5, size.width, size.height)];
    }
    NSString *fileName = [infoDic objectForKey:@"FileName"];
    NSString *thubmName = [infoDic objectForKey:@"ThumbName"] ? [infoDic objectForKey:@"ThumbName"] : [NSString stringWithFormat:@"%@_thumb.jpg", [[fileName componentsSeparatedByString:@"."] firstObject]];
    NSString *thumbUrl = [infoDic objectForKey:@"ThumbUrl"];
    if (![thumbUrl stimDB_hasPrefixHttpHeader]) {
        thumbUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingPathComponent:thumbUrl];
    }
    [_imageView stimDB_setImageWithURL:[NSURL URLWithString:thumbUrl] placeholderImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"PhotoDownloadPlaceHolder"]];
    [_infoView setFrame:CGRectMake(0, _imageView.bottom - _infoView.height, _infoView.width, _infoView.height)];
    [_imageView setFrame:CGRectMake((self.message.messageDirection==STIMMessageDirection_Received?kBackViewCap+10:5) - 1, 5, size.width, size.height)];
    float backWidth = size.width + 6 + kBackViewCap + 8;
    float backHeight = size.height;
    [self setBackViewWithWidth:backWidth WithHeight:backHeight];

    [self.backView setBubbleBgColor:[UIColor clearColor]];
    [self.backView setMenuViewHidden:YES];
    _playIconView.center = CGPointMake(_imageView.width / 2.0, _imageView.height / 2.0);
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case STIMMessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case STIMMessageDirection_Sent: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        default:
            break;
    }
    if ([[[STIMKit sharedInstance] qimNav_getDebugers] containsObject:[STIMKit getLastUserName]]) {
        [menuList addObject:@(MA_CopyOriginMsg)];
    }
    if ([[STIMKit sharedInstance] getIsIpad]) {
//        [menuList removeObject:@(MA_Refer)];
//        [menuList removeObject:@(MA_Repeater)];
//        [menuList removeObject:@(MA_Delete)];
        [menuList removeObject:@(MA_Forward)];
//        [menuList removeObject:@(MA_Repeater)];
    }
    return menuList;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  STIMMWPhotoSectionBrowserCollectionView.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2018/12/12.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMMWPhotoSectionBrowserVC.h"
#import "STIMMWPhotoSectionBrowserCell.h"
#import "STIMMWPhotoSectionBrowserLayout.h"
#import "STIMMWPhotoBrowser.h"
#import "STIMPhotoBrowserNavController.h"
#import "STIMMWPhotoSectionReusableView.h"
#import "STIMContactSelectionViewController.h"
#import "STIMMessageParser.h"
#import "MBProgressHUD.h"

@interface STIMMWPhotoSectionBrowserVC () <UICollectionViewDelegate, UICollectionViewDataSource, STIMMWPhotoBrowserDelegate, STIMMWPhotoSectionBrowserChooseDelegate>

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) NSMutableArray *sectionPhotos;

@property (nonatomic, strong) NSMutableArray *dimensionalPhotos;    //二维数组拆一维
@property (nonatomic, strong) NSMutableArray *dimensionalPhotoIndexPaths;    //二维数组拆一维

@property (nonatomic, strong) NSMutableDictionary *photoIdentifierDic;

@property (nonatomic, strong) UIButton *chooseBtn;

@property (nonatomic, strong) UICollectionView *photoCollectionView;

@property (nonatomic, assign) CGPoint collectionViewOffsetPoint;            //纪录当前的浏览位置

@property (nonatomic, assign) NSIndexPath *currentPhotoIndexPath;  //当前图片Index

@property (nonatomic, strong) NSMutableArray *fixedImageArray;

@property (nonatomic, strong) UIView *controlPanelView;

@property (nonatomic, assign) BOOL chooseMediaFlag;

@property (nonatomic, strong) NSMutableArray *selectMediaArray;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation STIMMWPhotoSectionBrowserVC

#pragma mark - setter and getter

- (NSMutableArray *)photos {
    if (!_photos) {
        _photos = [NSMutableArray arrayWithCapacity:3];
    }
    return _photos;
}

- (NSMutableArray *)sectionPhotos {
    if (!_sectionPhotos) {
        _sectionPhotos = [NSMutableArray arrayWithCapacity:3];
    }
    return _sectionPhotos;
}

- (NSMutableArray *)dimensionalPhotos {
    if (!_dimensionalPhotos) {
        _dimensionalPhotos = [NSMutableArray arrayWithCapacity:3];
    }
    return _dimensionalPhotos;
}

- (NSMutableArray *)dimensionalPhotoIndexPaths {
    if (!_dimensionalPhotoIndexPaths) {
        _dimensionalPhotoIndexPaths = [NSMutableArray arrayWithCapacity:3];
    }
    return _dimensionalPhotoIndexPaths;
}

- (NSMutableDictionary *)photoIdentifierDic {
    if (!_photoIdentifierDic) {
        _photoIdentifierDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _photoIdentifierDic;
}

- (NSMutableArray *)selectMediaArray {
    if (!_selectMediaArray) {
        _selectMediaArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _selectMediaArray;
}

- (UIButton *)chooseBtn {
    if (!_chooseBtn) {
        _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseBtn.frame = CGRectMake(0, 0, 45, 22);
        [_chooseBtn setTitle:@"选择" forState:UIControlStateNormal];
        [_chooseBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] forState:UIControlStateSelected];
        [_chooseBtn setTitleColor:[UIColor qunarTextBlackColor] forState:UIControlStateNormal];
        [_chooseBtn setTitleColor:[UIColor qunarTextBlackColor] forState:UIControlStateSelected];
        [_chooseBtn addTarget:self action:@selector(chooseMedia:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chooseBtn;
}

- (UIView *) controlPanelView {
    if (!_controlPanelView) {
        _controlPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, SCREEN_WIDTH, 48 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        _controlPanelView.backgroundColor = [UIColor stimDB_colorWithHex:0x333333 alpha:0.9];
        
        UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
        panelView.backgroundColor = [UIColor stimDB_colorWithHex:0x333333 alpha:0.9];
        [_controlPanelView addSubview:panelView];
        
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(0, 12, 24, 24);
        [shareBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e0cf" size:24 color:[UIColor whiteColor]]] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e0cf" size:24 color:[UIColor whiteColor]]] forState:UIControlStateSelected];
        [shareBtn addTarget:self action:@selector(shareMedias:) forControlEvents:UIControlEventTouchUpInside];
        shareBtn.backgroundColor = [UIColor clearColor];
        shareBtn.centerX = SCREEN_WIDTH / 4.0f;
        [panelView addSubview:shareBtn];
        
        UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        downloadBtn.frame = CGRectMake(0, 12, 24, 24);
        downloadBtn.centerX = 3 * SCREEN_WIDTH / 4.0f;
        [downloadBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f0aa" size:21 color:[UIColor whiteColor]]] forState:UIControlStateNormal];
        [downloadBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f0aa" size:21 color:[UIColor whiteColor]]] forState:UIControlStateSelected];
        [downloadBtn addTarget:self action:@selector(downloadMedia:) forControlEvents:UIControlEventTouchUpInside];
        downloadBtn.backgroundColor = [UIColor clearColor];
        [panelView addSubview:downloadBtn];
    }
    return _controlPanelView;
}

- (UICollectionView *)photoCollectionView {
    if (!_photoCollectionView) {
        STIMMWPhotoSectionBrowserLayout *layout = [[STIMMWPhotoSectionBrowserLayout alloc] init];
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[STIMDeviceManager sharedInstance] getNAVIGATION_BAR_HEIGHT] - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) collectionViewLayout:layout];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
         if (@available(iOS 11.0, *)) {
             _photoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
         } else {
             self.automaticallyAdjustsScrollViewInsets = NO;
         }
        _photoCollectionView.backgroundColor = [UIColor clearColor];
        [_photoCollectionView registerClass:[STIMMWPhotoSectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionElementKindSectionHeader"];
    }
    return _photoCollectionView;
}

#pragma mark - Action Progress

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [self.view addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)hideProgressHUD:(BOOL)animated {
    [self.progressHUD hide:animated];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if (message) {
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.5];
    } else {
        [self.progressHUD hide:YES];
    }
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (NSString *)getTimeStr:(long long)time {
    NSDate *date = [NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:time];
    if ([date stimDB_isToday]) {
        return @"今天";
    } else if ([date stimDB_isThisWeek]) {
        return @"这周";
    } else if ([date stimDB_isThisMonth]) {
        return @"这个月";
    } else {
        return [date stimDB_MonthDescription];
    }
    return nil;
}

- (NSDictionary *)getObjectInfoFromString:(NSString *)string{
    if (string.length > 1 && [string hasPrefix:@"["] && [string hasSuffix:@"]"]) {
        string = [string substringWithRange:NSMakeRange(1, string.length - 2)];
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    NSArray * sepArr = [string componentsSeparatedByString:@" "];
    for (NSString * item in sepArr) {
        if ([item rangeOfString:@"="].location != NSNotFound) {
            NSArray * itemArr = [item componentsSeparatedByString:@"="];
            if (itemArr.count > 1) {
                NSString * value = [[itemArr subarrayWithRange:NSMakeRange(1, itemArr.count - 1)] componentsJoinedByString:@"="];
                [infoDic setSTIMSafeObject:[self delQuoteForString:value] forKey:[self delQuoteForString:itemArr.firstObject]];
            }
        }
    }
    return infoDic;
}

//去引号
- (NSString *)delQuoteForString:(NSString *)str{
    if (str.length > 1 && [str hasPrefix:@"\""] && [str hasSuffix:@"\""]) {
        NSString * sss = [str substringWithRange:NSMakeRange(1, str.length - 2)];
        return sss;
    }else{
        return str;
    }
}

- (NSString *)timeFormatted:(int)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours != 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    } else if (seconds != 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%02d", seconds];
    }
}

- (NSArray *)splitLocalMediasWithLocalMsg:(NSArray *)localMsgs {
    NSMutableDictionary *msgsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSMutableArray *dateArray = [NSMutableArray arrayWithCapacity:3];
    for (STIMMessageModel * msg in localMsgs) {
        NSString *timeStr = [self getTimeStr:msg.messageDate];
        if (![dateArray containsObject:timeStr]) {
            [dateArray addObject:timeStr];
        }
        NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:3];
        STIMMessageType msgType = msg.messageType;
        if (msgType == STIMMessageType_SmallVideo) {
            
            NSDictionary *videoExtendInfoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:msg.extendInformation.length > 0 ? msg.extendInformation : msg.message error:nil];
            if (!videoExtendInfoDic) {
                continue;
            }
            STIMVerboseLog(@"videoExtendInfoDic : %@", videoExtendInfoDic);
            NSString *ThumbUrl = [videoExtendInfoDic objectForKey:@"ThumbUrl"];
            if (![ThumbUrl stimDB_hasPrefixHttpHeader] && ThumbUrl.length > 0) {
                ThumbUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", ThumbUrl];
            } else {
                ThumbUrl = ThumbUrl;
            }
            NSString *fileUrl = [videoExtendInfoDic objectForKey:@"FileUrl"];
            if (![fileUrl stimDB_hasPrefixHttpHeader] && fileUrl.length > 0) {
                fileUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", fileUrl];
            } else {
                fileUrl = fileUrl;
            }
            NSString *fileName = [videoExtendInfoDic objectForKey:@"FileName"];
            NSString *fileSize = [videoExtendInfoDic objectForKey:@"FileSize"];
            int videoDuration = [[videoExtendInfoDic objectForKey:@"Duration"] intValue];
            
            [msgDic setSTIMSafeObject:@(YES) forKey:@"isVideo"];
            [msgDic setSTIMSafeObject:ThumbUrl forKey:@"ThumbUrl"];
            [msgDic setSTIMSafeObject:fileUrl forKey:@"FileUrl"];
            [msgDic setSTIMSafeObject:fileName forKey:@"FileName"];
            [msgDic setSTIMSafeObject:fileSize forKey:@"ThumbUrl"];
            [msgDic setSTIMSafeObject:ThumbUrl forKey:@"FileSize"];
            [msgDic setSTIMSafeObject:[self timeFormatted:videoDuration] forKey:@"VideoDuration"];
            
            STIMMWPhoto *video = [STIMMWPhoto photoWithURL:[[NSURL alloc] initWithString:ThumbUrl]];
            video.videoURL = [[NSURL alloc] initWithString:fileUrl];
            video.extendInfo = msgDic;
            video.photoMsg = msg;
            video.isVideo = YES;
            
            NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
            if (timeStrMsgsGroup) {
                [timeStrMsgsGroup addObject:video];
                [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
            } else {
                timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
                [timeStrMsgsGroup addObject:video];
                [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
            }
        } else {
            NSString *content = msg.message;
            //正则 分析内容，匹配消息
            NSString *regulaStr = @"\\[obj type=\"(.*?)\" value=\"(.*?)\"(.*?)\\]";
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
            if (!msg) {
                return nil;
            }
            NSArray *arrayOfAllMatches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
            
            NSUInteger startLoc = 0;
            NSMutableArray * storages = [NSMutableArray arrayWithCapacity:1];
            for (NSTextCheckingResult *match in arrayOfAllMatches) {
                NSDictionary * objInfoDic = [self getObjectInfoFromString:[content substringWithRange:[match rangeAtIndex:0]]];
                NSString * type = objInfoDic[@"type"];
                NSString * value = objInfoDic[@"value"];
                NSUInteger len = match.range.location - startLoc;
                NSString *tStr = [content substringWithRange:NSMakeRange(startLoc, len)];
                
                //image
                if ([type hasPrefix:@"image"]) {
                    NSString *httpUrl = @"";
                    if (![value stimDB_hasPrefixHttpHeader] && value.length > 0) {
                        httpUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", value];
                    } else {
                        httpUrl = value;
                    }
                    STIMMWPhoto *photo = [[STIMMWPhoto alloc] initWithURL:[NSURL URLWithString:httpUrl]];
                    photo.photoMsg = msg;
                    NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
                    if (timeStrMsgsGroup) {
                        [timeStrMsgsGroup addObject:photo];
                        [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
                    } else {
                        timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
                        [timeStrMsgsGroup addObject:photo];
                        [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
                    }
                }
            }
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *cMap = [NSMutableDictionary dictionaryWithCapacity:2];
    for (NSInteger i = 0; i < dateArray.count; i++) {
        NSString *dateStr = [dateArray objectAtIndex:i];
        for (NSString *mapKey in [msgsMap allKeys]) {
            if ([mapKey isEqualToString:dateStr]) {
                NSArray *dateArray = [msgsMap objectForKey:mapKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                [dic setSTIMSafeObject:dateArray forKey:@"data"];
                [dic setSTIMSafeObject:mapKey forKey:@"key"];
                [array addObject:dic];
            }
        }
    }
    return array;
}

- (void)loadLocalMedia {
    
    NSArray *localMedia = @[];
    if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
        localMedia = [[STIMKit sharedInstance] getLocalMediasByXmppId:self.xmppId ByRealJid:self.realJid];
        NSLog(@"localMedia : %@", localMedia);
    } else {
        localMedia = [[STIMKit sharedInstance] getLocalMediasByXmppId:self.xmppId ByRealJid:nil];
        NSLog(@"localMedia : %@", localMedia);
    }
    self.sectionPhotos = [self splitLocalMediasWithLocalMsg:localMedia];
    for (NSInteger i = 0; i < self.sectionPhotos.count; i++) {
        NSDictionary *photosDic = [self.sectionPhotos objectAtIndex:i];
        NSArray *photos = [photosDic objectForKey:@"data"];
        for (NSInteger j = 0; j < photos.count; j++) {
            STIMMWPhoto *photo = [photos objectAtIndex:j];
            [self.dimensionalPhotoIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:i]];
            [self.dimensionalPhotos addObject:photo];
        }
    }
}

#pragma mark - life ctyle

- (void)setupNav {
    self.title = @"图片与视频";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.chooseBtn];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor spectralColorGrayDarkColor];
    [self.view addSubview:self.photoCollectionView];
    [self.view addSubview:self.controlPanelView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self loadLocalMedia];
    [self setupUI];
//    [self scrollBottom];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)scrollBottom {
    CGPoint offset = CGPointMake(0, self.photoCollectionView.contentSize.height - self.photoCollectionView.frame.size.height);
//    if (offset.y > 0) {
        [self.photoCollectionView setContentOffset:offset animated:NO];
//    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionPhotos.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDictionary *dataDic = [self.sectionPhotos objectAtIndex:section];
    NSArray *dataArray = [dataDic objectForKey:@"data"];
    return dataArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 每次先从字典中根据IndexPath取出唯一标识符
    NSDictionary *dataDic = [self.sectionPhotos objectAtIndex:indexPath.section];
    NSArray *dataArray = [dataDic objectForKey:@"data"];
    
    STIMMWPhoto *photo = [dataArray objectAtIndex:indexPath.row];
    NSDictionary *extendInfo = photo.extendInfo;
    NSString *videoDuration = [extendInfo objectForKey:@"VideoDuration"];
    NSString *identifier = [self.photoIdentifierDic objectForKey:[NSString stringWithFormat:@"%@", photo.photoURL.absoluteString]];
    // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"%@", photo.photoURL.absoluteString];
        [self.photoIdentifierDic setValue:identifier forKey:identifier];
        // 注册Cell
        [self.photoCollectionView registerClass:[STIMMWPhotoSectionBrowserCell class]  forCellWithReuseIdentifier:identifier];
    }
    
    STIMMWPhotoSectionBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell setShouldChooseFlag:self.chooseMediaFlag];
    [cell setPhoto:photo];
    if (!cell.reloaded) {
        [cell setType:photo.isVideo ? STIMMWTypeVideo : STIMMWTypePhoto];
        [cell setThumbUrl:photo.photoURL];
        [cell setVideoDuration:videoDuration];
        [cell setReloaded:YES];
    }
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

- (NSInteger)getDidSelectItemIndexWithIndexPath:(NSIndexPath *)indexPath {
    for (NSInteger i = 0; i < self.dimensionalPhotoIndexPaths.count; i++) {
        NSIndexPath *photoIndexPath = [self.dimensionalPhotoIndexPaths objectAtIndex:i];
        if(photoIndexPath.row == indexPath.row && photoIndexPath.section == indexPath.section) {
            return i;
        }
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger tag = [self getDidSelectItemIndexWithIndexPath:indexPath];
    [[STIMFastEntrance sharedInstance] browseBigHeader:@{@"MWPhotoList": self.dimensionalPhotos, @"CurrentIndex":@(tag)}];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

//这个也是最重要的方法 获取Header的 方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //从缓存中获取 Headercell
    NSDictionary *sectionDic = [self.sectionPhotos objectAtIndex:indexPath.section];
    NSString *sectionHeaderStr = [sectionDic objectForKey:@"key"];
    STIMMWPhotoSectionReusableView *header = (STIMMWPhotoSectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionElementKindSectionHeader" forIndexPath:indexPath];
    [header removeAllSubviews];
    header.backgroundColor = [UIColor spectralColorGrayDarkColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, header.width, 17)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:sectionHeaderStr];
    [header addSubview:label];
    return header;
}

- (void)didReceiveMemoryWarning {
    [[STIMImageManager sharedInstance] clearMemory];
}

- (void)chooseMedia:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.chooseMediaFlag = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.controlPanelView.frame = CGRectMake(0, self.view.bounds.size.height  - 48 - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], self.view.bounds.size.width, 48 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]);
            [self.view bringSubviewToFront:self.controlPanelView];
        } completion:^(BOOL finished) {
            [self.photoCollectionView reloadData];
        }];
    } else {
        self.chooseMediaFlag = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.controlPanelView.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 48 + [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]);
        } completion:^(BOOL finished) {
            [self.photoCollectionView reloadData];
        }];
    }
}

- (void)shareMedias:(id)sender {
    if (self.selectMediaArray.count) {
        NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
        for (STIMMWPhoto *photo in self.selectMediaArray) {
            STIMMessageModel *msg = [STIMMessageModel new];
            [msg setMessageType:STIMMessageType_Text];
            NSString *msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\"]", photo.photoURL.absoluteString];
            [msg setMessage:msgText];
            [msgList addObject:msg];
        }
        STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
        STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
        [controller setMessageList:msgList];
        __weak typeof(self) weakSelf = self;
        [[self navigationController] presentViewController:nav
                                                  animated:YES
                                                completion:^{
                                                    weakSelf.chooseMediaFlag = NO;
                                                    [weakSelf.photoCollectionView reloadData];
                                                }];
    } else {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Please share after selecting videos or photos"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:okAction];
        [self.navigationController presentViewController:alertVc animated:YES completion:nil];
    }
}

- (void)downloadMedia:(id)sender {
    if (self.selectMediaArray.count > 0) {
        [self showProgressHUDWithMessage:@"正在保存图片..."];
        dispatch_group_t group = dispatch_group_create();
        __block BOOL downLoadSuccess = YES;
        for (STIMMWPhoto *photo in self.selectMediaArray) {
            dispatch_group_enter(group);
            NSString *photoUrl = photo.photoURL.absoluteString;
            NSString *photoPath = [[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithHeaderUrl:photoUrl];
            if ([[NSFileManager defaultManager] fileExistsAtPath:photoPath]) {
                NSData *imageData = [NSData dataWithContentsOfFile:photoPath];
                if (imageData.length > 0) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                        request.creationDate = [NSDate date];
                        [request addResourceWithType:PHAssetResourceTypePhoto data:imageData options:options];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        STIMVerboseLog(@"是否保存成功：%d",success);
                        dispatch_group_leave(group);
                        if (success) {
                            
                        } else {
                            if (downLoadSuccess == YES) {
                                downLoadSuccess = NO;
                            }
                        }
                    }];
                } else {
                    NSData *fileData = [NSData dataWithContentsOfURL:photo.photoURL];
                    if (fileData.length > 0) {
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                            request.creationDate = [NSDate date];
                            [request addResourceWithType:PHAssetResourceTypePhoto data:fileData options:options];
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            STIMVerboseLog(@"是否保存成功：%d",success);
                            dispatch_group_leave(group);
                            if (success) {
                                
                            } else {
                                if (downLoadSuccess == YES) {
                                    downLoadSuccess = NO;
                                }
                            }
                        }];
                    }
                }
            } else {
                NSData *fileData = [NSData dataWithContentsOfURL:photo.photoURL];
                if (fileData.length > 0) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                        request.creationDate = [NSDate date];
                        [request addResourceWithType:PHAssetResourceTypePhoto data:fileData options:options];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        STIMVerboseLog(@"是否保存成功：%d",success);
                        dispatch_group_leave(group);
                        if (success) {
                            
                        } else {
                            if (downLoadSuccess == YES) {
                                downLoadSuccess = NO;
                            }
                        }
                    }];
                }
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (downLoadSuccess) {
                typeof(self) __weak weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideProgressHUD:YES];
                    [weakSelf showProgressHUDWithMessage:@"已保存到系统相册"];
                    [weakSelf hideProgressHUD:YES];
                    weakSelf.chooseMediaFlag = NO;
                    [weakSelf.selectMediaArray removeAllObjects];
                    [weakSelf.photoCollectionView reloadData];
                    [weakSelf chooseMedia:self.chooseBtn];
                });
            }
        });
    } else {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"请选择视频或图片后再保存" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:okAction];
        [self.navigationController presentViewController:alertVc animated:YES completion:nil];
    }
}

#pragma mark - STIMMWPhotoSectionBrowserChooseDelegate

- (void)selectedSTIMMWPhotoSectionBrowserChoose:(STIMMWPhoto *)photo {
    if (!self.selectMediaArray) {
        self.selectMediaArray = [NSMutableArray arrayWithCapacity:3];
    }
    [self.selectMediaArray addObject:photo];
    STIMVerboseLog(@"selectedSTIMMWPhotoSectionBrowserChoose : %@", photo);
}

- (void)deSelectedSTIMMWPhotoSectionBrowserChoose:(STIMMWPhoto *)photo {
    if (!self.selectMediaArray) {
        self.selectMediaArray = [NSMutableArray arrayWithCapacity:3];
    }
    [self.selectMediaArray removeObject:photo];
    STIMVerboseLog(@"deSelectedSTIMMWPhotoSectionBrowserChoose : %@", photo);
}

@end

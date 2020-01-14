//
//  STIMCollectionFaceManager.m
//  STChatIphone
//
//  Created by haibin.li on 16/1/6.
//
//

#define kCollectionResourceCachePath @"collectionResource"
#import "NSBundle+STIMLibrary.h"
#import "STIMCollectionFaceManager.h"
#import "STIMJSONSerializer.h"

@interface STIMCollectionFaceManager ()
{
    dispatch_queue_t       _updateLoadFaceQueue;
    dispatch_queue_t       _saveSmallImageQueue;
    dispatch_queue_t       _collectFaceQueue;
    void                  *_collectFaceQueueTag;
}
@end

@implementation STIMCollectionFaceManager

+ (id)sharedInstance{
    
    static STIMCollectionFaceManager *__global_emotion_manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_emotion_manger = [[STIMCollectionFaceManager alloc] init];
    });
    return __global_emotion_manger;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _collectFaceQueueTag = &_collectFaceQueueTag;
        _collectFaceQueue = dispatch_queue_create("xmppRunningQueue", 0);
        dispatch_queue_set_specific(_collectFaceQueue, _collectFaceQueueTag, _collectFaceQueueTag, NULL);
        _collectionFaceList = [NSMutableArray arrayWithArray:[[STIMKit sharedInstance] getClientConfigValueArrayWithType:STIMClientConfigTypeKCollectionCacheKey]];
//        _collectionFaceList = [[NSMutableArray alloc] initWithArray:[[STIMKit sharedInstance] userObjectForKey:kCollectionCacheKey]];
//        [self fixErrorData];
//        [self downloadRoamingCollectionFace];
    }
    return self;
}


/**
 *  根据小图索引获取图片
 *
 *  @param callback 回调
 *  @param index    索引
 */
- (void) showSmallImage:(void(^)(UIImage *)) callback withIndex:(NSInteger)index {
    
    NSString *imageNamePath = [self getSmallEmojiLocalPathWithIndex:index];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:imageNamePath];
    if (exist) {
        
        callback([UIImage stimDB_imageNamedFromSTIMUIKitBundle:imageNamePath]);
        
    } else {

        NSString *httpUrl = [[STIMCollectionFaceManager sharedInstance] getCollectionFaceHttpUrlWithIndex:index];
        
            //在这里下载
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[STIMKit sharedInstance] downloadCollectionEmoji:httpUrl width:CollectionFaceWidth height:CollectionFaceHeight forCacheType:STIMFileCacheTypeColoction complation:^(NSData *data) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (data) {
                        
                        callback([UIImage imageWithData:data]);
                    } else {
                        
                        callback([UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"aio_ogactivity_default"]);
                    }
                });
            }];
        });
    }
}

- (void) showOriginImage:(void(^)(UIImage *)) callback withIndex:(NSInteger)index {
 
    NSString *imageName = [self getOriginEmojiImageNameAtPos:index];
    NSString *imageNamePath = [self getCollectionFaceEmojiLocalPathWithIndex:index];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:imageNamePath];
    if (exist) {
        
        callback([STIMImage imageWithContentsOfFile:imageNamePath]);
    } else {
        if (!imageName) {
            callback([UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"NetworkErrorHint"]);
        } else {
            NSString *httpUrl = [[STIMCollectionFaceManager sharedInstance] getCollectionFaceHttpUrlWithIndex:index];
            [[STIMKit sharedInstance] downloadCollectionEmoji:httpUrl width:CollectionFaceWidth height:CollectionFaceHeight forCacheType:STIMFileCacheTypeColoction complation:^(NSData *data) {
                if (data) {
                    callback([UIImage imageWithData:data]);
                } else {
                    callback([UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"NetworkErrorHint"]);
                }
            }];
        }
    }
}

/**
 *  根据index获取小图本地路径
 *
 *  @param index 索引
 */
- (NSString *)getSmallEmojiLocalPathWithIndex: (NSInteger)index {
    
    NSString *smallImageName = [self getSmallEmojiImageNameAtPos:index];
    NSString *originImageName = [self getOriginEmojiImageNameAtPos:index];
    NSString *smallImageLocalPath = [[STIMKit sharedInstance] getFilePathForFileName:smallImageName forCacheType:STIMFileCacheTypeColoction];
    if (smallImageName.length && [[NSFileManager defaultManager] fileExistsAtPath:smallImageLocalPath]) {
        
        return smallImageLocalPath;
    } else {
        NSString *originImageLocalPath = [[STIMKit sharedInstance] getFilePathForFileName:smallImageName forCacheType:STIMFileCacheTypeColoction];

        if (originImageLocalPath.length && [[NSFileManager defaultManager] fileExistsAtPath:originImageLocalPath]) {
            return [[STIMKit sharedInstance] getFilePathForFileName:originImageName forCacheType:STIMFileCacheTypeColoction];
        } else {
            return nil;
        }
    }
    return nil;
}


/**
 *  根据index获取大图本地路径
 *
 *  @param index 索引
 */
- (NSString *)getCollectionFaceEmojiLocalPathWithIndex: (NSInteger)index {
    
    NSString *imageName = [self getOriginEmojiImageNameAtPos:index];
    NSString *imagePath = @"";
    if (imageName) {
        imagePath = [[STIMKit sharedInstance] getFilePathForFileName:imageName forCacheType:STIMFileCacheTypeColoction];
    }
    return imagePath;
}

/**
 *  根据Index获取收藏表情httpURL
 *
 *  @param index 索引
 */
- (NSString *)getCollectionFaceHttpUrlWithIndex: (NSInteger) index {
    
    if (index < 0 || index > [_collectionFaceList count]) {
        
        return nil;
    } else {
        
        NSString *collectionEmojiUrl = [_collectionFaceList objectAtIndex:index];
        return collectionEmojiUrl;
    }
}

/*
- (NSDictionary *)getCollectionFaceInfoWithIndex: (NSInteger) index {
    
    if (index < 0 || index > [_collectionFaceList count]) {
        
        return nil;
    } else {
        
        NSDictionary *dict = [_collectionFaceList objectAtIndex:index];
        return dict;
    }
}
*/
/**
 *  根据索引获取小图md5
 *
 *  @param index 索引
 *
 *  @return 小图md5
 */
- (NSString *) getSmallEmojiImageNameAtPos:(NSInteger) index {
    
    NSString *httpUrl = [self getCollectionFaceHttpUrlWithIndex:index];
    NSString *smallImageName = [[STIMKit sharedInstance] getFileNameFromUrl:httpUrl width:CollectionFaceWidth height:CollectionFaceHeight];
    return smallImageName;
}

/**
 *  根据索引获取图片md5
 *
 *  @param index 索引
 *
 *  @return 小图md5
 */
- (NSString *) getOriginEmojiImageNameAtPos:(NSInteger) index {
    
    NSString *httpUrl = [self getCollectionFaceHttpUrlWithIndex:index];
    NSString *imageName = [[STIMKit sharedInstance] getFileNameFromUrl:httpUrl];
    return imageName;
}

//获取CollectionFaceList个数
- (NSInteger)countOfCollectionFaceListCount {
    
    return [_collectionFaceList count];
}

- (NSArray *)getCollectionFaceList {
    
    dispatch_block_t block = ^{
        if (!_collectionFaceList)
            _collectionFaceList = [[NSMutableArray alloc] initWithCapacity:10];
        
        if ([_collectionFaceList count] <= 0) {
//            [_collectionFaceList addObjectsFromArray:[[STIMKit sharedInstance] userObjectForKey:kCollectionCacheKey]];
//            [self fixErrorData];
            [_collectionFaceList addObjectsFromArray:[[STIMKit sharedInstance] getClientConfigValueArrayWithType:STIMClientConfigTypeKCollectionCacheKey]];
        }
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
    
    return _collectionFaceList;
}

- (void)downloadRoamingCollectionFace{
    
    dispatch_queue_t tempQueue = dispatch_queue_create("downloadRoamingCollectionFace", DISPATCH_QUEUE_SERIAL);
    
    void(^forBlock)(id item) = ^(id item){
        
        if ([item isKindOfClass:[NSString class]] && item) {
            NSString *httpUrl = item;
            NSString *imageName = [[STIMKit sharedInstance] getFileNameFromUrl:httpUrl width:CollectionFaceWidth height:CollectionFaceHeight];
            NSString *imagePath = [[STIMKit sharedInstance] getFilePathForFileName:imageName forCacheType:STIMFileCacheTypeColoction];
            
            if (!imageName.length && ![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                
                if (_updateLoadFaceQueue == nil) {
                    _updateLoadFaceQueue = dispatch_queue_create("Upload Face Queue", 0);
                }
                
                [[STIMKit sharedInstance] downloadImage:httpUrl width:CollectionFaceWidth height:CollectionFaceHeight forCacheType:STIMFileCacheTypeColoction];
                
            }
        }
    };
    dispatch_block_t block = ^{
        for (id item in _collectionFaceList) {
            dispatch_async(tempQueue, ^{
                forBlock(item);
            });
        }
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
}

- (void)insertCollectionEmojiWithEmojiUrl:(NSString *)emojiUrl {
    __block BOOL isUpdate = NO;
    NSString *httpUrl = [emojiUrl copy];

    BOOL isContain = [self.collectionFaceList containsObject:httpUrl];
    if (!isContain) {
        
        isUpdate = YES;
        [self.collectionFaceList addObject:httpUrl];
        [[STIMKit sharedInstance] downloadImage:httpUrl width:CollectionFaceWidth height:CollectionFaceHeight forCacheType:STIMFileCacheTypeColoction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleSuccessNotification object:nil];
        });
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSBundle stimDB_localizedStringForKey:@"has_added_sticker"] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_ok"] otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (isUpdate) {
        [self updateCollectionEmojiWithEmojiUrl:httpUrl];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleNotification object:nil];
    });
}

- (void)updateCollectionEmojiWithEmojiUrl:(NSString *)emojiUrl {
    dispatch_block_t block = ^{
        NSString *emojiMd5 = [[STIMKit sharedInstance] md5fromUrl:emojiUrl];
        [[STIMKit sharedInstance] updateRemoteClientConfigWithType:STIMClientConfigTypeKCollectionCacheKey WithSubKey:emojiMd5 WithConfigValue:emojiUrl WithDel:NO];
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
}

- (void) replaceCollectionInfoWithIndex:(NSInteger )index NewInfo:(NSDictionary *)newInfo {
    
    __block BOOL isUpdate = NO;
        
    isUpdate = YES;
    if (index < 0 || index > [_collectionFaceList count]) {
        
        return ;
    } else {
        
        _collectionFaceList[index] = newInfo;
        [[STIMKit sharedInstance] setUserObject:_collectionFaceList forKey:kCollectionCacheKey];
        
        if (isUpdate) {
            [self updateConfig];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleNotification object:nil];
        });
    }
}

- (void)fixErrorData {
    __block BOOL fixed = NO;
    __block NSMutableArray * fixedArr = [NSMutableArray arrayWithCapacity:1];
    dispatch_block_t block = ^{
        fixedArr = [NSMutableArray arrayWithCapacity:[_collectionFaceList count] + 1];
        for (NSString *item in _collectionFaceList) {
            NSString * faceStr = item;
            [fixedArr addObject:faceStr];
            
        }
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
    
    if (fixed) {
        
        dispatch_block_t block = ^{
            _collectionFaceList = [NSMutableArray arrayWithArray:fixedArr];
            [[STIMKit sharedInstance] setUserObject:nil forKey:kCollectionCacheKey];
        };
        
        if (dispatch_get_specific(_collectFaceQueueTag))
            block();
        else
            dispatch_sync(_collectFaceQueue, block);
        
        [self updateConfig];
    }
}

- (void) delCollectionFaceArr:(NSArray *)delArr
{
    for (id item in delArr) {
        NSString * httpUrl = nil;
        if ([item isKindOfClass:[NSString class]]) {
            httpUrl = item;
            NSString *imageName = [[STIMKit sharedInstance] getFileNameFromUrl:httpUrl];
            [self delCollectionFaceImageWithFileName:imageName];
        }
    }
    
    dispatch_block_t block = ^{
        [_collectionFaceList removeObjectsInArray:delArr];
        [[STIMKit sharedInstance] setUserObject:_collectionFaceList forKey:kCollectionCacheKey];
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
    
    [self updateCollectionFaceArray:delArr WithDelFlag:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleNotification object:nil];
    });
}

- (void)delCollectionFaceImageWithFileName:(NSString *)fileName{
    
    NSString *filePath = [[STIMKit sharedInstance] getFilePathForFileName:fileName forCacheType:STIMFileCacheTypeColoction];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (void)delCollectionItemsNotInRoamingItems:(NSArray *)items{
    
    dispatch_block_t block = ^{
        NSInteger num = _collectionFaceList.count;
        NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < [_collectionFaceList count]; i++) {
            
            NSString *httpUrl = _collectionFaceList[i];
            BOOL isIn = NO;
            for (NSString *item in items) {
                if ([httpUrl respondsToSelector:@selector(isEqualToString:)]) {                    
                    if ([httpUrl isEqualToString:item]) {
                        
                        isIn = YES;
                    }
                }
            }
            if (!isIn) {
                
                [indexSet addIndex:i];
            }
        }
        
        [_collectionFaceList removeObjectsAtIndexes:indexSet];
        if (num > _collectionFaceList.count) {
            [[STIMKit sharedInstance] setUserObject:_collectionFaceList forKey:kCollectionCacheKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleNotification object:nil];
            });
        }
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
}

- (void)resetCollectionItems:(NSArray *)items WithUpdate:(BOOL)updateFlag {
    
    dispatch_block_t block = ^{
        [_collectionFaceList removeAllObjects];
        [_collectionFaceList addObjectsFromArray:items];
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
    
    if (updateFlag) {
        /*暂不支持表情排序
        [self updateConfig];
         */
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleNotification object:nil];
    });
}

- (void)updateCollectionFaceArray:(NSArray *)array WithDelFlag:(BOOL)del {
    dispatch_block_t block = ^{
        NSMutableArray * canUpdateArr = [NSMutableArray arrayWithCapacity:10];
        for (NSString *item in array) {
            NSString *httpUrl = item;
            if (!httpUrl.length) {
                continue;
            } else {
                NSString *configKey = @"kCollectionCacheKey";
                NSString *configSubKey = [[STIMKit sharedInstance] md5fromUrl:httpUrl];
                NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithCapacity:3];
                [newDic setSTIMSafeObject:configKey forKey:@"key"];
                [newDic setSTIMSafeObject:configSubKey forKey:@"subkey"];
                [newDic setSTIMSafeObject:httpUrl forKey:@"value"];
                [canUpdateArr addObject:newDic];
            }
        }
        if (canUpdateArr.count) {
            NSString *infoDicStr = [[STIMJSONSerializer sharedInstance] serializeObject:canUpdateArr];
            [[STIMKit sharedInstance] updateRemoteClientConfigWithType:STIMClientConfigTypeKCollectionCacheKey BatchProcessConfigInfo:canUpdateArr WithDel:del];
        }
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
}

- (void)updateConfig{
    
    dispatch_block_t block = ^{
        NSMutableArray * canUpdateArr = [NSMutableArray arrayWithCapacity:10];
        for (NSString *item in _collectionFaceList) {
            NSString *httpUrl = item;
            if (!httpUrl.length) {
                continue;
            } else {
                NSString *configKey = @"kCollectionCacheKey";
                NSString *configSubKey = [[STIMKit sharedInstance] md5fromUrl:httpUrl];
                NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithCapacity:3];
                [newDic setSTIMSafeObject:configKey forKey:@"key"];
                [newDic setSTIMSafeObject:configSubKey forKey:@"subkey"];
                [newDic setSTIMSafeObject:httpUrl forKey:@"value"];
                [canUpdateArr addObject:newDic];
            }
        }
        /*
        for (NSDictionary *item in _collectionFaceList) {
            
            NSString *httpUrl = item[@"httpUrl"];
            if (!httpUrl) {
                
                continue;
            } else {
                
                NSMutableDictionary * newDic = [NSMutableDictionary dictionaryWithDictionary:item];
                [canUpdateArr addObject:newDic];
            }
        }
        */
        if (canUpdateArr.count) {
            NSString *infoDicStr = [[STIMJSONSerializer sharedInstance] serializeObject:canUpdateArr];
//            [[STIMKit sharedInstance] updateRemoteClientConfigBatchProcessConfigInfo:infoDicStr WithDel:YES];
            [[STIMKit sharedInstance] updateRemoteClientConfigWithType:STIMClientConfigTypeKCollectionCacheKey BatchProcessConfigInfo:infoDicStr WithDel:YES];
        }
    };

    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
    
    
    
}

- (BOOL)hasLocalCollectionFace{
    
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        for (id item in _collectionFaceList) {
            if (![item isKindOfClass:[NSDictionary class]] || item[@"httpUrl"] == nil) {
                result = YES;
                break;
            }
        }
        result = NO;
    };
    
    if (dispatch_get_specific(_collectFaceQueueTag))
        block();
    else
        dispatch_sync(_collectFaceQueue, block);
    
    return result;
}

- (void)checkForUploadLocalCollectionFace{
    if ([self hasLocalCollectionFace]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"common_prompt"] message:[NSBundle stimDB_localizedStringForKey:@"common_roaming_tips"] delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_cancel"] otherButtonTitles:[NSBundle stimDB_localizedStringForKey:@"common_done_roaming"], nil];
        [alertView show];
    }
}

#pragma mark - UIALertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [self uploadLocalCollectionFace];
        
        [self updateConfig];
    } else {
        
        return;
    }
}

- (void)uploadLocalCollectionFace {
    
    __block NSArray *tmpCollectList = nil;
    {
        dispatch_block_t block = ^{
            tmpCollectList  = [NSArray arrayWithArray:_collectionFaceList];
        };
        
        if (dispatch_get_specific(_collectFaceQueueTag))
            block();
        else
            dispatch_sync(_collectFaceQueue, block);
    }
    for (NSDictionary *item in _collectionFaceList) {
        
        NSString *httpUrl = item[@"httpUrl"];
        NSData *data = [[STIMKit sharedInstance] getFileDataFromUrl:httpUrl forCacheType:STIMFileCacheTypeColoction];
        
        dispatch_block_t uploadblock = ^{
            
            NSString *jid = [[STIMKit sharedInstance] getLastJid];
            [[STIMKit sharedInstance] uploadFileForData:data forMessage:nil withJid:jid isFile:0];

        };
        
        if (dispatch_get_specific(_collectFaceQueueTag)) {
            uploadblock();
        }
        else
            dispatch_sync(_collectFaceQueue, uploadblock);
    }
}

@end

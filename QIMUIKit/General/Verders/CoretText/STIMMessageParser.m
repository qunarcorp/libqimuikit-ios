//
//  STIMMessageParser.m
//  STChatIphone
//
//  Created by haibin.li on 16/7/6.
//
//

#import "STIMMessageParser.h"
#import "STIMJSONSerializer.h"
#import "STIMTextStorage.h"
#import "STIMImageStorage.h"
#import "STIMLinkTextStorage.h"
#import "STIMTextStorageProtocol.h"
#import "STIMAttributedLabel.h"
#import "STIMMessageCellCache.h"
#import "STIMPhoneNumberTextStorage.h"
#import <objc/runtime.h>
#import "STIMEmotionManager.h"
#import "STIMCommonFont.h"

#define kMessageTextFontSize        15
//([[STIMCommonFont sharedInstance] currentFontSize] - 4)
#define kThumbMaxWidth              [UIScreen mainScreen].bounds.size.width / 3
#define kThumbMaxHeight             [UIScreen mainScreen].bounds.size.width / 3

#define kCellWidth                 IS_Ipad ? ([UIScreen mainScreen].stimDB_rightWidth  * 240 / 320) : ([UIScreen mainScreen].bounds.size.width * 3/5)

//#define kNomalFontName              @"FZLTHJW--GB1-0" //@"MarkerFelt-Thin"
//#define kLinkFontName               @"CourierNewPS-ItalicMT"

typedef void (^QCParseCompleteBlock)(NSDictionary *info);

@interface STIMMessageParser () <NSXMLParserDelegate> {
    QCParseCompleteBlock _parseCompleteBlock;
    NSMutableDictionary *_msgInfoDic;
}
@end

@implementation STIMMessageParser

+ (instancetype)sharedInstance {
    static STIMMessageParser *parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[STIMMessageParser alloc] init];
    });
    return parser;
}

+ (float)getCellWidth {
    return kCellWidth;
}

+ (STIMAttributedLabel *)attributedLabelForMessage:(STIMMessageModel *)message {
    NSArray *storages = [self storagesFromMessage:message];
    STIMAttributedLabel *label = [[STIMMessageCellCache sharedInstance] getObjectForKey:message.messageId];
    [label appendTextStorageArray:storages];
    [label sizeToFit];
    [[STIMMessageCellCache sharedInstance] setObject:label forKey:message.messageId];

    return label;
}

+ (STIMTextContainer *)textContainerForMessage:(STIMMessageModel *)message {
    return [self textContainerForMessage:message fromCache:YES];
}

+ (STIMTextContainer *)textContainerForMessage:(STIMMessageModel *)message fromCache:(BOOL)fromCache {
    if (message == nil) {
        return nil;
    }
    STIMTextContainer *textContainer = [[STIMMessageCellCache sharedInstance] getObjectForKey:message.messageId];
    if (fromCache == NO || !textContainer) {
        NSArray *storages = [self storagesFromMessage:message];
        // 属性文本生成器
        textContainer = [[STIMTextContainer alloc] init];
        if (message.messageType == STIMMessageType_GroupNotify) {
            textContainer.textColor = [UIColor whiteColor];
            textContainer.font = [UIFont systemFontOfSize:12];
//            [UIFont fontWithName:kNomalFontName size:12];
        } else {
            UIColor *textColor = message.messageDirection == STIMMessageDirection_Sent ? [UIColor stimDB_rightBallocFontColor] : [UIColor stimDB_leftBallocFontColor];
            textContainer.textColor = textColor;
            textContainer.font = [UIFont systemFontOfSize:kMessageTextFontSize];
//            [UIFont fontWithName:kNomalFontName size:kMessageTextFontSize];
        }
        [textContainer appendTextStorageArray:storages];
        textContainer.linesSpacing = 2;
        textContainer.isWidthToFit = YES;
        textContainer = [textContainer createTextContainerWithTextWidth:kCellWidth];
        if (fromCache) {
            [[STIMMessageCellCache sharedInstance] setObject:textContainer forKey:message.messageId];
        }
    }
//    STIMVerboseLog(@"return textContainerForMessage : %@", textContainer);
    return textContainer;
}


+ (STIMTextContainer *)textContainerForMessageCtnt:(NSString *)ctnt withId:(NSString *)signId direction:(STIMMessageDirection)direction {
    if (signId == nil || ctnt.length == 0) {
        return nil;
    }
    STIMTextContainer *textContainer = [[STIMMessageCellCache sharedInstance] getObjectForKey:signId];
    if (!textContainer) {
        NSArray *storages = [self storagesWithContent:ctnt WithMsgId:signId WithDirection:direction];
        // 属性文本生成器
        textContainer = [[STIMTextContainer alloc] init];
        UIColor *textColor = direction == STIMMessageDirection_Sent ? [UIColor stimDB_rightBallocFontColor] : [UIColor stimDB_leftBallocFontColor];
        textContainer.textColor = textColor;
        textContainer.font = [UIFont systemFontOfSize:kMessageTextFontSize];
        textContainer.linesSpacing = 2;
        [textContainer appendTextStorageArray:storages];
        textContainer.isWidthToFit = YES;
        textContainer.lineBreakMode = kCTLineBreakByCharWrapping;
        textContainer = [textContainer createTextContainerWithTextWidth:kCellWidth];
        [[STIMMessageCellCache sharedInstance] setObject:textContainer forKey:signId];
    }
    return textContainer;
}

+ (NSArray *)storagesWithContent:(NSString *)content WithMsgId:(NSString *)msgId WithDirection:(STIMMessageDirection)direction {
    NSString *msg = content;
    //正则 分析内容，匹配消息
    NSString *regulaStr = @"\\[obj type=\"(.*?)\" value=\"(.*?)\"(.*?)\\]";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (!msg) {
        return nil;
    }
    NSArray *arrayOfAllMatches = [regex matchesInString:msg options:0 range:NSMakeRange(0, [msg length])];

    NSUInteger startLoc = 0;
    NSMutableArray *storages = [NSMutableArray arrayWithCapacity:1];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSDictionary *objInfoDic = [self getObjectInfoFromString:[msg substringWithRange:[match rangeAtIndex:0]]];
        NSString *type = objInfoDic[@"type"];
        NSString *value = objInfoDic[@"value"];
        NSUInteger len = match.range.location - startLoc;
        NSString *tStr = [msg substringWithRange:NSMakeRange(startLoc, len)];

        //text
        if (tStr.length) {

            [storages addObjectsFromArray:[self getStoragesForTextString:tStr msgDirection:direction]];
        }

        //image
        if ([type hasPrefix:@"image"]) {
            NSString *httpUrl = @"";
            if (![value stimDB_hasPrefixHttpHeader] && value.length > 0) {
                httpUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", value];
            } else {
                httpUrl = value;
            }

            CGFloat width = 0;
            CGFloat height = 0;
            NSString *widthStr = objInfoDic[@"width"];
            NSString *heightStr = objInfoDic[@"height"];
            if (widthStr.length && heightStr.length) {
                widthStr = [widthStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                heightStr = [heightStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                width = [widthStr floatValue];
                height = [heightStr floatValue];
            }
            /*
            if (width == 0 || height == 0) {
                UIImage * image = [YLGIFImage imageWithData:[[STIMKit sharedInstance] getFileDataFromUrl:httpUrl forCacheType:STIMFileCacheTypeColoction]];
                width = image.size.width;
                height = image.size.height;
            }
            */
            if (height > SCREEN_HEIGHT * 3 && height / width >= 5) {
                width = 50;
                height = 100;
            } else {
                if (width > kThumbMaxWidth || height > kThumbMaxHeight) {
                    float scale = MIN(kThumbMaxWidth / width, kThumbMaxHeight / height);
                    width = width * scale;
                    height = height * scale;
                }
                if (width <= 0) {
                    width = 100;
                }
                if (height <= 0) {
                    height = 100;
                }
            }

            [storages addObject:[self parseImageRunFromDictinary:@{@"httpUrl": httpUrl ? httpUrl : @"", @"width": @(width), @"height": @(height), @"range": NSStringFromRange(match.range)}]];

        }
            //链接link
        else if ([type hasPrefix:@"url"]) {
            NSString *url = value;
            if (url.length) {
                UIColor *textColor = direction == STIMMessageDirection_Sent ? stimDB_messageLinkurl_color : stimDB_messageLinkurl_color;
                [storages addObject:[self parseLinkRunFromDictinary:@{@"content": url ? url : @"", @"fontSize": @(kMessageTextFontSize), @"color": textColor, @"linkUrl": url ? url : @"", @"range": NSStringFromRange(match.range)}]];
            }
        }
            //at me
        else if ([type hasPrefix:@"atStrType"]) {
            NSString *content = [NSString stringWithFormat:@"@%@", [[STIMKit sharedInstance] getMyNickName]];
            if (content.length) {
                UIColor *textColor = [UIColor redColor];
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content": content ? content : @"", @"fontSize": @(kMessageTextFontSize), @"color": textColor, @"range": NSStringFromRange(match.range)}]];
            }

        }
            //emotions
        else if ([type hasPrefix:@"emoticon"]) {
            if ([value hasPrefix:@"["] && value.length > 1) {
                value = [value substringFromIndex:1];
            }
            if ([value hasSuffix:@"]"] && value.length > 1) {
                value = [value substringToIndex:value.length - 1];
            }
            NSString *pkId = objInfoDic[@"width"];

            NSString *imageName = [[STIMEmotionManager sharedInstance] getEmotionImagePathForShortCut:value withPackageId:pkId];
            BOOL hasEmotion = YES;
            if ((imageName == nil) && ([imageName length] == 0)) {
                hasEmotion = NO;
            }
            STIMImage *emotionImage = nil;
            CGSize emotionImageSize = CGSizeZero;
            if ([imageName length] > 0) {
                NSData *imageData = [NSData dataWithContentsOfFile:imageName];
                emotionImage = [STIMImage imageWithData:imageData scale:0.5];
                emotionImageSize = CGSizeMake(emotionImage.size.width / 2.0f, emotionImage.size.height / 2.0f);
            }
            if (!emotionImage) {
                NSData *imageData = [[STIMEmotionManager sharedInstance] getEmotionThumbIconDataWithImageStr:imageName];
                emotionImage = [STIMImage imageWithData:imageData scale:0.5];
                emotionImageSize = CGSizeMake(48, 48);
            }
            if (!emotionImage) {
                [[STIMEmotionManager sharedInstance] getEmotionImageFromHttpForPkId:pkId shortcut:value signKey:msgId];
                hasEmotion = NO;
            }

            CGSize size = CGSizeEqualToSize(emotionImageSize, CGSizeZero) ? emotionImage.size : emotionImageSize;
            if (hasEmotion && ![pkId isEqualToString:@"EmojiOne"] && ![pkId isEqualToString:@"qq"] && ![pkId isEqualToString:@"newqq"] && ![pkId isEqualToString:@"yahoo"] && ![pkId isEqualToString:@"mop"] && ![pkId isEqualToString:@"SmallCamel"]) {
                if (emotionImage) {
                    [storages addObject:[self parseEmotionFromDictinary:@{@"image": emotionImage, @"infoDic": @{@"signKey": msgId, @"pkId": pkId ? pkId : @"noPkId", @"shortCut": value ? value : @""}, @"width": @(128), @"height": @(128), @"range": NSStringFromRange(match.range)}]];
                }
            } else if (hasEmotion && ([pkId isEqualToString:@"EmojiOne"] || [pkId isEqualToString:@"qq"] || [pkId isEqualToString:@"newqq"] || [pkId isEqualToString:@"yahoo"] || [pkId isEqualToString:@"mop"] || [pkId isEqualToString:@"SmallCamel"])) {
                if (emotionImage) {
                    [storages addObject:[self parseEmotionFromDictinary:@{@"image": emotionImage, @"infoDic": @{@"signKey": msgId, @"pkId": pkId ? pkId : @"noPkId", @"shortCut": value ? value : @""}, @"width": @(24), @"height": @(24), @"range": NSStringFromRange(match.range)}]];
                }
            } else {
                [storages addObject:[self parseEmotionFromDictinary:@{@"infoDic": @{@"signKey": msgId, @"pkId": pkId ? pkId : @"noPkId", @"shortCut": value ? value : @""}, @"width": @(128), @"height": @(128), @"range": NSStringFromRange(match.range)}]];
            }
        }
        startLoc = match.range.location + match.range.length;
    }

    //处理 特殊类型后的普通字符串 未被处理 BUG
    if (startLoc < msg.length) {
        NSString *tStr = [msg substringFromIndex:startLoc];
        if (tStr.length) {
            [storages addObjectsFromArray:[self getStoragesForTextString:tStr msgDirection:direction]];
        }
    }

    return storages;
}

+ (NSArray *)storagesFromMessage:(STIMMessageModel *)message {
    return [self storagesWithContent:message.message WithMsgId:message.messageId WithDirection:message.messageDirection];
}

+ (NSArray *)getStoragesForTextString:(NSString *)tStr msgDirection:(STIMMessageDirection)direction {

    UIColor *textColor = direction == STIMMessageDirection_Sent ? [UIColor stimDB_rightBallocFontColor] : [UIColor stimDB_leftBallocFontColor];
    NSString *content = [NSString stringWithFormat:@"@%@", [[STIMKit sharedInstance] getMyNickName]];
    NSInteger startLoc = 0;
    NSArray *subStrs = [tStr componentsSeparatedByString:content];
    NSMutableArray *storages = [NSMutableArray arrayWithCapacity:1];
    if (subStrs.count >= 1) {
        NSUInteger tempLen = 0;
        NSInteger i = 0;
        for (NSString *subStr in subStrs) {
            tempLen += subStr.length;
            [storages addObject:[self parseTextStorageFromDictinary:@{@"content": subStr ? subStr : @"", @"fontSize": @(kMessageTextFontSize), @"color": textColor}]];
            if (i < subStrs.count - 1) {
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content": content ? content : @"", @"fontSize": @(kMessageTextFontSize), @"color": [UIColor redColor]}]];
                tempLen += content.length;
            }
            i++;
        }
    } else {
        //文本中解析URL和PhoneNumber
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
        NSArray *matches = [linkDetector matchesInString:tStr options:0 range:NSMakeRange(0, [tStr length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange tstrRange = NSMakeRange(startLoc, [match range].location - startLoc);
            NSString *textStr = [tStr substringWithRange:tstrRange];
            if (textStr.length > 0) {
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content": textStr ? textStr : @"", @"fontSize": @(kMessageTextFontSize), @"color": textColor}]];
            }
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSString *url = [[match URL] absoluteString];
                NSRange urlRange = [match range];
                if (urlRange.location + urlRange.length <= tStr.length && urlRange.length + urlRange.location > 0) {
                    UIColor *linkTextColor = direction == STIMMessageDirection_Sent ? stimDB_messageLinkurl_color : stimDB_messageLinkurl_color;
                    [storages addObject:[self parseLinkRunFromDictinary:@{@"content": url ? url : @"", @"fontSize": @(kMessageTextFontSize), @"color": linkTextColor, @"linkUrl": url, @"range": NSStringFromRange(match.range)}]];
                    startLoc = match.range.location + match.range.length;
                }
            } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                NSString *phoneNumber = [match phoneNumber];
                NSRange phoneNumberRange = [match range];
                if (phoneNumberRange.location + phoneNumberRange.length <= tStr.length && phoneNumberRange.length + phoneNumberRange.location > 0) {
                    UIColor *phoneNumColor = direction == STIMMessageDirection_Sent ? stimDB_messageLinkurl_color : stimDB_messageLinkurl_color;
                    [storages addObject:[self parsePhoneNumberRunFromDictionary:@{@"content": phoneNumber ? phoneNumber : @"", @"fontSize": @(kMessageTextFontSize), @"phoneNumColor": phoneNumColor}]];
                    startLoc = match.range.location + match.range.length;
                }
            }
        }
        if (startLoc < tStr.length) {
            NSString *testStr = [tStr substringFromIndex:startLoc];
            if (testStr.length > 0) {
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content": testStr ? testStr : @"", @"fontSize": @(kMessageTextFontSize), @"color": textColor}]];
            }
        }
    }
    return storages;
}

+ (id <QCAppendTextStorageProtocol>)parseTextStorageFromDictinary:(NSDictionary *)dic {
    STIMTextStorage *textStorage = [[STIMTextStorage alloc] init];
    textStorage.text = dic[@"content"];
    float fontSize = [dic[@"fontSize"] floatValue];
    if (fontSize > 0) {
        textStorage.font = [UIFont systemFontOfSize:fontSize];
//        [UIFont fontWithName:kNomalFontName size:fontSize];
    }
    textStorage.textColor = dic[@"color"];

    return textStorage;
}

+ (id <STIMDrawStorageProtocol>)parseImageRunFromDictinary:(NSDictionary *)dic {
    STIMImageStorage *imageStorage = [[STIMImageStorage alloc] init];
    imageStorage.imageURL = [NSURL URLWithString:dic[@"httpUrl"]];
    imageStorage.size = CGSizeMake([dic[@"width"] floatValue], [dic[@"height"] floatValue]);
    imageStorage.storageType = STIMImageStorageTypeImage;
    return imageStorage;
}

+ (id <STIMDrawStorageProtocol>)parseEmotionFromDictinary:(NSDictionary *)dic {
    STIMImageStorage *imageStorage = [[STIMImageStorage alloc] init];
    imageStorage.image = dic[@"image"];
    imageStorage.imageAlignment = QCImageAlignmentRight;
    imageStorage.size = CGSizeMake([dic[@"width"] floatValue], [dic[@"height"] floatValue]);
    imageStorage.infoDic = dic[@"infoDic"];
    imageStorage.storageType = STIMImageStorageTypeEmotion;
    return imageStorage;
}

+ (id <QCAppendTextStorageProtocol>)parseLinkRunFromDictinary:(NSDictionary *)dic {
    STIMLinkTextStorage *linkStorage = [[STIMLinkTextStorage alloc] init];
    linkStorage.text = dic[@"content"];
    float fontSize = [dic[@"fontSize"] floatValue];
    if (fontSize > 0) {
        linkStorage.font = [UIFont systemFontOfSize:fontSize];
//        [UIFont fontWithName:kLinkFontName size:fontSize];
    }
    linkStorage.textColor = dic[@"color"];
    linkStorage.linkData = dic[@"linkUrl"];

    return linkStorage;
}

+ (id <QCAppendTextStorageProtocol>)parsePhoneNumberRunFromDictionary:(NSDictionary *)dic {

    STIMPhoneNumberTextStorage *phoneNumberStorage = [[STIMPhoneNumberTextStorage alloc] init];
    phoneNumberStorage.text = dic[@"content"];
    float fontSize = [dic[@"fontSize"] floatValue];
    if (fontSize > 0) {
        phoneNumberStorage.font = [UIFont systemFontOfSize:fontSize];
//        [UIFont fontWithName:kLinkFontName size:fontSize];
    }
    phoneNumberStorage.textColor = dic[@"phoneNumColor"];
    phoneNumberStorage.phoneNumData = dic[@"content"];
    return phoneNumberStorage;
}

+ (NSDictionary *)getObjectInfoFromString:(NSString *)string {
    if (string.length > 1 && [string hasPrefix:@"["] && [string hasSuffix:@"]"]) {
        string = [string substringWithRange:NSMakeRange(1, string.length - 2)];
    }
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    NSArray *sepArr = [string componentsSeparatedByString:@" "];
    for (NSString *item in sepArr) {
        if ([item rangeOfString:@"="].location != NSNotFound) {
            NSArray *itemArr = [item componentsSeparatedByString:@"="];
            if (itemArr.count > 1) {
                NSString *value = [[itemArr subarrayWithRange:NSMakeRange(1, itemArr.count - 1)] componentsJoinedByString:@"="];
                [infoDic setSTIMSafeObject:[self delQuoteForString:value] forKey:[self delQuoteForString:itemArr.firstObject]];
            }
        }
    }
    return infoDic;
}

//去引号
+ (NSString *)delQuoteForString:(NSString *)str {
    if (str.length > 1 && [str hasPrefix:@"\""] && [str hasSuffix:@"\""]) {
        NSString *sss = [str substringWithRange:NSMakeRange(1, str.length - 2)];
        return sss;
    } else {
        return str;
    }
}

+ (STIMMessageModel *)reductionMessageForMessage:(STIMMessageModel *)message {
    STIMMessageModel *newMsg = message;
    NSString *parseStr = message.extendInformation.length ? message.extendInformation : message.message;
    NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:parseStr error:nil];
    switch (message.messageType) {
        case STIMMessageType_LocalShare: {
            //@"{\"name\":\"%@\",\"adress\":\"%@\",\"latitude\":\"%lf\",\"longitude\":\"%lf\"}"
            double latitude = [infoDic[@"latitude"] doubleValue];
            double longitude = [infoDic[@"longitude"] doubleValue];
            NSString *adress = infoDic[@"adress"];
            newMsg.message = [NSString stringWithFormat:@"我在这里，点击查看：[obj type=\"url\" value=\"%@\"] (%@)", [NSString stringWithFormat:@"http://api.map.baidu.com/marker?location=%lf,%lf&title=我的位置&content=%@&output=html", latitude, longitude, adress], adress];
            newMsg.extendInformation = parseStr;
        }
            break;
        case STIMMessageType_CommonTrdInfo: {
            //{"title" : "c10k问题", "linkurl" : "http:\/\/www.360doc.cn\/article\/1542811_287328391.html"}
            NSString *title = infoDic[@"title"];
            NSString *linkurl = infoDic[@"linkurl"];
            NSString *msgStr = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:[title stringByAppendingString:linkurl]];
            newMsg.message = msgStr;
            newMsg.extendInformation = parseStr;
        }
            break;
        case STIMMessageType_ExProduct: {
            NSString *msgStr = infoDic[@"titletxt"];
            msgStr = [msgStr stringByAppendingString:@"\n"];
            msgStr = [msgStr stringByAppendingString:infoDic[@"detailurl"]];
            for (NSDictionary *dic in infoDic[@"descs"]) {
                msgStr = [msgStr stringByAppendingString:@"\n"];
                msgStr = [msgStr stringByAppendingString:dic[@"k"]];
                msgStr = [msgStr stringByAppendingString:@" : "];
                msgStr = [msgStr stringByAppendingString:dic[@"v"]];
            }
            msgStr = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:msgStr];
            newMsg.message = msgStr;
            newMsg.extendInformation = parseStr;
        }
            break;
        case STIMMessageType_product: {
            NSString *title = infoDic[@"title"];
            NSString *linkurl = infoDic[@"touchDtlUrl"];
            NSString *msgStr = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:[title stringByAppendingString:linkurl]];
            newMsg.message = msgStr;
            newMsg.extendInformation = parseStr;
        }
            break;
        default:
            break;
    }
    return newMsg;
}

@end

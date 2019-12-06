//
//  QIMWorkMomentParser.m
//  QIMUIKit
//
//  Created by lilu on 2019/2/25.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentParser.h"
#import "QIMJSONSerializer.h"
#import "QIMTextStorage.h"
#import "QIMImageStorage.h"
#import "QIMLinkTextStorage.h"
#import "QIMTextStorageProtocol.h"
#import "QIMAttributedLabel.h"
#import "QIMMessageCellCache.h"
#import "QIMPhoneNumberTextStorage.h"
#import <objc/runtime.h>
#import "QIMEmotionManager.h"
#import "QIMCommonFont.h"

#define kThumbMaxWidth              [UIScreen mainScreen].bounds.size.width / 3
#define kThumbMaxHeight             [UIScreen mainScreen].bounds.size.width / 3
#define kWorkMomentTextFontSize     15

@implementation QIMWorkMomentParser

+ (instancetype) sharedInstance {
    static QIMWorkMomentParser * parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[QIMWorkMomentParser alloc] init];
    });
    return parser;
}

+ (QIMTextContainer *)textContainerForMessage:(QIMMessageModel *)message fromCache:(BOOL)fromCache withCellWidth:(CGFloat)cellWidth withFontSize:(CGFloat)fontSize withFontColor:(UIColor *)textColor withNumberOfLines:(NSInteger)numberOfLines {
    if (message == nil) {
        return nil;
    }
    QIMTextContainer *textContainer = [[QIMMessageCellCache sharedInstance] getObjectForKey:message.messageId];
    if (fromCache == NO || !textContainer) {
        NSArray * storages = [self storagesFromMessage:message];
        // 属性文本生成器
        textContainer = [[QIMTextContainer alloc] init];
        textContainer.numberOfLines = numberOfLines;
        textContainer.textColor = textColor;
        textContainer.font = [UIFont systemFontOfSize:fontSize];
        [textContainer appendTextStorageArray:storages];
        textContainer.linesSpacing = 1.0f;
        textContainer.isWidthToFit = YES;
        textContainer.lineBreakMode = kCTLineBreakByTruncatingTail;
        textContainer = [textContainer createTextContainerWithTextWidth:cellWidth];
        if (fromCache) {
            [[QIMMessageCellCache sharedInstance] setObject:textContainer forKey:message.messageId];
        }
    }
    return textContainer;
}

+ (NSArray *)storagesWithContent:(NSString *)content WithMsgId:(NSString *)msgId WithDirection:(QIMMessageDirection)direction {
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
    NSMutableArray * storages = [NSMutableArray arrayWithCapacity:1];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSDictionary * objInfoDic = [self getObjectInfoFromString:[msg substringWithRange:[match rangeAtIndex:0]]];
        NSString * type = objInfoDic[@"type"];
        NSString * value = objInfoDic[@"value"];
        NSUInteger len = match.range.location - startLoc;
        NSString *tStr = [msg substringWithRange:NSMakeRange(startLoc, len)];
        
        //text
        if (tStr.length) {
            
            [storages addObjectsFromArray:[self getStoragesForTextString:tStr msgDirection:direction]];
        }
        
        //image
        if ([type hasPrefix:@"image"]) {
            NSString *httpUrl = @"";
            if (![value qim_hasPrefixHttpHeader] && value.length > 0) {
                httpUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", value];
            } else {
                httpUrl = value;
            }
            
            CGFloat width = 0;
            CGFloat height = 0;
            NSString * widthStr = objInfoDic[@"width"];
            NSString * heightStr = objInfoDic[@"height"];
            if (widthStr.length && heightStr.length) {
                widthStr = [widthStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                heightStr = [heightStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                width = [widthStr floatValue];
                height = [heightStr floatValue];
            }
            if (height > SCREEN_HEIGHT * 3 && height / width >= 5) {
                width = 50;
                height = 100;
            } else {
                if (width > kThumbMaxWidth || height > kThumbMaxHeight) {
                    float scale = MIN(kThumbMaxWidth/width, kThumbMaxHeight/height);
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
            
            [storages addObject:[self parseImageRunFromDictinary:@{@"httpUrl":httpUrl?httpUrl:@"",@"width":@(width),@"height":@(height),@"range":NSStringFromRange(match.range)}]];
            
        } else if ([type hasPrefix:@"deleteComment"]) {
            //删评
            NSString *deleteStr = value;
            if (deleteStr.length) {
                UIColor *deleteColor = [UIColor redColor];
                NSInteger deleteFontSize = 15;
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content":deleteStr?deleteStr:@"",@"fontSize":@(deleteFontSize),@"color":deleteColor}]];
            }
        } else if ([type hasPrefix:@"reply"]) {
            //回复
            NSString *replyStr = value;
            if (replyStr.length) {
                UIColor *replyColor = [UIColor qim_colorWithHex:0x999999];
                NSInteger replyFontSize = 14;
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content":replyStr?replyStr:@"",@"fontSize":@(replyFontSize),@"color":replyColor}]];
            }
        } else if ([type hasPrefix:@"topMoment"]) {
            //置顶
            NSString *topMoment = value;
            if (topMoment.length) {
                UIColor *topColor = [UIColor qim_colorWithHex:0x389CFE];
                NSInteger topFontSize = 15;
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content":topMoment?topMoment:@"",@"fontSize":@(topFontSize),@"color":topColor}]];
            }
        } else if ([type hasPrefix:@"hotMoment"]) {
          //置热
            NSString *hotMoment = value;
            if (hotMoment.length) {
                UIColor *hotColor = [UIColor qim_colorWithHex:0xFF6916];
                NSInteger hotFontSize = 15;
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content":hotMoment?hotMoment:@"",@"fontSize":@(hotFontSize),@"color":hotColor}]];
            }
        } else if ([type hasPrefix:@"url"]) {
            //链接link
            NSString * url  = value;
            if (url.length) {
                UIColor *linkColor = [UIColor qim_colorWithHex:0x336cd5];
                [storages addObject:[self parseLinkRunFromDictinary:@{@"content":url?url:@"",@"fontSize":@(kWorkMomentTextFontSize),@"color":linkColor,@"linkUrl":url?url:@"",@"range":NSStringFromRange(match.range)}]];
            }
        }
        //at me
        else if ([type hasPrefix:@"atStrType"]) {
            NSString * content = [NSString stringWithFormat:@"@%@",[[QIMKit sharedInstance] getMyNickName]];
            if (content.length) {
                UIColor * textColor = [UIColor redColor];
                [storages addObject:[self parseTextStorageFromDictinary:@{@"content":content?content:@"",@"fontSize":@(kWorkMomentTextFontSize),@"color":textColor,@"range":NSStringFromRange(match.range)}]];
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
            NSString * pkId = objInfoDic[@"width"];
            
            NSString * imageName  =  [[QIMEmotionManager sharedInstance] getEmotionImagePathForShortCut:value withPackageId:pkId];
            BOOL hasEmotion = YES;
            if ((imageName == nil) && ([imageName length] == 0)) {
                hasEmotion = NO;
            }
            QIMImage * emotionImage = nil;
            CGSize emotionImageSize = CGSizeZero;
            if ([imageName length] > 0) {
                NSData *imageData = [NSData dataWithContentsOfFile:imageName];
                emotionImage = [QIMImage imageWithData:imageData scale:0.5];
                emotionImageSize = CGSizeMake(emotionImage.size.width/2.0f, emotionImage.size.height/2.0f);
            }
            if (!emotionImage) {
                NSData *imageData = [[QIMEmotionManager sharedInstance] getEmotionThumbIconDataWithImageStr:imageName];
                emotionImage = [QIMImage imageWithData:imageData scale:0.5];
                emotionImageSize = CGSizeMake(48, 48);
            }
            if (!emotionImage) {
                [[QIMEmotionManager sharedInstance] getEmotionImageFromHttpForPkId:pkId shortcut:value signKey:msgId];
                hasEmotion = NO;
            }
            
            CGSize size = CGSizeEqualToSize(emotionImageSize, CGSizeZero) ? emotionImage.size : emotionImageSize;
            if (hasEmotion && ![pkId isEqualToString:@"EmojiOne"]) {
                if (emotionImage) {
                    if (size.width >= ([UIScreen mainScreen].bounds.size.width / 2.0f) || size.height >= ([UIScreen mainScreen].bounds.size.height / 2.0f)) {
                        [storages addObject:[self parseEmotionFromDictinary:@{@"image":emotionImage,@"infoDic":@{@"signKey":msgId,@"pkId":pkId?pkId:@"noPkId",@"shortCut":value?value:@""},@"width":@(size.width*0.3),@"height":@(size.height*0.3),@"range":NSStringFromRange(match.range)}]];
                    } else if (size.width >= ([UIScreen mainScreen].bounds.size.width / 3.0f) || size.height >= ([UIScreen mainScreen].bounds.size.height / 3.0f)) {
                        [storages addObject:[self parseEmotionFromDictinary:@{@"image":emotionImage,@"infoDic":@{@"signKey":msgId,@"pkId":pkId?pkId:@"noPkId",@"shortCut":value?value:@""},@"width":@(size.width*0.2),@"height":@(size.height*0.2),@"range":NSStringFromRange(match.range)}]];
                    } else {
                        [storages addObject:[self parseEmotionFromDictinary:@{@"image":emotionImage,@"infoDic":@{@"signKey":msgId,@"pkId":pkId?pkId:@"noPkId",@"shortCut":value?value:@""},@"width":@(size.width),@"height":@(size.height),@"range":NSStringFromRange(match.range)}]];
                    }
                }
            } else if (hasEmotion && [pkId isEqualToString:@"EmojiOne"]) {
                if (emotionImage) {
                    [storages addObject:[self parseEmotionFromDictinary:@{@"image":emotionImage,@"infoDic":@{@"signKey":msgId,@"pkId":pkId?pkId:@"noPkId",@"shortCut":value?value:@""},@"width":@(24),@"height":@(24),@"range":NSStringFromRange(match.range)}]];
                }
            } else {
                [storages addObject:[self parseEmotionFromDictinary:@{@"infoDic":@{@"signKey":msgId,@"pkId":pkId?pkId:@"noPkId",@"shortCut":value?value:@""},@"width":@(24),@"height":@(24),@"range":NSStringFromRange(match.range)}]];
            }
        }
        startLoc = match.range.location + match.range.length;
    }
    
    //处理 特殊类型后的普通字符串 未被处理 BUG
    if (startLoc < msg.length) {
        NSString * tStr = [msg substringFromIndex:startLoc];
        if (tStr.length) {
            [storages addObjectsFromArray:[self getStoragesForTextString:tStr msgDirection:direction]];
        }
    }
    
    return storages;
}

+ (NSArray *)storagesFromMessage:(QIMMessageModel *)message {
    return [self storagesWithContent:message.message WithMsgId:message.messageId WithDirection:message.messageDirection];
}

+ (NSArray *)getStoragesForTextString:(NSString *)tStr msgDirection:(QIMMessageDirection) direction {
    
    UIColor * textColor = [UIColor qim_colorWithHex:0x333333];
    NSString *content = @"";
    NSInteger startLoc = 0;
    NSMutableArray *storages = [NSMutableArray arrayWithCapacity:1];
        //文本中解析URL和PhoneNumber
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:tStr options:0 range:NSMakeRange(0, [tStr length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange tstrRange = NSMakeRange(startLoc, [match range].location - startLoc);
        NSString *textStr = [tStr substringWithRange:tstrRange];
        if (textStr.length > 0) {
            [storages addObject:[self parseTextStorageFromDictinary:@{@"content":textStr?textStr:@"",@"fontSize":@(kWorkMomentTextFontSize),@"color":textColor}]];
        }
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSString *url = [[match URL] absoluteString];
            NSRange urlRange = [match range];
            if (urlRange.location + urlRange.length <= tStr.length && urlRange.length + urlRange.location > 0) {
                UIColor *linkTextColor = [UIColor qim_colorWithHex:0x336cd5];
                [storages addObject:[self parseLinkRunFromDictinary:@{@"content":url?url:@"",@"fontSize":@(kWorkMomentTextFontSize),@"color":linkTextColor,@"linkUrl":url,@"range":NSStringFromRange(match.range)}]];
                startLoc = match.range.location + match.range.length;
            }
        } else {
            
        }
    }
    if (startLoc < tStr.length) {
        NSString *testStr = [tStr substringFromIndex:startLoc];
        if (testStr.length > 0) {
            [storages addObject:[self parseTextStorageFromDictinary:@{@"content":testStr?testStr:@"",@"fontSize":@(kWorkMomentTextFontSize),@"color":textColor}]];
        }
    }
    return storages;
}

+ (id<QCAppendTextStorageProtocol>)parseTextStorageFromDictinary:(NSDictionary *)dic
{
    QIMTextStorage *textStorage = [[QIMTextStorage alloc]init];
    textStorage.text = dic[@"content"];
    float fontSize = [dic[@"fontSize"] floatValue];
    if (fontSize > 0) {
        textStorage.font = [UIFont systemFontOfSize:fontSize];
    }
    textStorage.textColor = dic[@"color"];
    
    return textStorage;
}

+ (id<QIMDrawStorageProtocol>)parseImageRunFromDictinary:(NSDictionary *)dic
{
    QIMImageStorage *imageStorage = [[QIMImageStorage alloc]init];
    imageStorage.imageURL = [NSURL URLWithString:dic[@"httpUrl"]];
    imageStorage.size = CGSizeMake([dic[@"width"] floatValue], [dic[@"height"] floatValue]);
    imageStorage.storageType = QIMImageStorageTypeImage;
    return imageStorage;
}

+ (id<QIMDrawStorageProtocol>)parseEmotionFromDictinary:(NSDictionary *)dic
{
    QIMImageStorage *imageStorage = [[QIMImageStorage alloc]init];
    imageStorage.emotionImage = dic[@"image"];
    imageStorage.imageAlignment = QCImageAlignmentRight;
    imageStorage.size = CGSizeMake([dic[@"width"] floatValue], [dic[@"height"] floatValue]);
    imageStorage.infoDic = dic[@"infoDic"];
    imageStorage.storageType = QIMImageStorageTypeEmotion;
    return imageStorage;
}

+ (id<QCAppendTextStorageProtocol>)parseLinkRunFromDictinary:(NSDictionary *)dic
{
    QIMLinkTextStorage *linkStorage = [[QIMLinkTextStorage alloc]init];
    linkStorage.text = dic[@"content"];
    float fontSize = [dic[@"fontSize"] floatValue];
    if (fontSize > 0) {
        linkStorage.font = [UIFont systemFontOfSize:fontSize];
    }
    linkStorage.textColor = dic[@"color"];
    linkStorage.linkData = dic[@"linkUrl"];
    
    return linkStorage;
}

+ (id<QCAppendTextStorageProtocol>)parsePhoneNumberRunFromDictionary:(NSDictionary *)dic {
    
    QIMPhoneNumberTextStorage *phoneNumberStorage = [[QIMPhoneNumberTextStorage alloc] init];
    phoneNumberStorage.text = dic[@"content"];
    float fontSize = [dic[@"fontSize"] floatValue];
    if (fontSize > 0) {
        phoneNumberStorage.font = [UIFont systemFontOfSize:fontSize];
    }
    phoneNumberStorage.textColor = dic[@"phoneNumColor"];
    phoneNumberStorage.phoneNumData = dic[@"content"];
    return phoneNumberStorage;
}

+ (NSDictionary *)getObjectInfoFromString:(NSString *)string{
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
                [infoDic setQIMSafeObject:[self delQuoteForString:value] forKey:[self delQuoteForString:itemArr.firstObject]];
            }
        }
    }
    return infoDic;
}

//去引号
+ (NSString *)delQuoteForString:(NSString *)str{
    if (str.length > 1 && [str hasPrefix:@"\""] && [str hasSuffix:@"\""]) {
        NSString * sss = [str substringWithRange:NSMakeRange(1, str.length - 2)];
        return sss;
    }else{
        return str;
    }
}

@end

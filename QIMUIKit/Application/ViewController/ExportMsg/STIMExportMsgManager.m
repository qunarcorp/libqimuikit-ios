//
//  STIMExportMsgManager.m
//  STChatIphone
//
//  Created by haibin.li on 2016/08/26.
//
//

#define kMsgTemplateForHtml_PageHeader \
    @"<div id=\"pageheader\" style=\"height:20px;width:auto;\"> \
        <div style=\"margin-left:10px;margin-top:10px;height:1px;width:auto;background-color:#d1d1d1;\"></div> \
        <div style=\"margin:0 auto;margin-top:-10px;height:20px;width:150px;background-color:#f4f4f4;color:black;text-align:center;\">[MSGLISTDATE]</div> \
    </div>"

#define kMsgTemplateForHtml_SepLine \
    @"<div id=\"sepline\" style=\"margin-left:65px;margin-top:10px;height:1px;width:auto;background-color:#e3e3e3;\"></div>"

#define kMsgTemplateForHtml_Message \
    @"<img id=\"headerImg\" src=\"[MSGFROMIMG]\" style=\"margin-left:5px;margin-top:5px;background-color:#f4f4f4;height:30px;width:30px;float:left;\" alt=\"head img\"> \
    <div id=\"messageInfo\" style=\"margin-left:45px;margin-top:5px;background-color:#333333;height:[MSGVIEWHEIGHT];width:auto;display:inline\"> \
        <div id=\"msgfrom\" style=\"margin-left:10px;margin-top:5px;height:20px;width:auto;float:left;\">[MSGFROMNAME]</div> \
        <div id=\"msgtime\" style=\"margin-left:10px;margin-top:5px;height:20px;width:auto;text-align:right;float:right;\">[MSGTIME]</div> \
        <div id=\"messagetext\" style=\"margin-left:45px;margin-top:10px;height:auto;width:auto;\"> \
            [MSGTEXT]</div> \
    </div>"

#define kMsgTemplateForHtml_IMG @"<img id=\"msgImg\" src=\"[MSGIMGSRC]\" style=\"max-width:250px\" alt=\"[MSGIMGALT]\">"
#define kMsgTemplateForHtml_LINK @"<a href=\"[MSGLINKURL]\">[MSGLINKTEXT]</a>"

#define kMsgTemplateForHtml_Body  \
    @"<div id=\"message\" style=\"width:100%;float:left;\">[MSGSEPLINE][MSGBODY]</div>"

#define kMsgTemplateForHtml_Header \
    @"<!DOCTYPE html> \
        <html> \
        <title>[HTMLTITLE]</title> \
        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /> \
        <meta content=\"width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no,minimal-ui\" name=\"viewport\" /> \
        <meta name=\"apple-mobile-web-app-capable\" content=\"yes\" /> \
        <style type=\"text/css\"> \
        </style> \
        <body bgcolor=#f4f4f4> \
        <div id=\"container\" style=\"width:auto;min-width=300px\">[MSGLIST]</div></body></html>"


#import "STIMExportMsgManager.h"
#import "STIMMessageParser.h"
#import "STIMTextContainer.h"
#import "STIMJSONSerializer.h"

@implementation STIMExportMsgManager

+ (NSString *)parseForJsonStrFromMsgList:(NSArray *)msgList withTitle:(NSString *)title{
    NSMutableArray * jsonStrArr = [NSMutableArray arrayWithCapacity:1];
    for (STIMMessageModel * msg in msgList) {
        NSNumber * type = @(msg.messageType);
        NSString *body = msg.message;
        if ([[STIMKit sharedInstance] getRegisterMsgCellClassForMessageType:msg.messageType]) {
            
            body = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
        }
        NSDictionary * userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:msg.from];
        NSString * nickName = userInfo[@"Name"]?userInfo[@"Name"]:msg.from;
        NSNumber * direction = @(msg.messageDirection + 1);
        NSNumber * stamp = @(msg.messageDate);
        if (!body) {
            STIMVerboseLog(@"body Empty");
        }
        [jsonStrArr addObject:@{@"t":type,@"b":body?body:@"",@"n":nickName?nickName:@"",@"d":direction,@"s":stamp}];
    }
    NSString *jsonStr = [[STIMJSONSerializer sharedInstance] serializeObject:jsonStrArr];
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:@"msglistExportPath"];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",title]];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    [jsonStr writeToFile:resourcePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return resourcePath;
}

+ (NSString *)exportMsgList:(NSArray *)msgList withTitle:(NSString *)title{
    NSString * msgListStr = @"";
    NSString * dateFrom = [[[NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:[(STIMMessageModel *)msgList.firstObject messageDate]] stimDB_formattedDateDescription] componentsSeparatedByString:@" "].firstObject;
    NSString * dateTo = [[[NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:[(STIMMessageModel *)msgList.lastObject messageDate]] stimDB_formattedDateDescription] componentsSeparatedByString:@" "].firstObject;
    NSString * firstTitle = [dateFrom isEqualToString:dateTo]?dateFrom:[NSString stringWithFormat:@"%@~%@",dateFrom,dateTo];
    for (STIMMessageModel * msg in msgList) {
        msgListStr = [msgListStr stringByAppendingString:[self htmlStrForMsg:msg firstTitle:[msgList indexOfObject:msg] == 0?firstTitle:nil]];
    }
    NSString * msgListHtml = kMsgTemplateForHtml_Header;
    msgListHtml = [msgListHtml stringByReplacingOccurrencesOfString:@"[HTMLTITLE]" withString:title];
    msgListHtml = [msgListHtml stringByReplacingOccurrencesOfString:@"[MSGLIST]" withString:msgListStr];
    
    
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:@"msglistExportPath"];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.html",title,firstTitle]];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    [msgListHtml writeToFile:resourcePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return resourcePath;

}

+ (NSString *)htmlStrForMsg:(STIMMessageModel *)msg firstTitle:(NSString *)firstTitle {
    NSString * msgSepLineHtmlStr = firstTitle.length?kMsgTemplateForHtml_PageHeader:kMsgTemplateForHtml_SepLine;
    if (firstTitle.length) {
        msgSepLineHtmlStr = [msgSepLineHtmlStr stringByReplacingOccurrencesOfString:@"[MSGLISTDATE]" withString:[NSString stringWithFormat:@"%@",firstTitle]];
    }
    
    NSString * msgBodyHtmlStr = kMsgTemplateForHtml_Message;
    msgBodyHtmlStr = [msgBodyHtmlStr stringByReplacingOccurrencesOfString:@"[MSGVIEWHEIGHT]" withString:@"auto"];
    NSDictionary * userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:msg.from];
    NSString *headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:userInfo[@"XmppId"]];
    msgBodyHtmlStr = [msgBodyHtmlStr stringByReplacingOccurrencesOfString:@"[MSGFROMIMG]" withString:headerUrl?headerUrl:@""];
    msgBodyHtmlStr = [msgBodyHtmlStr stringByReplacingOccurrencesOfString:@"[MSGFROMNAME]" withString:userInfo[@"Name"]?userInfo[@"Name"]:msg.from];
    
    NSString * msgTime = [[NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:msg.messageDate] stimDB_formattedDateDescription];
    
    msgBodyHtmlStr = [msgBodyHtmlStr stringByReplacingOccurrencesOfString:@"[MSGTIME]" withString:[NSString stringWithFormat:@"%@",msgTime]];
    msgBodyHtmlStr = [msgBodyHtmlStr stringByReplacingOccurrencesOfString:@"[MSGTEXT]" withString:[self getMsgTextForMsg:msg]];
    
    NSString * htmlStr = kMsgTemplateForHtml_Body;
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"[MSGSEPLINE]" withString:msgSepLineHtmlStr];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"[MSGBODY]" withString:msgBodyHtmlStr];
    
    return htmlStr;
}

+ (NSString *)getMsgTextForMsg:(STIMMessageModel *)msg {
    NSString * msgText = @"";
    STIMTextContainer * textContainer = [STIMMessageParser textContainerForMessage:msg fromCache:YES];
    for (id textStorage in [textContainer textStorages]) {
        if ([textStorage isMemberOfClass:[STIMLinkTextStorage class]]) {
            NSString * link = kMsgTemplateForHtml_LINK;
            link = [link stringByReplacingOccurrencesOfString:@"[MSGLINKURL]" withString:[textStorage linkData]];
            link = [link stringByReplacingOccurrencesOfString:@"[MSGLINKTEXT]" withString:[textStorage linkData]];
            msgText = [msgText stringByAppendingString:link];
        } else if ([textStorage isMemberOfClass:[STIMTextStorage class]]) {
            msgText = [msgText stringByAppendingString:[textStorage text]];
        } else if ([textStorage isMemberOfClass:[STIMImageStorage class]]) {
            NSString * imgStr = kMsgTemplateForHtml_IMG;
            if ([(STIMImageStorage *)textStorage storageType] == STIMImageStorageTypeEmotion) {
                NSDictionary * infoDic = [(STIMImageStorage *)textStorage infoDic];
                NSString * pkId = infoDic[@"pkId"];
                NSString * shortcut = infoDic[@"shortCut"];
                NSString * urlStr = nil;
                if (pkId.length) {
                    urlStr = [NSString stringWithFormat:@"%@/file/v2/emo/d/e/%@/%@/%@?u=%@&k=%@",
                              [[STIMKit sharedInstance] qimNav_InnerFileHttpHost],
                              pkId,
                              shortcut,
                              @"org",
                              [[STIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                              [[STIMKit sharedInstance] myRemotelogginKey]];//org或者fixed
                }else{
                    //兼容老版本
                    urlStr = [NSString stringWithFormat:@"%@/file/v2/emo/d/oe/%@/%@?u=%@&k=%@",
                           [[STIMKit sharedInstance] qimNav_InnerFileHttpHost],
                           shortcut,
                           @"org",
                           [[STIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           [[STIMKit sharedInstance] myRemotelogginKey]];//org或者fixed
                }
                imgStr = [imgStr stringByReplacingOccurrencesOfString:@"[MSGIMGSRC]" withString:urlStr];
                imgStr = [imgStr stringByReplacingOccurrencesOfString:@"[MSGIMGALT]" withString:@"[表情]"];
            }else{
                imgStr = [imgStr stringByReplacingOccurrencesOfString:@"[MSGIMGSRC]" withString:[[textStorage imageURL] absoluteString]];
                imgStr = [imgStr stringByReplacingOccurrencesOfString:@"[MSGIMGALT]" withString:[NSBundle stimDB_localizedStringForKey:@"[Photo]"]];//@"[图片]"];
            }
            msgText = [msgText stringByAppendingString:imgStr];
        }
    }
    return msgText;
}

@end

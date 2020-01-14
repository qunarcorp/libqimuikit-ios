//
//  STIMMessageTextAttachment.m
//  STChatIphone
//
//  Created by 李海彬 on 2018/4/4.
//

#import "STIMMessageTextAttachment.h"
#import "STIMEmojiTextAttachment.h"
#import "STIMATGroupMemberTextAttachment.h"

@implementation STIMMessageTextAttachment

static STIMMessageTextAttachment *_attachmentManager = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _attachmentManager = [[STIMMessageTextAttachment alloc] init];
    });
    return _attachmentManager;
}

- (NSString *)getStringFromAttributedString:(NSAttributedString *)attributedString WithOutAtInfo:(NSMutableArray **)outAtInfo {
    //最终纯文本
    NSMutableString *plainString = [NSMutableString stringWithString:attributedString.string];
    //替换下标的偏移量
    __block NSUInteger base = 0;
    
    *outAtInfo = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *atInfoDic = [NSMutableDictionary dictionaryWithCapacity:3];
    NSMutableArray *atInfoList = [NSMutableArray array];
    [atInfoDic setSTIMSafeObject:atInfoList forKey:@"data"];
    [atInfoDic setSTIMSafeObject:@(10001) forKey:@"type"];
    [*outAtInfo addObject:atInfoDic];
    //遍历
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value && [value isKindOfClass:[STIMEmojiTextAttachment class]]) {
            //替换
            [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                       withString:[((STIMEmojiTextAttachment *) value) getSendText]];
            
            //增加偏移量
            base += [((STIMEmojiTextAttachment *) value) getSendText].length - 1;
        } else if (value && [value isKindOfClass:[STIMATGroupMemberTextAttachment class]]) {
            NSMutableDictionary *atDic = [NSMutableDictionary dictionary];
            [atDic setSTIMSafeObject:[(STIMATGroupMemberTextAttachment *)value groupMemberName] forKey:@"text"];
            [atDic setSTIMSafeObject:[(STIMATGroupMemberTextAttachment *)value groupMemberJid] forKey:@"jid"];
            [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:[(STIMATGroupMemberTextAttachment *)value groupMemberName]];
            [atInfoList addObject:atDic];
            base += [((STIMATGroupMemberTextAttachment *) value) getSendText].length - 1;
        }
    }];
    if (atInfoList.count <= 0) {
        *outAtInfo = nil;
    }
    plainString = [NSMutableString stringWithString:[plainString stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""]];
    return plainString;
}

@end

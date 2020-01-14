//
//  STIMNotifyView.m
//  STChatIphone
//
//  Created by 李海彬 on 2018/2/24.
//

#import "STIMNotifyView.h"
#import "STIMAttributedLabel.h"
#import "ASIHTTPRequest.h"
#import "STIMJSONSerializer.h"
#import "STIMHTTPRequest.h"
#import "STIMHTTPClient.h"

@interface STIMNotifyView () <STIMAttributedLabelDelegate>

@property (nonatomic, strong) STIMAttributedLabel *attributeLabel;

@property (nonatomic, strong) NSDictionary *notifyMsg;

@property (nonatomic, strong) UIButton *closeBtn;
//title_close@2x

@end

@implementation STIMNotifyView

static STIMNotifyView *_notifyView = nil;

+ (instancetype)sharedNotifyViewWithMessage:(NSDictionary *)message {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _notifyView = [[STIMNotifyView alloc] initWithNotifyMessage:message];
    });
    if (![_notifyView.notifyMsg isEqual:message]) {
        [_notifyView removeAllSubviews];
        [_notifyView setMessage:message];
    }
    return _notifyView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setBackgroundColor:[UIColor qtalkChatBgColor]];
        _closeBtn.frame = CGRectMake(SCREEN_WIDTH - 45, 0, 21, 21);
        _closeBtn.layer.cornerRadius = CGRectGetWidth(_closeBtn.frame) / 2.0f;
        _closeBtn.layer.masksToBounds = YES;
        [_closeBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"title_close"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"title_close"] forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(closeNotifView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)setMessage:(NSDictionary *)message {
    if (message) {
        self.notifyMsg = message;
        [self setupTextAttributedLabel];
        [self addSubview:self.closeBtn];
        self.closeBtn.centerY = self.centerY;
    }
}

- (instancetype)initWithNotifyMessage:(NSDictionary *)message {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor stimDB_colorWithHex:0xf8fbdf];
        [self setMessage:message];
        /*
        self.notifyMsg = message;
        [self setupTextAttributedLabel];
        [self addSubview:self.closeBtn];
        self.closeBtn.centerY = self.centerY;
         */
    }
    return self;
}

- (void)setupTextAttributedLabel {
    STIMAttributedLabel *label = [[STIMAttributedLabel alloc] init];
    label.backgroundColor = [UIColor stimDB_colorWithHex:0xf8fbdf];
    label.delegate = self;
    NSArray *textArray = [self.notifyMsg objectForKey:@"noticeStr"];
    NSInteger textRange = 0;
    NSMutableString *mutableStr = [NSMutableString stringWithFormat:@""];
    NSMutableArray *textRunArray = [NSMutableArray array];
    for (NSDictionary *textDic in textArray) {
        NSString *textType = [textDic objectForKey:@"type"];
        NSString *str = [textDic objectForKey:@"str"];
        NSString *strColor = [textDic objectForKey:@"strColor"];
        if ([textType isEqualToString:@"link"] || [textType isEqualToString:@"newChat"] || [textType isEqualToString:@"request"]) {
            strColor = [@"#03A9F4" stringByReplacingOccurrencesOfString:@"#" withString:@""];
            STIMLinkTextStorage *linkTextStorage = [[STIMLinkTextStorage alloc] init];
            linkTextStorage.text = str;
            linkTextStorage.range = NSMakeRange(textRange, str.length);
            linkTextStorage.font = [UIFont systemFontOfSize:14];
            linkTextStorage.textColor = [UIColor stimDB_colorWithHexString:strColor];
            linkTextStorage.linkData = textDic;
            linkTextStorage.underLineStyle = kCTUnderlineStyleNone;
            linkTextStorage.modifier = NSDirectPredicateModifier;
            [textRunArray addObject:linkTextStorage];
            textRange += str.length;
            [mutableStr appendString:str];
        } else if ([textType isEqualToString:@"text"]) {
            STIMTextStorage *textStorage = [[STIMTextStorage alloc] init];
            textStorage.text = str;
            textStorage.range = NSMakeRange(textRange, str.length);
            textStorage.textColor = [UIColor stimDB_colorWithHexString:strColor];
            textStorage.font = [UIFont systemFontOfSize:14];
            [textRunArray addObject:textStorage];
            textRange += str.length;
            [mutableStr appendString:str];
        } else {
            STIMTextStorage *textStorage = [[STIMTextStorage alloc] init];
            textStorage.text = str;
            textStorage.range = NSMakeRange(textRange, str.length);
            textStorage.textColor = [UIColor stimDB_colorWithHexString:strColor];
            textStorage.font = [UIFont systemFontOfSize:14];
            [textRunArray addObject:textStorage];
            textRange += str.length;
            [mutableStr appendString:str];
        }
    }
    [label setText:mutableStr];
    label.numberOfLines = 0;
    label.isWidthToFit = YES;
    [label addTextStorageArray:textRunArray];
    [label setFrameWithOrign:CGPointMake(20, 0) Width:SCREEN_WIDTH - 80];
    _attributeLabel = label;
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, label.height);
    [self addSubview:_attributeLabel];
    STIMVerboseLog(@"self.notifyMsg : %@", self.notifyMsg);
}

#pragma mark - STIMAttributedLabelDelegate

// 点击代理
- (void)attributedLabel:(STIMAttributedLabel *)attributedLabel textStorageClicked:(id<STIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    if ([textStorage isKindOfClass:[STIMLinkTextStorage class]]) {
        STIMLinkTextStorage *linkTextStorage = (STIMLinkTextStorage *)textStorage;
        NSDictionary *linkData = linkTextStorage.linkData;
        STIMVerboseLog(@"linkData : %@", linkData);
        NSString *type = [linkData objectForKey:@"type"];
        if ([type isEqualToString:@"request"]) {
            NSString *url = [linkData objectForKey:@"url"];
            if (url) {
                
                STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
                [request setTimeoutInterval:10];
                [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
                    if (response.code == 200) {
                        NSData *data = response.data;
                        NSDictionary *requestDic = [[STIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
                        BOOL ret = [[requestDic objectForKey:@"ret"] boolValue];
                        if (ret) {
                            NSDictionary *data = [requestDic objectForKey:@"data"];
                            if (data.count) {
                                NSString *type = [data objectForKey:@"type"];
                                if ([type isEqualToString:@"link"]) {
                                    NSString *desc = [data objectForKey:@"desc"];
                                    NSString *url = [data objectForKey:@"url"];
                                    if (url) {
                                        STIMVerboseLog(@"Notify Link请求回来的url为%@，准备跳转url", url);
                                        [STIMFastEntrance openWebViewForUrl:url showNavBar:YES];
                                    } else {
                                        STIMVerboseLog(@"Notify Link请求回来的url为空，不做任何跳转");
                                    }
                                } else if ([type isEqualToString:@"newChat"]) {
                                    
                                    NSString *desc = [data objectForKey:@"desc"];
                                    NSString *from = [data objectForKey:@"from"];
                                    NSString *to = [data objectForKey:@"to"];
                                    NSString *realFrom = [data objectForKey:@"realFrom"];
                                    NSString *realTo = [data objectForKey:@"realTo"];
                                    NSInteger chatType = [[data objectForKey:@"consult"] integerValue];
                                    BOOL isConsult = [[data objectForKey:@"isConsult"] boolValue];
                                    if (isConsult) {
                                        if (chatType == ChatType_Consult) {
                                            [STIMFastEntrance openConsultChatByChatType:ChatType_Consult UserId:realTo WithVirtualId:to];
                                        } else {
                                            [STIMFastEntrance openConsultChatByChatType:ChatType_ConsultServer UserId:realTo WithVirtualId:to];
                                        }
                                    } else {
                                        [STIMFastEntrance openSingleChatVCByUserId:realFrom];
                                    }
                                    [self closeNotifView];
                                } else {
                                    
                                }
                            }
                        }
                        STIMVerboseLog(@"%@", requestDic);
                    }
                } failure:^(NSError *error) {
                    
                }];
                
                /*
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
                [request setTimeOutSeconds:10];
                [request startSynchronous];
                NSError *error = [request error];
                if ([request responseStatusCode] == 200 && !error) {
                    NSData *data = [request responseData];
                    NSDictionary *requestDic = [[STIMJSONSerializer sharedInstance] deserializeObject:data error:nil]; */
                    /*
                    requestDic = @{
                                   @"ret":@(YES),
                                   @"data" : @{
                                           @"desc":@"这一段是link",
                                           @"type":@"link",
                                           @"url":@"www.baidu.com"
                                           }
                                   };
                    requestDic = @{
                                   @"ret":@(YES),
                                   @"data" : @{
                                           @"desc":@"这一段是跳转",
                                           @"type":@"newChat",
                                           @"from":@"lilulucas.li@ejabhost1",
                                           @"to":@"shop323@ejabhost1",
                                           @"realFrom":@"lilulucas.li@ejabhost1",
                                           @"realTo":@"huajun.liu@ejabhost1",
                                           @"isConsult":@(YES),
                                           @"consult":@"5"
                                           }
                                   };
                    requestDic = @{
                                   @"ret":@(YES),
                                   @"data" : @{
                                           @"desc":@"这一段是跳转",
                                           @"type":@"newChat",
                                           @"from":@"lilulucas.li@ejabhost1",
                                           @"to":@"shop323@ejabhost1",
                                           @"realFrom":@"lilulucas.li@ejabhost1",
                                           @"realTo":@"huajun.liu@ejabhost1",
                                           @"isConsult":@(YES),
                                           @"consult":@"4"
                                           }
                                   };
                     */
                    /*
                    BOOL ret = [[requestDic objectForKey:@"ret"] boolValue];
                    
                    if (ret) {
                        NSDictionary *data = [requestDic objectForKey:@"data"];
                        if (data.count) {
                            NSString *type = [data objectForKey:@"type"];
                            if ([type isEqualToString:@"link"]) {
                                NSString *desc = [data objectForKey:@"desc"];
                                NSString *url = [data objectForKey:@"url"];
                                if (url) {
                                    STIMVerboseLog(@"Notify Link请求回来的url为%@，准备跳转url", url);
                                    [STIMFastEntrance openWebViewForUrl:url showNavBar:YES];
                                } else {
                                    STIMVerboseLog(@"Notify Link请求回来的url为空，不做任何跳转");
                                }
                            } else if ([type isEqualToString:@"newChat"]) {
                                
                                NSString *desc = [data objectForKey:@"desc"];
                                NSString *from = [data objectForKey:@"from"];
                                NSString *to = [data objectForKey:@"to"];
                                NSString *realFrom = [data objectForKey:@"realFrom"];
                                NSString *realTo = [data objectForKey:@"realTo"];
                                NSInteger chatType = [[data objectForKey:@"consult"] integerValue];
                                BOOL isConsult = [[data objectForKey:@"isConsult"] boolValue];
                                if (isConsult) {
                                    if (chatType == ChatType_Consult) {
                                        [STIMFastEntrance openConsultChatByChatType:ChatType_Consult UserId:realTo WithVirtualId:to];
                                    } else {
                                        [STIMFastEntrance openConsultChatByChatType:ChatType_ConsultServer UserId:realTo WithVirtualId:to];
                                    }
                                } else {
                                    [STIMFastEntrance openSingleChatVCByUserId:realFrom];
                                }
                                [self closeNotifView];
                            } else {
                                
                            }
                        }
                    }
                    STIMVerboseLog(@"%@", requestDic);
                }*/
            }
        } else if ([type isEqualToString:@"newChat"]) {
            NSInteger chatType = [[linkData objectForKey:@"consult"] integerValue];
            NSString *from = [linkData objectForKey:@"from"];
            NSString *realFrom = [linkData objectForKey:@"realFrom"];
            NSString *realTo = [linkData objectForKey:@"realTo"];
            NSString *to = [linkData objectForKey:@"to"];
            BOOL isConsult = [[linkData objectForKey:@"isConsult"] boolValue];
            if (isConsult) {
                if (chatType == ChatType_Consult) {
                    [STIMFastEntrance openConsultChatByChatType:ChatType_Consult UserId:realTo WithVirtualId:to];
                } else {
                    [STIMFastEntrance openConsultChatByChatType:ChatType_ConsultServer UserId:realFrom WithVirtualId:from];
                }
            } else {
                [STIMFastEntrance openSingleChatVCByUserId:realFrom];
            }
            [self closeNotifView];
        } else if ([type isEqualToString:@"link"]) {
            NSString *url = [linkData objectForKey:@"url"];
            if (url) {
                [STIMFastEntrance openWebViewForUrl:url showNavBar:YES];
            }
        }
    } else {
        
    }
}

// 长按代理 有多个状态 begin, changes, end 都会调用,所以需要判断状态
- (void)attributedLabel:(STIMAttributedLabel *)attributedLabel textStorageLongPressed:(id<STIMTextStorageProtocol>)textStorage onState:(UIGestureRecognizerState)state atPoint:(CGPoint)point {
}

- (void)closeNotifView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyViewCloseNotification object:self];
    });
}

@end

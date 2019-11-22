//
//  STIMSingleChatImageTools.m
//  DangDiRen
//
//  Created by 平 薛 on 14-4-23.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "STIMSingleChatImageTools.h"
static STIMSingleChatImageTools *__global_chat_image_tools = nil;
@implementation STIMSingleChatImageTools{
    UIImage *_sentImageBg;
    UIImage *_receivedImageBg;
    UIImage *_downFaildImage_Receive;
    UIImage *_downFaildImage_Sent;
    UIImage *_downingImage;
}

+ (STIMSingleChatImageTools *)sharedInstance{
    if (__global_chat_image_tools == nil) {
        __global_chat_image_tools = [[STIMSingleChatImageTools alloc] init];
    }
    return __global_chat_image_tools;
}

- (id)init{
    self = [super init];
    if (self) {
        _sentImageBg = [[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"im_sent_msg_bg"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        _receivedImageBg = [[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"singleChatAddbg"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    }
    return self;
}

- (UIImage *)getSentBg{
    return _sentImageBg;
}
- (UIImage *)getReceivedBg{
    return _receivedImageBg;
}

- (UIImage *)getImageDownloadFaildWithDirect:(int)direct{
    if (direct == 0) {
        if (_downFaildImage_Sent == nil) {
            _downFaildImage_Sent = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:kImageDownloadFailImageFileName];
        }
        return _downFaildImage_Sent;
    } else {
        if (_downFaildImage_Receive == nil) {
            _downFaildImage_Receive = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:kImageDownloadFailImageFileName];
        }
        return _downFaildImage_Receive;
    }
}

- (UIImage *)getImageDownloading{
    if (_downingImage == nil) {
        _downingImage = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:kImageDownloadFailImageFileName];
    }
    return _downingImage;
}

@end

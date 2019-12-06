//
//  QIMChatBgManager.m
//  QIMUIKit
//
//  Created by admin on 2019/4/25.
//

#import "QIMChatBgManager.h"
#import "UIColor+QIMUtility.h"
#import <CommonCrypto/CommonDigest.h>

#define kChatBgHashSalt       @"kChatBgHashSalt"

@interface QIMChatBgManager ()

@property (nonatomic, strong) NSString *chatBgCachePath;

@end

@implementation QIMChatBgManager

static QIMChatBgManager *_chatBgManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chatBgManager = [[QIMChatBgManager alloc] init];
        _chatBgManager.chatBgCachePath = [UserCachesPath stringByAppendingPathComponent:@"ChatBg"];
        BOOL isDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_chatBgManager.chatBgCachePath isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_chatBgManager.chatBgCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return _chatBgManager;
}

- (NSString *)getChatBgSourcePath:(NSString *)fileName {
    fileName  = [NSString qim_hashString:fileName withSalt:kChatBgHashSalt];

    if (nil == fileName || [fileName length] == 0)
    {
        return nil;
    }
    // 获取resource文件路径
    NSString *resourcePath = [self.chatBgCachePath stringByAppendingPathComponent:fileName];

    return resourcePath;
}

- (void)deleteChatBgImageWithFileName:(NSString *)fileName {
    fileName = [NSString qim_hashString:fileName withSalt:kChatBgHashSalt];

    if (nil == fileName || [fileName length] == 0) {
        return;
    }
    // 获取resource文件路径
    NSString *resourcePath = [self.chatBgCachePath stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:resourcePath error:nil];
}

- (void)saveChatBgImageWithFileName:(NSString *)fileName imageData:(NSData *)data {
    fileName = [NSString qim_hashString:fileName withSalt:kChatBgHashSalt];

    if (nil == fileName || [fileName length] == 0) {
        return;
    }
    // 获取resource文件路径
    NSString *resourcePath = [self.chatBgCachePath stringByAppendingPathComponent:fileName];
    [data writeToFile:resourcePath atomically:YES];
}

- (void)getChatBgById:(NSString *)userId ByName:(NSString *)name WithReset:(BOOL)reset Complete:(void(^)(UIImage *bgImage)) complete {
    NSString *fileName = [[[NSString stringWithFormat:@"%@_%@_%@",userId,name?name:userId, [[QIMKit sharedInstance] AppBuildVersion]] dataUsingEncoding:NSUTF8StringEncoding] qim_md5String];
    NSString *filePath = [self.chatBgCachePath stringByAppendingPathComponent:fileName];
    if (reset == NO) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIImage *rstImage = [UIImage imageWithContentsOfFile:filePath];
            if (rstImage) {
                complete(rstImage);
                return;
            }
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGSize imageSize = CGSizeMake(500, 1000);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        //初始化信息
        CGFloat textCap = 155;
        UIFont *font = [UIFont systemFontOfSize:14];
        UIColor *bgColor = qim_chatWaterMaskBgColor;
        UIColor *textColor = qim_chatWaterMaskTextColor;
        CGFloat startY = - imageSize.height / 2.0;
        // 填充背景色
        [bgColor setFill];
        UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
        // 旋转画布
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
//        CGContextScaleCTM(bitmap, 1.0, -1.0);
        CGContextTranslateCTM(bitmap, 0, imageSize.height/2.0);
        double radius = - 30 * M_PI / 180;
        CGContextRotateCTM(bitmap, radius);
        // 绘制文字
        int row = 0;
        while (startY < imageSize.height * 1.5) {
            CGFloat startX = - imageSize.width/2.0;
            while (startX < imageSize.width * 1.5) {
                NSAttributedString *textAtt = [[NSAttributedString alloc] initWithString:(row%2==0?(name?name:userId):userId) attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
                [textAtt drawAtPoint:CGPointMake(startX, startY)];
                CGSize textSize = textAtt.size;
                startX += textSize.width + textCap;
            } 
            startY += 140;
            row++;
        }
        // 获取图片
        UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
        [UIImageJPEGRepresentation(newImage, 0.6) writeToFile:filePath atomically:NO];
        UIGraphicsEndImageContext();
        // 缓存文件
        dispatch_async(dispatch_get_main_queue(), ^{ 
            complete(newImage);
        });
    });
}

@end

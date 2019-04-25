//
//  ChatBgManager.m
//  QIMUIKit
//
//  Created by admin on 2019/4/25.
//

#import "ChatBgManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ChatBgManager

+ (NSString *)getMD5ByData:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (unsigned int) [data length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return imageHash;
}

+ (void)getChatBgById:(NSString *)userId ByName:(NSString *)name WithReset:(BOOL)reset Complete:(void(^)(UIImage *bgImage)) complete {
    NSString *fileName =  [self getMD5ByData:[[NSString stringWithFormat:@"%@_%@",userId,name] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
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
        CGFloat rowCap = 20;
        CGFloat textCap = 60;
        UIFont *font = [UIFont systemFontOfSize:16];
        UIColor *bgColor = [UIColor colorWithRed:0xea/255.0 green:0xea/255.0 blue:0xea/255.0 alpha:1];
        UIColor *textColor = [UIColor colorWithRed:0xbb/255.0 green:0xbb/255.0 blue:0xbb/255.0 alpha:1];
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
                NSAttributedString *textAtt = [[NSAttributedString alloc] initWithString:(row%2==0?name:userId) attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
                [textAtt drawAtPoint:CGPointMake(startX, startY)];
                CGSize textSize = textAtt.size;
                startX += textSize.width + textCap;
            } 
            startY += textCap + 16;
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

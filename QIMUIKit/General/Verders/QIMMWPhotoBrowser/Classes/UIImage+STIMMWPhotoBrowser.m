//
//  UIImage+STIMMWPhotoBrowser.m
//  Pods
//
//  Created by Michael Waterfall on 05/07/2015.
//
//

#import "UIImage+STIMMWPhotoBrowser.h"

@implementation UIImage (STIMMWPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:path ofType:type]];
}

+ (UIImage *)clearImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end

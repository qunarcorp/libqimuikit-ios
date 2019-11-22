//
//  UIImage+STIMMWPhotoBrowser.h
//  Pods
//
//  Created by Michael Waterfall on 05/07/2015.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (STIMMWPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle;
+ (UIImage *)clearImageWithSize:(CGSize)size;

@end

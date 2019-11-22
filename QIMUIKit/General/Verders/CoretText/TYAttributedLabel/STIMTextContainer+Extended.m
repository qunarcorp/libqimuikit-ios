//
//  STIMTextContainer+Extended.m
//  STIMAttributedLabelDemo
//
//  Created by tanyang on 15/6/7.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "STIMTextContainer.h"

@implementation STIMTextContainer (Link)

#pragma mark - addLink
- (void)addLinkWithLinkData:(id)linkData range:(NSRange)range
{
    [self addLinkWithLinkData:linkData linkColor:nil range:range];
}

- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor range:(NSRange )range;
{
    [self addLinkWithLinkData:linkData linkColor:linkColor underLineStyle:kCTUnderlineStyleSingle range:range];
}

- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle range:(NSRange )range
{
    STIMLinkTextStorage *linkTextStorage = [[STIMLinkTextStorage alloc]init];
    linkTextStorage.range = range;
    linkTextStorage.textColor = linkColor;
    linkTextStorage.linkData = linkData;
    linkTextStorage.underLineStyle = underLineStyle;
    [self addTextStorage:linkTextStorage];
}

#pragma mark - appendLink
- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkData:(id)linkData
{
    [self appendLinkWithText:linkText linkFont:linkFont linkColor:nil linkData:linkData];
}

- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor linkData:(id)linkData
{
    [self appendLinkWithText:linkText linkFont:linkFont linkColor:linkColor underLineStyle:kCTUnderlineStyleSingle linkData:linkData];
}

- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle linkData:(id)linkData
{
    STIMLinkTextStorage *linkTextStorage = [[STIMLinkTextStorage alloc]init];
    linkTextStorage.text = linkText;
    linkTextStorage.font = linkFont;
    linkTextStorage.textColor = linkColor;
    linkTextStorage.linkData = linkData;
    linkTextStorage.underLineStyle = underLineStyle;
    [self appendTextStorage:linkTextStorage];
}

@end

@implementation STIMTextContainer (UIImage)

#pragma mark addImage

- (void)addImageContent:(id)imageContent range:(NSRange)range size:(CGSize)size alignment:(QCDrawAlignment)alignment
{
    STIMImageStorage *imageStorage = [[STIMImageStorage alloc]init];
    if ([imageContent isKindOfClass:[UIImage class]]) {
        imageStorage.image = imageContent;
    }else if ([imageContent isKindOfClass:[NSString class]]){
        imageStorage.imageName = imageContent;
    } else {
        return;
    }
    
    imageStorage.drawAlignment = alignment;
    imageStorage.range = range;
    imageStorage.size = size;
    [self addTextStorage:imageStorage];
}

- (void)addImage:(UIImage *)image range:(NSRange)range size:(CGSize)size alignment:(QCDrawAlignment)alignment
{
    [self addImageContent:image range:range size:size alignment:alignment];
}

- (void)addImage:(UIImage *)image range:(NSRange)range size:(CGSize)size
{
    [self addImage:image range:range size:size alignment:QCDrawAlignmentTop];
}

- (void)addImage:(UIImage *)image range:(NSRange)range
{
    [self addImage:image range:range size:image.size];
}

- (void)addstimDB_imageNamedFromSTIMUIKitBundle:(NSString *)imageName range:(NSRange)range size:(CGSize)size alignment:(QCDrawAlignment)alignment
{
    [self addImageContent:imageName range:range size:size alignment:alignment];
}

- (void)addstimDB_imageNamedFromSTIMUIKitBundle:(NSString *)imageName range:(NSRange)range size:(CGSize)size
{
    [self addstimDB_imageNamedFromSTIMUIKitBundle:imageName range:range size:size alignment:QCDrawAlignmentTop];
}

- (void)addstimDB_imageNamedFromSTIMUIKitBundle:(NSString *)imageName range:(NSRange)range
{
    [self addstimDB_imageNamedFromSTIMUIKitBundle:imageName range:range size:CGSizeMake(self.font.pointSize, self.font.ascender)];
    
}

#pragma mark - appendImage

- (void)appendImageContent:(id)imageContent size:(CGSize)size alignment:(QCDrawAlignment)alignment
{
    STIMImageStorage *imageStorage = [[STIMImageStorage alloc]init];
    if ([imageContent isKindOfClass:[UIImage class]]) {
        imageStorage.image = imageContent;
    }else if ([imageContent isKindOfClass:[NSString class]]){
        imageStorage.imageName = imageContent;
    } else {
        return;
    }
    
    imageStorage.drawAlignment = alignment;
    imageStorage.size = size;
    [self appendTextStorage:imageStorage];
}

- (void)appendImage:(UIImage *)image size:(CGSize)size alignment:(QCDrawAlignment)alignment
{
    [self appendImageContent:image size:size alignment:alignment];
}

- (void)appendImage:(UIImage *)image size:(CGSize)size
{
    [self appendImage:image size:size alignment:QCDrawAlignmentTop];
}

- (void)appendImage:(UIImage *)image
{
    [self appendImage:image size:image.size];
}

- (void)appendstimDB_imageNamedFromSTIMUIKitBundle:(NSString *)imageName size:(CGSize)size alignment:(QCDrawAlignment)alignment
{
    [self appendImageContent:imageName size:size alignment:alignment];
}

- (void)appendstimDB_imageNamedFromSTIMUIKitBundle:(NSString *)imageName size:(CGSize)size
{
    [self appendstimDB_imageNamedFromSTIMUIKitBundle:imageName size:size alignment:QCDrawAlignmentTop];
}

- (void)appendstimDB_imageNamedFromSTIMUIKitBundle:(NSString *)imageName
{
    [self appendstimDB_imageNamedFromSTIMUIKitBundle:imageName size:CGSizeMake(self.font.pointSize, self.font.ascender)];
    
}

@end

@implementation STIMTextContainer (UIView)

#pragma mark - addView

- (void)addView:(UIView *)view range:(NSRange)range alignment:(QCDrawAlignment)alignment
{
    STIMViewStorage *viewStorage = [[STIMViewStorage alloc]init];
    viewStorage.drawAlignment = alignment;
    viewStorage.view = view;
    viewStorage.range = range;
    
    [self addTextStorage:viewStorage];
}

- (void)addView:(UIView *)view range:(NSRange)range
{
    [self addView:view range:range alignment:QCDrawAlignmentTop];
}

#pragma mark - appendView

- (void)appendView:(UIView *)view alignment:(QCDrawAlignment)alignment
{
    STIMViewStorage *viewStorage = [[STIMViewStorage alloc]init];
    viewStorage.drawAlignment = alignment;
    viewStorage.view = view;
    
    [self appendTextStorage:viewStorage];
}

- (void)appendView:(UIView *)view
{
    [self appendView:view alignment:QCDrawAlignmentTop];
}


@end

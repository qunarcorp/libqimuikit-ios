//
//  STIMMWPhoto.h
//  STIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import <Photos/Photos.h>
#import "STIMMWPhotoProtocol.h"

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to STIMMWPhotoProtocol
@interface STIMMWPhoto : NSObject <STIMMWPhoto>

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSData *photoData;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;
@property (nonatomic, strong) NSDictionary *extendInfo;
@property (nonatomic, strong) id photoMsg;

+ (STIMMWPhoto *)photoWithImage:(STIMImage *)image;
+ (STIMMWPhoto *)photoWithURL:(NSURL *)url;
+ (STIMMWPhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (STIMMWPhoto *)videoWithURL:(NSURL *)url; // Initialise video with no poster image

- (id)init;
- (id)initWithImage:(STIMImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (id)initWithVideoURL:(NSURL *)url;

@end


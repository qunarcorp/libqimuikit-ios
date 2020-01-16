//
//  QTImageAssetCell.m
//  STChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QTImageAssetCell.h"

#import "QTImageAssetView.h"

#import "QTImageAssetViewController.h"

#define kAssetViewTagPriex  10001

@interface QTImageAssetCell()<QTImageAssetViewDelegate>

@end

@implementation QTImageAssetCell

+ (CGFloat)getCellHeight{
    NSString *getCellHeight = @"getCellHeight";
    NSLog(getCellHeight);
    return kImageCap + imageItemWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    NSString *initWithStyle = @"initWithStyle";
    NSLog(initWithStyle);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        for (int i = 0; i < kColoumn; i++) {
            QTImageAssetView *assetView=[[QTImageAssetView alloc] initWithFrame:CGRectMake((imageItemWidth+kImageCap)*i, kImageCap, imageItemWidth, imageItemWidth)];
            [assetView setDelegate:self];
            [assetView setTag:kAssetViewTagPriex+i];
            [self.contentView addSubview:assetView];
        }
    }
    return self;
}

- (void)refreshUI{
    NSString *refreshUI = @"refreshUI";
    NSLog(refreshUI);
    for (int i = 0; i < kColoumn; i++) {
        QTImageAssetView *assetView = (QTImageAssetView *)[self.contentView viewWithTag:kAssetViewTagPriex+i];
        if (i < self.assets.count) {
            [assetView setHidden:NO];
            ALAsset *asset = [self.assets objectAtIndex:i];
            NSArray *list = [((QTImageAssetViewController*)_delegate) indexPathsForSelectedItems];
            [assetView bind:asset selectionFilter:self.selectionFilter isSeleced:[list containsObject:self.assets[i]]];
        } else {
            [assetView setHidden:YES];
        }
    }
}

#pragma mark - ZYQAssetView Delegate

-(BOOL)shouldSelectAsset:(ALAsset *)asset{
    NSString *shouldSelectAsset = @"shouldSelectAsset";
    NSLog(shouldSelectAsset);
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldSelectAsset:)]) {
        return [_delegate shouldSelectAsset:asset];
    }
    return YES;
}

-(void)tapSelectHandle:(BOOL)select asset:(ALAsset *)asset{
    NSString *tapSelectHandle = @"tapSelectHandle";
    NSLog(tapSelectHandle);
    if (select) {
        if (_delegate!=nil&&[_delegate respondsToSelector:@selector(didSelectAsset:)]) {
            [_delegate didSelectAsset:asset];
        }
    }
    else{
        if (_delegate!=nil&&[_delegate respondsToSelector:@selector(didDeselectAsset:)]) {
            [_delegate didDeselectAsset:asset];
        }
    }
}

- (void)dismissUI{
    NSString *dismissUI = @"dismissUI";
    NSLog(dismissUI);
}

@end

//
//  STIMAssetModel.m
//  STIMImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "STIMAssetModel.h"
#import "STIMImagePickerManager.h"

@implementation STIMAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(STIMAssetModelMediaType)type{
    STIMAssetModel *model = [[STIMAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(STIMAssetModelMediaType)type timeLength:(NSString *)timeLength {
    STIMAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end



@implementation QIMAlbumModel

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    if (needFetchAssets) {
        [[STIMImagePickerManager manager] getAssetsFromFetchResult:result completion:^(NSArray<STIMAssetModel *> *models) {
            self->_models = models;
            if (self->_selectedModels) {
                [self checkSelectedModels];
            }
        }];
    }
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (STIMAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (STIMAssetModel *model in _models) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount ++;
        }
    }
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
    return @"";
}

@end

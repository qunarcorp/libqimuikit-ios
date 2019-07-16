//
//  QIMAssetModel.m
//  QIMImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "QIMAssetModel.h"
#import "QIMImagePickerManager.h"

@implementation QIMAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(QIMAssetModelMediaType)type{
    QIMAssetModel *model = [[QIMAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(QIMAssetModelMediaType)type timeLength:(NSString *)timeLength {
    QIMAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end



@implementation QIMAlbumModel

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    if (needFetchAssets) {
        [[QIMImagePickerManager manager] getAssetsFromFetchResult:result completion:^(NSArray<QIMAssetModel *> *models) {
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
    for (QIMAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (QIMAssetModel *model in _models) {
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

//
//  QIMWorkMomentUserIdentityModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentUserIdentityModel.h"
#import "YYModel.h"

@implementation QIMWorkMomentUserIdentityModel

@end

@interface QIMWorkMomentUserIdentityManager ()

@property (nonatomic, copy) NSString *postUUID;

@end

@implementation QIMWorkMomentUserIdentityManager

static QIMWorkMomentUserIdentityManager *_manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[QIMWorkMomentUserIdentityManager alloc] init];
    });
    return _manager;
}

+ (instancetype)sharedInstanceWithPOSTUUID:(NSString *)postuuid {
    [QIMWorkMomentUserIdentityManager sharedInstance];
    if (postuuid.length > 0) {
        _manager.postUUID = [NSString stringWithFormat:@"WorkMomentUserIdentityManager-%@", postuuid];
    } else {
        _manager.postUUID = nil;
    }
    return _manager;
}

- (QIMWorkMomentUserIdentityModel *)userIdentityModel {
    if (_manager.postUUID.length > 0) {
        NSDictionary *modelDic = [[QIMKit sharedInstance] userObjectForKey:_manager.postUUID];
        QIMWorkMomentUserIdentityModel *model = [QIMWorkMomentUserIdentityModel yy_modelWithDictionary:modelDic];
        if (model) {
            return model;
        } else {
            model = [[QIMWorkMomentUserIdentityModel alloc] init];
            model.isAnonymous = NO;
            
            return model;
        }
    } else {
        return nil;
    }
}

- (void)setUserIdentityModel:(QIMWorkMomentUserIdentityModel *)userIdentityModel {
    NSDictionary *modelDic = [userIdentityModel yy_modelToJSONObject];
    [[QIMKit sharedInstance] setUserObject:modelDic forKey:_manager.postUUID];
}

@end

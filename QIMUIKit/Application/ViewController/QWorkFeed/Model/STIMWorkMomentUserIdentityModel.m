//
//  STIMWorkMomentUserIdentityModel.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentUserIdentityModel.h"
#import "YYModel.h"

@implementation STIMWorkMomentUserIdentityModel

@end

@interface STIMWorkMomentUserIdentityManager ()

@property (nonatomic, copy) NSString *postUUID;

@end

@implementation STIMWorkMomentUserIdentityManager

static STIMWorkMomentUserIdentityManager *_manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[STIMWorkMomentUserIdentityManager alloc] init];
    });
    return _manager;
}

+ (instancetype)sharedInstanceWithPOSTUUID:(NSString *)postuuid {
    [STIMWorkMomentUserIdentityManager sharedInstance];
    if (postuuid.length > 0) {
        _manager.postUUID = [NSString stringWithFormat:@"WorkMomentUserIdentityManager-%@", postuuid];
    } else {
        _manager.postUUID = nil;
    }
    return _manager;
}

- (STIMWorkMomentUserIdentityModel *)userIdentityModel {
    if (_manager.postUUID.length > 0) {
        NSDictionary *modelDic = [[STIMKit sharedInstance] userObjectForKey:_manager.postUUID];
        STIMWorkMomentUserIdentityModel *model = [STIMWorkMomentUserIdentityModel yy_modelWithDictionary:modelDic];
        if (model) {
            return model;
        } else {
            model = [[STIMWorkMomentUserIdentityModel alloc] init];
            model.isAnonymous = NO;
            
            return model;
        }
    } else {
        return nil;
    }
}

- (void)setUserIdentityModel:(STIMWorkMomentUserIdentityModel *)userIdentityModel {
    NSDictionary *modelDic = [userIdentityModel yy_modelToJSONObject];
    [[STIMKit sharedInstance] setUserObject:modelDic forKey:_manager.postUUID];
}

@end

//
//  STIMSelectComponyViewController.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/2/14.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
@class STIMPublicCompanyModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^onSelectCompanyBlock)(STIMPublicCompanyModel * companyModel);

@interface STIMSelectComponyViewController : QTalkViewController

@property (nonatomic, copy) onSelectCompanyBlock companyBlock;

@end

NS_ASSUME_NONNULL_END

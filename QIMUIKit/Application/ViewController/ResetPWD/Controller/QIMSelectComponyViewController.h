//
//  QIMSelectComponyViewController.h
//  QIMUIKit
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
@class QIMPublicCompanyModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^onSelectCompanyBlock)(QIMPublicCompanyModel * companyModel);

@interface QIMSelectComponyViewController : QTalkViewController

@property (nonatomic, copy) onSelectCompanyBlock companyBlock;

@end

NS_ASSUME_NONNULL_END

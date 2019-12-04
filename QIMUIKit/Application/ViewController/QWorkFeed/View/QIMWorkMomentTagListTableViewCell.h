//
//  QIMWorkMomentTagListTableViewCell.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/18.
//

#import <UIKit/UIKit.h>
#import "QIMCommonUIFramework.h"
@class QIMWorkMomentTopicListModel;
@class QIMWorkMomentTagModel;
typedef void(^QIMSelectTagBlock)(QIMWorkMomentTagModel * model);
NS_ASSUME_NONNULL_BEGIN
@interface QIMWorkMomentTagListTableViewCell : UITableViewCell
@property (nonatomic,strong) QIMWorkMomentTopicListModel * model;
@property (nonatomic , copy) QIMSelectTagBlock selectBlock;
@end

NS_ASSUME_NONNULL_END

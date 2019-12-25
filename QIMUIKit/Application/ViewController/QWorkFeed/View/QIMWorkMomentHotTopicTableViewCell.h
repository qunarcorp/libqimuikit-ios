//
//  QIMWorkMomentHotTopicTableViewCell.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import <UIKit/UIKit.h>
#import "QIMWorkMomentHotTopicModel.h"



@interface QIMWorkMomentHotTopicTableViewCell : UITableViewCell
@property (nonatomic,assign)BOOL showNumber;
- (void)setHotTopicModel:(QIMWorkMomentHotTopicModel *)model;
@end



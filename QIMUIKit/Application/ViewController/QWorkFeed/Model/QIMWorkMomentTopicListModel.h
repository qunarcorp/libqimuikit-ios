//
//  QIMWorkMomentTopicListModel.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class QIMWorkMomentTagModel;
@interface QIMWorkMomentTopicListModel : NSObject
@property (nonatomic,copy) NSNumber * topicId;
@property (nonatomic,copy) NSString * topicTitle;
@property (nonatomic,strong) NSArray <QIMWorkMomentTagModel *> * tagList;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,copy) NSString * topicBGColor;
@property (nonatomic,strong) NSMutableArray * selectArr;
@end

NS_ASSUME_NONNULL_END

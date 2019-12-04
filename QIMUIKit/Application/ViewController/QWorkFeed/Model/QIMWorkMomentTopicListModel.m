//
//  QIMWorkMomentTopicListModel.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/15.
//

#import "QIMWorkMomentTopicListModel.h"
#import "QIMWorkMomentTagModel.h"

@implementation QIMWorkMomentTopicListModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectArr = [NSMutableArray array];
    }
    return self;
}
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"tagList":[QIMWorkMomentTagModel class]};
}

@end

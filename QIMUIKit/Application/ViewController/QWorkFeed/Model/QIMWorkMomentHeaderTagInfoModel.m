//
//  QIMWorkMomentHeaderTagInfoModel.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import "QIMWorkMomentHeaderTagInfoModel.h"

@implementation QIMWorkMomentHeaderTagInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
   // 将personId映射到key为id的数据字段
    return @{@"descriptionString":@"description"};
   // 映射可以设定多个映射字段
   //  return @{@"personId":@[@"id",@"uid",@"ID"]};
}
@end

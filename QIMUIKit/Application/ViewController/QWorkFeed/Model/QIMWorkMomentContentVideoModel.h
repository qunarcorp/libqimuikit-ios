//
//  QIMWorkMomentContentVideoModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/7/31.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentContentVideoModel : NSObject

/*
{\"Duration\":\"20650\",\"FileName\":\"20190730165753995_vr15Vy_Screenrecording_20190328_1526_trans_V.mp4\",\"FileSize\":\"1484013\",\"FileUrl\":\"http://osd.corp.qunar.com/vs_cricle_camel_vs_cricle_camel/20190730165753995_vr15Vy_Screenrecording_20190328_1526_trans_V.mp4\",\"Height\":\"1352\",\"ThumbName\":\"20190730165753995_vr15Vy_Screenrecording_20190328_1526_trans_V.png\",\"ThumbUrl\":\"http://osd.corp.qunar.com/vs_cricle_camel_vs_cricle_camel/20190730165753995_vr15Vy_Screenrecording_20190328_1526_trans_V.png\",\"Width\":\"640\"}
 */

@property (nonatomic, copy) NSString *Duration;
@property (nonatomic, copy) NSString *FileName;
@property (nonatomic, copy) NSString *FileSize;
@property (nonatomic, copy) NSString *FileUrl;
@property (nonatomic, copy) NSString *Height;
@property (nonatomic, copy) NSString *ThumbName;
@property (nonatomic, copy) NSString *ThumbUrl;
@property (nonatomic, copy) NSString *Width;
@property (nonatomic, copy) NSString *LocalVideoOutPath;

@end

NS_ASSUME_NONNULL_END

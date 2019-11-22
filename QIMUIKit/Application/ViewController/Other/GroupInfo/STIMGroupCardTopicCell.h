//
//  STIMGroupCardTopicCell.h
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@interface STIMGroupCardTopicCell : UITableViewCell

@property (nonatomic, strong) NSString *topic;

+ (CGFloat)getCellHeightWithTopic:(NSString *)topic;

- (void)refreshUI;

@end

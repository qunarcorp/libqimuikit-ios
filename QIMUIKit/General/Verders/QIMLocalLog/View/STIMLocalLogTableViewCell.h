//
//  STIMLocalLogTableViewCell.h
//  STChatIphone
//
//  Created by Qunar-Lu on 2017/3/10.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMLocalLogTableViewCell : UITableViewCell

- (void)setLogFileDict:(NSDictionary *)logFileDict;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;

@end

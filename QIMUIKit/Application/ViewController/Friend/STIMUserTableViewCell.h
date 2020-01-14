//
//  STIMUserTableViewCell.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/1/17.
//

#import "STIMCommonUIFramework.h"

#define kQTalkUserCellHeaderLeftMargin 17.0f
#define kQTalkUserCellHeaderTopMargin 9.0f
#define kQTalkUserCellHeaderWidth 36
#define kQTalkUserCellHeaderHeight 36
#define kQTalkUserCellNameLabelLeftMargin 15.0f

@interface STIMUserTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *userInfoDic;

- (void)refreshUI;

@end

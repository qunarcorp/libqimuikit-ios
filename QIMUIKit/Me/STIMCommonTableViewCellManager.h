//
//  STIMCommonTableViewCellManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "STIMCommonUIFramework.h"

#define QCBlankLineCellHeight       20.0f
#define QCMineProfileCellHeight     79.0f
#define QCMineOtherCellHeight       44.0f
#define QCMineSectionHeaderHeight   20.0f
#define QCMineMinSectionHeight      0.00001f

@class STIMCommonTableViewCellData;
@class STIMUserInfoModel;
@class GroupModel;
@class QCGroupModel;
@interface STIMCommonTableViewCellManager : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;
@property (nonatomic) NSArray<NSArray<STIMCommonTableViewCellData *> *> *dataSource;
@property (nonatomic, strong) NSArray *dataSourceTitle;
@property (nonatomic, strong) STIMUserInfoModel *model;
@property (nonatomic, strong) QCGroupModel *groupModel;

@end

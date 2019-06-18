//
//  QTalkNewSessionTableViewCell.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/6/10.
//

#import "QIMCommonUIFramework.h"
#import "QIMNewSessionScrollDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface QTalkNewSessionTableViewCell : UITableViewCell

@property (nonatomic, weak) id <QIMNewSessionScrollDelegate> sessionScrollDelegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) NSDictionary *infoDic;

@property (nonatomic, copy) NSString *combineJid;

@property (nonatomic, assign) ChatType chatType;

@property (nonatomic, copy) NSString *bindId;

@property (nonatomic, weak) UITableView *containingTableView;

@property (nonatomic, assign) BOOL hasAtCell;

@property (nonatomic, strong) UITableViewRowAction *deleteBtn;  //右滑删除会话

@property (nonatomic, strong) UITableViewRowAction *stickyBtn;  //右滑置顶会话

@property (nonatomic, assign) NSInteger notReadCount;

@property (nonatomic, assign) BOOL firstRefresh;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end

@interface NSMutableArray (SWUtilityButtons)

- (void)addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title;
- (void)addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon;

@end

NS_ASSUME_NONNULL_END

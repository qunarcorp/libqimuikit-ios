//
//  STIMContactSelectionViewController.h
//  STChatIphone
//
//  Created by may on 15/7/7.
//
//

#import "STIMCommonUIFramework.h"

@class STIMGroupChatVC,STIMChatVC;
@class STIMContactSelectionViewController;
@protocol STIMContactSelectionViewControllerDelegate <NSObject>
@optional
- (void)contactSelectionViewController:(STIMContactSelectionViewController *)contactVC groupChatVC:(STIMGroupChatVC *)vc;
- (void)contactSelectionViewController:(STIMContactSelectionViewController *)contactVC chatVC:(STIMChatVC *)vc;

@end

@interface STIMContactSelectionViewController : QTalkViewController
@property (nonatomic, weak) id<STIMContactSelectionViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL ExternalForward;
@property (nonatomic, strong)STIMMessageModel *message;
@property (nonatomic, strong) NSArray *messageList;

@property (nonatomic, assign) BOOL      isTransfer;//是否是会话转移

- (NSDictionary *)getSelectInfoDic;

@end

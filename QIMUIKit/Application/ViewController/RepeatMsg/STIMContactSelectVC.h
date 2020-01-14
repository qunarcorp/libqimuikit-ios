//
//  STIMContactSelectVC.h
//  STChatIphone
//
//  Created by haibin.li on 2016/09/20.
//
//

#import "STIMCommonUIFramework.h"
@class STIMContactSelectVC;

@protocol STIMContactSelectVCDelegate <NSObject>

- (void)STIMContactSelectVC:(STIMContactSelectVC *)vc completeWithUsersInfo:(NSArray *)usersInfo;

@end

@interface STIMContactSelectVC : UIViewController

@property (nonatomic, assign) id<STIMContactSelectVCDelegate> delegate;
@property (nonatomic, assign) BOOL      allowMulSelect;//是否支持多选
@property (nonatomic, strong) NSArray   * defaultSelectIds;//默认选中users（支持多选，才能默认选中）

@end

//
//  STIMUserProfileViewController.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/25.
//

#import "STIMCommonUIFramework.h"
#import "STIMUserInfoModel.h"

@interface STIMUserProfileViewController : QTalkViewController

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) STIMUserInfoModel *model;

@property (nonatomic, assign) BOOL myOwnerProfile; //是否打开的我个人资料

@end

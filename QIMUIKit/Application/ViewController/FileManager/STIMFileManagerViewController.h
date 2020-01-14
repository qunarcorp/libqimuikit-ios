//
//  STIMFileManagerViewController.h
//  STChatIphone
//
//  Created by haibin.li on 15/7/24.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMFileManagerViewController : QTalkViewController

@property (nonatomic,assign) BOOL       isSelect;//是否是选择界面
@property (nonatomic,copy) NSString         * userId;
@property (nonatomic,assign) ChatType    messageSaveType;

@end

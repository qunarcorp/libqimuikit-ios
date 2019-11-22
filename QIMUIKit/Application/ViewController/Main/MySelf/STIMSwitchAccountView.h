//
//  STIMSwitchAccountView.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/8.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMSwitchAccountViewDelegate <NSObject>

- (void)swicthAccountWithAccount:(NSDictionary *)accountDict;

@end

@interface STIMSwitchAccountView : UIView

- (instancetype)initWithFrame:(CGRect)frame WithAccounts:(NSMutableArray *)accounts;

@property (nonatomic, weak) id <STIMSwitchAccountViewDelegate> delegate;

@end

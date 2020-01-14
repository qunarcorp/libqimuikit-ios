//
//  STIMGroupPassworVC.h
//  STChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMGroupPassworVCDelegate <NSObject>
@optional
- (void)setGroupPassword:(NSString *)password;
@end
@interface STIMGroupPassworVC : QTalkViewController
@property (nonatomic, weak) id<STIMGroupPassworVCDelegate> delegate;
@property (nonatomic, strong) NSString *password;
@end

//
//  STIMGroupMaxMemberVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMGroupMaxMemberVCDelegate <NSObject>
@optional
- (void)setGroupMaxMember:(NSString *)maxMember;
@end
@interface STIMGroupMaxMemberVC : QTalkViewController
@property (nonatomic, weak) id<STIMGroupMaxMemberVCDelegate> delegate;
@property (nonatomic, strong) NSString *maxMember;
@end

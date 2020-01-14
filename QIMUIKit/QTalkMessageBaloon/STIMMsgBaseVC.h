//
//  STIMMsgBaseVC.h
//  STChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "STIMCommonUIFramework.h"

@protocol STIMMsgBaseVCDelegate <NSObject>
@optional
- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType;
@end

@interface STIMMsgBaseVC : QTalkViewController
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, assign) id<STIMMsgBaseVCDelegate> delegate;
@end

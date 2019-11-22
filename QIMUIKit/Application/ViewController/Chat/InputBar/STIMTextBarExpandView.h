//
//  STIMTextBarExpandView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/9.
//
//

#import "STIMCommonUIFramework.h"
#import "STIMMsgBaseVC.h"
typedef enum {
    STIMTextBarExpandViewTypeNomal = 1 << 0,
    STIMTextBarExpandViewTypeGroup = 1 << 1,//群组
    STIMTextBarExpandViewTypeSingle = 1 << 2,//单人聊天
    STIMTextBarExpandViewTypeRobot = 1 << 3,//机器人
    STIMTextBarExpandViewTypeConsult = 1 << 4, //Consult会话
    STIMTextBarExpandViewTypeConsultServer = 1 << 5, //ConsultServer会话
    STIMTextBarExpandViewTypePublicNumber = 1 << 6, //公众号会话
} STIMTextBarExpandViewType;


#define STIMTextBarExpandViewItem_Photo            @"Album"
#define STIMTextBarExpandViewItem_Camera           @"Camera"
#define STIMTextBarExpandViewItem_MyFiles          @"MyFile"
#define STIMTextBarExpandViewItem_QuickReply       @"QuickReply"
#define STIMTextBarExpandViewItem_VideoCall        @"VideoCall"
#define STIMTextBarExpandViewItem_Location         @"Location"
#define STIMTextBarExpandViewItem_BurnAfterReading @"BurnAfterReading"
#define STIMTextBarExpandViewItem_ChatTransfer     @"ChatTransfer"
#define STIMTextBarExpandViewItem_ShareCard        @"ShareCard"
#define STIMTextBarExpandViewItem_RedPack          @"RedPack"
#define STIMTextBarExpandViewItem_AACollection     @"AACollection"
#define STIMTextBarExpandViewItem_Encryptchat      @"Encrypt"
#define STIMTextBarExpandViewItem_SendProduct      @"SendProduct"
#define STIMTextBarExpandViewItem_SendActivity     @"SendActivity"
#define STIMTextBarExpandViewItem_Shock            @"Shock"
#define STIMTextBarExpandViewItem_TouPiao          @"toupiao"
#define STIMTextBarExpandViewItem_Task_list        @"Task_list"

@class STIMTextBarExpandView;
@protocol STIMTextBarExpandViewDelegate <NSObject>

- (void)didClickExpandItemForTrdextendId:(NSString *)trdextendId;

- (void)textBarExpandView:(STIMTextBarExpandView *)expandView forItemIndex:(NSInteger)itemIndex;

- (void)scrollViewDidScrollToIndex:(NSInteger)currentPage;

@end

@interface STIMTextBarExpandView : UIView <STIMMsgBaseVCDelegate>

@property (nonatomic,assign)id<STIMTextBarExpandViewDelegate> delegate;
@property (nonatomic,assign)UIViewController        * parentVC;
@property (nonatomic,assign)STIMTextBarExpandViewType   type;
-(instancetype)initWithFrame:(CGRect)frame;

- (void)displayItems;

- (void)addItems;

+ (NSDictionary *)getTrdExtendInfoForType:(NSNumber *)type;

@end

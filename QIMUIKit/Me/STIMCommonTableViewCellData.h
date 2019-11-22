//
//  STIMCommonTableViewCellData.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "STIMCommonUIFramework.h"

typedef enum {
    STIMCommonTableViewCellDataTypeBlankLines = 0,       //空行
    STIMCommonTableViewCellDataTypeMine = 1,
    STIMCommonTableViewCellDataTypeMyRedEnvelope,        //红包
    STIMCommonTableViewCellDataTypeBalanceInquiry,       //余额查询
    STIMCommonTableViewCellDataTypeAttendance,           //签到打卡
    STIMCommonTableViewCellDataTypeTotpToken,            //Totp Token
    STIMCommonTableViewCellDataTypeMyFile,               //我的文件
    STIMCommonTableViewCellDataTypeFeedback,             //意见反馈
    STIMCommonTableViewCellDataTypeSetting,              //设置
    STIMCommonTableViewCellDataTypeMessageNotification,  //开启消息推送
    STIMCommonTableViewCellDataTypeMessageAlertSound,    //通知提示音
    STIMCommonTableViewCellDataTypeMessageVibrate,       //通知震动提示
    STIMCommonTableViewCellDataTypeMessageShowPreviewText,      //通知显示消息详情
    STIMCommonTableViewCellDataTypeMessageOnlineNotification, //在线也接受通知
    STIMCommonTableViewCellDataTypeShowSignature,        //优先展示心情短语
    STIMCommonTableViewCellDataTypeDressUp,              //个性化装扮
    STIMCommonTableViewCellDataTypeSearchHistory,        //历史消息查询
    STIMCommonTableViewCellDataTypeClearSessionList,     //清空消息列表
    STIMCommonTableViewCellDataTypePrivacy,              //隐私
    STIMCommonTableViewCellDataTypeGeneral,              //通用
    STIMCommonTableViewCellDataTypeUpdateConfig,         //更新配置
    STIMCommonTableViewCellDataTypeContactBlack,         //通讯录黑名单
    STIMCommonTableViewCellDataTypeClearCache,           //清除缓存
    STIMCommonTableViewCellDataTypeMconfig,              //账号管理
    STIMCommonTableViewCellDataTypeServiceMode,          //服务模式
    STIMCommonTableViewCellDataTypeAbout,                //关于
    STIMCommonTableViewCellDataTypeLogout,               //退出登录
    STIMCommonTableViewCellDataTypeGroupName,            //群名称
    STIMCommonTableViewCellDataTypeGroupTopic,           //群公告
    STIMCommonTableViewCellDataTypeGroupPush,            //群消息设置
    STIMCommonTableViewCellDataTypeGroupQRcode,          //群二维码
    STIMCommonTableViewCellDataTypeGroupLeave,           //退出群聊
    STIMCommonTableViewCellDataTypeGroupAdd,             //加入群聊
    STIMCommonTableViewCellDataTypeStickChat,            //置顶聊天
} STIMCommonTableViewCellDataType;

@interface STIMCommonTableViewCellData : NSObject

@property (nonatomic, assign) STIMCommonTableViewCellDataType cellDataType;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic) UIImage *icon;

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName cellDataType:(STIMCommonTableViewCellDataType)cellDataType;

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconName:(NSString *)iconName cellDataType:(STIMCommonTableViewCellDataType)cellDataType;

@end


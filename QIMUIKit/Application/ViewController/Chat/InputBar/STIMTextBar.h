//
//  STIMTextBar.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/24.
//
//

//  关于声音的说明：在这里面进行声音的录制、保存、压缩和上传。保存的是原文件，上传的是压缩后的文件，再将文件名、文件大小和获取到的url返回给delagate，由delegate来进行有关于文件的描述信息的提交
//  send的文件：filePath = [STIMPathManage getPathByFileName:fileName ofType:@"amr"];

#import "STIMCommonUIFramework.h"
#import "STIMTextBarExpandView.h"
#import "STIMChatToolBar.h"
#import "STIMVoiceChatView.h"
#import "STIMQuickReplyExpandView.h"
#import "STIMTextBarExpandView.h"
#import "STIMOfficialAccountToolbar.h"

#define kHasVoice 1
#define kSTIMTextBarIsFirstResponder @"kSTIMTextBarIsFirstResponder"

typedef NS_ENUM(NSInteger, KeyBoardStyle)
{
    KeyBoardStyleChat = 0,
    KeyBoardStyleComment
};

typedef enum {
    IMTextBarInputItemTypeText,
    IMTextBarInputItemTypeEmotion,
    IMTextBarInputItemTypeImage,
} IMTextBarInputItemType;

@class STIMTextBar;
@protocol STIMTextBarDelegate <NSObject>
@required
- (void)sendText:(NSString *)text;
- (void)emptyText:(NSString *)text;
- (void)sendNormalEmotion:(NSString *)faceStr WithPackageId:(NSString *)packageId;
- (void)sendCollectionFaceStr:(NSString *)faceStr;
- (void)clickFaildCollectionFace;
@optional
- (void)sendImageUrl:(NSString *)imageUrl;
- (void)sendImageData:(NSData *)imageData;
- (void)sendVoiceUrl:(NSString *)voiceUrl WithDuration:(int)duration WithSmallData:(NSData *)amrData WithFileName:(NSString *)filename AndFilePath:(NSString *)filepath;
- (void)setKeyBoardHeight:(CGFloat)height WithScrollToBottom:(BOOL)flag;

- (void)textBarReferBtnDidClicked:(STIMTextBar *)textBar;

#pragma mark -let delegate do view update when voiceRecoding -add by dan.zheng 15/4/24
- (void)beginDoVoiceRecord;
- (void)updateVoiceViewHeightInVCWithPower:(float)power;
- (void)voiceRecordWillFinishedIsTrue:(BOOL)isTrue andCancelByUser:(BOOL)isCancelByUser;
- (void)voiceMaybeCancelWithState:(BOOL)ifMaybeCancel;
// 小视频
- (void)sendVideoPath:(NSString *)videoPath WithThumbImage:(UIImage *)thumbImage WithFileSizeStr:(NSString *)fileSizeStr WithVideoDuration:(float)duration;

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType;

- (void)sendTyping;

- (void)showActionBottomView;

@end

@interface IMTextBarInputItem : NSObject

@property (nonatomic, assign) IMTextBarInputItemType type;

@property (nonatomic, copy) NSString *dispalyStr;

@property (nonatomic, copy) NSString *emotionPKId;

@end

@class STIMRemoteAudioPlayer;
@interface STIMTextBar : UIView

+ (void)clearALLTextBar;



@property (nonatomic, weak) id <STIMTextBarDelegate> delegate;

/**
 工具条
 */
@property (nonatomic, strong) STIMChatToolBar *chatToolBar;

/**
 扩展键盘
 */
@property (nonatomic, strong) STIMTextBarExpandView *expandPanel;

/**
 表情键盘
 */
@property (nonatomic, strong) UIView *emotionPanel;

/**
 遮罩蒙板
 */
@property (nonatomic, strong) UIView *maskView;

//快捷回复
@property (nonatomic, strong) STIMQuickReplyExpandView *quickReplyExpandView;

/**
 机器人键盘
 */
@property (nonatomic, strong) STIMOfficialAccountToolbar *robotActionToolBar;

/**
 设置键盘风格
 默认是KeyBoardStyleChat
 */
@property (nonatomic, assign) KeyBoardStyle keyBoardStyle;

/**
 *  placeHolder内容
 */
@property (nonatomic, copy) NSString * placeHolder;

/**
 *  placeHolder颜色
 */
@property (nonatomic, strong) UIColor *placeHolderColor;

/**
 是否开启语音，默认开启
 */
@property (nonatomic, assign) BOOL allowVoice;

/**
 是否开启表情，默认开启
 */
@property (nonatomic, assign) BOOL allowFace;

/**
 是否开启更多功能，默认开启
 */
@property (nonatomic, assign) BOOL allowMore;

/**
 是否开启切换，默认关闭
 */
@property (nonatomic, assign) BOOL allowSwitchBar;

/**
 键盘弹起
 */
- (void)keyBoardUp;

/**
 键盘收起
 */
- (void)keyBoardDown;

@property (nonatomic, strong) UIColor *textViewBackgroundColor;

@property (nonatomic, strong) UIImage *textViewBackgroundImage;

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, copy) NSString *replyName;

@property (nonatomic, assign) BOOL removeStateBarHeight;

@property (nonatomic, assign) BOOL hasExpandKeyboard;

@property (nonatomic, assign) BOOL hasVoice;

@property (nonatomic, assign) BOOL hasEmotion;

// 机器人菜单
@property (nonatomic, assign) BOOL hasShowActionButton;
@property (nonatomic, assign) BOOL isRobotTextBar;

@property (nonatomic, assign) CGRect rootFrame;

@property (nonatomic, assign) BOOL hasAtFun;
@property (nonatomic, assign) NSRange currentRange;
@property (nonatomic,assign) STIMTextBarExpandViewType   expandViewType;

@property(nonatomic,copy) NSString                  * currentPKId;
@property (nonatomic,strong) NSMutableArray         * inputItems;

@property (nonatomic,assign) BOOL    isRefer;  //是否正在引用消息输入
@property (nonatomic,strong) STIMMessageModel  *referMsg; //引用的消息

//会话id
@property (nonatomic, retain) NSString *chatId;

//真实Id
@property (nonatomic, copy) NSString *realJid;
/**
 *
 *  设置关联的TableView
 */
@property (nonatomic, weak) UITableView *associateTableView;

- (void)configActionsWithActionList:(NSArray *)actionList;


+ (instancetype)sharedIMTextBarWithBounds:(CGRect)bounds WithExpandViewType:(STIMTextBarExpandViewType)expandType;

- (void)updateFilrStatus:(BOOL) on;
- (void)setText:(NSString *)text;
- (NSAttributedString *)getTextBarAttributedText;
- (NSString *)getSendAttributedText;
- (NSArray *)encodeInputItems;
- (void)decodeInputItems:(NSArray *)items;

- (void)setSTIMAttributedTextWithItems:(NSArray *)items;
- (NSArray *)getAttributedTextItems;

- (NSRange) selectedRange;
- (void)needFirstResponder:(BOOL)isFirst;

- (void)setSelectedEmotion:(void (^)(NSString * faceStr)) onEmotionSelected;

-(UIButton *)exportExpandButton;

- (STIMRemoteAudioPlayer *)playCurrentVoice;
- (void)stopCurrentVoice;
- (NSTimeInterval)getCurrentVoiceTimeout;

- (void)becomeFirstResponder;
- (void)resignFirstResponder;

- (void)setTextViewPlaceholder:(NSString *)placeholder;

- (void)refreshTextInputCacheWithRange:(NSRange )range text:(NSString *)text itemType:(IMTextBarInputItemType)type isDel:(BOOL)isDel;

- (void)insertEmojiTextWithTipsName:(NSString *)tipsName shortCut:(NSString *)shortCut;

@end

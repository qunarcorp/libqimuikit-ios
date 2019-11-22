
#import "STIMCommonUIFramework.h"
#import "QTalkTextView.h"
#import "STIMRecordButton.h"

typedef NS_ENUM(NSInteger, ButKind)
{
    kButKindVoice,
    kButKindFace,
    kButKindMore,
    kButKindSwitchBar
};

@class STIMChatToolBar;
@class STIMChatToolBarItem;

@protocol STIMChatToolBarDelegate <NSObject>

@optional
- (void)chatToolBar:(STIMChatToolBar *)toolBar voiceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(STIMChatToolBar *)toolBar faceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(STIMChatToolBar *)toolBar moreBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBarSwitchToolBarBtnPressed:(STIMChatToolBar *)toolBar keyBoardState:(BOOL)change;

- (void)chatToolBarDidStartRecording:(STIMChatToolBar *)toolBar;
- (void)chatToolBarDidCancelRecording:(STIMChatToolBar *)toolBar;
- (void)chatToolBarDidFinishRecoding:(STIMChatToolBar *)toolBar;
- (void)chatToolBarWillCancelRecoding:(STIMChatToolBar *)toolBar;
- (void)chatToolBarContineRecording:(STIMChatToolBar *)toolBar;

- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView;
- (void)chatToolBarSendText:(NSString *)text;
- (void)chatToolBarTextViewDidChange:(UITextView *)textView;
- (void)chatToolBarTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)chatToolBarTextViewDeleteBackward:(QTalkTextView *)textView;
@end


@interface STIMChatToolBar : UIImageView

@property (nonatomic, weak) id<STIMChatToolBarDelegate> delegate;

/** 切换barView按钮 */
@property (nonatomic, readonly, strong) UIButton *switchBarBtn;
/** 语音按钮 */
@property (nonatomic, readonly, strong) UIButton *voiceBtn;
/** 表情按钮 */
@property (nonatomic, readonly, strong) UIButton *faceBtn;
/** more按钮 */
@property (nonatomic, readonly, strong) UIButton *moreBtn;
/** 输入文本框 */
@property (nonatomic, readonly, strong) QTalkTextView *textView;

//@property (nonatomic, assign) BOOL chatToolTextViewShow;
/** 按住录制语音按钮 */
//@property (nonatomic, readonly, strong) STIMRecordButton *recordBtn;

/** 默认为no */
@property (nonatomic, assign) BOOL allowSwitchBar;
/** 以下默认为yes*/
@property (nonatomic, assign) BOOL allowVoice;
@property (nonatomic, assign) BOOL allowFace;
@property (nonatomic, assign) BOOL allowMoreFunc;

@property (readonly) BOOL voiceSelected;
@property (readonly) BOOL faceSelected;
@property (readonly) BOOL moreFuncSelected;
@property (readonly) BOOL switchBarSelected;


/**
 *  配置textView内容
 */
- (void)setTextViewContent:(NSString *)text;
- (void)clearTextViewContent;

/**
 *  配置placeHolder
 */
- (void)setTextViewPlaceHolder:(NSString *)placeholder;
- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor;

/**
 *  为开始评论和结束评论做准备
 */
- (void)prepareForBeginComment;
- (void)prepareForEndComment;


/**
 *  加载数据
 */
- (void)loadBarItems:(NSArray<STIMChatToolBarItem *> *)barItems;

@end

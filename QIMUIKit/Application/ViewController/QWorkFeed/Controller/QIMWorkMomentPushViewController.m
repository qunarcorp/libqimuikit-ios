//
//  QIMWorkMomentPushViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/2.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentPushViewController.h"
#import "QTImagePickerController.h"
#import "QIMAuthorizationManager.h"
#import "QTPHImagePickerManager.h"
#import "QTPHImagePickerController.h"
#import "QIMWorkMomentUserIdentityVC.h"
#import "UIApplication+QIMApplication.h"
#import "QTalkTextView.h"
#import "QIMWorkMomentLinkView.h"
#import "QIMWorkMomentContentLinkModel.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "QIMCollectionEmotionPanView.h"
#import "QIMWorkMomentPanelModel.h"
#import "QIMImageUtil.h"
#import "QIMStringTransformTools.h"
#import "QIMWorkMomentPushCell.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMPhotoBrowserNavController.h"
#import "QIMWorkMomentUserIdentityModel.h"
#import "QIMMessageTextAttachment.h"
#import "QIMWorkMomentModel.h"
#import "QIMUUIDTools.h"
#import "YYModel.h"
#import "MBProgressHUD.h"
#import "QIMProgressHUD.h"
#import "QIMEmotionManager.h"
#import "QTalkTipsView.h"
#import "QIMWorkFeedAtNotifyViewController.h"
#import "QIMATGroupMemberTextAttachment.h"
#import "YYKeyboardManager.h"
#import "QIMVideoPlayerVC.h"
#if __has_include("QIMIPadWindowManager.h")
#import "QIMIPadWindowManager.h"
#endif
#import <Toast/Toast.h>

static const NSInteger QIMWORKMOMENTLIMITNUM = 50;

@protocol QIMWorkMomentPushUserIdentityViewDelegate <NSObject>

- (void)openUserIdentity;

@end

@interface QIMWorkMomentPushUserIdentityView : UIView

@property (nonatomic, weak) id <QIMWorkMomentPushUserIdentityViewDelegate> delegate;

@property (nonatomic, strong) UIImageView *iconView;    //用户头像

@property (nonatomic, strong) UILabel *userIdentityLabel;   //用户匿名/实名身份

@end

@implementation QIMWorkMomentPushUserIdentityView

- (void)updatePushUserIdentityView {
    if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
        [self.iconView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
        self.userIdentityLabel.text = @"实名发布";
    } else {
        NSString *anonymousPhoto = [[QIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
        [self.iconView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
        self.userIdentityLabel.text = @"匿名发布";
    }
}

- (void)openUserIdentity {
    if (self.delegate && [self.delegate respondsToSelector:@selector(openUserIdentity)]) {
        [self.delegate openUserIdentity];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserIdentity)];
        [self addGestureRecognizer:tap];
        self.layer.cornerRadius = 16.0f;
        self.layer.masksToBounds = YES;
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.iconView.backgroundColor = [UIColor yellowColor];
        [self.iconView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
        [self addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(23);
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(5);
        }];
        self.iconView.layer.cornerRadius = 11.5f;
        self.iconView.layer.masksToBounds = YES;
        
        self.userIdentityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.userIdentityLabel.text = @"实名发布";
        self.userIdentityLabel.textColor = [UIColor qim_colorWithHex:0x666666];
        self.userIdentityLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.userIdentityLabel];
        [self.userIdentityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconView.mas_right).mas_offset(4);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(60);
        }];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        arrowView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_useridentify_arrow size:28 color:[UIColor qim_colorWithHex:0xBABABA]]];
        [self addSubview:arrowView];
        [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-11);
            make.top.mas_equalTo(10);
            make.width.mas_offset(12);
            make.bottom.mas_offset(-10);
        }];
    }
    return self;
}

@end

@interface QIMWorkMomentPushUserIdentityCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel *textLab;

@end

@implementation QIMWorkMomentPushUserIdentityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 9, 32, 32)];
    self.iconView.layer.cornerRadius = 16.0f;
    self.iconView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.iconView];
    
    self.textLab = [[UILabel alloc] init];
    self.textLab.textColor = [UIColor qim_colorWithHex:0x333333];
    self.textLab.font = [UIFont systemFontOfSize:15];
    self.textLab.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.textLab];
    [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(18);
        make.left.mas_equalTo(self.iconView.mas_right).offset(10);
        make.bottom.mas_offset(-18);
    }];
}

@end

@interface QIMWorkMomentPushViewController () <QTPHImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, QIMDragCellCollectionViewDelegate, QIMDragCellCollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, QIMMWPhotoBrowserDelegate, QIMWorkMomentPushCellDeleteDelegate, UITextViewDelegate, QIMWorkMomentPushUserIdentityViewDelegate>

@property(nonatomic, strong) UIView *keyboardToolView;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UILabel *remainingLabel;

@property (nonatomic, strong) QIMWorkMomentPushUserIdentityView *identiView;

@property (nonatomic, strong) QIMWorkMomentLinkView *linkView;

@property (nonatomic, strong) QIMCollectionEmotionPanView *photoCollectionView;

@property (nonatomic, strong) UILabel    *atLabel;

@property (nonatomic, strong) UITableView *panelListView;

@property (nonatomic, strong) NSMutableArray *workmomentPushPanelModels;

@property (nonatomic, strong) UIButton *pushBtn;

@property (nonatomic, strong) NSMutableArray *selectPhotos;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSString *momentId;

@property (nonatomic, assign) QIMWorkMomentMediaType currentSelectMediaType;

@end

@implementation QIMWorkMomentPushViewController

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.photoCollectionView];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [self.photoCollectionView addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.hidden = NO;
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)hideProgressHUD:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hide:animated];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    });
}

#pragma mark - setter and getter

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, [[UIScreen mainScreen] qim_rightWidth] - 30, 150)];
        _textView.backgroundColor = [UIColor whiteColor];
        [_textView setFont:[UIFont systemFontOfSize:17]];
        _textView.delegate = self;
        [_textView setTextColor:[UIColor qim_colorWithHex:0x333333]];
        [_textView setTintColor:[UIColor qim_colorWithHex:0x333333]];
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = @"来吧，尽情发挥吧…";
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = [UIColor qim_colorWithHex:0xBFBFBF];
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        // kvc 设置 placeholderLabel
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.3) {
            [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
        }
    }
    return _textView;
}

- (UIView *)keyboardToolView {
    if (!_keyboardToolView) {
        _keyboardToolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - 80, self.view.width, 80)];
        _keyboardToolView.backgroundColor = [UIColor whiteColor];
    }
    return _keyboardToolView;
}

- (UILabel *)remainingLabel {
    if (!_remainingLabel) {
        _remainingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _remainingLabel.text = [NSString stringWithFormat:@"0/%ld", QIMWORKMOMENTLIMITNUM];
        _remainingLabel.textColor = [UIColor qim_colorWithHex:0xA5A5A5];
        _remainingLabel.font = [UIFont systemFontOfSize:13];
        _remainingLabel.textAlignment = NSTextAlignmentRight;
    }
    return _remainingLabel;
}

- (QIMWorkMomentLinkView *)linkView {
    if (!_linkView) {
        _linkView = [[QIMWorkMomentLinkView alloc] initWithFrame:CGRectMake(14, self.textView.bottom + 10, [[UIScreen mainScreen] qim_rightWidth] - 28, 66)];
        _linkView.linkModel = [self getLinkModelWithLinkDic:self.shareLinkUrlDic];
    }
    return _linkView;
}

- (QIMWorkMomentPushUserIdentityView *)identiView {
    if (!_identiView) {
        _identiView = [[QIMWorkMomentPushUserIdentityView alloc] initWithFrame:CGRectZero];
        _identiView.delegate = self;
    }
    return _identiView;
}

- (void)setupKeyBoardTools {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
    topView.backgroundColor = [UIColor whiteColor];
    [self.keyboardToolView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(28);
    }];
    
    [topView addSubview:self.remainingLabel];
    [self.remainingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(8);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(13);
        make.right.mas_offset(-18);
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    [topView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
//        make.width.mas_equalTo(topView.mas_width);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(topView.mas_bottom).mas_offset(-1);
    }];
    
    UIButton *alumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [alumBtn setBackgroundColor:[UIColor whiteColor]];
    [alumBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_alum size:28 color:qim_moment_alum_btnColor]] forState:UIControlStateNormal];
    [alumBtn addTarget:self action:@selector(onPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardToolView addSubview:alumBtn];
    [alumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(18);
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(topView.mas_bottom).mas_offset(12);
    }];
    
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoBtn setBackgroundColor:[UIColor whiteColor]];
    [videoBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_video size:28 color:qim_moment_video_btnColor]] forState:UIControlStateNormal];
    [self.keyboardToolView addSubview:videoBtn];
    [videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(alumBtn.mas_right).mas_offset(24);
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(topView.mas_bottom).mas_offset(12);
    }];
    
    UIButton *atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [atBtn setBackgroundColor:[UIColor whiteColor]];
    [atBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:qim_moment_at size:28 color:qim_moment_at_btnColor]] forState:UIControlStateNormal];
    [atBtn addTarget:self action:@selector(atSomeone:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardToolView addSubview:atBtn];
    [atBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(videoBtn.mas_right).mas_offset(24);
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(topView.mas_bottom).mas_offset(12);
    }];
    
    [self.keyboardToolView addSubview:self.identiView];
    [self.identiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(120);
        make.right.mas_offset(-15);
    }];
}

- (QIMWorkMomentContentLinkModel *)getLinkModelWithLinkDic:(NSDictionary *)linkDic {
    return [QIMWorkMomentContentLinkModel yy_modelWithDictionary:linkDic];
}

- (QIMCollectionEmotionPanView *)photoCollectionView {
    if (!_photoCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellHeight = ([[UIScreen mainScreen] qim_rightWidth] - 75) / 3;
        CGFloat cellWidth = ([[UIScreen mainScreen] qim_rightWidth] - 75) / 3;
        layout.itemSize = CGSizeMake(cellWidth, cellHeight);
        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 25);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        if (self.shareLinkUrlDic.count > 0) {
            layout.headerReferenceSize = CGSizeMake(0, 180 + self.linkView.height + 10);
        } else {
            layout.headerReferenceSize = CGSizeMake(0, 180);
        }
        layout.footerReferenceSize = CGSizeMake(0, 300);
        // 水平间隔
        layout.minimumInteritemSpacing = 15.0f;
        // 上下垂直间隔
        layout.minimumLineSpacing = 15.0f;
        
        _photoCollectionView = [[QIMCollectionEmotionPanView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_photoCollectionView registerClass:[QIMWorkMomentPushCell class] forCellWithReuseIdentifier:@"cellId"];
        [_photoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        [_photoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        _photoCollectionView.qimDragDelegate = self;
        _photoCollectionView.qimDragDataSource = self;
        _photoCollectionView.shakeLevel = 0.1f;
        _photoCollectionView.shakeWhenMoveing = YES;
        _photoCollectionView.isOpenMove = YES;
        if (@available(iOS 11.0, *)) {
            _photoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _photoCollectionView.showsVerticalScrollIndicator = NO;
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.alwaysBounceVertical = YES;
    }
    return _photoCollectionView;
}

- (UILabel *)atLabel {
    if (!_atLabel) {
        _atLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, [[UIScreen mainScreen] qim_rightWidth], 51)];
        _atLabel.text = @"     @ 提醒谁看";
        _atLabel.textAlignment = NSTextAlignmentLeft;
        _atLabel.backgroundColor = [UIColor whiteColor];
        _atLabel.textColor = [UIColor qim_colorWithHex:0x333333];
        _atLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(atSomeone:)];
        [_atLabel addGestureRecognizer:tap];
    }
    return _atLabel;
}

- (UITableView *)panelListView {
    if (!_panelListView) {
//        _panelListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 51, [[UIScreen mainScreen] qim_rightWidth], [[UIScreen mainScreen] height]) style:UITableViewStylePlain];
        _panelListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] qim_rightWidth], [[UIScreen mainScreen] height]) style:UITableViewStylePlain];
        _panelListView.backgroundColor = [UIColor qim_colorWithHex:0xf8f8f8];
        _panelListView.delegate = self;
        _panelListView.dataSource = self;
        _panelListView.estimatedRowHeight = 0;
        _panelListView.estimatedSectionHeaderHeight = 0;
        _panelListView.estimatedSectionFooterHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _panelListView.tableFooterView = [UIView new];
        _panelListView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _panelListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _panelListView.bounces = NO;
        _panelListView.scrollEnabled = NO;
    }
    return _panelListView;
}

- (NSMutableArray *)workmomentPushPanelModels {
    if (!_workmomentPushPanelModels) {
        _workmomentPushPanelModels = [NSMutableArray arrayWithCapacity:3];
        
        QIMWorkMomentPanelModel *model1 = [[QIMWorkMomentPanelModel alloc] init];
        model1.icon = @"";
        model1.title = @"发帖身份";
        [_workmomentPushPanelModels addObject:model1];
        
        /*
        QIMWorkMomentPanelModel *model2 = [[QIMWorkMomentPanelModel alloc] init];
        model2.icon = @"";
        model2.title = @"发起活动";
        [_workmomentPushPanelModels addObject:model2];
        
        QIMWorkMomentPanelModel *model3 = [[QIMWorkMomentPanelModel alloc] init];
        model3.icon = @"";
        model3.title = @"发起投票";
        [_workmomentPushPanelModels addObject:model3];
        */
    }
    return _workmomentPushPanelModels;
}

- (NSMutableArray *)selectPhotos {
    if (!_selectPhotos) {
        _selectPhotos = [NSMutableArray arrayWithCapacity:1];
//        if (self.shareWorkMoment == NO && self.shareLinkUrlDic.count <= 0) {
//            [_selectPhotos addObject:@"Q_Work_Add"];
//        }
    }
    return _selectPhotos;
}

- (void)beginSortSelectPhotos {
    NSString * item = self.selectPhotos.lastObject;
    [self.selectPhotos removeObject:@"Q_Work_Add"];
    [self.photoCollectionView reloadData];
}

- (void)updateSelectPhotos {
    
    if (self.currentSelectMediaType == QIMWorkMomentMediaTypeVideo) {
        //不能再选择图片，不展示➕
        
    } else {
        if (self.selectPhotos.count >= 9) {
            //新增图片之后>=9，移除➕
            [self.selectPhotos removeObject:@"Q_Work_Add"];
        } else {
            //新增图片之后<9，新增➕
            
            NSInteger maxCount = 9 - self.selectPhotos.count;
            [[QTPHImagePickerManager sharedInstance] setMaximumNumberOfSelection:maxCount];
            //        [[QTPHImagePickerManager sharedInstance] setNotAllowSelectVideo:YES];
            [self.selectPhotos addObject:@"Q_Work_Add"];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.photoCollectionView reloadData];
    });
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[QIMKit sharedInstance] getIsIpad] == YES) {
        [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] qim_rightWidth], [[UIScreen mainScreen] height])];
    }
    QIMVerboseLog(@"即将进入发帖页面匿名名称 : %@", [[QIMWorkMomentUserIdentityManager sharedInstance] anonymousName]);
    QIMVerboseLog(@"即将进入发帖页面匿名状态 : %d", [[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous]);
    QIMVerboseLog(@"即将进入发帖页面匿名头像地址 : %@", [[QIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto]);
//    [self.panelListView reloadData];
    
    [self.identiView updatePushUserIdentityView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupNav {

    self.navigationItem.title = @"发布动态";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x333333]}];
    if (self.shareWorkMoment) {
        self.navigationController.navigationBar.translucent = NO;
    } else {
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
        [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    }
    UIBarButtonItem *newMomentBtn = [[UIBarButtonItem alloc] initWithCustomView:self.pushBtn];
    [[self navigationItem] setRightBarButtonItem:newMomentBtn];
}

- (UIButton *)pushBtn {
    if (!_pushBtn) {
        _pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pushBtn setFrame:CGRectMake(0, 0, 36, 18)];
        [_pushBtn setTitle:@"发布" forState:UIControlStateNormal];
        [_pushBtn setTitle:@"发布" forState:UIControlStateDisabled];
        [_pushBtn setTitleColor:[UIColor qim_colorWithHex:0xBFBFBF] forState:UIControlStateDisabled];
        [_pushBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_pushBtn addTarget:self action:@selector(pushNewMoment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushBtn;
}

- (void)setupUI {
    [self.view addSubview:self.photoCollectionView];
    [self.view addSubview:self.keyboardToolView];
    [self setupKeyBoardTools];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.photoCollectionView addSubview:_progressHUD];
    _progressHUD.hidden = YES;
    [[YYKeyboardManager defaultManager] addObserver:self];
    [[QTPHImagePickerManager sharedInstance] setMaximumNumberOfSelection:9];
//    [[QTPHImagePickerManager sharedInstance] setNotAllowSelectVideo:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor qim_colorWithHex:0xF7F7F7];
    self.view.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
    [self setupNav];
    [self setupUI];
    self.momentId = [NSString stringWithFormat:@"0-%@", [QIMUUIDTools UUID]];
    [self.textView becomeFirstResponder];
}

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGRect kbFrame1 = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    CGFloat kbFrameOriginY = CGRectGetMinY(kbFrame1);
    CGFloat kbFrameHeight = CGRectGetHeight(kbFrame1);
    CGRect kbFrame = [[YYKeyboardManager defaultManager] keyboardFrame];
    if (kbFrameOriginY + kbFrameHeight > SCREEN_HEIGHT) {
        //键盘落下
        [UIView animateWithDuration:0.25 animations:^{
            //键盘落下
            self.keyboardToolView.frame = CGRectMake(0, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - 80, self.view.width, 80);
        } completion:nil];
    } else {
        //键盘弹起
        [UIView animateWithDuration:0.25 animations:^{
            self.keyboardToolView.frame = CGRectMake(0, kbFrameOriginY - 80, self.view.width, 80);
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)atSomeone:(UITapGestureRecognizer *)tap {
    QIMWorkFeedAtNotifyViewController * qNoticeVC = [[QIMWorkFeedAtNotifyViewController alloc] init];
    __weak __typeof(&*self) weakSelf = self;
    
    [qNoticeVC onQIMWorkFeedSelectUser:^(NSArray *selectUsers) {
        NSLog(@"selectUsers : %@", selectUsers);
        for (NSString *userXmppJid in selectUsers) {
            if (userXmppJid.length > 0) {
                NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userXmppJid];
                if (userInfo.count > 0) {
                    NSString *name = [userInfo objectForKey:@"Name"];
                    NSString *jid = [userInfo objectForKey:@"XmppId"];
                    NSString *memberName = [NSString stringWithFormat:@"@%@ ", name];
                    
                    QIMATGroupMemberTextAttachment *atTextAttachment = [[QIMATGroupMemberTextAttachment alloc] init];
                    CGSize size = [memberName qim_sizeWithFontCompatible:self.textView.font];
                    atTextAttachment.image = [UIImage qim_imageWithColor:[UIColor whiteColor] size:CGSizeMake(size.width, self.textView.font.lineHeight) text:memberName textAttributes:@{NSFontAttributeName:self.textView.font} circular:NO];
                    atTextAttachment.groupMemberName = memberName;
                    atTextAttachment.groupMemberJid = jid;
                    
                    [self.textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:atTextAttachment] atIndex:self.textView.selectedRange.location];
                    self.textView.selectedRange = NSMakeRange(MIN(self.textView.selectedRange.location + 1, self.textView.text.length - self.textView.selectedRange.length), self.textView.selectedRange.length);
                    [self resetTextStyle];
                    
                } else {
                    QIMVerboseLog(@"未选择要艾特的群成员");
                    weakSelf.textView.selectedRange = NSMakeRange(weakSelf.textView.selectedRange.location + self.textView.selectedRange.length + 1, 0);
                    [weakSelf resetTextStyle];
                }
            }
        }
    }];
    
    if ([[QIMKit sharedInstance] getIsIpad]) {
        qNoticeVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        QIMNavController *qtalNav = [[QIMNavController alloc] initWithRootViewController:qNoticeVC];
        qtalNav.modalPresentationStyle = UIModalPresentationCurrentContext;
#if __has_include("QIMIPadWindowManager.h")
        [[[QIMIPadWindowManager sharedInstance] detailVC] presentViewController:qtalNav animated:YES completion:nil];
#endif
    } else {
        [weakSelf.navigationController pushViewController:qNoticeVC animated:YES];
    }
}

- (void)resetTextStyle {
    //After changing text selection, should reset style.
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.firstLineHeadIndent = 0;    /**首行缩进宽度*/
    if (self.textView.textStorage.length <= 0) {
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:17],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
    }else{
        NSRange wholeRange = NSMakeRange(0, self.textView.textStorage.length);
        [self.textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
        [self.textView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:wholeRange];
        [self.textView.textStorage removeAttribute:NSParagraphStyleAttributeName range:wholeRange];
    }
    [self.textView setFont:[UIFont systemFontOfSize:17]];
}

- (void)onPhotoButtonClick:(UIButton *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.view endEditing:YES];
    });
    __weak QIMWorkMomentPushViewController *weakSelf = self;
    [QIMAuthorizationManager sharedManager].authorizedBlock = ^{
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        QTPHImagePickerController *picker = [[QTPHImagePickerController alloc] init];
        picker.delegate = strongSelf;
        picker.title = @"选取照片";
        picker.customDoneButtonTitle = @"";
        picker.customCancelButtonTitle = @"取消";
        picker.customNavigationBarPrompt = nil;
        
        picker.colsInPortrait = 4;
        picker.colsInLandscape = 5;
        picker.minimumInteritemSpacing = 2.0;
        if ([[QIMKit sharedInstance] getIsIpad] == YES) {
            picker.modalPresentationStyle = UIModalPresentationCurrentContext;
            [strongSelf presentViewController:picker animated:YES completion:nil];
        } else {
            [[[UIApplication sharedApplication] visibleViewController] presentViewController:picker animated:YES completion:nil];
        }
    };
    [[QIMAuthorizationManager sharedManager] requestAuthorizationWithType:ENUM_QAM_AuthorizationTypePhotos];
}

- (void)goBack:(id)sender {
    [[QIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
//    [[QTPHImagePickerManager sharedInstance] setNotAllowSelectVideo:NO];
    if (self.shareWorkMoment) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//判断内容是否全部为空格  YES 全部为空格
- (BOOL)isEmpty:(NSString *)str {
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)pushNewMoment:(id)sender {
    QIMVerboseLog(@"发布了一条新动态");
    if (self.textView.text.length > QIMWORKMOMENTLIMITNUM) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [QTalkTipsView showTips:[NSString stringWithFormat:@"动态内容不能超过%ld字哦～", QIMWORKMOMENTLIMITNUM] InView:self.view];
        });
        return;
    }
    
    BOOL selectPhoto = (self.selectPhotos.count == 1) && ([[self.selectPhotos firstObject] isEqualToString:@"Q_Work_Add"]);
    
    if ((self.textView.text.length <= 0 || [self isEmpty:self.textView.text]) && selectPhoto)  {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请尽情发挥吧..." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:okAction];
        [self.navigationController presentViewController:alertVc animated:YES completion:nil];
    } else {
        [self showProgressHUDWithMessage:@"动态上传中..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showProgressHUDWithMessage:@"动态上传中..."];
            NSMutableDictionary *momentDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [momentDic setQIMSafeObject:self.momentId forKey:@"uuid"];
            [momentDic setQIMSafeObject:[QIMKit getLastUserName] forKey:@"owner"];
            [momentDic setQIMSafeObject:[[QIMKit sharedInstance] getDomain] forKey:@"ownerHost"];
            [momentDic setQIMSafeObject:@([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous]) forKey:@"isAnonymous"];
            if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
                [momentDic setQIMSafeObject:@"" forKey:@"AnonymousName"];
                [momentDic setQIMSafeObject:@"" forKey:@"AnonymousPhoto"];
            } else {
                [momentDic setQIMSafeObject:[[QIMWorkMomentUserIdentityManager sharedInstance] anonymousName] forKey:@"AnonymousName"];
                [momentDic setQIMSafeObject:[[QIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto] forKey:@"AnonymousPhoto"];
            }
            
            NSMutableArray *outATInfoArray = [NSMutableArray arrayWithCapacity:3];
            NSString *finallyContent = [[QIMMessageTextAttachment sharedInstance] getStringFromAttributedString:self.textView.attributedText WithOutAtInfo:&outATInfoArray];
            
            NSMutableDictionary *momentContentDic = [[NSMutableDictionary alloc] initWithCapacity:3];
            if (self.shareLinkUrlDic.count > 0) {
                [momentContentDic setQIMSafeObject:@"分享了一条链接!" forKey:@"content"];
            } else {
                [momentContentDic setQIMSafeObject:finallyContent forKey:@"content"];
            }
            [momentContentDic setQIMSafeObject:[[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:finallyContent] forKey:@"exContent"];
            NSMutableArray *imageList = [[NSMutableArray alloc] init];
            dispatch_group_t group = dispatch_group_create();
            for (id imageData in self.selectPhotos) {
                if ([imageData isKindOfClass:[NSData class]]) {
                    dispatch_group_enter(group);
                    NSString *fileUrl = [QIMKit updateLoadMomentFile:imageData WithMsgId:[QIMUUIDTools UUID] WithMsgType:QIMMessageType_Image WithPathExtension:@"png"];
                    if (fileUrl.length > 0) {
                        NSDictionary *imageDic = @{@"addTime":@(0), @"data":fileUrl};
                        [imageList addObject:imageDic];
                        dispatch_group_leave(group);
                    }
                }
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                
                [momentContentDic setQIMSafeObject:imageList forKey:@"imgList"];
                if (imageList.count > 0) {
                    [momentContentDic setQIMSafeObject:@(QIMWorkFeedContentTypeImage) forKey:@"type"];
                } else if (self.shareLinkUrlDic.count > 0) {
                    [momentContentDic setQIMSafeObject:self.shareLinkUrlDic forKey:@"linkContent"];
                    [momentContentDic setQIMSafeObject:@(QIMWorkFeedContentTypeLink) forKey:@"type"];
                } else {
                    [momentContentDic setQIMSafeObject:@(QIMWorkFeedContentTypeText) forKey:@"type"];
                }
//                [momentContentDic setQIMSafeObject:@(0) forKey:@"type"];
                NSString *momentContent = [[QIMJSONSerializer sharedInstance] serializeObject:momentContentDic];
                [momentDic setQIMSafeObject:momentContent forKey:@"content"];
                [momentDic setQIMSafeObject:outATInfoArray forKey:@"atList"];
                QIMVerboseLog(@"outATInfoArray: %@", outATInfoArray);
                QIMVerboseLog(@"momentContentDic : %@", momentContentDic);
                QIMVerboseLog(@"momentDic: %@", momentDic);
                QIMVerboseLog(@"imageList : %@", imageList);
                [momentDic setObject:@(7) forKey:@"postType"];
                [[QIMKit sharedInstance] pushNewMomentWithMomentDic:momentDic withCallBack:^(BOOL successed) {
                    if (successed) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self hideProgressHUD:YES];
                        });
                        [self goBack:nil];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self hideProgressHUD:YES];
                            dispatch_after(3, dispatch_get_main_queue(), ^{
                               [QTalkTipsView showTips:[NSString stringWithFormat:@"发布驼圈失败，请稍后重试"] InView:self.view];
                            });
                        });
                    }
                }];
            });
        });
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    // 判断是否存在高亮字符，如果有，则不进行字数统计和字符串截断
    UITextRange *selectedRange = textView.markedTextRange;
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (position) {
        return;
    }
    
    // 判断是否超过最大字数限制，如果超过就截断
    NSInteger textLength = textView.text.length;
    
    // 剩余字数显示 UI 更新
    if (textLength - (NSInteger)QIMWORKMOMENTLIMITNUM > 0) {
        
        self.remainingLabel.textColor = [UIColor qim_colorWithHex:0xA5A5A5];
        NSString *numStr = [NSString stringWithFormat:@"%ld", textLength - (NSInteger)QIMWORKMOMENTLIMITNUM];
        NSString *str = [NSString stringWithFormat:@"已超出%@个字", numStr];
        NSMutableAttributedString *muString = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0xA5A5A5]}];
        [muString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[str rangeOfString:numStr]];
        self.remainingLabel.attributedText = muString;
    } else if ((NSInteger)QIMWORKMOMENTLIMITNUM - textLength <= 10) {
        self.remainingLabel.text = [NSString stringWithFormat:@"%ld/%ld", textLength,(NSInteger)QIMWORKMOMENTLIMITNUM];
        self.remainingLabel.textColor = [UIColor orangeColor];
    } else {
        self.remainingLabel.text = [NSString stringWithFormat:@"%ld/%ld", textLength,(NSInteger)QIMWORKMOMENTLIMITNUM];
        self.remainingLabel.textColor = [UIColor qim_colorWithHex:0xA5A5A5];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //输入
    if ([text isEqualToString:@"@"]) {
        text = @"";
        QIMWorkFeedAtNotifyViewController * qNoticeVC = [[QIMWorkFeedAtNotifyViewController alloc] init];
        __weak __typeof(&*self) weakSelf = self;
        
        [qNoticeVC onQIMWorkFeedSelectUser:^(NSArray *selectUsers) {
            NSLog(@"selectUsers : %@", selectUsers);
            if (selectUsers.count <= 0) {
                
                NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:@"@"];
                [self.textView.textStorage insertAttributedString:attStr atIndex:self.textView.selectedRange.location];
                self.textView.selectedRange = NSMakeRange(MIN(self.textView.selectedRange.location + 1, self.textView.text.length - self.textView.selectedRange.length), self.textView.selectedRange.length);
                [self resetTextStyle];
            } else {
                for (NSString *userXmppJid in selectUsers) {
                    if (userXmppJid.length > 0) {
                        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userXmppJid];
                        if (userInfo.count > 0) {
                            NSString *name = [userInfo objectForKey:@"Name"];
                            NSString *jid = [userInfo objectForKey:@"XmppId"];
                            NSString *memberName = [NSString stringWithFormat:@"@%@ ", name];
                            
                            QIMATGroupMemberTextAttachment *atTextAttachment = [[QIMATGroupMemberTextAttachment alloc] init];
                            CGSize size = [memberName qim_sizeWithFontCompatible:self.textView.font];
                            atTextAttachment.image = [UIImage qim_imageWithColor:[UIColor whiteColor] size:CGSizeMake(size.width, self.textView.font.lineHeight) text:memberName textAttributes:@{NSFontAttributeName:self.textView.font} circular:NO];
                            atTextAttachment.groupMemberName = memberName;
                            atTextAttachment.groupMemberJid = jid;
                            
                            [self.textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:atTextAttachment] atIndex:self.textView.selectedRange.location];
                            self.textView.selectedRange = NSMakeRange(MIN(self.textView.selectedRange.location + 1, self.textView.text.length - self.textView.selectedRange.length), self.textView.selectedRange.length);
                            [self resetTextStyle];
                        } else {
                            QIMVerboseLog(@"未选择要艾特的群成员");
                            weakSelf.textView.selectedRange = NSMakeRange(weakSelf.textView.selectedRange.location + self.textView.selectedRange.length + 1, 0);
                            [weakSelf resetTextStyle];
                        }
                    }
                }
            }
        }];
        
        if ([[QIMKit sharedInstance] getIsIpad]) {
            qNoticeVC.modalPresentationStyle = UIModalPresentationCurrentContext;
            QIMNavController *qtalNav = [[QIMNavController alloc] initWithRootViewController:qNoticeVC];
            qtalNav.modalPresentationStyle = UIModalPresentationCurrentContext;
#if __has_include("QIMIPadWindowManager.h")
            [[[QIMIPadWindowManager sharedInstance] detailVC] presentViewController:qtalNav animated:YES completion:nil];
#endif
        } else {
            [weakSelf.navigationController pushViewController:qNoticeVC animated:YES];
        }
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDatasource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.textView) {
        [self.textView resignFirstResponder];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectPhotos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkMomentPushCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.backgroundColor = [UIColor whiteColor];
    id photoData = [self.selectPhotos objectAtIndex:indexPath.row];
    cell.dDelegate = self;
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:cell.bounds];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.layer.cornerRadius = 2.4f;
    iconView.layer.masksToBounds = YES;
    if ([photoData isKindOfClass:[NSString class]]) {
        if ([photoData isEqualToString:@"Q_Work_Add"]) {
            iconView.image = [UIImage qim_imageNamedFromQIMUIKitBundle:@"q_work_add"];
            iconView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:iconView];
            [cell setCanDelete:NO];
        }
    } else {
        NSDictionary *mediaDic = (NSDictionary *)photoData;
        NSInteger mediaType = [[mediaDic objectForKey:@"MediaType"] integerValue];
        if (mediaType == QIMWorkMomentMediaTypeImage) {
            //图片
//            NSDictionary *imageMediaDic = @{@"MediaType":@(0), @"imageDic": @{@"imageData" : pngData}};
            NSDictionary *imageDic = [mediaDic objectForKey:@"imageDic"];
            NSData *imageData = [imageDic objectForKey:@"imageData"];
            iconView.image = [UIImage imageWithData:imageData];
            [cell.contentView addSubview:iconView];
            [cell setMediaType:QIMWorkMomentMediaTypeImage];
            [cell setCanDelete:YES];
        } else if (mediaType == QIMWorkMomentMediaTypeVideo) {
            //视频
            
//            NSDictionary *videoDic = @{@"MediaType":@(1), @"VideoDic": @{@"videoOutPath" : videoOutPath, @"fileSizeStr":fileSizeStr, @"videoDuration":@(videoDuration), @"thumbImage":thumbImage}};

            NSDictionary *videoDic = [mediaDic objectForKey:@"VideoDic"];
            UIImage *thumbImage = [videoDic objectForKey:@"thumbImage"];
            iconView.image = thumbImage;
            [cell.contentView addSubview:iconView];
            [cell setMediaType:QIMWorkMomentMediaTypeVideo];
            [cell setCanDelete:YES];
            
        } else {
            
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id photoData = [self.selectPhotos objectAtIndex:indexPath.row];
    if ([photoData isKindOfClass:[NSString class]]) {
        if ([photoData isEqualToString:@"Q_Work_Add"]) {
            QIMVerboseLog(@"进去选图界面");
            [self onPhotoButtonClick:nil];
        }
    } else {
        NSDictionary *mediaDic = (NSDictionary *)photoData;
        NSInteger mediaType = [[mediaDic objectForKey:@"MediaType"] integerValue];
        if (mediaType == QIMWorkMomentMediaTypeImage) {
            //初始化图片浏览控件
            QIMMWPhotoBrowser *browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = NO;
            browser.zoomPhotosToFill = YES;
            browser.enableSwipeToDismiss = NO;
            browser.autoPlayOnAppear = YES;
            [browser setCurrentPhotoIndex:indexPath.row];
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            
            //初始化navigation
            QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
        } else if (mediaType == QIMWorkMomentMediaTypeVideo) {
            //            NSDictionary *videoDic = @{@"MediaType":@(1), @"VideoDic": @{@"videoOutPath" : videoOutPath, @"fileSizeStr":fileSizeStr, @"videoDuration":@(videoDuration), @"thumbImage":thumbImage}};
            
            NSDictionary *videoDic = [mediaDic objectForKey:@"VideoDic"];
            UIImage *thumbImage = [videoDic objectForKey:@"thumbImage"];
            NSString *videoOutPath = [videoDic objectForKey:@"videoOutPath"];
            
            QIMVideoPlayerVC *videoPlayVC = [[QIMVideoPlayerVC alloc] init];  
            [videoPlayVC setVideoPath:videoOutPath];
            [self.navigationController pushViewController:videoPlayVC animated:YES];
        } else {
            
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:self.textView];
        if (self.shareLinkUrlDic.count > 0) {
            [headerView addSubview:self.linkView];
        }
        return headerView;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor whiteColor];
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] qim_rightWidth], 1.0f)];
//        lineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
//        [footerView addSubview:lineView];
//        [footerView addSubview:self.atLabel];
//        [footerView addSubview:self.panelListView];
        return footerView;
    } else {
        return nil;
    }
}

#pragma mark - QIMDragCellCollectionViewDelegate, QIMDragCellCollectionViewDataSource

- (NSArray *)dataSourceArrayOfCollectionView:(QIMCollectionEmotionPanView *)collectionView{
    
    return _selectPhotos;
}

- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    
    [_selectPhotos removeAllObjects];
    [_selectPhotos addObjectsFromArray:newDataArray];
}

- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath{
    //拖动时候最后禁用掉编辑按钮的点击
}

- (void)dragCellCollectionViewCellEndMoving:(QIMCollectionEmotionPanView *)collectionView{
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.workmomentPushPanelModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkMomentPushUserIdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[QIMWorkMomentPushUserIdentityCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellId"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    QIMWorkMomentPanelModel *model = [self.workmomentPushPanelModels objectAtIndex:indexPath.row];
    cell.textLab.text = model.title;
    cell.iconView.contentMode = UIViewContentModeScaleAspectFill;
    if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
        [cell.iconView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
    } else {
        NSString *anonymousPhoto = [[QIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
        [cell.iconView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.textColor = [UIColor qim_colorWithHex:0x999999];
    if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
        cell.detailTextLabel.text = @"实名发布";
    } else {
        cell.detailTextLabel.text = @"匿名发布";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QIMWorkMomentPanelModel *model = [self.workmomentPushPanelModels objectAtIndex:indexPath.row];
    NSString *modelId = model.title;
    if ([modelId isEqualToString:@"发帖身份"]) {
        QIMWorkMomentUserIdentityVC *identityVc = [[QIMWorkMomentUserIdentityVC alloc] init];
        identityVc.momentId = self.momentId;
        [self.navigationController pushViewController:identityVc animated:YES];
    } else if ([modelId isEqualToString:@""]) {
        
    } else {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8.0f;
}

#pragma mark - QTPHImagePickerControllerDelegate

- (void)assetsPickerControllerDidCancel:(QTPHImagePickerController *)picker {
    
}

- (void)assetsPickerController:(QTPHImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [self sendAssetList:[NSMutableArray arrayWithArray:assets] ForPickerController:picker];
}

-(void)assetsPickerController:(QTPHImagePickerController *)picker didFinishEditWithImage:(UIImage *)image
{
    NSData * imageData = UIImageJPEGRepresentation(image, 1.0);
    [self.selectPhotos removeObject:@"Q_Work_Add"];
    [self.selectPhotos addObject:imageData];
    [self updateSelectPhotos];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)sendAssetList:(NSMutableArray *)assetList ForPickerController:(QTPHImagePickerController *)picker{
    PHCachingImageManager * imageManager = [[PHCachingImageManager alloc] init];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize targetSize = picker.isOriginal ? PHImageManagerMaximumSize : screenSize;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    
    __block PHAsset *asset = assetList.firstObject;
    [assetList removeObject:asset];
    if (asset) {
        if (asset.mediaType ==  PHAssetMediaTypeImage) {
            [self showProgressHUDWithMessage:@"图片处理中"];
            [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                //gif 图片
                QIMVerboseLog(@"choose Image Url : %@", dataUTI);
                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                    if (downloadFinined && imageData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.selectPhotos removeObject:@"Q_Work_Add"];
                            NSDictionary *imageDic = @{@"MediaType":@(QIMWorkMomentMediaTypeImage), @"imageDic": @{@"imageData" : imageDic}};
                            [self.selectPhotos addObject:imageDic];
                            self.currentSelectMediaType = QIMWorkMomentMediaTypeVideo;
                            [self updateSelectPhotos];
                            [self hideProgressHUD:YES];
                        });
                    }
                } else if ([dataUTI isEqualToString:@"public.heic"] || [dataUTI isEqualToString:@"public.heif"]) {
                    CIImage *ciImage = [CIImage imageWithData:imageData];
                    CIContext *context = [CIContext context];
                    NSData *pngData = [context PNGRepresentationOfImage:ciImage format:kCIFormatARGB8 colorSpace:ciImage.colorSpace options:@{}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.selectPhotos removeObject:@"Q_Work_Add"];
                        NSDictionary *imageDic = @{@"MediaType":@(QIMWorkMomentMediaTypeImage), @"imageDic": @{@"imageData" : pngData}};

                        [self.selectPhotos addObject:imageDic];
                        self.currentSelectMediaType = QIMWorkMomentMediaTypeVideo;
                        [self updateSelectPhotos];
                        [self hideProgressHUD:YES];
                    });
                } else {
                    BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (downloadFinined) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage * imageFix = [QIMImageUtil fixOrientation:[UIImage imageWithData:imageData]];
                            if ((imageFix.size.width > 512 || imageFix.size.height > 512) && (!picker.isOriginal)) {
                                CGFloat height = (imageFix.size.height / imageFix.size.width) * 512;
                                imageFix = [imageFix qim_imageByScalingAndCroppingForSize:CGSizeMake(512, height)];
                            }
                            [self.selectPhotos removeObject:@"Q_Work_Add"];
                            NSDictionary *imageDic = @{@"MediaType":@(QIMWorkMomentMediaTypeImage), @"imageDic": @{@"imageData" : imageData}};
                            [self.selectPhotos addObject:imageDic];
                            self.currentSelectMediaType = QIMWorkMomentMediaTypeVideo;
                            [self updateSelectPhotos];
                            [self hideProgressHUD:YES];
                        });
                    }
                }
            }];
            [self sendAssetList:assetList ForPickerController:picker];
        } else if (asset.mediaType == PHAssetMediaTypeVideo){
            int videoDuration = (int)(asset.duration);
            [imageManager requestAVAssetForVideo:asset
                                         options:nil
                                   resultHandler:
             ^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                 NSString * videoResultPath = nil;
                 if (picker.videoPath) {
                     videoResultPath = picker.videoPath;
                 } else {
                     NSString * key = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
                     videoResultPath = [[key componentsSeparatedByString:@";"] lastObject];
                 }
                 NSString *fileSizeStr = [QIMStringTransformTools CapacityTransformStrWithSize:[self getFileSize:videoResultPath]];
                 AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                 gen.appliesPreferredTrackTransform = YES;
                 CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                 NSError *error = nil;
                 CMTime actualTime;
                 CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                 UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                 CGImageRelease(image);
                 NSString *videoOutPath = videoResultPath;
                 UIImage *thumbImage = thumb;
                 
                 NSDictionary *videoDic = @{@"MediaType":@(QIMWorkMomentMediaTypeVideo), @"VideoDic": @{@"videoOutPath" : videoOutPath, @"fileSizeStr":fileSizeStr, @"videoDuration":@(videoDuration), @"thumbImage":thumbImage}};
                 [self.selectPhotos removeObject:@"Q_Work_Add"];
                 [self.selectPhotos addObject:videoDic];
                 self.currentSelectMediaType = QIMWorkMomentMediaTypeVideo;
                 [self updateSelectPhotos];
                 [self hideProgressHUD:YES];
             }];
            [self sendAssetList:assetList ForPickerController:picker];
        } else {
            
        }
    } else {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

//获取文件大小
- (CGFloat) getFileSize:(NSString *)path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size;
    }
    return filesize;
}

//获取video长度
- (CGFloat) getVideoLength:(NSURL *)URL {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

#pragma mark - QIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser {
    if (self.selectPhotos.count >= 9) {
        return self.selectPhotos.count;
    }
    return self.selectPhotos.count - 1;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSArray *tempImageArr = _selectPhotos;
    if (index > tempImageArr.count) {
        return nil;
    }
    NSDictionary *mediaDic = [self.selectPhotos objectAtIndex:index];
    NSInteger mediaType = [[mediaDic objectForKey:@"MediaType"] integerValue];
    if (mediaType == QIMWorkMomentMediaTypeImage) {
        NSDictionary *imageDic = [mediaDic objectForKey:@"imageDic"];
        NSData *imageData = [imageDic objectForKey:@"imageData"];
        if (imageData.length > 0) {
            QIMMWPhoto *photo = [[QIMMWPhoto alloc] initWithImage:[UIImage qim_animatedImageWithAnimatedGIFData:imageData]];
            photo.photoData = imageData;
            return photo;
        }
    } else if (mediaType == QIMWorkMomentMediaTypeVideo) {
        
//        NSDictionary *videoDic = @{@"MediaType":@(1), @"VideoDic": @{@"videoOutPath" : videoOutPath, @"fileSizeStr":fileSizeStr, @"videoDuration":@(videoDuration), @"thumbImage":thumbImage}};
        NSDictionary *videoDic = [mediaDic objectForKey:@"VideoDic"];
        NSString *videoOutPath = [videoDic objectForKey:@"videoOutPath"];
        UIImage *thumbImage = [videoDic objectForKey:@"thumbImage"];
        QIMMWPhoto *video = [[QIMMWPhoto alloc] initWithImage:thumbImage];
        video.videoURL = [NSURL fileURLWithPath:videoOutPath];
        
        return video;
        
    } else {
        
    }
    return nil;
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
    }];
}

- (void)removeSelectPhoto:(QIMWorkMomentPushCell *)cell {
    NSInteger cellTag = cell.tag;
    [self.selectPhotos removeObjectAtIndex:cellTag];
    [self.selectPhotos removeObject:@"Q_Work_Add"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateSelectPhotos];
    });
}

- (void)dealloc {
    [[YYKeyboardManager defaultManager] removeObserver:self];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
}

#pragma mark - QIMWorkMomentPushUserIdentityViewDelegate

- (void)openUserIdentity {
    QIMWorkMomentUserIdentityVC *identityVc = [[QIMWorkMomentUserIdentityVC alloc] init];
    identityVc.momentId = self.momentId;
    [self.navigationController pushViewController:identityVc animated:YES];
}

@end

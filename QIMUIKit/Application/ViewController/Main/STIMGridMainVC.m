//
//  STIMGridMainVC.m
//  AFNetworking
//
//  Created by admin on 2019/12/9.
//

#import "STIMGridMainVC.h"

#import "Masonry.h"
#import "UIColor+STIMUtility.h"
#import "STIMPublicRedefineHeader.h"
#import "STIMKit.h"
#import "STIMKit+STIMUserCacheManager.h"
#import "STIMKit+STIMUserVcard.h"
#import "STIMKit+STIMLogin.h"
#import "STIMKit+STIMNavConfig.h"
#import "STIMUUIDTools.h"
#import "STIMNavBackBtn.h"
#import "STIMNavTitleView.h"
#import "UIView+TTCategory.h"
#import "UIImageView+WebCache.h"
#import "UIApplication+STIMApplication.h"

#import "STIMNavController.h"
#import "QTalkSessionView.h"
#import "STIMUserListView.h"
#import "STIMGroupCreateVC.h"
#import "QTalkEverNotebookVC.h"
#import "STIMMySettingController.h"
#import "STIMMineTableView.h"
#import "STIMZBarViewController.h"
#import "STIMJumpURLHandle.h"
#define kItemCap 16

typedef enum {
    STIMGridItemType_Message,           // 消息
    STIMGridItemType_Contact,           // 通讯录
    STIMGridItemType_CreateGroup,       // 创建群众
    STIMGridItemType_FileTransfer,      // 文件传输
    STIMGridItemType_Self,              // 我的
    STIMGridItemType_Route,             // 行程
    STIMGridItemType_Setting,           // 设置
    STIMGridItemType_Scan,              // 扫一扫
    STIMGridItemType_Notebook,          // 笔记本
}STIMGridItemType;

@interface STIMGridItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) int bgColor;
@property (nonatomic, assign) STIMGridItemType itemType;
@property (nonatomic, copy) void(^clickAction)(void);
@end
@implementation STIMGridItem @end

@interface STIMGridCell : UICollectionViewCell
@property (nonatomic, strong) STIMGridItem *gridItem;
@property (nonatomic, strong) UIView *gridContentView;
@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation STIMGridCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.gridContentView = [[UIView alloc] init];
        [self.gridContentView setBackgroundColor:[UIColor redColor]];
        [self.gridContentView.layer setCornerRadius:10];
        [self.gridContentView setClipsToBounds:YES];
        [self.contentView addSubview:self.gridContentView];
        [self.gridContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView);
        }];
        
        UIView *itemtView = [[UIView alloc] init];
        [self.gridContentView addSubview:itemtView];
        [itemtView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(self.gridContentView);
            make.left.right.mas_equalTo(self.gridContentView);
        }];
         
        self.iconView = [[UIView alloc] init];
        [self.iconView setClipsToBounds:YES];
        [self.iconView.layer setCornerRadius:22];
        [self.iconView setBackgroundColor:[UIColor stimDB_colorWithHex:0x0 alpha:0.1]];
        [itemtView addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(itemtView);
            make.centerX.mas_equalTo(itemtView);
            make.width.height.mas_equalTo(44);
        }];
        
        self.iconImageView = [[UIImageView alloc] init];
        [self.iconImageView setContentMode:UIViewContentModeScaleToFill];
        [self.iconView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(self.iconView).offset(10);
            make.right.bottom.mas_equalTo(self.iconView).offset(-10);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [itemtView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconView.mas_bottom).offset(6);
            make.left.right.mas_equalTo(itemtView);
            make.bottom.mas_equalTo(itemtView);
        }];
        
    }
    return self;
}

- (void)refreshUI {

    [self.gridContentView setBackgroundColor:[UIColor stimDB_colorWithHex:self.gridItem.bgColor]];
    [self.iconImageView setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:self.gridItem.imageName]];
    [self.titleLabel setText:self.gridItem.title];
    
}

@end

@interface STIMGridMainFlowLayout : UICollectionViewFlowLayout

@end

@implementation STIMGridMainFlowLayout

-(id)init
{
    self = [super init];
    if (self) {
        CGFloat collectionWidth = [UIScreen mainScreen].bounds.size.width - kItemCap * 2;
        CGFloat itemCap = 9;
        CGFloat itemWidth = ceilf(((float)(collectionWidth - itemCap * 2)/ [self rowItemCount]));
        self.itemSize  = CGSizeMake(itemWidth, itemWidth / (83.5 / 59));
        self.minimumInteritemSpacing = itemCap;
        self.minimumLineSpacing = itemCap;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.headerReferenceSize = CGSizeMake(0, 200);
    }

    return self;
}

- (int)rowItemCount {
    return 2;
}

@end

@interface STIMGridRootVC : QTalkViewController
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation STIMGridRootVC
 
- (instancetype)initWithRootView:(UIView *)rootView {
    self = [super init];
    if (self) {
        self.rootView = rootView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[STIMNavBackBtn sharedInstance] addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[STIMNavBackBtn sharedInstance] removeTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftBarBtnClicked:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = stimDB_singlechat_title_color;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:stimDB_singlechat_title_size];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _titleLabel;
}

- (void)initTitleView {
    STIMNavTitleView *titleView = [[STIMNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleView.autoresizesSubviews = YES;
    titleView.backgroundColor = [UIColor clearColor];
    [titleView addSubview:self.titleLabel];
    self.navigationItem.titleView = titleView;
}
- (void)setBackBtn {
    STIMNavBackBtn *backBtn = [STIMNavBackBtn sharedInstance];
    [backBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //将宽度设为负值
    spaceItem.width = -15;
    //将两个BarButtonItem都返回给
    self.navigationItem.leftBarButtonItems = @[spaceItem,backBarBtn];
}

- (void)setupNavBar {
    [self setBackBtn];
    [self initTitleView];
    self.titleLabel.text = self.title;
}
@end

@interface STIMGridHeaderInfoView : UIView

@end

@implementation STIMGridHeaderInfoView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ((CAGradientLayer *)self.layer).startPoint = CGPointMake(0, 0);
        ((CAGradientLayer *)self.layer).endPoint = CGPointMake(1, 0);
        ((CAGradientLayer *)self.layer).colors = @[(__bridge id)[UIColor stimDB_colorWithHex:0x2EFFD7].CGColor,(__bridge id)[UIColor stimDB_colorWithHex:0x0BE5D3].CGColor,(__bridge id)[UIColor stimDB_colorWithHex:0x0ED6C8].CGColor];
        ((CAGradientLayer *)self.layer).locations = @[@(0), @(0.3), @(1.0f)];
    }
    return self;
}

@end

@interface STIMGridViewHeader : UICollectionReusableView
@property (nonatomic, strong) STIMGridHeaderInfoView *bgInfoView;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) UIButton *scanBtn;
@property (nonatomic, strong) UIView *selfView;
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIImage *headerImage;
@property (nonatomic, copy)   NSString *userName;
@property (nonatomic, copy)   NSString *userInfo;
@property (nonatomic, copy)   NSString *headerUrl;

@property (nonatomic, copy)   void(^mineClick)(void);
@property (nonatomic, copy)   void(^settingClick)(void);
@property (nonatomic, copy)   void(^scanClick)(void);

@end

@implementation STIMGridViewHeader


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        self.bgInfoView = [[STIMGridHeaderInfoView alloc] init];
        [self.bgInfoView setClipsToBounds:YES];
        [self.bgInfoView.layer setCornerRadius:20];
        [self addSubview:self.bgInfoView];
        [self.bgInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(self);
            make.top.mas_equalTo(self).offset(-30);
        }];
        
        self.settingBtn = [[UIButton alloc] init];
        self.settingBtn.backgroundColor = [UIColor clearColor];
        [self.settingBtn setTitle:@"设置" forState:UIControlStateNormal];
        [self.settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.settingBtn addTarget:self action:@selector(onSettingClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.settingBtn];
        [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-15);
            make.top.mas_equalTo(self).offset(CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame)+10);
        }];
        
        self.headerView = [[UIImageView alloc] init];
        [self.headerView setClipsToBounds:YES];
        [self.headerView.layer setCornerRadius:15];
        [self addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.settingBtn.mas_bottom).offset(27);
            make.left.mas_equalTo(self).offset(15);
            make.width.height.mas_equalTo(60);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [self.nameLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headerView.mas_right).offset(20);
            make.bottom.mas_equalTo(self.headerView.mas_centerY);
        }];
        
        self.arrowView = [[UIImageView alloc] init];
        [self.arrowView setBackgroundColor:[UIColor clearColor]];
        [self.arrowView setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"grid_arrow"]];
        [self addSubview:self.arrowView];
        [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_right).offset(20);
            make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
            make.width.mas_equalTo(6);
            make.height.mas_equalTo(10);
        }];
        
        self.infoLabel = [[UILabel alloc] init];
        [self.infoLabel setBackgroundColor:[UIColor clearColor]];
        [self.infoLabel setFont:[UIFont systemFontOfSize:12]];
        [self.infoLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.infoLabel];
        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left).offset(20);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(6);
        }];
        
        self.scanBtn = [[UIButton alloc] init];
        [self.scanBtn setBackgroundColor:[UIColor stimDB_colorWithHex:0xF863A2 alpha:1]];
        [self.scanBtn.layer setCornerRadius:30];
        [self.scanBtn setClipsToBounds:YES];
        [self.scanBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"grid_erweima"] forState:UIControlStateNormal];
        [self.scanBtn addTarget:self action:@selector(onScanClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.scanBtn];
        [self.scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-24);
            make.width.height.mas_equalTo(60);
            make.top.mas_equalTo(self.bgInfoView.mas_bottom).offset(-30);
        }];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfClick)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)onScanClick {
    if (self.scanClick) {
        self.scanClick();
    }
}

- (void)onSettingClick {
    if (self.settingClick) {
        self.settingClick();
    }
}
 
- (void)onSelfClick {
    if (self.mineClick) {
        self.mineClick();
    }
}

- (void)refreshUI {
    if (self.headerImage) {
        [self.headerView setImage:self.headerImage];
    } else {
        [self.headerView sd_setImageWithURL:[NSURL URLWithString:self.headerUrl]];
    }
    [self.nameLabel setText:self.userName];
    [self.infoLabel setText:self.userInfo];
}

@end

@interface STIMGridMainVC () <UICollectionViewDelegate,UICollectionViewDataSource> {
}
@property (nonatomic, copy) NSString *collectionCellIdentifier;
@property (nonatomic, copy) NSString *collectionHeaderIdentifier;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation STIMGridMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"星语";
    [self intDataSource];
    [self initUI];
    if (self.skipLogin) {
        [self autoLogin];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - init DataSource
- (void)intDataSource {
    self.dataSource = [NSMutableArray array];
    __weak STIMGridMainVC *weakSelf = self;
    // 消息
    STIMGridItem *messageItem = [[STIMGridItem alloc] init];
    [messageItem setTitle:@"消息"];
    [messageItem setBgColor:0x08BDBC];
    [messageItem setImageName:@"grid_xiaoxi"];
    [messageItem setItemType:STIMGridItemType_Message];
    [messageItem setClickAction:^{
        QTalkSessionView *sessionView = [[QTalkSessionView alloc] initWithFrame:self.view.bounds];
        STIMGridRootVC *sessionVC = [[STIMGridRootVC alloc] initWithRootView:sessionView];
        [sessionVC setTitle:@"消息"];
        [weakSelf.navigationController pushViewController:sessionVC animated:YES];
    }];
    [self.dataSource addObject:messageItem];
     
    // 通讯录
    STIMGridItem *contactItem = [[STIMGridItem alloc] init];
    [contactItem setTitle:@"通讯录"];
    [contactItem setBgColor:0xAFD13A];
    [contactItem setImageName:@"grid_tongxunlu"];
    [contactItem setItemType:STIMGridItemType_Contact];
    [contactItem setClickAction:^{
        UIView *contactView = [weakSelf userListView];
        STIMGridRootVC *sessionVC = [[STIMGridRootVC alloc] initWithRootView:contactView];
        [sessionVC setTitle:@"通讯录"];
        [weakSelf.navigationController pushViewController:sessionVC animated:YES];
    }];
    [self.dataSource addObject:contactItem];
    
    // 创建群组
    STIMGridItem *createGroupItem = [[STIMGridItem alloc] init];
    [createGroupItem setTitle:@"创建群组"];
    [createGroupItem setBgColor:0xF05873];
    [createGroupItem setImageName:@"grid_qunzu"];
    [createGroupItem setItemType:STIMGridItemType_CreateGroup];
    [createGroupItem setClickAction:^{
        STIMGroupCreateVC * groupCreateVC = [[STIMGroupCreateVC alloc] init];
        [weakSelf.navigationController pushViewController:groupCreateVC animated:YES];
    }];
    [self.dataSource addObject:createGroupItem];
    
    // 文件传输
    STIMGridItem *fileTransferItem = [[STIMGridItem alloc] init];
    [fileTransferItem setTitle:@"文件传输"];
    [fileTransferItem setBgColor:0xF58123];
    [fileTransferItem setImageName:@"grid_chuanshu"];
    [fileTransferItem setItemType:STIMGridItemType_FileTransfer];
    [fileTransferItem setClickAction:^{
        [[STIMFastEntrance sharedInstance] openFileTransMiddleVC];
    }];
    [self.dataSource addObject:fileTransferItem];
     
//    // 我的
    STIMGridItem *notebookItem = [[STIMGridItem alloc] init];
    [notebookItem setTitle:@"笔记本"];
    [notebookItem setBgColor:0xFCD00F];
    [notebookItem setImageName:@"grid_bijiben"];
    [notebookItem setItemType:STIMGridItemType_Notebook];
    [notebookItem setClickAction:^{
        [STIMFastEntrance openQTalkNotesVC];
    }];
    [self.dataSource addObject:notebookItem];
    
    // 行程
    STIMGridItem *routeItem = [[STIMGridItem alloc] init];
    [routeItem setTitle:@"行程"];
    [routeItem setBgColor:0x8463CD];
    [routeItem setImageName:@"grid_xingcheng"];
    [routeItem setItemType:STIMGridItemType_Route];
    [routeItem setClickAction:^{
        UIView *travelView = [weakSelf travelView];
        STIMGridRootVC *sessionVC = [[STIMGridRootVC alloc] initWithRootView:travelView];
        [sessionVC setTitle:@"行程"];
        [weakSelf.navigationController pushViewController:sessionVC animated:YES];
    }];
    [self.dataSource addObject:routeItem];
    
//    STIMGridItem *scanItem = [[STIMGridItem alloc] init];
//    [scanItem setTitle:@"扫一扫"];
//    [scanItem setImageName:@""];
//    [scanItem setItemType:STIMGridItemType_Scan];
//    [scanItem setClickAction:^{
//
//    }];
//    [self.dataSource addObject:scanItem];
    
}

- (UIView *)travelView {
    #if __has_include("QimRNBModule.h")
            STIMVerboseLog(@"打开STIM RN 行程页面");
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"createSTIMRNVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"module": @"TravelCalendar"};
                vc = [RunC performSelector:sel withObject:param];
            }
            UIView *travelView = [vc view];
            [travelView setFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    #endif
        return travelView;
}

- (UIView *)userListView {
        UIView *resultView = nil;
#if __has_include("QimRNBModule.h")
        //导航中返回RNContactView == NO，展示Native界面
        STIMVerboseLog(@"RNContactView : %d", [[STIMKit sharedInstance] qimNav_RNContactView]);
        if ([[STIMKit sharedInstance] qimNav_RNContactView] == NO) {
            STIMVerboseLog(@"打开Native 通讯录页");
            STIMUserListView *userlistView = [[STIMUserListView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            [userlistView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [userlistView setRootViewController:self];
            [userlistView setBackgroundColor:[UIColor spectralColorWhiteColor]];
            resultView = userlistView;
        } else {
            STIMVerboseLog(@"打开STIM RN 通讯录页");
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"createSTIMRNVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"module": @"Contacts"};
                vc = [RunC performSelector:sel withObject:param];
            }
            resultView = [vc view];
            [resultView setFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        }
#else
        STIMVerboseLog(@"打开Native 通讯录页");
        STIMUserListView *userlistView = [[STIMUserListView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        [userlistView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [userlistView setRootViewController:self];
        [userlistView setBackgroundColor:[UIColor spectralColorWhiteColor]];
        resultView = userlistView;
#endif
    return resultView;
}

- (UIView *)mineView {
    UIView *mineView = nil;
#if __has_include("QimRNBModule.h")

        //导航中返回RNMineView == NO，展示Native界面
        STIMVerboseLog(@"RNMineView : %d", [[STIMKit sharedInstance] qimNav_RNMineView]);
        if ([[STIMKit sharedInstance] qimNav_RNMineView] == NO) {
            STIMVerboseLog(@"打开Native 我的页面");
            STIMMineTableView *mineNativeView = [[STIMMineTableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            [mineNativeView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [mineNativeView setRootViewController:self];
            mineView = mineNativeView;
        } else {
            STIMVerboseLog(@"打开STIM RN 我的页面");

            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"createSTIMRNVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"module": @"MySetting"};
                vc = [RunC performSelector:sel withObject:param];
            }
            mineView = vc;
            mineView = [vc view];
            [mineView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            [mineView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        }

#else
        STIMVerboseLog(@"打开Native 我的页面");
        STIMMineTableView *mineNativeView = [[STIMMineTableView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, _contentView.height)];
        [mineNativeView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [mineNativeView setRootViewController:self];
        mineView = mineNativeView;
#endif
    return mineView;
}

#pragma mark - init UI
- (void)initUI {
    self.collectionCellIdentifier = @"Cell";
    self.collectionHeaderIdentifier = @"Header";
    STIMGridMainFlowLayout *flowLayout = [[STIMGridMainFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView registerClass:[STIMGridCell class] forCellWithReuseIdentifier:self.collectionCellIdentifier];
    [self.collectionView registerClass:[STIMGridViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.collectionHeaderIdentifier];
    [self.collectionView setContentInset:UIEdgeInsetsMake(-[UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0)];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
    }];
}
 
#pragma mark - Collection View Data Source
 - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
     if ( kind == UICollectionElementKindSectionHeader ) {
         STIMGridViewHeader *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.collectionHeaderIdentifier forIndexPath:indexPath];
         NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:[[STIMKit sharedInstance] getLastJid]];
         [headerView setUserName:[userInfo objectForKey:@"Name"]];
         if ([[STIMKit sharedInstance] moodshow]) {
             [headerView setUserInfo:[userInfo objectForKey:@"Mood"]];
         } else {
             [headerView setUserInfo:[userInfo objectForKey:@"DescInfo"]];
         }
         NSString *headerSrc = [userInfo objectForKey:@"HeaderSrc"];
         UIImage *myHeader = nil; //[UIImage imageWithContentsOfFile:[[STIMImageManager sharedInstance] stimDB_getHeaderCachePathWithHeaderUrl:headerSrc]];
         [headerView setHeaderImage:myHeader?myHeader:[UIImage imageWithData:[STIMKit defaultUserHeaderImage]]];
         [headerView setHeaderUrl:headerSrc];

         __weak STIMGridMainVC *weakSelf = self;
         [headerView setMineClick:^{
             UIView *mineView = [weakSelf mineView];
             STIMGridRootVC *mineVC = [[STIMGridRootVC alloc] initWithRootView:mineView];
             [mineVC setTitle:@"我的"];
             [weakSelf.navigationController pushViewController:mineVC animated:YES];
         }];
         [headerView setSettingClick:^{
             STIMMySettingController *settingVc = [[STIMMySettingController alloc] init];
             [weakSelf.navigationController pushViewController:settingVc animated:YES];
         }];
         [headerView setScanClick:^{
             STIMZBarViewController *vc = [[STIMZBarViewController alloc] initWithBlock:^(NSString *str, BOOL isScceed) {
                 if (isScceed) {
                     [STIMJumpURLHandle decodeQCodeStr:str];
                 }
             }];
             if (@available(iOS 13.0, *)) {
                 [vc setModalPresentationStyle:UIModalPresentationOverFullScreen];
             } else {
                 // Fallback on earlier versions
             }
             [weakSelf.navigationController presentViewController:vc animated:YES completion:nil];
         }];
         [headerView refreshUI];
         return headerView;
     }
     
     return nil;
 }

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    STIMGridMainFlowLayout *layout = (STIMGridMainFlowLayout *)collectionViewLayout;
    int line = (self.dataSource.count - 1) / 2.0 +1;
    CGFloat lineCap = ([UIScreen mainScreen].bounds.size.height - (layout.itemSize.height * line + layout.minimumLineSpacing * (line-1)) - layout.headerReferenceSize.height) / 2.0;
    return UIEdgeInsetsMake(lineCap, kItemCap, 0, kItemCap);//分别为上、左、下、右
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //Each Section is a Month
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //We need the number of calendar weeks for the full months (it will maybe include previous month and next months cells)
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STIMGridCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:self.collectionCellIdentifier forIndexPath:indexPath];
    [cell setGridItem:[self.dataSource objectAtIndex:indexPath.row]];
    [cell refreshUI];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    STIMGridCell *cell = (STIMGridCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell && cell.gridItem.clickAction) {
        cell.gridItem.clickAction();
    }
}

#pragma mark -
- (void)autoLogin {
    NSString *lastUserName = [STIMKit getLastUserName];
    NSString *userToken = [[STIMKit sharedInstance] getLastUserToken];
//    [[STIMKit sharedInstance] userObjectForKey:@"userToken"];
    NSString *userFullJid = [[STIMKit sharedInstance] userObjectForKey:@"kFullUserJid"];
    STIMVerboseLog(@"autoLogin lastUserName : %@, userFullJid : %@, userToken : %@", lastUserName, userFullJid, userToken);
    STIMVerboseLog(@"autoLogin UserDict : %@", [[STIMKit sharedInstance] userObjectForKey:@"Users"]);
    if ([lastUserName length] > 0 && [userToken length] > 0) {
        if ([lastUserName isEqualToString:@"appstore"]) {
            [[STIMKit sharedInstance] updateLastTempUserToken:@"appstore"];
//            [[STIMKit sharedInstance] setUserObject:@"appstore" forKey:@"kTempUserToken"];
            [[STIMKit sharedInstance] loginWithUserName:@"appstore" WithPassWord:@"appstore"];
        } else if ([[lastUserName lowercaseString] isEqualToString:@"qtalktest"]) {
            [[STIMKit sharedInstance] updateLastTempUserToken:@"qtalktest123"];
//            [[STIMKit sharedInstance] setUserObject:@"qtalktest123" forKey:@"kTempUserToken"];
            [[STIMKit sharedInstance] loginWithUserName:@"qtalktest" WithPassWord:@"qtalktest123"];
        } else {
            if ([[STIMKit sharedInstance] qimNav_LoginType] == QTLoginTypeSms) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *pwd = [NSString stringWithFormat:@"%@@%@", [STIMUUIDTools deviceUUID], userToken];
                    [[STIMKit sharedInstance] updateLastTempUserToken:userToken];
//                    [[STIMKit sharedInstance] setUserObject:userToken forKey:@"kTempUserToken"];
                    [[STIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:pwd];
                });
            } else {
                [[STIMKit sharedInstance] updateLastTempUserToken:userToken];
//                [[STIMKit sharedInstance] setUserObject:userToken forKey:@"kTempUserToken"];
                [[STIMKit sharedInstance] loginWithUserName:lastUserName WithPassWord:userToken];
            }
        }
    } else {
        STIMVerboseLog(@"lastUserName或userToken为空,回到登录页面");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationOutOfDate" object:nil];
    }
}


@end

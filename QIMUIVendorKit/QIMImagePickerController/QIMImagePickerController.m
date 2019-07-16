//
//  QIMImagePickerController.m
//  QIMImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//  version 3.2.0 - 2019.03.02
//  更多信息，请前往项目的github地址：https://github.com/banchichen/QIMImagePickerController

#import "QIMImagePickerController.h"
#import "QIMPhotoPickerController.h"
#import "QIMPhotoPreviewController.h"
#import "QIMAssetModel.h"
#import "QIMAssetCell.h"
#import "UIView+QIMLayout.h"
#import "QIMImagePickerManager.h"
#import "UIImage+QIMImagePicker.h"

@interface QIMImagePickerController () {
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    BOOL _pushPhotoPickerVc;
    BOOL _didPushPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
    UIStatusBarStyle _originStatusBarStyle;
}
/// Default is 4, Use in photos collectionView in QIMPhotoPickerController
/// 默认4列, QIMPhotoPickerController中的照片collectionView
@property (nonatomic, assign) NSInteger columnNumber;
@end

@implementation QIMImagePickerController

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithMaxImagesCount:9 delegate:nil];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)viewDidLoad {
    [super viewDidLoad];
    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [QIMImagePickerManager manager].shouldFixOrientation = NO;

    // Default appearance, you can reset these after this method
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor {
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont {
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)configNaviTitleAppearance {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    if (self.naviTitleColor) {
        textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    }
    if (self.naviTitleFont) {
        textAttrs[NSFontAttributeName] = self.naviTitleFont;
    }
    self.navigationBar.titleTextAttributes = textAttrs;
}

- (void)setBarItemTextFont:(UIFont *)barItemTextFont {
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}

- (void)setBarItemTextColor:(UIColor *)barItemTextColor {
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}

- (void)setIsStatusBarDefault:(BOOL)isStatusBarDefault {
    _isStatusBarDefault = isStatusBarDefault;
    
    if (isStatusBarDefault) {
        self.statusBarStyle = UIStatusBarStyleDefault;
    } else {
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem;
    if (@available(iOS 9, *)) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[QIMImagePickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[QIMImagePickerController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = self.statusBarStyle;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<QIMImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<QIMImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<QIMImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc {
    _pushPhotoPickerVc = pushPhotoPickerVc;
    QIMAlbumPickerController *albumPickerVc = [[QIMAlbumPickerController alloc] init];
    albumPickerVc.isFirstAppear = YES;
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedAssets = [NSMutableArray array];
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.allowTakeVideo = YES;
        self.videoMaximumDuration = 10 * 60;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        
        if (![[QIMImagePickerManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.qim_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            
            NSDictionary *infoDict = [QIMCommonTools qim_getInfoDictionary];
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.qim_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            if ([PHPhotoLibrary authorizationStatus] == 0) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
            }
        } else {
            [self pushPhotoPickerVc];
        }
    }
    return self;
}

/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index{
    QIMPhotoPreviewController *previewVc = [[QIMPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        [self configDefaultSetting];
        
        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (!strongSelf) return;
                if (strongSelf.didFinishPickingPhotosHandle) {
                    strongSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
                }
            }];
        }];
    }
    return self;
}

/// This init method for crop photo / 用这个初始化方法以裁剪图片
- (instancetype)initCropTypeWithAsset:(PHAsset *)asset photo:(UIImage *)photo completion:(void (^)(UIImage *cropImage,PHAsset *asset))completion {
    QIMPhotoPreviewController *previewVc = [[QIMPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.maxImagesCount = 1;
        self.allowPickingImage = YES;
        self.allowCrop = YES;
        self.selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
        [self configDefaultSetting];
        
        previewVc.photos = [NSMutableArray arrayWithArray:@[photo]];
        previewVc.isCropImage = YES;
        previewVc.currentIndex = 0;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockCropMode:^(UIImage *cropImage, id asset) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (completion) {
                    completion(cropImage,asset);
                }
            }];
        }];
    }
    return self;
}

- (void)configDefaultSetting {
    self.timeout = 15;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.naviTitleColor = [UIColor whiteColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    self.allowPreview = YES;
    // 2.2.26版本，不主动缩放图片，降低内存占用
    self.notScaleImage = YES;
    self.needFixComposition = NO;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.allowCameraLocation = YES;
    
    self.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    [self configDefaultBtnTitle];
    
    CGFloat cropViewWH = MIN(self.view.qim_width, self.view.qim_height) / 3 * 2;
    self.cropRect = CGRectMake((self.view.qim_width - cropViewWH) / 2, (self.view.qim_height - cropViewWH) / 2, cropViewWH, cropViewWH);
}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture80";
    self.photoSelImageName = @"photo_sel_photoPickerVc";
    self.photoDefImageName = @"photo_def_photoPickerVc";
    self.photoNumberIconImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12]; // @"photo_number_icon";
    self.photoPreviewOriginDefImageName = @"preview_original_def";
    self.photoOriginDefImageName = @"photo_original_def";
    self.photoOriginSelImageName = @"photo_original_sel";
}

- (void)setTakePictureImageName:(NSString *)takePictureImageName {
    _takePictureImageName = takePictureImageName;
    _takePictureImage = [UIImage qim_imageNamedFromQIMImagePickerBundle:takePictureImageName];
}

- (void)setPhotoSelImageName:(NSString *)photoSelImageName {
    _photoSelImageName = photoSelImageName;
    _photoSelImage = [UIImage qim_imageNamedFromQIMImagePickerBundle:photoSelImageName];
}

- (void)setPhotoDefImageName:(NSString *)photoDefImageName {
    _photoDefImageName = photoDefImageName;
    _photoDefImage = [UIImage qim_imageNamedFromQIMImagePickerBundle:photoDefImageName];
}

- (void)setPhotoNumberIconImageName:(NSString *)photoNumberIconImageName {
    _photoNumberIconImageName = photoNumberIconImageName;
    _photoNumberIconImage = [UIImage qim_imageNamedFromQIMImagePickerBundle:photoNumberIconImageName];
}

- (void)setPhotoPreviewOriginDefImageName:(NSString *)photoPreviewOriginDefImageName {
    _photoPreviewOriginDefImageName = photoPreviewOriginDefImageName;
    _photoPreviewOriginDefImage = [UIImage qim_imageNamedFromQIMImagePickerBundle:photoPreviewOriginDefImageName];
}

- (void)setPhotoOriginDefImageName:(NSString *)photoOriginDefImageName {
    _photoOriginDefImageName = photoOriginDefImageName;
    _photoOriginDefImage = [UIImage qim_imageNamedFromQIMImagePickerBundle:photoOriginDefImageName];
}

- (void)setPhotoOriginSelImageName:(NSString *)photoOriginSelImageName {
    _photoOriginSelImageName = photoOriginSelImageName;
    _photoOriginSelImage = [UIImage qim_imageNamedFromQIMImagePickerBundle:photoOriginSelImageName];
}

- (void)setIconThemeColor:(UIColor *)iconThemeColor {
    _iconThemeColor = iconThemeColor;
    [self configDefaultImageName];
}

- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = [NSBundle qim_localizedStringForKey:@"Done"];
    self.cancelBtnTitleStr = [NSBundle qim_localizedStringForKey:@"Cancel"];
    self.previewBtnTitleStr = [NSBundle qim_localizedStringForKey:@"Preview"];
    self.fullImageBtnTitleStr = [NSBundle qim_localizedStringForKey:@"Full image"];
    self.settingBtnTitleStr = [NSBundle qim_localizedStringForKey:@"Setting"];
    self.processHintStr = [NSBundle qim_localizedStringForKey:@"Processing..."];
}

- (void)setShowSelectedIndex:(BOOL)showSelectedIndex {
    _showSelectedIndex = showSelectedIndex;
    if (showSelectedIndex) {
        self.photoSelImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12];
    }
    [QIMImagePickerConfig sharedInstance].showSelectedIndex = showSelectedIndex;
}

- (void)setShowPhotoCannotSelectLayer:(BOOL)showPhotoCannotSelectLayer {
    _showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
    [QIMImagePickerConfig sharedInstance].showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
}

- (void)setNotScaleImage:(BOOL)notScaleImage {
    _notScaleImage = notScaleImage;
    [QIMImagePickerConfig sharedInstance].notScaleImage = notScaleImage;
}

- (void)setNeedFixComposition:(BOOL)needFixComposition {
    _needFixComposition = needFixComposition;
    [QIMImagePickerConfig sharedInstance].needFixComposition = needFixComposition;
}

- (void)observeAuthrizationStatusChange {
    [_timer invalidate];
    _timer = nil;
    if ([PHPhotoLibrary authorizationStatus] == 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
    }
    
    if ([[QIMImagePickerManager manager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];

        [self pushPhotoPickerVc];
        
        QIMAlbumPickerController *albumPickerVc = (QIMAlbumPickerController *)self.visibleViewController;
        if ([albumPickerVc isKindOfClass:[QIMAlbumPickerController class]]) {
            [albumPickerVc configTableView];
        }
    }
}

- (void)pushPhotoPickerVc {
    _didPushPhotoPickerVc = NO;
    // 1.6.8 判断是否需要push到照片选择页，如果_pushPhotoPickerVc为NO,则不push
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) {
        QIMPhotoPickerController *photoPickerVc = [[QIMPhotoPickerController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        photoPickerVc.columnNumber = self.columnNumber;
        [[QIMImagePickerManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage needFetchAssets:NO completion:^(QIMAlbumModel *model) {
            photoPickerVc.model = model;
            [self pushViewController:photoPickerVc animated:YES];
            self->_didPushPhotoPickerVc = YES;
        }];
    }
}

- (UIAlertController *)showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (void)hideAlertView:(UIAlertController *)alertView {
    [alertView dismissViewControllerAnimated:YES completion:nil];
    alertView = nil;
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = self.processHintStr;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    UIWindow *applicationWindow;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    } else {
        applicationWindow = [[UIApplication sharedApplication] keyWindow];
    }
    [applicationWindow addSubview:_progressHUD];
    [self.view setNeedsLayout];
    
    // if over time, dismiss HUD automatic
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectBtn = YES;
        _allowCrop = NO;
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    // 多选模式下，不允许让showSelectBtn为NO
    if (!showSelectBtn && _maxImagesCount > 1) {
        _showSelectBtn = YES;
    }
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) { // 允许裁剪的时候，不能选原图和GIF
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingGif = NO;
    }
}

- (void)setCircleCropRadius:(NSInteger)circleCropRadius {
    _circleCropRadius = circleCropRadius;
    self.cropRect = CGRectMake(self.view.qim_width / 2 - circleCropRadius, self.view.qim_height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _cropRectPortrait = cropRect;
    CGFloat widthHeight = cropRect.size.width;
    _cropRectLandscape = CGRectMake((self.view.qim_height - widthHeight) / 2, cropRect.origin.x, widthHeight, widthHeight);
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60) {
        _timeout = 60;
    }
}

- (void)setPickerDelegate:(id<QIMImagePickerControllerDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    [QIMImagePickerManager manager].pickerDelegate = pickerDelegate;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
    QIMAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [QIMImagePickerManager manager].columnNumber = _columnNumber;
}

- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable {
    _minPhotoWidthSelectable = minPhotoWidthSelectable;
    [QIMImagePickerManager manager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable {
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
    [QIMImagePickerManager manager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}

- (void)setHideWhenCanNotSelect:(BOOL)hideWhenCanNotSelect {
    _hideWhenCanNotSelect = hideWhenCanNotSelect;
    [QIMImagePickerManager manager].hideWhenCanNotSelect = hideWhenCanNotSelect;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [QIMImagePickerManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setPhotoWidth:(CGFloat)photoWidth {
    _photoWidth = photoWidth;
    [QIMImagePickerManager manager].photoWidth = photoWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    _selectedAssetIds = [NSMutableArray array];
    for (PHAsset *asset in selectedAssets) {
        QIMAssetModel *model = [QIMAssetModel modelWithAsset:asset type:[[QIMImagePickerManager manager] getAssetType:asset]];
        model.isSelected = YES;
        [self addSelectedModel:model];
    }
}

- (void)setAllowPickingImage:(BOOL)allowPickingImage {
    _allowPickingImage = allowPickingImage;
    [QIMImagePickerConfig sharedInstance].allowPickingImage = allowPickingImage;
    if (!allowPickingImage) {
        _allowTakePicture = NO;
    }
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
    [QIMImagePickerConfig sharedInstance].allowPickingVideo = allowPickingVideo;
    if (!allowPickingVideo) {
        _allowTakeVideo = NO;
    }
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    [QIMImagePickerConfig sharedInstance].preferredLanguage = preferredLanguage;
    [self configDefaultBtnTitle];
}

- (void)setLanguageBundle:(NSBundle *)languageBundle {
    _languageBundle = languageBundle;
    [QIMImagePickerConfig sharedInstance].languageBundle = languageBundle;
    [self configDefaultBtnTitle];
}

- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [QIMImagePickerManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}

- (void)settingBtnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    [super pushViewController:viewController animated:animated];
}

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (void)addSelectedModel:(QIMAssetModel *)model {
    [_selectedModels addObject:model];
    [_selectedAssetIds addObject:model.asset.localIdentifier];
}

- (void)removeSelectedModel:(QIMAssetModel *)model {
    [_selectedModels removeObject:model];
    [_selectedAssetIds removeObject:model.asset.localIdentifier];
}

- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius {
    if (!color) {
        color = self.iconThemeColor;
    }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UIContentContainer

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![UIApplication sharedApplication].statusBarHidden) {
            if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
        }
    });
    if (size.width > size.height) {
        _cropRect = _cropRectLandscape;
    } else {
        _cropRect = _cropRectPortrait;
    }
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat progressHUDY = CGRectGetMaxY(self.navigationBar.frame);
    _progressHUD.frame = CGRectMake(0, progressHUDY, self.view.qim_width, self.view.qim_height - progressHUDY);
    _HUDContainer.frame = CGRectMake((self.view.qim_width - 120) / 2, (_progressHUD.qim_height - 90 - progressHUDY) / 2, 120, 90);
    _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    _HUDLabel.frame = CGRectMake(0,40, 120, 50);
}

#pragma mark - Public

- (void)cancelButtonClick {
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

- (void)callDelegateMethod {
    if ([self.pickerDelegate respondsToSelector:@selector(qim_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate qim_imagePickerControllerDidCancel:self];
    }
    if (self.imagePickerControllerDidCancelHandle) {
        self.imagePickerControllerDidCancelHandle();
    }
}

@end


@interface QIMAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
@end

@implementation QIMAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstAppear = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    QIMImagePickerController *imagePickerVc = (QIMImagePickerController *)self.navigationController;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    QIMImagePickerController *imagePickerVc = (QIMImagePickerController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
    if (imagePickerVc.allowPickingImage) {
        self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"Photos"];
    } else if (imagePickerVc.allowPickingVideo) {
        self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"Videos"];
    }
    
    if (self.isFirstAppear && !imagePickerVc.navLeftBarButtonSettingBlock) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Back"] style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    [self configTableView];
}

- (void)configTableView {
    if (![[QIMImagePickerManager manager] authorizationStatusAuthorized]) {
        return;
    }

    if (self.isFirstAppear) {
        QIMImagePickerController *imagePickerVc = (QIMImagePickerController *)self.navigationController;
        [imagePickerVc showProgressHUD];
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        QIMImagePickerController *imagePickerVc = (QIMImagePickerController *)self.navigationController;
        [[QIMImagePickerManager manager] getAllAlbums:imagePickerVc.allowPickingVideo allowPickingImage:imagePickerVc.allowPickingImage needFetchAssets:!self.isFirstAppear completion:^(NSArray<QIMAlbumModel *> *models) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_albumArr = [NSMutableArray arrayWithArray:models];
                for (QIMAlbumModel *albumModel in self->_albumArr) {
                    albumModel.selectedModels = imagePickerVc.selectedModels;
                }
                [imagePickerVc hideProgressHUD];
                
                if (self.isFirstAppear) {
                    self.isFirstAppear = NO;
                    [self configTableView];
                }
                
                if (!self->_tableView) {
                    self->_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                    self->_tableView.rowHeight = 70;
                    self->_tableView.tableFooterView = [[UIView alloc] init];
                    self->_tableView.dataSource = self;
                    self->_tableView.delegate = self;
                    [self->_tableView registerClass:[QIMAlbumCell class] forCellReuseIdentifier:@"QIMAlbumCell"];
                    [self.view addSubview:self->_tableView];
                } else {
                    [self->_tableView reloadData];
                }
            });
        }];
    });
}

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    QIMImagePickerController *tzImagePicker = (QIMImagePickerController *)self.navigationController;
    if (tzImagePicker && [tzImagePicker isKindOfClass:[QIMImagePickerController class]]) {
        return tzImagePicker.statusBarStyle;
    }
    return [super preferredStatusBarStyle];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat tableViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.qim_height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden) top += [QIMCommonTools qim_statusBarHeight];
        tableViewHeight = self.view.qim_height - top;
    } else {
        tableViewHeight = self.view.qim_height;
    }
    _tableView.frame = CGRectMake(0, top, self.view.qim_width, tableViewHeight);
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QIMAlbumCell"];
    QIMImagePickerController *imagePickerVc = (QIMImagePickerController *)self.navigationController;
    cell.albumCellDidLayoutSubviewsBlock = imagePickerVc.albumCellDidLayoutSubviewsBlock;
    cell.albumCellDidSetModelBlock = imagePickerVc.albumCellDidSetModelBlock;
    cell.selectedCountButton.backgroundColor = imagePickerVc.iconThemeColor;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMPhotoPickerController *photoPickerVc = [[QIMPhotoPickerController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    QIMAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma clang diagnostic pop

@end

@implementation QIMCommonTools

+ (BOOL)qim_isIPhoneX {
    return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)));
}

+ (CGFloat)qim_statusBarHeight {
    return [self qim_isIPhoneX] ? 44 : 20;
}

// 获得Info.plist数据字典
+ (NSDictionary *)qim_getInfoDictionary {
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict || !infoDict.count) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    if (!infoDict || !infoDict.count) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return infoDict ? infoDict : @{};
}

+ (BOOL)qim_isRightToLeftLayout {
    if (@available(iOS 9.0, *)) {
        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:UISemanticContentAttributeUnspecified] == UIUserInterfaceLayoutDirectionRightToLeft) {
            return YES;
        }
    } else {
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        if ([preferredLanguage hasPrefix:@"ar-"]) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation QIMImagePickerConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static QIMImagePickerConfig *config = nil;
    dispatch_once(&onceToken, ^{
        if (config == nil) {
            config = [[QIMImagePickerConfig alloc] init];
            config.preferredLanguage = nil;
            config.gifPreviewMaxImagesCount = 50;
        }
    });
    return config;
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    
    if (!preferredLanguage || !preferredLanguage.length) {
        preferredLanguage = [NSLocale preferredLanguages].firstObject;
    }
    if ([preferredLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        preferredLanguage = @"zh-Hans";
    } else if ([preferredLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        preferredLanguage = @"zh-Hant";
    } else if ([preferredLanguage rangeOfString:@"vi"].location != NSNotFound) {
        preferredLanguage = @"vi";
    } else {
        preferredLanguage = @"en";
    }
    _languageBundle = [NSBundle bundleWithPath:[[NSBundle qim_imagePickerBundle] pathForResource:preferredLanguage ofType:@"lproj"]];
}

@end

//
//  QIMPhotoPreviewController.m
//  QIMImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "QIMPhotoPreviewController.h"
#import "QIMPhotoPreviewCell.h"
#import "QIMAssetModel.h"
#import "UIView+QIMLayout.h"
#import "QIMImagePickerController.h"
#import "QIMImagePickerManager.h"
#import "QIMImageCropManager.h"
#import "QIMImageClipView.h"
#import "QIMImageDoodleView.h"
#import "QIMImageUtil.h"
#import "UIImage+QIMImagePicker.h"

#define kImageTagFrom 10000
#define kColorViewTagFrom 100
#define kSendBtnTag 1001
#define kTurnLeftBtnTag 1101
#define kTurnRightBtnTag 1102

//LOMO
const float qim_colormatrix_lomo[] = {
    1.7f,  0.1f, 0.1f, 0, -73.1f,
    0,  1.7f, 0.1f, 0, -73.1f,
    0,  0.1f, 1.6f, 0, -73.1f,
    0,  0, 0, 1.0f, 0 };

//黑白
const float qim_colormatrix_heibai[] = {
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0,  0, 0, 1.0f, 0 };
//复古
const float qim_colormatrix_huajiu[] = {
    0.2f,0.5f, 0.1f, 0, 40.8f,
    0.2f, 0.5f, 0.1f, 0, 40.8f,
    0.2f,0.5f, 0.1f, 0, 40.8f,
    0, 0, 0, 1, 0 };

//哥特
const float qim_colormatrix_gete[] = {
    1.9f,-0.3f, -0.2f, 0,-87.0f,
    -0.2f, 1.7f, -0.1f, 0, -87.0f,
    -0.1f,-0.6f, 2.0f, 0, -87.0f,
    0, 0, 0, 1.0f, 0 };

//锐化
const float qim_colormatrix_ruise[] = {
    4.8f,-1.0f, -0.1f, 0,-388.4f,
    -0.5f,4.4f, -0.1f, 0,-388.4f,
    -0.5f,-1.0f, 5.2f, 0,-388.4f,
    0, 0, 0, 1.0f, 0 };


//淡雅
const float qim_colormatrix_danya[] = {
    0.6f,0.3f, 0.1f, 0,73.3f,
    0.2f,0.7f, 0.1f, 0,73.3f,
    0.2f,0.3f, 0.4f, 0,73.3f,
    0, 0, 0, 1.0f, 0 };

//酒红
const float qim_colormatrix_jiuhong[] = {
    1.2f,0.0f, 0.0f, 0.0f,0.0f,
    0.0f,0.9f, 0.0f, 0.0f,0.0f,
    0.0f,0.0f, 0.8f, 0.0f,0.0f,
    0, 0, 0, 1.0f, 0 };

//清宁
const float qim_colormatrix_qingning[] = {
    0.9f, 0, 0, 0, 0,
    0, 1.1f,0, 0, 0,
    0, 0, 0.9f, 0, 0,
    0, 0, 0, 1.0f, 0 };

//浪漫
const float qim_colormatrix_langman[] = {
    0.9f, 0, 0, 0, 63.0f,
    0, 0.9f,0, 0, 63.0f,
    0, 0, 0.9f, 0, 63.0f,
    0, 0, 0, 1.0f, 0 };

//光晕
const float qim_colormatrix_guangyun[] = {
    0.9f, 0, 0,  0, 64.9f,
    0, 0.9f,0,  0, 64.9f,
    0, 0, 0.9f,  0, 64.9f,
    0, 0, 0, 1.0f, 0 };

//蓝调
const float qim_colormatrix_landiao[] = {
    2.1f, -1.4f, 0.6f, 0.0f, -31.0f,
    -0.3f, 2.0f, -0.3f, 0.0f, -31.0f,
    -1.1f, -0.2f, 2.6f, 0.0f, -31.0f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

//梦幻
const float qim_colormatrix_menghuan[] = {
    0.8f, 0.3f, 0.1f, 0.0f, 46.5f,
    0.1f, 0.9f, 0.0f, 0.0f, 46.5f,
    0.1f, 0.3f, 0.7f, 0.0f, 46.5f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

//夜色
const float qim_colormatrix_yese[] = {
    1.0f, 0.0f, 0.0f, 0.0f, -66.6f,
    0.0f, 1.1f, 0.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 1.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

@interface QIMPhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate> {
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    NSArray *_photosTemp;
    NSArray *_assetsTemp;
    
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    UILabel *_indexLabel;
    
    UIView *_toolBar;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_editPhotoButton;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    
    CGFloat _offsetItemCount;
    
    //Edit
    UIButton *_cancelEditButton; //取消编辑按钮
    UIButton *_completeEditButton; //完成编辑按钮
    
    UIView          * _editToolButtonBar;   //工具栏
    UIView          * _editClipButtonBar;   //裁剪时候的工具栏
    UIView          * _editNaviBar;//导航栏
//    UIImageView     * _editImageDisplayView;//展示图片
    
    UIScrollView    * _editDuangView;//特效
    UIView          * _editOrientationView;//旋转工具条
    UIScrollView    * _editDoodleSelectBar;//涂鸦工具条
    
    UIButton        * _editReductionButton;     //还原按钮
    
    NSArray         * _editDataSource;
    NSArray         * _editTitles;
    NSArray         * _editColors;
    
    QIMImageClipView   * _editImageClipView;//图片裁剪
    QIMImageDoodleView * _editImageDoodleView;//涂鸦
    
    UIButton        * _editDuangBtn;//特效按钮
    UIButton        * _editClipsBtn;//裁剪按钮
    UIButton        * _editDoodleBtn;//涂鸦按钮
    
    
    BOOL _didSetIsSelectOriginalPhoto;
}
@property (nonatomic, assign) BOOL isHideNaviBar;
@property (nonatomic, strong) UIView *cropBgView;
@property (nonatomic, strong) UIView *cropView;

@property (nonatomic, assign) double progress;
@property (strong, nonatomic) UIAlertController *alertView;
@end

@implementation QIMPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [QIMImagePickerManager manager].shouldFixOrientation = YES;
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    if (!_didSetIsSelectOriginalPhoto) {
        _isSelectOriginalPhoto = _tzImagePickerVc.isSelectOriginalPhoto;
    }
    if (!self.models.count) {
        self.models = [NSMutableArray arrayWithArray:_tzImagePickerVc.selectedModels];
        _assetsTemp = [NSMutableArray arrayWithArray:_tzImagePickerVc.selectedAssets];
    }
    [self configCollectionView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
    [self configEditNaviBar];
    [self configEditToolBar];
    self.view.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)setIsSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    _didSetIsSelectOriginalPhoto = YES;
}

- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    _photosTemp = [NSArray arrayWithArray:photos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
    if (_currentIndex) {
        [_collectionView setContentOffset:CGPointMake((self.view.qim_width + 20) * self.currentIndex, 0) animated:NO];
    }
    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    QIMImagePickerController *tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    if (tzImagePickerVc.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    [QIMImagePickerManager manager].shouldFixOrientation = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)configEditNaviBar {
    _editNaviBar = [[UIView alloc] initWithFrame:CGRectZero];
    _editNaviBar.backgroundColor = [UIColor blackColor];
    _editNaviBar.hidden = YES;
    
    _cancelEditButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_cancelEditButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelEditButton addTarget:self action:@selector(cancelEditImage:) forControlEvents:UIControlEventTouchUpInside];
    
    _completeEditButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_completeEditButton setTitle:@"完成" forState:UIControlStateNormal];
    [_completeEditButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_completeEditButton addTarget:self action:@selector(complateEditImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [_editNaviBar addSubview:_cancelEditButton];
    [_editNaviBar addSubview:_completeEditButton];
    [self.view addSubview:_editNaviBar];
}

- (void)initEditToolsBar {
    
    _editToolButtonBar = [[UIView alloc] initWithFrame:CGRectZero];
    _editToolButtonBar.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    _editToolButtonBar.layer.borderColor = [UIColor grayColor].CGColor;
    _editToolButtonBar.layer.borderWidth = 1.0f;
    [self.view addSubview:_editToolButtonBar];
    _editToolButtonBar.hidden = YES;
    
    _editDuangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editDuangBtn.frame = CGRectMake(70, 5, 34, 34);
    [_editDuangBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_filter"] forState:UIControlStateNormal];
    [_editDuangBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_filter_pressed"] forState:UIControlStateHighlighted];
    [_editDuangBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_filter_pressed"] forState:UIControlStateSelected];
    [_editDuangBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_editDuangBtn addTarget:self action:@selector(duangBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    _editDuangBtn.selected = YES;
    [_editToolButtonBar addSubview:_editDuangBtn];
    
    _editDoodleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editDoodleBtn.frame = CGRectMake(140, 5, 34, 34);
    [_editDoodleBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_editDoodleBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_brush"] forState:UIControlStateNormal];
    [_editDoodleBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_brush_pressed"] forState:UIControlStateHighlighted];
    [_editDoodleBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_brush_pressed"] forState:UIControlStateSelected];
    [_editDoodleBtn addTarget:self action:@selector(doodleBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_editToolButtonBar addSubview:_editDoodleBtn];
    
    _editClipsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editClipsBtn.frame = CGRectMake(210, 5, 34, 34);
    [_editClipsBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_editClipsBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_cut"] forState:UIControlStateNormal];
    [_editClipsBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_cut_pressed"] forState:UIControlStateHighlighted];
    [_editClipsBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"aio_photo_cut_pressed"] forState:UIControlStateSelected];
    [_editClipsBtn addTarget:self action:@selector(clipsBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_editToolButtonBar addSubview:_editClipsBtn];

    [self addDuangView];
}

- (void)initClipButtonBar {
    
    _editClipButtonBar = [[UIView alloc] initWithFrame:CGRectZero];
    _editClipButtonBar.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    _editClipButtonBar.layer.borderColor = [UIColor grayColor].CGColor;
    _editClipButtonBar.layer.borderWidth = 1.0f;
    [self.view addSubview:_editClipButtonBar];
    _editClipButtonBar.hidden = YES;
    
    UIButton *roateBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 34, 34)];
    [roateBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_normal"] forState:UIControlStateNormal];
    [roateBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_pressed"] forState:UIControlStateHighlighted];
    [roateBtn addTarget:self action:@selector(orientationBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_editClipButtonBar addSubview:roateBtn];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 50, 34, 34)];
    [cancelBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_normal"] forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_pressed"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelClipImage:) forControlEvents:UIControlEventTouchUpInside];
    [_editClipButtonBar addSubview:cancelBtn];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(300, 50, 34, 34)];
    [okBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_normal"] forState:UIControlStateNormal];
    [okBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_pressed"] forState:UIControlStateHighlighted];
    [okBtn addTarget:self action:@selector(complateClipImage:) forControlEvents:UIControlEventTouchUpInside];
    [_editClipButtonBar addSubview:okBtn];
}

- (void)initImageDisplayView
{
    /*
    _imageDisplayView = [[UIImageView alloc] initWithImage:_originalImage];
    _imageDisplayView.frame = kDisplayImageViewFrame;
    _imageDisplayView.backgroundColor = [UIColor blackColor];
    _imageDisplayView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageDisplayView];
    */
}

//加特效 Duang
- (void)addDuangView {
    
    _editDataSource = [[NSArray alloc] initWithObjects:@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit",@"photo_edit", nil];
    _editTitles = [[NSArray alloc] initWithObjects:@"原图",@"LOMO",@"黑白",@"怀旧",@"哥特",@"锐化",@"淡雅",@"酒红",@"清宁",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    _editDuangView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 88)];
    _editDuangView.showsVerticalScrollIndicator = NO;
    _editDuangView.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    _editDuangView.hidden = YES;
    [self.view addSubview:_editDuangView];
    
    NSInteger i = 0;
    for (NSString * imageStr in _editDataSource) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80 * i, 0, 80, 80)];
        imageView.image = [self getDuangImageWithIndexTag:i originalImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:imageStr]];
        imageView.tag = kImageTagFrom + i;
        imageView.userInteractionEnabled = YES;
        [_editDuangView addSubview:imageView];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, imageView.height - 20, imageView.width - 4, 20)];
        titleLabel.backgroundColor = [UIColor blackColor];
        titleLabel.alpha = 0.7;
        titleLabel.text = _editTitles[i];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        titleLabel.textColor = [UIColor yellowColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        [imageView addSubview:titleLabel];
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewHandle:)];
        [imageView addGestureRecognizer:tapGes];
        i++;
    }
    _editDuangView.contentSize = CGSizeMake(80 * _editDataSource.count, _editDuangView.height);
}

//图片旋转工具条
- (void)addOrientationView {
    
    _editOrientationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolBar.bounds), CGRectGetHeight(_toolBar.bounds))];
    _editOrientationView.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    [self.view addSubview:_editOrientationView];
    
    UIButton * orientationLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    orientationLeftBtn.frame = CGRectMake(_editOrientationView.width / 2 - 70, 10, 34, 34);
    [orientationLeftBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_normal"] forState:UIControlStateNormal];
    [orientationLeftBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_left_ccw_pressed"] forState:UIControlStateHighlighted];
    [orientationLeftBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    orientationLeftBtn.tag = kTurnLeftBtnTag;
    [orientationLeftBtn addTarget:self action:@selector(orientationBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_editOrientationView addSubview:orientationLeftBtn];
    
    UIButton * orientationRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    orientationRightBtn.frame = CGRectMake(_editOrientationView.width / 2 + 20, 10, 34, 34);
    [orientationRightBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_right_ccw_normal"] forState:UIControlStateNormal];
    [orientationRightBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_crop_right_ccw_pressed"] forState:UIControlStateHighlighted];
    [orientationRightBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    orientationRightBtn.tag = kTurnRightBtnTag;
    [orientationRightBtn addTarget:self action:@selector(orientationBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_editOrientationView addSubview:orientationRightBtn];
}

//涂鸦工具条
- (void)addDoodleSelectBar {
    
    _editDoodleSelectBar = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 88)];
    _editDoodleSelectBar.showsVerticalScrollIndicator = NO;
    _editDoodleSelectBar.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    [self.view addSubview:_editDoodleSelectBar];
    
    UIButton * cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cleanBtn.frame = CGRectMake(10, 10, 34, 34);
    [cleanBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cleanBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_doodle_eraser_normal"] forState:UIControlStateNormal];
    [cleanBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_doodle_eraser_pressed"] forState:UIControlStateHighlighted];
    [cleanBtn setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"pe_doodle_eraser_pressed"] forState:UIControlStateSelected];
    [cleanBtn addTarget:self action:@selector(cleanBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_editDoodleSelectBar addSubview:cleanBtn];
    
    _editColors = [NSArray arrayWithObjects:[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor], nil];
    
    cleanBtn.tag = 1000 + _editColors.count;
    
    NSInteger i = 0;
    for (UIColor * color in _editColors) {
        UIView * colorView = [[UIView alloc] initWithFrame:CGRectMake(54 + i * 44, 10, 34, 34)];
        colorView.backgroundColor = color;
        colorView.layer.cornerRadius = 5;
        if (i == 0) {
            colorView.layer.borderColor = [UIColor blueColor].CGColor;
            colorView.layer.borderWidth = 1;
            _editImageDoodleView.selectedColor = [_editColors firstObject];
        }
        [_editDoodleSelectBar addSubview:colorView];
        colorView.tag = 1000 + i;
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorViewTapHandle:)];
        [colorView addGestureRecognizer:tapGes];
        i ++;
    }
}

- (void)configEditToolBar {
    [self initEditToolsBar];
    [self initClipButtonBar];
}

- (void)configCustomNaviBar {
    QIMImagePickerController *tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    
    _naviBar = [[UIView alloc] initWithFrame:CGRectZero];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_backButton setImage:[UIImage qim_imageNamedFromQIMImagePickerBundle:@"navi_back"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _selectButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_selectButton setImage:tzImagePickerVc.photoDefImage forState:UIControlStateNormal];
    [_selectButton setImage:tzImagePickerVc.photoSelImage forState:UIControlStateSelected];
    _selectButton.imageView.clipsToBounds = YES;
    _selectButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    _selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    _selectButton.hidden = !tzImagePickerVc.showSelectBtn;
    
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.font = [UIFont systemFontOfSize:14];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    
    [_naviBar addSubview:_selectButton];
    [_naviBar addSubview:_indexLabel];
    [_naviBar addSubview:_backButton];
    [self.view addSubview:_naviBar];
}

- (void)configBottomToolBar {
    
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    static CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    _editPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_editPhotoButton addTarget:self action:@selector(editPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_editPhotoButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    
    if (_tzImagePickerVc.allowPickingOriginalPhoto) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, [QIMCommonTools qim_isRightToLeftLayout] ? 10 : -10, 0, 0);
        _originalPhotoButton.backgroundColor = [UIColor clearColor];
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_originalPhotoButton setTitle:_tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:_tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:_tzImagePickerVc.photoPreviewOriginDefImage forState:UIControlStateNormal];
        [_originalPhotoButton setImage:_tzImagePickerVc.photoOriginSelImage forState:UIControlStateSelected];
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:13];
        _originalPhotoLabel.textColor = [UIColor whiteColor];
        _originalPhotoLabel.backgroundColor = [UIColor clearColor];
        if (_isSelectOriginalPhoto) [self showPhotoBytes];
    }
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:_tzImagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitleColor:_tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    
    _numberImageView = [[UIImageView alloc] initWithImage:_tzImagePickerVc.photoNumberIconImage];
    _numberImageView.backgroundColor = [UIColor clearColor];
    _numberImageView.clipsToBounds = YES;
    _numberImageView.contentMode = UIViewContentModeScaleAspectFit;
    _numberImageView.hidden = _tzImagePickerVc.selectedModels.count <= 0;
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",_tzImagePickerVc.selectedModels.count];
    _numberLabel.hidden = _tzImagePickerVc.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    [_originalPhotoButton addSubview:_originalPhotoLabel];
    [_toolBar addSubview:_editPhotoButton];
    [_toolBar addSubview:_doneButton];
    [_toolBar addSubview:_originalPhotoButton];
    [_toolBar addSubview:_numberImageView];
    [_toolBar addSubview:_numberLabel];
    [self.view addSubview:_toolBar];
    
    if (_tzImagePickerVc.photoPreviewPageUIConfigBlock) {
        _tzImagePickerVc.photoPreviewPageUIConfigBlock(_collectionView, _naviBar, _backButton, _selectButton, _indexLabel, _toolBar, _editPhotoButton, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel);
    }
}

- (void)configCollectionView {
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.models.count * (self.view.qim_width + 20), 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[QIMPhotoPreviewCell class] forCellWithReuseIdentifier:@"QIMPhotoPreviewCell"];
    [_collectionView registerClass:[QIMVideoPreviewCell class] forCellWithReuseIdentifier:@"QIMVideoPreviewCell"];
    [_collectionView registerClass:[QIMGifPreviewCell class] forCellWithReuseIdentifier:@"QIMGifPreviewCell"];
}

- (void)configCropView {
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    if (_tzImagePickerVc.maxImagesCount <= 1 && _tzImagePickerVc.allowCrop && _tzImagePickerVc.allowPickingImage) {
        [_cropView removeFromSuperview];
        [_cropBgView removeFromSuperview];
        
        _cropBgView = [UIView new];
        _cropBgView.userInteractionEnabled = NO;
        _cropBgView.frame = self.view.bounds;
        _cropBgView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_cropBgView];
        [QIMImageCropManager overlayClippingWithView:_cropBgView cropRect:_tzImagePickerVc.cropRect containerView:self.view needCircleCrop:_tzImagePickerVc.needCircleCrop];
        
        _cropView = [UIView new];
        _cropView.userInteractionEnabled = NO;
        _cropView.frame = _tzImagePickerVc.cropRect;
        _cropView.backgroundColor = [UIColor clearColor];
        _cropView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropView.layer.borderWidth = 1.0;
        if (_tzImagePickerVc.needCircleCrop) {
            _cropView.layer.cornerRadius = _tzImagePickerVc.cropRect.size.width / 2;
            _cropView.clipsToBounds = YES;
        }
        [self.view addSubview:_cropView];
        if (_tzImagePickerVc.cropViewSettingBlock) {
            _tzImagePickerVc.cropViewSettingBlock(_cropView);
        }
        
        [self.view bringSubviewToFront:_naviBar];
        [self.view bringSubviewToFront:_toolBar];
    }
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    
    CGFloat statusBarHeight = [QIMCommonTools qim_statusBarHeight];
    CGFloat statusBarHeightInterval = statusBarHeight - 20;
    CGFloat naviBarHeight = statusBarHeight + _tzImagePickerVc.navigationBar.qim_height;
    _naviBar.frame = CGRectMake(0, 0, self.view.qim_width, naviBarHeight);
    _backButton.frame = CGRectMake(10, 10 + statusBarHeightInterval, 44, 44);
    _selectButton.frame = CGRectMake(self.view.qim_width - 56, 10 + statusBarHeightInterval, 44, 44);
    _indexLabel.frame = _selectButton.frame;
    
    _editNaviBar.frame = CGRectMake(0, 0, self.view.qim_width, naviBarHeight);
    _cancelEditButton.frame = CGRectMake(10, 10 + statusBarHeightInterval, 44, 44);
    _completeEditButton.frame = CGRectMake(self.view.qim_width - 56, 10 + statusBarHeightInterval, 44, 44);
    
    _layout.itemSize = CGSizeMake(self.view.qim_width + 20, self.view.qim_height);
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    _collectionView.frame = CGRectMake(-10, 0, self.view.qim_width + 20, self.view.qim_height);
    [_collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetX = _offsetItemCount * _layout.itemSize.width;
        [_collectionView setContentOffset:CGPointMake(offsetX, 0)];
    }
    if (_tzImagePickerVc.allowCrop) {
        [_collectionView reloadData];
    }
    
    CGFloat toolBarHeight = [QIMCommonTools qim_isIPhoneX] ? 44 + (83 - 49) : 44;
    CGFloat toolBarTop = self.view.qim_height - toolBarHeight;
    
    CGFloat editToolBarHeight = [QIMCommonTools qim_isIPhoneX] ? 80 + (83 - 49) : 80;
    CGFloat editToolBarTop = self.view.qim_height - editToolBarHeight;
    
    _toolBar.frame = CGRectMake(0, toolBarTop, self.view.qim_width, toolBarHeight);
    _editToolButtonBar.frame = CGRectMake(0, toolBarTop, self.view.qim_width, toolBarHeight);
    _editClipButtonBar.frame = CGRectMake(0, editToolBarTop, self.view.qim_width, editToolBarHeight);
    
    _editDuangView.frame = CGRectMake(0, toolBarTop - 88, self.view.qim_width, 88);
    _editOrientationView.frame = CGRectMake(0, toolBarTop - 54, self.view.qim_width, 54);
    _editDoodleSelectBar.frame = CGRectMake(0, toolBarTop - 54, self.view.qim_width, 54);
    
    _editPhotoButton.frame = CGRectMake(0, 0, 44, 44);
    if (_tzImagePickerVc.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [_tzImagePickerVc.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton.frame = CGRectMake(50, 0, fullImageWidth + 56, 44);
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 42, 0, 80, 44);
    }
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.qim_width - _doneButton.qim_width - 12, 0, _doneButton.qim_width, 44);
    _numberImageView.frame = CGRectMake(_doneButton.qim_left - 24 - 5, 10, 24, 24);
    _numberLabel.frame = _numberImageView.frame;
    
    [self configCropView];
    
    if (_tzImagePickerVc.photoPreviewPageDidLayoutSubviewsBlock) {
        _tzImagePickerVc.photoPreviewPageDidLayoutSubviewsBlock(_collectionView, _naviBar, _backButton, _selectButton, _indexLabel, _toolBar, _editPhotoButton, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel);
    }
}

#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.x / _layout.itemSize.width;
}

#pragma mark - Click Event

- (void)select:(UIButton *)selectButton {
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    QIMAssetModel *model = _models[self.currentIndex];
    if (!selectButton.isSelected) {
        // 1. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
        if (_tzImagePickerVc.selectedModels.count >= _tzImagePickerVc.maxImagesCount) {
            NSString *title = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"Select a maximum of %zd photos"], _tzImagePickerVc.maxImagesCount];
            [_tzImagePickerVc showAlertWithTitle:title];
            return;
            // 2. if not over the maxImagesCount / 如果没有超过最大个数限制
        } else {
            [_tzImagePickerVc addSelectedModel:model];
            if (self.photos) {
                [_tzImagePickerVc.selectedAssets addObject:_assetsTemp[self.currentIndex]];
                [self.photos addObject:_photosTemp[self.currentIndex]];
            }
            if (model.type == QIMAssetModelMediaTypeVideo && !_tzImagePickerVc.allowPickingMultipleVideo) {
                [_tzImagePickerVc showAlertWithTitle:[NSBundle qim_localizedStringForKey:@"Select the video when in multi state, we will handle the video as a photo"]];
            }
        }
    } else {
        NSArray *selectedModels = [NSArray arrayWithArray:_tzImagePickerVc.selectedModels];
        for (QIMAssetModel *model_item in selectedModels) {
            if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                // 1.6.7版本更新:防止有多个一样的model,一次性被移除了
                NSArray *selectedModelsTmp = [NSArray arrayWithArray:_tzImagePickerVc.selectedModels];
                for (NSInteger i = 0; i < selectedModelsTmp.count; i++) {
                    QIMAssetModel *model = selectedModelsTmp[i];
                    if ([model isEqual:model_item]) {
                        [_tzImagePickerVc removeSelectedModel:model];
                        // [_tzImagePickerVc.selectedModels removeObjectAtIndex:i];
                        break;
                    }
                }
                if (self.photos) {
                    // 1.6.7版本更新:防止有多个一样的asset,一次性被移除了
                    NSArray *selectedAssetsTmp = [NSArray arrayWithArray:_tzImagePickerVc.selectedAssets];
                    for (NSInteger i = 0; i < selectedAssetsTmp.count; i++) {
                        id asset = selectedAssetsTmp[i];
                        if ([asset isEqual:_assetsTemp[self.currentIndex]]) {
                            [_tzImagePickerVc.selectedAssets removeObjectAtIndex:i];
                            break;
                        }
                    }
                    // [_tzImagePickerVc.selectedAssets removeObject:_assetsTemp[self.currentIndex]];
                    [self.photos removeObject:_photosTemp[self.currentIndex]];
                }
                break;
            }
        }
    }
    model.isSelected = !selectButton.isSelected;
    [self refreshNaviBarAndBottomBarState];
    if (model.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:QIMOscillatoryAnimationToBigger];
    }
    [UIView showOscillatoryAnimationWithLayer:_numberImageView.layer type:QIMOscillatoryAnimationToSmaller];
}

- (void)backButtonClick {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        if ([self.navigationController isKindOfClass: [QIMImagePickerController class]]) {
            QIMImagePickerController *nav = (QIMImagePickerController *)self.navigationController;
            if (nav.imagePickerControllerDidCancelHandle) {
                nav.imagePickerControllerDidCancelHandle();
            }
        }
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock(_isSelectOriginalPhoto);
    }
}

#pragma mark - EditImage

//取消编辑图片
- (void)cancelEditImage:(id)sender {
    _editClipsBtn.selected = NO;
    [UIView animateWithDuration:1 animations:^{
        _editNaviBar.hidden = YES;
        _editDuangView.hidden = YES;
        _editOrientationView.hidden = YES;
        _editDoodleSelectBar.hidden = YES;
        _editToolButtonBar.hidden = YES;
    } completion:^(BOOL finished) {
        _naviBar.hidden = NO;
        _toolBar.hidden = NO;
    }];
}

//完成编辑图片
- (void)complateEditImage:(id)sender {
    _editClipsBtn.selected = NO;
    [UIView animateWithDuration:1 animations:^{
        _editNaviBar.hidden = YES;
        _editDuangView.hidden = YES;
        _editOrientationView.hidden = YES;
        _editDoodleSelectBar.hidden = YES;
        _editToolButtonBar.hidden = YES;
        
    } completion:^(BOOL finished) {
        _naviBar.hidden = NO;
        _toolBar.hidden = NO;
    }];
}

-(void)imageViewHandle:(UITapGestureRecognizer *)tapGes {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    QIMPhotoPreviewCell *cell = (QIMPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    UIImage *originImage = cell.previewView.imageView.image;
    
    UIImage *image = [self getDuangImageWithIndexTag:tapGes.view.tag - kImageTagFrom originalImage:originImage];
    cell.previewView.imageView.image = originImage;
    float desOffsetX = tapGes.view.origin.x - (_editDuangView.width - 80) / 2;
    [_editDuangView setContentOffset:CGPointMake(MIN(MAX(desOffsetX, 0), _editDuangView.contentSize.width - _editDuangView.width), 0) animated:YES];
}

//旋转图片
- (void)orientationBtnHandle:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    QIMPhotoPreviewCell *cell = (QIMPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    UIImage *originImage = cell.previewView.imageView.image;
    cell.previewView.imageView.image = [QIMImageUtil image:originImage rotation:UIImageOrientationLeft];

    [_editImageClipView resetClipRectWithImage:cell.previewView.imageView.image];
}

//取消裁剪图片
- (void)cancelClipImage:(id)sender {
    _editClipsBtn.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _naviBar.hidden = YES;
        _toolBar.hidden = YES;
        _editClipButtonBar.hidden = YES;
    } completion:^(BOOL finished) {
        _editNaviBar.hidden = NO;
        _editDuangView.hidden = YES;
//        _editOrientationView.hidden = YES;
        _editDoodleSelectBar.hidden = YES;
        _editToolButtonBar.hidden = NO;
    }];
}

//完成裁剪图片
- (void)complateClipImage:(id)sender {
    _editClipsBtn.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _naviBar.hidden = YES;
        _toolBar.hidden = YES;
        _editClipButtonBar.hidden = YES;
    } completion:^(BOOL finished) {
        _editNaviBar.hidden = NO;
        _editDuangView.hidden = YES;
        //        _editOrientationView.hidden = YES;
        _editDoodleSelectBar.hidden = YES;
        _editToolButtonBar.hidden = NO;
    }];
}

- (void)colorViewTapHandle:(UITapGestureRecognizer *)tap {
    _editImageDoodleView.drawingMode = DrawingModePaint;
    
    [self cleanColorSelection];
    
    UIColor * color = [_editColors objectAtIndex:tap.view.tag - 1000];
    _editImageDoodleView.selectedColor = color;
    
    tap.view.layer.borderColor = [UIColor blueColor].CGColor;
    tap.view.layer.borderWidth = 1;
}

//加滤镜
- (void)duangBtnHandle:(id)sender {
    _editDuangView.hidden = NO;
    _editImageClipView.hidden = YES;
    _editImageDoodleView.hidden = YES;
    if (_editDuangView) {
        [self.view bringSubviewToFront:_editDuangView];
    }
    
    _editDuangBtn.selected = YES;
    _editClipsBtn.selected = NO;
    _editDoodleBtn.selected = NO;
}

//裁剪
- (void)clipsBtnHandle:(id)sender {
    _editDuangView.hidden = YES;
    _editToolButtonBar.hidden = YES;
    _editNaviBar.hidden = YES;
    _editImageClipView.hidden = NO;
    _editClipButtonBar.hidden = NO;
    [self setupImageClipView];

    _editClipsBtn.selected = YES;
    _editDoodleBtn.selected = NO;
    _editDuangBtn.selected = NO;
}

- (void)setupImageClipView {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    QIMPhotoPreviewCell *cell = (QIMPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    if (_editImageClipView) {
        [_editImageClipView resetClipRectWithImage:cell.previewView.imageView.image];
        [self.view bringSubviewToFront:_editImageClipView];
    }else{
//        _editImageClipView = [[QIMImageClipView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth([UIScreen mainScreen].bounds) - 40, _editToolBar.top - 40) imageView:cell.previewView.imageView.image];
        [self.view addSubview:_editImageClipView];
    }
//    cell.previewView.imageView.frame = CGRectMake(20, 20, CGRectGetWidth([UIScreen mainScreen].bounds) - 40, _editToolBar.top - 40);
    
    if (_editClipButtonBar) {
        [self.view bringSubviewToFront:_editClipButtonBar];
    } else {
//        [self addOrientationView];
    }
}

//画笔
- (void)doodleBtnHandle:(id)sender {
    _editDuangView.hidden = YES;
    _editImageClipView.hidden = YES;
    _editImageDoodleView.hidden = NO;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    QIMPhotoPreviewCell *cell = (QIMPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if (_editImageDoodleView) {
        [_editImageDoodleView clean];
        [self.view bringSubviewToFront:_editImageDoodleView];
    } else {
        [self setUpQIMImageDoodleView];
    }
    
    UIImage *image = cell.previewView.imageView.image;
    _editImageDoodleView.hidden = NO;
    if (_editDoodleSelectBar) {
        [self.view bringSubviewToFront:_editDoodleSelectBar];
    } else {
        [self addDoodleSelectBar];
    }
    
    _editDoodleBtn.selected = YES;
    _editClipsBtn.selected = NO;
    _editDuangBtn.selected = NO;
}

- (void)setUpQIMImageDoodleView
{
    _editImageDoodleView = [[QIMImageDoodleView alloc] initWithFrame:CGRectZero];
    _editImageDoodleView.drawingMode = DrawingModePaint;
    [self.view addSubview:_editImageDoodleView];
}

- (void)cleanBtnHandle:(id)sender {
    
}

- (void)cleanColorSelection {
    
    for (int i = 0; i <= _editColors.count; i ++) {
        UIView * colorView = [_editDoodleSelectBar viewWithTag:1000 + i];
        if ([colorView isKindOfClass:[UIButton class]]) {
            [(UIButton *)colorView setSelected:NO];
        }else{
            colorView.layer.borderWidth = 0;
        }
    }
}

- (UIImage *)getDuangImageWithIndexTag:(NSInteger)indexTag originalImage:(UIImage *)originalImage {
    
    UIImage *image;
    switch (indexTag) {
        case 0:
        {
            return originalImage;
        }
            break;
        case 1:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_lomo];
        }
            break;
        case 2:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_heibai];
        }
            break;
        case 3:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_huajiu];
        }
            break;
        case 4:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_gete];
        }
            break;
        case 5:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_ruise];
        }
            break;
        case 6:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_danya];
        }
            break;
        case 7:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_jiuhong];
        }
            break;
        case 8:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_qingning];
        }
            break;
        case 9:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_langman];
        }
            break;
        case 10:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_guangyun];
        }
            break;
        case 11:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_landiao];
            
        }
            break;
        case 12:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_menghuan];
            
        }
            break;
        case 13:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:qim_colormatrix_yese];
            
        }
    }
    return image;
}

#pragma mark - ToolBar

- (void)editPhotoButtonClick {
    [UIView animateWithDuration:0.3 animations:^{
        _naviBar.hidden = YES;
        _toolBar.hidden = YES;
    } completion:^(BOOL finished) {
        _editNaviBar.hidden = NO;
        _editDuangView.hidden = NO;
        _editOrientationView.hidden = YES;
        _editDoodleSelectBar.hidden = YES;
        _editToolButtonBar.hidden = NO;
    }];
}

- (void)doneButtonClick {
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    // 如果图片正在从iCloud同步中,提醒用户
    if (_progress > 0 && _progress < 1 && (_selectButton.isSelected || !_tzImagePickerVc.selectedModels.count )) {
        _alertView = [_tzImagePickerVc showAlertWithTitle:[NSBundle qim_localizedStringForKey:@"Synchronizing photos from iCloud"]];
        return;
    }
    
    // 如果没有选中过照片 点击确定时选中当前预览的照片
    if (_tzImagePickerVc.selectedModels.count == 0 && _tzImagePickerVc.minImagesCount <= 0) {
        QIMAssetModel *model = _models[self.currentIndex];
        [_tzImagePickerVc addSelectedModel:model];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    QIMPhotoPreviewCell *cell = (QIMPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if (_tzImagePickerVc.allowCrop && [cell isKindOfClass:[QIMPhotoPreviewCell class]]) { // 裁剪状态
        _doneButton.enabled = NO;
        [_tzImagePickerVc showProgressHUD];
        UIImage *cropedImage = [QIMImageCropManager cropImageView:cell.previewView.imageView toRect:_tzImagePickerVc.cropRect zoomScale:cell.previewView.scrollView.zoomScale containerView:self.view];
        if (_tzImagePickerVc.needCircleCrop) {
            cropedImage = [QIMImageCropManager circularClipImage:cropedImage];
        }
        _doneButton.enabled = YES;
        [_tzImagePickerVc hideProgressHUD];
        if (self.doneButtonClickBlockCropMode) {
            QIMAssetModel *model = _models[self.currentIndex];
            self.doneButtonClickBlockCropMode(cropedImage,model.asset);
        }
    } else if (self.doneButtonClickBlock) { // 非裁剪状态
        self.doneButtonClickBlock(_isSelectOriginalPhoto);
    }
    if (self.doneButtonClickBlockWithPreviewType) {
        self.doneButtonClickBlockWithPreviewType(self.photos,_tzImagePickerVc.selectedAssets,self.isSelectOriginalPhoto);
    }
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
        if (!_selectButton.isSelected) {
            // 如果当前已选择照片张数 < 最大可选张数 && 最大可选张数大于1，就选中该张图
            QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
            if (_tzImagePickerVc.selectedModels.count < _tzImagePickerVc.maxImagesCount && _tzImagePickerVc.showSelectBtn) {
                [self select:_selectButton];
            }
        }
    }
}

- (void)didTapPreviewCell {
    self.isHideNaviBar = !self.isHideNaviBar;
    _naviBar.hidden = self.isHideNaviBar;
    _toolBar.hidden = self.isHideNaviBar;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.qim_width + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (self.view.qim_width + 20);
    if (currentIndex < _models.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewCollectionViewDidScroll" object:nil];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    QIMAssetModel *model = _models[indexPath.item];
    
    QIMAssetPreviewCell *cell;
    __weak typeof(self) weakSelf = self;
    if (_tzImagePickerVc.allowPickingMultipleVideo && model.type == QIMAssetModelMediaTypeVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QIMVideoPreviewCell" forIndexPath:indexPath];
    } else if (_tzImagePickerVc.allowPickingMultipleVideo && model.type == QIMAssetModelMediaTypePhotoGif && _tzImagePickerVc.allowPickingGif) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QIMGifPreviewCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QIMPhotoPreviewCell" forIndexPath:indexPath];
        QIMPhotoPreviewCell *photoPreviewCell = (QIMPhotoPreviewCell *)cell;
        photoPreviewCell.cropRect = _tzImagePickerVc.cropRect;
        photoPreviewCell.allowCrop = _tzImagePickerVc.allowCrop;
        __weak typeof(_tzImagePickerVc) weakTzImagePickerVc = _tzImagePickerVc;
        __weak typeof(_collectionView) weakCollectionView = _collectionView;
        __weak typeof(photoPreviewCell) weakCell = photoPreviewCell;
        [photoPreviewCell setImageProgressUpdateBlock:^(double progress) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            __strong typeof(weakTzImagePickerVc) strongTzImagePickerVc = weakTzImagePickerVc;
            __strong typeof(weakCollectionView) strongCollectionView = weakCollectionView;
            __strong typeof(weakCell) strongCell = weakCell;
            strongSelf.progress = progress;
            if (progress >= 1) {
                if (strongSelf.isSelectOriginalPhoto) [strongSelf showPhotoBytes];
                if (strongSelf.alertView && [strongCollectionView.visibleCells containsObject:strongCell]) {
                    [strongTzImagePickerVc hideAlertView:strongSelf.alertView];
                    strongSelf.alertView = nil;
                    [strongSelf doneButtonClick];
                }
            }
        }];
    }
    
    cell.model = model;
    [cell setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didTapPreviewCell];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[QIMPhotoPreviewCell class]]) {
        [(QIMPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[QIMPhotoPreviewCell class]]) {
        [(QIMPhotoPreviewCell *)cell recoverSubviews];
    } else if ([cell isKindOfClass:[QIMVideoPreviewCell class]]) {
        QIMVideoPreviewCell *videoCell = (QIMVideoPreviewCell *)cell;
        if (videoCell.player && videoCell.player.rate != 0.0) {
            [videoCell pausePlayerAndShowNaviBar];
        }
    }
}

#pragma mark - Private Method

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (void)refreshNaviBarAndBottomBarState {
    QIMImagePickerController *_tzImagePickerVc = (QIMImagePickerController *)self.navigationController;
    QIMAssetModel *model = _models[self.currentIndex];
    _selectButton.selected = model.isSelected;
    [self refreshSelectButtonImageViewContentMode];
    if (_selectButton.isSelected && _tzImagePickerVc.showSelectedIndex && _tzImagePickerVc.showSelectBtn) {
        NSString *index = [NSString stringWithFormat:@"%d", (int)([_tzImagePickerVc.selectedAssetIds indexOfObject:model.asset.localIdentifier] + 1)];
        _indexLabel.text = index;
        _indexLabel.hidden = NO;
    } else {
        _indexLabel.hidden = YES;
    }
    _numberLabel.text = [NSString stringWithFormat:@"%zd",_tzImagePickerVc.selectedModels.count];
    _numberImageView.hidden = (_tzImagePickerVc.selectedModels.count <= 0 || _isHideNaviBar || _isCropImage);
    _numberLabel.hidden = (_tzImagePickerVc.selectedModels.count <= 0 || _isHideNaviBar || _isCropImage);
    
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self showPhotoBytes];
    
    // If is previewing video, hide original photo button
    // 如果正在预览的是视频，隐藏原图按钮
    if (!_isHideNaviBar) {
        if (model.type == QIMAssetModelMediaTypeVideo) {
            _originalPhotoButton.hidden = YES;
            _originalPhotoLabel.hidden = YES;
        } else {
            _originalPhotoButton.hidden = NO;
            if (_isSelectOriginalPhoto)  _originalPhotoLabel.hidden = NO;
        }
    }
    
    _doneButton.hidden = NO;
    _selectButton.hidden = !_tzImagePickerVc.showSelectBtn;
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[QIMImagePickerManager manager] isPhotoSelectableWithAsset:model.asset]) {
        _numberLabel.hidden = YES;
        _numberImageView.hidden = YES;
        _selectButton.hidden = YES;
        _originalPhotoButton.hidden = YES;
        _originalPhotoLabel.hidden = YES;
        _doneButton.hidden = YES;
    }
}

- (void)refreshSelectButtonImageViewContentMode {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_selectButton.imageView.image.size.width <= 27) {
            self->_selectButton.imageView.contentMode = UIViewContentModeCenter;
        } else {
            self->_selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    });
}

- (void)showPhotoBytes {
    [[QIMImagePickerManager manager] getPhotosBytesWithArray:@[_models[self.currentIndex]] completion:^(NSString *totalBytes) {
        self->_originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

- (NSInteger)currentIndex {
    return [QIMCommonTools qim_isRightToLeftLayout] ? self.models.count - _currentIndex - 1 : _currentIndex;
}

@end

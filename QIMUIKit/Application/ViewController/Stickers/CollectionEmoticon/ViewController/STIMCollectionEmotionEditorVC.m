//
//  STIMCollectionEmotionEditorVC.m
//  STChatIphone
//
//  Created by qitmac000495 on 16/5/13.
//
//

#import "STIMCollectionEmotionEditorVC.h"
#import "STIMCollectionFaceManager.h"
#import "MBProgressHUD.h"

typedef NS_ENUM(NSUInteger, STIMDragCellCollectionViewScrollDirection) {
    STIMDragCellCollectionViewScrollDirectionNone = 0,
    STIMDragCellCollectionViewScrollDirectionLeft,
    STIMDragCellCollectionViewScrollDirectionRight,
    STIMDragCellCollectionViewScrollDirectionUp,
    STIMDragCellCollectionViewScrollDirectionDown
};
#define kEmotionItemColumnNum   4

#import "STIMCollectionEmotionEditorViewFlowLayout.h"
#import "QTImagePickerController.h"
#import "STIMImageUtil.h"
#import "UIBarButtonItem+Utility.h"
#import "STIMCollectionEmotionEditorViewCell.h"
#import "STIMCollectionEmotionPanView.h"

static NSString *collectEmojiCellID = @"collectEmojiCellID";

@interface STIMCollectionEmotionEditorVC () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationBarDelegate, STIMCollectionEmotionEditorViewDelegate, QTImagePickerControllerDelegate, STIMDragCellCollectionViewDelegate, STIMDragCellCollectionViewDataSource, UIAlertViewDelegate>
{
    NSMutableArray *_emotionSelectedList;
}

@property (nonatomic, strong) STIMCollectionEmotionPanView *mainCollectionView;

@property (nonatomic, strong) UIView *emotionDelBar;

@property (nonatomic, strong) UIButton *emotionDelBtn;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) UIButton *sortBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, assign) BOOL willRefresh;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation STIMCollectionEmotionEditorVC

#pragma mark - setter and getter

- (NSMutableArray *)dataList {
    
    if (!_dataList) {
        
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (STIMCollectionEmotionPanView *)mainCollectionView {
    
    if (!_mainCollectionView) {
        
        STIMCollectionEmotionEditorViewFlowLayout *layout = [[STIMCollectionEmotionEditorViewFlowLayout alloc] init];
        _mainCollectionView = [[STIMCollectionEmotionPanView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_mainCollectionView registerClass:[STIMCollectionEmotionEditorViewCell class] forCellWithReuseIdentifier:collectEmojiCellID];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.qimDragDelegate = self;
        _mainCollectionView.qimDragDataSource = self;
        _mainCollectionView.shakeLevel = 3.0f;
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        
        UIView * headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(_mainCollectionView.frame), CGRectGetWidth(_mainCollectionView.frame), CGRectGetHeight(_mainCollectionView.frame))];
        headerBgView.backgroundColor = [UIColor stimDB_colorWithHex:0xececec alpha:1];
        [_mainCollectionView addSubview:headerBgView];
    }
    return _mainCollectionView;
}

#pragma mark - HUD
- (MBProgressHUD *)progressHUDWithText:(NSString *)text {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [_progressHUD setLabelText:@""];
        [self.mainCollectionView addSubview:_progressHUD];
    }
    [_progressHUD setDetailsLabelText:text];
    return _progressHUD;
}
- (UIButton *)sortBtn {
    
    if (!_sortBtn) {
        
        _sortBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sortBtn.frame =  CGRectMake(0, 0, 44, 44);
        [_sortBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Manage"] forState:UIControlStateNormal];
        [_sortBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Done"] forState:UIControlStateSelected];
        [_sortBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [_sortBtn addTarget:self action:@selector(arrangeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sortBtn;
}

- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, 0, 44, 44);
        [_cancelBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"common_close"] forState:UIControlStateNormal];
        [_cancelBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] forState:UIControlStateSelected];
        [_cancelBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateSelected];
        [_cancelBtn addTarget:self action:@selector(CancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

#pragma mark - 初始化

- (void)initUI {
    
    self.title = [NSBundle stimDB_localizedStringForKey:@"Favorites_Stickers"];
    
    self.view.backgroundColor = [UIColor stimDB_colorWithHex:0xececec alpha:1.0];
    [self.view addSubview:self.mainCollectionView];
}

/**
 *  设置导航条
 */
- (void)setNavBar {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sortBtn];
}

- (void)updateDelBar{
    if (_emotionDelBar == nil) {
        _emotionDelBar = [[UIView alloc] initWithFrame:CGRectMake(0, _mainCollectionView.bottom - 50, _mainCollectionView.width, 50)];
        _emotionDelBar.backgroundColor = [UIColor qtalkChatBgColor];
        UILabel * dispalyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _emotionDelBar.width / 2 - 10, 50)];
        dispalyLabel.text = [NSString stringWithFormat:@"%ld%@",@(_dataList.count), [NSBundle stimDB_localizedStringForKey:@"Stickers"]];
        dispalyLabel.textColor = [UIColor grayColor];
        [_emotionDelBar addSubview:dispalyLabel];
        
        [self.view addSubview:_emotionDelBar];
        _mainCollectionView.frame = CGRectMake(0 , 0, self.view.width, self.view.height - _emotionDelBar.height);
        
    }
    if (_emotionDelBtn == nil) {
        
        _emotionDelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emotionDelBtn.frame = CGRectMake(_emotionDelBar.width - 120, 0, 100, 50);
        _emotionDelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_emotionDelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_emotionDelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_emotionDelBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Delete"] forState:UIControlStateNormal];
        [_emotionDelBtn addTarget:self action:@selector(emotionDelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_emotionDelBar addSubview:_emotionDelBtn];
    
    
    if (_emotionSelectedList.count) {
        [_emotionDelBtn setTitle:[NSString stringWithFormat:@"删除(%@)",@(_emotionSelectedList.count)] forState:UIControlStateNormal];
        [_emotionDelBtn setEnabled:YES];
    }else{
        [_emotionDelBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Delete"] forState:UIControlStateNormal];
        [_emotionDelBtn setEnabled:NO];
        
    }
}

- (void)emotionDelBtnHandle:(id)sender{
    if (_emotionSelectedList.count > 0) {
        [_dataList removeObjectsInArray:_emotionSelectedList];
        [[STIMCollectionFaceManager sharedInstance] delCollectionFaceArr:_emotionSelectedList];
        [_mainCollectionView reloadData];
        [self arrange];
        
        [_emotionDelBar removeFromSuperview];
    }
    _emotionSelectedList = nil;
    [_emotionDelBar removeFromSuperview];
    
    [self updateDelBar];
}


#pragma mark - actionMethod
//关闭
- (void)CancelAction:(id)sender {
    
    if (!self.cancelBtn.selected) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        
        
        self.sortBtn.selected = NO;
        self.cancelBtn.selected = NO;
        self.mainCollectionView.isOpenMove = NO;
        [_emotionDelBar removeFromSuperview];
        
        if (![self isChangeDataList]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel_Change"] message:nil delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle stimDB_localizedStringForKey:@"common_ok"], nil];
            alertView.tag = 0;
            [alertView show];
        }
        [_dataList addObject:kImageFacePageViewAddFlagName];
        [_mainCollectionView reloadData];
    }
}

//判断数据源是否改变
- (BOOL)isChangeDataList {
    
    NSArray *array = [[STIMCollectionFaceManager sharedInstance] getCollectionFaceList];
    BOOL isEqual = [_dataList isEqualToArray:array];
    return isEqual;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 0) {
        
        if (buttonIndex == 1) {
            
            [self refresh];
            [self.mainCollectionView reloadData];
        }
    }
}

//整理
- (void)arrangeAction {
    
    self.sortBtn.selected = !self.sortBtn.selected;
    self.cancelBtn.selected = self.sortBtn.selected;
    self.mainCollectionView.isOpenMove = self.sortBtn.selected;
    // 暂时不支持长按排序
    [self arrange];
     
}

- (void)arrange {
    
    NSString * item = _dataList.lastObject;
    if ([item isKindOfClass:[NSDictionary class]]) {
        item = _dataList.lastObject[@"imageName"];
    }
    
    if ([item isEqualToString:kImageFacePageViewAddFlagName]) {
        [_dataList removeLastObject];
        [self updateDelBar];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"common_prompt"] message:[NSBundle stimDB_localizedStringForKey:@"Long_press_stickers"] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_ok"] otherButtonTitles:nil, nil];
        [alertView show];
        
    }else{
        
        [_emotionDelBar removeFromSuperview];
        _emotionDelBar = nil;
        _mainCollectionView.frame = self.view.bounds;
        if (![self isChangeDataList]) {
            
            [[STIMCollectionFaceManager sharedInstance] resetCollectionItems:self.dataList WithUpdate:YES];
            [[self progressHUDWithText:[NSBundle stimDB_localizedStringForKey:@"Reordering_your_stickers"]] show:YES];
            [self performSelector:@selector(closeHUD) withObject:nil afterDelay:1.0f];
        }
        [self refresh];
    }
    [_mainCollectionView reloadData];
}

- (void)refresh {
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_dataList];
    if (self.sortBtn.selected) {
        
        [tempArray removeAllObjects];
        [tempArray addObjectsFromArray:[[STIMCollectionFaceManager sharedInstance] getCollectionFaceList]];
        _dataList = [NSMutableArray arrayWithArray:tempArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainCollectionView reloadData];
        });
    } else {
        
        [tempArray removeAllObjects];
        [tempArray addObjectsFromArray:[[STIMCollectionFaceManager sharedInstance] getCollectionFaceList]];
        [tempArray addObject:kImageFacePageViewAddFlagName];
        _dataList = [NSMutableArray arrayWithArray:tempArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainCollectionView reloadData];
        });
    }
    _emotionSelectedList = nil;
}

#pragma mark - life ctyle

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_willRefresh) {
        
        [self refresh];
        _willRefresh = NO;
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setNavBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:@"kCollectionEmotionUpdateHandleNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:@"refreshTableView"
                                               object:nil];
    _willRefresh = YES;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STIMCollectionEmotionEditorViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectEmojiCellID forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.editDelegate = self;
    
    NSString * item = _dataList.lastObject;
    if ([item isKindOfClass:[NSDictionary class]]) {
        item = _dataList.lastObject[@"httpUrl"];
    }
    cell.canSelect = ![item isEqualToString:kImageFacePageViewAddFlagName];
    [cell setEmotionItem:_dataList[cell.tag]];
    return cell;
}

- (void)collectionEmotionEditorCell:(STIMCollectionEmotionEditorViewCell *)cell didClickedItemAtIndex:(NSInteger)index selected:(BOOL)selected {
    
    if (self.sortBtn.selected) {
        [self.view addSubview:_emotionDelBar];
    }
    NSString *item = _dataList.lastObject;
    if ([item isKindOfClass:[NSDictionary class]]) {
        
        item = _dataList.lastObject[@"httpUrl"];
    }
    if (![item isEqualToString:kImageFacePageViewAddFlagName]) {
        
        if (_emotionSelectedList == nil) {
            
            _emotionSelectedList = [NSMutableArray arrayWithCapacity:1];
        }
        if (selected) {
            
            [_emotionSelectedList addObject:_dataList[index]];
        } else {
            
            [_emotionSelectedList removeObject:_dataList[index]];
        }
        
        [self updateDelBar];
    } else if (index == _dataList.count - 1) {
        
        QTImagePickerController *imagePickerController = [[QTImagePickerController alloc] init];
        imagePickerController.imageDelegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - QTImagePickerControllerDelegate
- (void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingVideo:(NSDictionary *)videoDic{
    
    [picker dismissViewControllerAnimated:NO completion:nil];
}

-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets ToOriginal:(BOOL)flag
{
    for (ALAsset * asset in assets) {
        NSData * imageData = nil;
        if (flag) {
            uint8_t *buffer = (uint8_t *)malloc(asset.defaultRepresentation.size);
            NSInteger length = [asset.defaultRepresentation getBytes:buffer fromOffset:0 length:asset.defaultRepresentation.size error:nil];
            imageData = [NSData dataWithBytes:buffer length:length];
            free(buffer);
            UIImage * image = [STIMImageUtil fixOrientation:[UIImage imageWithData:imageData]];
            imageData = UIImageJPEGRepresentation(image, 1.0);
        }else{
            UIImage * image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage                                         scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            image = [STIMImageUtil fixOrientation:image];
            imageData = UIImageJPEGRepresentation(image, 0.5);
        }
        
        [[STIMKit sharedInstance] uploadFileForData:imageData forCacheType:STIMFileCacheTypeColoction isFile:NO completionBlock:^(UIImage *image, NSError *error, STIMFileCacheType cacheType, NSString *imageURL) {
            
            
            [[STIMKit sharedInstance] getPermUrlWithTempUrl:imageURL PermHttpUrl:^(NSString *httpPermUrl) {
                
                [[STIMCollectionFaceManager sharedInstance] insertCollectionEmojiWithEmojiUrl:httpPermUrl];

                [[STIMCollectionFaceManager sharedInstance] checkForUploadLocalCollectionFace];

            }];
            
            [self refresh];
            [picker dismissViewControllerAnimated:NO completion:nil];
            
        }];
    }
}

-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingImage:(UIImage *)image
{
    NSData * imageData = UIImageJPEGRepresentation(image, 0.9);
    __block NSString *httpUrl = [NSString stringWithFormat:@""];
    [[STIMKit sharedInstance] uploadFileForData:imageData forCacheType:STIMFileCacheTypeColoction isFile:NO completionBlock:^(UIImage *image, NSError *error, STIMFileCacheType cacheType, NSString *imageURL) {
        
        httpUrl = imageURL;
        
        [[STIMKit sharedInstance] getPermUrlWithTempUrl:httpUrl PermHttpUrl:^(NSString *httpPermUrl) {
            [[STIMCollectionFaceManager sharedInstance] insertCollectionEmojiWithEmojiUrl:httpPermUrl];
            [[STIMCollectionFaceManager sharedInstance] checkForUploadLocalCollectionFace];

        }];
        [self refresh];
        [picker dismissViewControllerAnimated:NO completion:nil];
        
    }];
    
}

#pragma mark - <STIMDragCellCollectionViewDelegate> <STIMDragCellCollectionViewDataSource>

- (NSArray *)dataSourceArrayOfCollectionView:(STIMCollectionEmotionPanView *)collectionView{
    
    return _dataList;
}

- (void)dragCellCollectionView:(STIMCollectionEmotionPanView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    
    [_dataList removeAllObjects];
    [_dataList addObjectsFromArray:newDataArray];
}

- (void)dragCellCollectionView:(STIMCollectionEmotionPanView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath{
    //拖动时候最后禁用掉编辑按钮的点击
    
    [_emotionDelBar removeFromSuperview];
}

- (void)dragCellCollectionViewCellEndMoving:(STIMCollectionEmotionPanView *)collectionView{
    
}

- (void)closeHUD{
    if (_progressHUD) {
        [_progressHUD hide:YES];
    }
}

- (void)dealloc {
    
    _dataList = nil;
    _emotionSelectedList = nil;
    _mainCollectionView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
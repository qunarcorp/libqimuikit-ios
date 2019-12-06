//
//  QTImageAssetViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QTImageAssetViewController.h"
#import "QIMStringTransformTools.h"
#import "QTImagePickerController.h"

#import "QTImageAssetCell.h"

#import "QIMStringTransformTools.h"

#import "QIMImageEditViewController.h"

#import "QTImageAssetTools.h"

#import "QTalkTipsView.h"

#import "QTalkVideoAssetViewController.h"

#import "QTImagePreviewController.h"

#define kPopoverContentSize CGSizeMake(320, 480)
#define kAssetViewCellIdentifier           @"AssetViewCellIdentifier"

CGFloat imageItemWidth;

@interface QTImageAssetViewController ()<UITableViewDelegate,UITableViewDataSource,QTImageAssetCellDelegate,UIActionSheetDelegate,QIMImageEditViewControllerDelegate>{
    
    UIView   *_bottomView;
    UIButton *_previewButton;
    UIButton *_editButton;
    UIButton *_photoTypeButton;
    UIButton *_sendButton;
    
    UITableView *_tableView;
    CGSize _imageItemSize;
    
}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;

@end

@implementation QTImageAssetViewController

- (instancetype)init{
    if (self = [super init])
    {
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    imageItemWidth = (self.view.width - (kColoumn-1)*kImageCap) * 1.0 / kColoumn;

    [self initNavBar];
    [self initBottomView];
    [self initTableView];
    [self setupAssets];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    [self setTitleWithSelectedIndexPaths:picker.indexPathsForSelectedItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma makr - init
- (void)initNavBar{
    
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    if ([self.title.lowercaseString isEqualToString:@"camera roll"]) {
        self.title = [NSBundle qim_localizedStringForKey:@"Camera Roll"];
    }
    [self.navigationItem setTitle:self.title];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
}

- (void)onPreviewClick{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    QTImagePreviewController *previewVC = [[QTImagePreviewController alloc] init];
    [previewVC setPhotoArray:[NSArray arrayWithArray:picker.indexPathsForSelectedItems]];
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)onEditClick{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    if (picker.indexPathsForSelectedItems.count > 0) {
        ALAsset * asset = picker.indexPathsForSelectedItems.lastObject;
        UIImage * image = nil;
        if (picker.isOriginalImage) {
            uint8_t *buffer = (uint8_t *)malloc((unsigned long)asset.defaultRepresentation.size);
            NSInteger length = [asset.defaultRepresentation getBytes:buffer fromOffset:0 length:(unsigned long)asset.defaultRepresentation.size error:nil];
            NSData * imageData = [NSData dataWithBytes:buffer length:length];
            image = [UIImage imageWithData:imageData];
        }else{
            image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage                                         scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        }
        QIMImageEditViewController * imageEditVC = [[QIMImageEditViewController alloc] initWithImage:image];
        imageEditVC.delegate = self;
        [self.navigationController pushViewController:imageEditVC animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    if (buttonIndex == 0) {
        [_photoTypeButton setTitle:[NSString stringWithFormat:@"   %@\r(%@)", [NSBundle qim_localizedStringForKey:@"Standard Definition"], [QIMStringTransformTools qim_CapacityTransformStrWithSize:picker.compressDataLength]] forState:UIControlStateNormal];
        picker.isOriginalImage = NO;
        [[QIMKit sharedInstance] setPickerPixelOriginal:NO];
    } else if (buttonIndex == 1) {

        [_photoTypeButton setTitle:[NSString stringWithFormat:@"   %@\r(%@)", [NSBundle qim_localizedStringForKey:@"Full Image"], [QIMStringTransformTools qim_CapacityTransformStrWithSize:picker.originalDataLength]] forState:UIControlStateNormal];
        picker.isOriginalImage = YES;
        [[QIMKit sharedInstance] setPickerPixelOriginal:YES];
    }
}

- (void)onPhotoTypeClick{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Select photo size"] delegate:self cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"%@ (%@)",[NSBundle qim_localizedStringForKey:@"Standard Definition"], [QIMStringTransformTools qim_CapacityTransformStrWithSize:picker.compressDataLength]],
                            [NSString stringWithFormat:@"%@ (%@)", [NSBundle qim_localizedStringForKey:@"Full Image"], [QIMStringTransformTools qim_CapacityTransformStrWithSize:picker.originalDataLength]],nil];
    [sheet showInView:self.view];
}

- (void)onSendClick{
    [self finishPickingAssets:nil];
}

- (void)initBottomView{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - 49, self.view.width, 49)];
    [_bottomView setBackgroundColor:[UIColor qim_colorWithHex:0xf1f1f1 alpha:1]];
    [self.view addSubview:_bottomView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
    [lineView setBackgroundColor:[UIColor qim_colorWithHex:0x999999 alpha:1]];
    [_bottomView addSubview:lineView];
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_previewButton setFrame:CGRectMake(10, 8, 60, 30)];
    [_previewButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_previewButton setTitle:[NSBundle qim_localizedStringForKey:@"Preview"] forState:UIControlStateNormal];
     [_previewButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_previewButton addTarget:self action:@selector(onPreviewClick) forControlEvents:UIControlEventTouchUpInside];
    [_previewButton setEnabled:NO];
    [_bottomView addSubview:_previewButton];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_editButton setFrame:CGRectMake(_previewButton.right, 8, 60, 30)];
    [_editButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_editButton setTitle:[NSBundle qim_localizedStringForKey:@"Edit"] forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_editButton addTarget:self action:@selector(onEditClick) forControlEvents:UIControlEventTouchUpInside];
    [_editButton setEnabled:NO];
    [_bottomView addSubview:_editButton];
    
    _photoTypeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_photoTypeButton.titleLabel setNumberOfLines:0];
    [_photoTypeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_photoTypeButton setFrame:CGRectMake(_editButton.right + 15, 8, 100, 30)];
    [_photoTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_photoTypeButton setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"photo_browser_button_arrow_normal"] forState:UIControlStateNormal];
    [_photoTypeButton setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"photo_browser_button_arrow_pressed"] forState:UIControlStateHighlighted];
    [_photoTypeButton setTitle:[NSBundle qim_localizedStringForKey:@"Standard Definition"] forState:UIControlStateNormal];
    [_photoTypeButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_photoTypeButton setEnabled:NO];
    [_photoTypeButton addTarget:self action:@selector(onPhotoTypeClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_photoTypeButton];
    
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 90, 8, 80, 30)];
    [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_sendButton setBackgroundImage:[[UIImage qim_imageNamedFromQIMUIKitBundle:@"common_button_focus_nor"] stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:[[UIImage qim_imageNamedFromQIMUIKitBundle:@"common_button_focus_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateHighlighted];
    [_sendButton setBackgroundImage:[[UIImage qim_imageNamedFromQIMUIKitBundle:@"common_button_disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateDisabled];
    [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_sendButton setTitle:[NSBundle qim_localizedStringForKey:@"Confirm"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(onSendClick) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setEnabled:NO];
    [_bottomView addSubview:_sendButton];
    
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    [self setTitleWithSelectedIndexPaths:picker.indexPathsForSelectedItems];
    
}

- (void)initTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - _bottomView.height) style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

- (void)setupAssets
{
    self.numberOfPhotos = 0;
    self.numberOfVideos = 0;
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    QTImagePickerController *picker = (QTImagePickerController*)self.navigationController;
    NSMutableDictionary *assetUrlDic = [NSMutableDictionary dictionary];
    for (ALAsset *asset in picker.indexPathsForSelectedItems) {
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        [assetUrlDic setObject:asset forKey:url];
    }
    [picker.indexPathsForSelectedItems removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset)
        {
            NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            ALAsset *oldAsset = [assetUrlDic objectForKey:url];
            if (oldAsset) { 
                [picker.indexPathsForSelectedItems removeObject:oldAsset];
                [picker.indexPathsForSelectedItems addObject:asset];
            }
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }
        
        else if (self.assets.count > 0)
        {
            [_tableView reloadData];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ceil(self.assets.count*1.0/kColoumn)-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, 40)];
            [_tableView setTableFooterView:footerView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, footerView.width, 40)];
            [label setFont:[UIFont systemFontOfSize:18]];
            [label setTextColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1]];
            [label setTextAlignment:NSTextAlignmentCenter];
            NSString *title = nil;
            if (_numberOfVideos == 0) {
                title = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"n Photos"], (long)_numberOfPhotos];
            }
            else if (_numberOfPhotos == 0) {
                title = [NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"n Videos"], (long)_numberOfVideos];
            }
            else {
                title =[NSString stringWithFormat:@"%@,%@",[NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"n Photos"],(long)_numberOfPhotos],[NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"n Videos"],(long)_numberOfVideos]];
            }
            [label setText:title];
            [footerView addSubview:label];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ceil(self.assets.count*1.0/kColoumn)-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        });
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

- (NSMutableArray *)indexPathsForSelectedItems{
    QTImagePickerController *vc = (QTImagePickerController *)self.navigationController;
    return [vc indexPathsForSelectedItems];
}

#pragma mark - action
- (void)dismiss:(id)sender
{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    
    if ([picker.imageDelegate respondsToSelector:@selector(qtImagePickerControllerDidCancel:)]){
        [picker.imageDelegate qtImagePickerControllerDidCancel:picker];
    }
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableView DataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = kAssetViewCellIdentifier;
   QTImageAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[QTImageAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        QTImagePickerController *vc = (QTImagePickerController *)self.navigationController;
        [cell setSelectionFilter:vc.selectionFilter];
        cell.delegate=self;
    }
    NSInteger loc = indexPath.row * kColoumn;
    NSInteger len = (loc + kColoumn) > self.assets.count? self.assets.count - loc:4;
    cell.assets = [self.assets subarrayWithRange:NSMakeRange(loc, len)];
    [cell refreshUI];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int row = ceil(self.assets.count*1.0/kColoumn);
    return row;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [QTImageAssetCell getCellHeight];
}

#pragma mark - cell delegate

- (BOOL)shouldSelectAsset:(ALAsset *)asset
{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    BOOL isVideo = [[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo];
    if (isVideo) {
        if (picker.selectedPhoto) {
            [QTalkTipsView showTips:[NSBundle qim_localizedStringForKey:@"You cannot select photos and videos at the same time"] InView:self.view];
        } else { 
            QTalkVideoAssetViewController *vc = [[QTalkVideoAssetViewController alloc]  init];
            [vc setVideoAsset:asset];
            [self.navigationController pushViewController:vc animated:YES];
        }
        return NO;
    }
    
    BOOL selectable = [picker.selectionFilter evaluateWithObject:asset];
    if (picker.indexPathsForSelectedItems.count >= picker.maximumNumberOfSelection) {
        if (picker.delegate!=nil&&[picker.delegate respondsToSelector:@selector(qtImagePickerControllerDidMaximum:)]) {
            [picker.imageDelegate qtImagePickerControllerDidMaximum:picker];
            [QTalkTipsView showTips:[NSString stringWithFormat:[NSBundle qim_localizedStringForKey:@"Select a maximum of %d photos"],(int)picker.maximumNumberOfSelection] InView:self.view];
        }
    }
    return (selectable && picker.indexPathsForSelectedItems.count < picker.maximumNumberOfSelection);
}

- (void)didSelectAsset:(ALAsset *)asset
{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    NSURL *assetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    picker.originalDataLength += [representation size];
    NSNumber *bqNum = [picker.compressDataLengthDic objectForKey:assetUrl];
    if (bqNum) {
        picker.compressDataLength += bqNum.longLongValue;
    } else {
        @autoreleasepool { 
            long long temp = [[QTImageAssetTools getCompressImageFromALAsset:asset] length];
            picker.compressDataLength += temp > [representation size]? [representation size]:temp;
            [picker.compressDataLengthDic setObject:@(temp > [representation size]? [representation size]:temp) forKey:assetUrl];
        }
    }
    
    QTImagePickerController *vc = (QTImagePickerController *)self.navigationController;
    [vc.indexPathsForSelectedItems addObject:asset];
    
    if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(qtImagePickerController:didSelectAsset:)])
        [vc.imageDelegate qtImagePickerController:vc didSelectAsset:asset];
    
    [self setTitleWithSelectedIndexPaths:vc.indexPathsForSelectedItems];
}

- (void)didDeselectAsset:(ALAsset *)asset
{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    NSURL *assetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    picker.originalDataLength -= [representation size];
    NSNumber *bqNum = [picker.compressDataLengthDic objectForKey:assetUrl];
    if (bqNum) {
        picker.compressDataLength -= bqNum.longLongValue;
    } else {
        @autoreleasepool {
            long long temp = [[QTImageAssetTools getCompressImageFromALAsset:asset] length];
            picker.compressDataLength -= temp > [representation size]? [representation size]:temp;
            [picker.compressDataLengthDic setObject:@(temp > [representation size]? [representation size]:temp) forKey:assetUrl];
        }
    }
    
    [picker.indexPathsForSelectedItems removeObject:asset];
    if (picker.delegate!=nil&&[picker.delegate respondsToSelector:@selector(qtImagePickerController:didDeselectAsset:)])
        [picker.imageDelegate qtImagePickerController:picker didDeselectAsset:asset];
    
    [self setTitleWithSelectedIndexPaths:picker.indexPathsForSelectedItems];
}


#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    
    BOOL photosSelected = NO;
    BOOL videoSelected  = NO;
    
    for (int i=0; i<indexPaths.count; i++) {
        ALAsset *asset = indexPaths[i];
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto]) {
            picker.selectedPhoto = YES;
            photosSelected  = YES;
            break;
        }
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
            videoSelected   = YES;
        
        if (photosSelected && videoSelected)
            break;
        
    }
    
    self.number = indexPaths.count;
    
    if (indexPaths.count > 0) {
        [_previewButton setEnabled:YES];
        if (indexPaths.count == 1) {
            [_editButton setEnabled:YES];
        } else {
            [_editButton setEnabled:NO];
        }
        [_photoTypeButton setEnabled:YES];
        [_sendButton setEnabled:YES];
        [_sendButton setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)", [NSBundle qim_localizedStringForKey:@"Confirm"], (long)indexPaths.count,(long)picker.maximumNumberOfSelection] forState:UIControlStateNormal];
    } else {
        [_previewButton setEnabled:NO];
        [_editButton setEnabled:NO];
        [_photoTypeButton setEnabled:NO];
        [_sendButton setEnabled:NO];
        [_sendButton setTitle:[NSBundle qim_localizedStringForKey:@"Confirm"] forState:UIControlStateNormal];
    }
    picker.isOriginalImage = [[QIMKit sharedInstance] pickerPixelOriginal];

    if (picker.isOriginalImage == NO) {
        [_photoTypeButton setTitle:[NSString stringWithFormat:@"   %@\r(%@)", [NSBundle qim_localizedStringForKey:@"Standard Definition"], [QIMStringTransformTools qim_CapacityTransformStrWithSize:picker.compressDataLength]] forState:UIControlStateNormal];
    } else {
        [_photoTypeButton setTitle:[NSString stringWithFormat:@"   %@\r(%@)",[NSBundle qim_localizedStringForKey:@"Full Image"], [QIMStringTransformTools qim_CapacityTransformStrWithSize:picker.originalDataLength]] forState:UIControlStateNormal];
    }
}


#pragma mark - Actions

- (void)finishPickingAssets:(id)sender
{
    
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    if (picker.indexPathsForSelectedItems.count < picker.minimumNumberOfSelection) {
        if (picker.imageDelegate!=nil&&[picker.imageDelegate respondsToSelector:@selector(qtImagePickerControllerDidMaximum:)]) {
            [picker.imageDelegate qtImagePickerControllerDidMaximum:picker];
        }
    }
    
    if ([picker.imageDelegate respondsToSelector:@selector(qtImagePickerController:didFinishPickingAssets:ToOriginal:)])
        [picker.imageDelegate qtImagePickerController:picker didFinishPickingAssets:picker.indexPathsForSelectedItems ToOriginal:picker.isOriginalImage];
}

#pragma mark - QIMImageEditViewControllerDelegate

- (void)imageEditVC:(QIMImageEditViewController *)imageEditVC didEditWithProductImage:(UIImage *)productImage
{
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    if ([picker.imageDelegate respondsToSelector:@selector(qtImagePickerController:didFinishPickingImage:)])
        [picker.imageDelegate qtImagePickerController:picker didFinishPickingImage:productImage];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end

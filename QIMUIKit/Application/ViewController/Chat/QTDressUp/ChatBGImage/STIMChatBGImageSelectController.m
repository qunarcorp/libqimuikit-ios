//
//  STIMChatBGImageSelectController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "STIMChatBGImageSelectController.h"
#import "STIMChatBGImagePickerController.h"
#import "STIMImageUtil.h"
#import "STIMDataController.h"
#import "STIMCommonFont.h"
#import "STIMDefaultChatBGImageSelectController.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMChatBGImageSelectController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,STIMChatBGImagePickerControllerDelegate,STIMDefaultChatBGImageSelectControllerDelegate>
{
    UITableView         * _mainTableView;
    BOOL                  _useForAllUser;
    UIButton            * _userSelectBtn;
    UIImage             * _cucrrentBGImage;
    UIImageView         * _chatBGImageView;
    BOOL                  _canSave;
}

@end

@implementation STIMChatBGImageSelectController

- (instancetype)initWithCurrentBGImage:(UIImage *)image
{
    if (self = [self init]) {
        _cucrrentBGImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSBundle stimDB_localizedStringForKey:@"personality_change_bgimage"];
    self.view.backgroundColor = [UIColor stimDB_colorWithHex:0xebecef alpha:1];
    
    _useForAllUser = NO;
    
    [self initMainTableView];
    [self setUpCurrentBGImageView];
    [self initUserSelectBtn];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_canSave) {
        [self saveChatBGImage:_chatBGImageView.image];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _canSave = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpCurrentBGImageView
{
    _chatBGImageView = [[UIImageView alloc] initWithFrame:_mainTableView.frame];
    _chatBGImageView.contentMode = UIViewContentModeScaleAspectFill;
    _chatBGImageView.clipsToBounds = YES;
    _chatBGImageView.backgroundColor = [UIColor stimDB_colorWithHex:0xebecef alpha:1];
    _chatBGImageView.image = _cucrrentBGImage;
    [self.view insertSubview:_chatBGImageView belowSubview:_mainTableView];
}

- (void)initUserSelectBtn
{
    _userSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.height - 70 , self.view.width - 20, 50)];
    [_userSelectBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 2]];
    [_userSelectBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"personality_selected_all"] forState:UIControlStateNormal];
    if (self.isFromChat) {
        [_userSelectBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"personality_selected_current"] forState:UIControlStateSelected];
    }else{
        [_userSelectBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"personality_selected_normal"] forState:UIControlStateSelected];
    }
    
    [_userSelectBtn setTitleColor:[UIColor spectralColorWhiteColor] forState:UIControlStateNormal];
    [_userSelectBtn setTitleColor:[UIColor spectralColorWhiteColor] forState:UIControlStateSelected];
    [_userSelectBtn setBackgroundImage:[UIImage stimDB_imageFromColor:[UIColor spectralColorBlueColor]] forState:UIControlStateNormal];
    [_userSelectBtn setBackgroundImage:[UIImage stimDB_imageFromColor:[UIColor spectralColorBlueColor]] forState:UIControlStateSelected];
    [_userSelectBtn addTarget:self action:@selector(userSelectBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_userSelectBtn];
}

- (void)initMainTableView
{
    _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    [self.view addSubview:_mainTableView];
}

- (void)userSelectBtnHandle:(UIButton *)btn
{
    NSString * msg = nil;
    if (btn.selected) {
        if (self.isFromChat) {
            msg = @"您将选择的图片会作为当前的聊天界面背景，其他聊天界面的背景将不受影响。是否确定？";
        }else{
            msg = @"您将选择的图片会作为通用的聊天界面背景，已经拥有聊天背景的界面将不受影响。是否确定？";
        }
        
    }else{
        msg = @"您将选择的图片会作为所有的聊天界面背景，包括已经拥有聊天背景的界面。是否确定？";
    }
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"common_prompt"] message:msg delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_cancel"] otherButtonTitles:[NSBundle stimDB_localizedStringForKey:@"common_ok"], nil];
    [alertView show];
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        _useForAllUser = !_userSelectBtn.selected;
        _userSelectBtn.selected = !_userSelectBtn.selected;
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"cell";
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
    cell.backgroundView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 2];
    switch (indexPath.row) {
        case 0:
        case 2:
        case 4:
        {
            cell.textLabel.text = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1:
        {
            cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"personality_select_bgimage"];
        }
            break;
        case 3:
        {
            cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"personality_album"];
            break;
        }
        case 5:
        {
            cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"personality_camera"];
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        case 2:
        case 4:
        {
            return 15;
        }
        default:
            return [[STIMCommonFont sharedInstance] currentFontSize] + 28;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _canSave = NO;
    
    switch (indexPath.row) {
        case 1:
        {
            STIMDefaultChatBGImageSelectController * defaultChatBGImageVC = [[STIMDefaultChatBGImageSelectController alloc] init];
            defaultChatBGImageVC.delegate = self;
            [self.navigationController pushViewController:defaultChatBGImageVC animated:YES];
        }
            break;
        case 3:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
                imagePickerController.delegate = self;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }
            break;
        case 5:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
                imagePickerController.delegate = self;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }
        default:
            break;
    }
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //获取用户编辑之后的图像
        UIImage* editedImage = [STIMImageUtil fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
        STIMChatBGImagePickerController *vc = [[STIMChatBGImagePickerController alloc] initWithImage:editedImage];
        [vc setDelegate:self];
        [picker pushViewController:vc animated:YES];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImagePickerControllerDelegate

-(void)imagePicker:(STIMChatBGImagePickerController *)imagePicker willDismissWithImage:(UIImage *)image
{
    _chatBGImageView.image = image;
//    [self saveChatBGImage:image];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"设置成功，快去查看吧~" delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - STIMDefaultChatBGImageSelectControllerDelegate

-(void)defaultSTIMChatBGImageSelectController:(STIMDefaultChatBGImageSelectController *)imagePicker willPopWithImage:(UIImage *)image
{
    _chatBGImageView.image = image;
//    [self saveChatBGImage:image];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"设置成功，快去查看吧~" delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)saveChatBGImage : (UIImage *)image
{
    NSMutableDictionary * chatBGImageDic = [NSMutableDictionary dictionary];
    NSDictionary *dic = [[STIMKit sharedInstance] userObjectForKey:@"chatBGImageDic"];
    if (dic) {
        [chatBGImageDic setDictionary:dic];
    }
    if (!chatBGImageDic) {
        chatBGImageDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }else{
        if (_useForAllUser) {
            for (NSString * key in chatBGImageDic.allKeys) {
                [[STIMDataController getInstance] deleteResourceWithFileName:key];
            }
            [chatBGImageDic removeAllObjects];
        }
    }
    [chatBGImageDic setObject:[NSString stringWithFormat:@"chatBGImageFor_%@",_useForAllUser? @"Common" : self.userID] forKey:[NSString stringWithFormat:@"chatBGImageFor_%@",_useForAllUser? @"Common" : self.userID]]; 
    [[STIMKit sharedInstance] setUserObject:chatBGImageDic forKey:@"chatBGImageDic"];
    if (image) {
        [[STIMDataController getInstance] saveResourceWithFileName:[NSString stringWithFormat:@"chatBGImageFor_%@",_useForAllUser? @"Common" : self.userID] data:UIImageJPEGRepresentation(image, 1.0)];
    } else { 
        [[STIMDataController getInstance] deleteResourceWithFileName:[NSString stringWithFormat:@"chatBGImageFor_%@",_useForAllUser? @"Common" : self.userID]];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatBGImageDidSelected:)]) {
        [self.delegate ChatBGImageDidSelected:self];
    }
}

@end

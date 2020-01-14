//
//  STIMFileTransMiddleVC.m
//  STIMUIKit
//
//  Created by 李海彬 on 10/30/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMFileTransMiddleVC.h"

@interface STIMFileTransMiddleVC ()

@end

@implementation STIMFileTransMiddleVC

- (void)setupNav {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"common_close"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackBtnHandle)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor stimDB_colorWithHex:0x5CC57F]}];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor stimDB_colorWithHex:0x5CC57F]];
    //毛玻璃
    self.navigationController.navigationBar.translucent = YES;
}

- (void)setupUI {
    
    UIImageView *transFileImgView = [[UIImageView alloc] initWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"transFile"]];
    transFileImgView.width = 150;
    transFileImgView.height = 48;
    transFileImgView.center = CGPointMake(self.view.centerX, self.view.centerY - 120);
    [self.view addSubview:transFileImgView];
    
    UILabel *transFileLabel = [[UILabel alloc] init];
    NSString *transFileLabelText = [NSString stringWithFormat:[NSBundle stimDB_localizedStringForKey:@"You have logged in %@ on your computer"], @"QTalk"];
    UIFont *fnt = [UIFont systemFontOfSize:16];
    // 根据字体得到NSString的尺寸
    CGSize size = [transFileLabelText sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName,nil]];

    [transFileLabel setText:transFileLabelText];
    transFileLabel.textAlignment = NSTextAlignmentCenter;
    transFileLabel.width = size.width + 10;
    transFileLabel.height = 22.0f;
    [transFileLabel setFont:[UIFont systemFontOfSize:16]];
    transFileLabel.center = CGPointMake(self.view.centerX, self.view.centerY - 80);
    [transFileLabel setTextColor:[UIColor stimDB_colorWithHex:0x212121]];
    [self.view addSubview:transFileLabel];
    
    UILabel *promtLabel = [[UILabel alloc] init];
    [promtLabel setText:[NSBundle stimDB_localizedStringForKey:@"Transfer files between phone and computer without using USB."]];
    promtLabel.textAlignment = NSTextAlignmentCenter;
    promtLabel.font = [UIFont systemFontOfSize:16];
    promtLabel.width = self.view.width;
    promtLabel.height = 22.0f;
    promtLabel.center = self.view.center;
    promtLabel.adjustsFontSizeToFitWidth = YES;
    promtLabel.numberOfLines = 1;
    [promtLabel setTextColor:[UIColor stimDB_colorWithHex:0x616161]];
    [self.view addSubview:promtLabel];
    
    UILabel *promtLabel2 = [[UILabel alloc] init];
    [promtLabel2 setText:[NSBundle stimDB_localizedStringForKey:@"Try is now"]];
    promtLabel2.textAlignment = NSTextAlignmentCenter;
    promtLabel2.font = [UIFont systemFontOfSize:16];
    promtLabel2.width = self.view.width;
    promtLabel2.height = 22.0f;
    promtLabel2.center = self.view.center;
    promtLabel2.y = self.view.centerY + 22;
    promtLabel2.adjustsFontSizeToFitWidth = YES;
    promtLabel2.numberOfLines = 1;
    [promtLabel2 setTextColor:[UIColor stimDB_colorWithHex:0x616161]];
    [self.view addSubview:promtLabel2];
    
    UIView *fileImgbgView = [[UIView alloc] init];
    fileImgbgView.width = 56.0f;
    fileImgbgView.height = 56.0f;
    fileImgbgView.layer.cornerRadius = 28.0f;
    fileImgbgView.backgroundColor = [UIColor whiteColor];
    fileImgbgView.center = CGPointMake(self.view.centerX, promtLabel2.centerY + 11+34+28);
    [self.view addSubview:fileImgbgView];

    UIImageView *fileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    fileImageView.image = [UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e211" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]];
    fileImageView.center = fileImgbgView.center;
    [self.view addSubview:fileImageView];
    
    NSString *fileLabelText = [NSBundle stimDB_localizedStringForKey:@"Transfer_files"];
    UIFont *fileLabelfnt = [UIFont systemFontOfSize:12];
    // 根据字体得到NSString的尺寸
    CGSize fileLabelTextSize = [fileLabelText sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fileLabelfnt,NSFontAttributeName,nil]];

    UILabel *fileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, fileImgbgView.bottom + 5, fileLabelTextSize.width + 5, 17)];
    fileLabel.text = fileLabelText;
    [fileLabel setFont:[UIFont systemFontOfSize:12]];
    [fileLabel setTextAlignment:NSTextAlignmentCenter];
    fileLabel.centerX = fileImgbgView.centerX;
    fileLabel.textColor = [UIColor stimDB_colorWithHex:0x616161];
    [self.view addSubview:fileLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFileTransChatVc:)];
    [fileImgbgView addGestureRecognizer:tap];
}

- (void)openFileTransChatVc:(UITapGestureRecognizer *)tap {
    NSString *xmppId = [NSString stringWithFormat:@"%@@%@", @"file-transfer", [[STIMKit sharedInstance] getDomain]];
    [STIMFastEntrance openSingleChatVCByUserId:xmppId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stimDB_colorWithHex:0xEEEEEE];
    [self setupNav];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)goBackBtnHandle {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

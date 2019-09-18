//
//  QIMAgreementViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/8/5.
//
//

#import "QIMAgreementViewController.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMAgreementViewController ()
{
    UIWebView * _webView;
}

@end

@implementation QIMAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNav];
    [self setUpWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNav
{
    self.navigationItem.title = [NSString stringWithFormat:@"%@软件使用许可协议", [QIMKit getQIMProjectType] == QIMProjectTypeStartalk ? @"Startalk" : @"QTalk"];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_close"] style:UIBarButtonItemStyleDone target:self action:@selector(closeHandle:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)setUpWebView
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    NSString *eulaFileName = [NSString stringWithFormat:@"%@", [QIMKit getQIMProjectType] == QIMProjectTypeStartalk ? @"Startalkeula" : @"QTalkeula"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:eulaFileName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
}

- (void)closeHandle:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

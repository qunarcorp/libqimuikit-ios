//
//  STIMAboutVC.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/8/16.
//
//
#define kLoginViewSpaceToSide   ([UIScreen mainScreen].bounds.size.width / 16)
#define kLoginViewSpaceToTop    ([UIScreen mainScreen].bounds.size.height / 4)
#define kLoginViewHeight        ([UIScreen mainScreen].bounds.size.height * 3 / 5)
#import "STIMAboutVC.h"
#import "STIMProgressHUD.h"
#import "STIMJSONSerializer.h"
#import "STIMUUIDTools.h"
#import <CoreText/CoreText.h>
#import "STIMContactManager.h"
#import "NSBundle+STIMLibrary.h"
#import "STIMUtility.h"
#import "STIMDataController.h"
#if __has_include("STIMLocalLog.h")

#import "STIMLocalLog.h"
#endif

#import "STIMStringTransformTools.h"
#import "STIMGDPerformanceMonitor.h"
#import "STIMZipArchive.h"
#import "STIMNavConfigManagerVC.h"

@interface STIMAboutVC () <UITableViewDelegate, UITableViewDataSource>
{
    CABasicAnimation        * _writingStrokeStartAnimation;
    CABasicAnimation        * _writingStrokeEndAnimation;
    CAShapeLayer            * _writingLayer;
    CAGradientLayer         * _gradLayer;
}

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UILabel *versionLabel;

@property (nonatomic, copy) NSString *logFilePath;

@end

@implementation STIMAboutVC

#pragma mark - setter and getter

- (UITableView *)mainTableView {
    
    if (!_mainTableView) {
        
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.versionLabel.frame) + 20, self.view.width, self.view.height) style:UITableViewStylePlain];

        _mainTableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0.0001f)];

        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
    }
    return _mainTableView;
}

- (UILabel *)versionLabel {
    
    if (!_versionLabel) {
        
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kLoginViewSpaceToTop - 75 + _writingLayer.bounds.size.height + 20, self.view.width, 45)];
        NSString * appBundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        _versionLabel.text = [NSString stringWithFormat:@"%@ V%@-%@",  appBundleName, appVersion, appBuildVersion];
        _versionLabel.centerX = self.view.centerX;
        _versionLabel.textColor = [UIColor colorWithRed:0.502 green:0.502 blue:0.5059 alpha:1.0];
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        _versionLabel.font = [UIFont systemFontOfSize:21];
    }
    return _versionLabel;
}

- (NSMutableArray *)dataSource {
    
    _dataSource = [NSMutableArray arrayWithCapacity:4];
    
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
        [_dataSource addObject:@"Rate QTalk"];
    }
    
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        [_dataSource addObject:@"Rate QChat"];
    }

    //记录本地日志
#if __has_include("STIMLocalLog.h")
    STIMLocalLogType logType = [[[STIMKit sharedInstance] userObjectForKey:@"recordLogType"] integerValue];
    if (logType == STIMLocalLogTypeOpened) {
//        [_dataSource addObject:@"isLogging"];
        [_dataSource addObject:@"Instruments"];
      }
#endif
    [_dataSource addObject:@"DataFile"];
    [_dataSource addObject:@"DataWALFile"];
    return _dataSource;
}

#pragma mark - life ctyle


- (void)initWritingAnimations{
    if (_writingLayer == nil) {
        UIBezierPath *bezierPath = [self transformToBezierPath:[STIMKit getSTIMProjectTitleName]];
        CGSize size= CGPathGetBoundingBox(bezierPath.CGPath).size;
        _writingLayer = [CAShapeLayer layer];
        _writingLayer.bounds = CGPathGetBoundingBox(bezierPath.CGPath);
        _writingLayer.position = CGPointMake(size.width/2, size.height/2);
        _writingLayer.geometryFlipped = YES;
        _writingLayer.path = bezierPath.CGPath;
        _writingLayer.fillColor = [UIColor clearColor].CGColor;
        _writingLayer.lineWidth = 1;
        _writingLayer.strokeColor = [UIColor stimDB_colorWithHex:0x11cd6e alpha:1.0].CGColor;
        
    }else{
        [_writingLayer removeAllAnimations];
    }
    if (_gradLayer == nil) {
        CGSize size = _writingLayer.bounds.size;
        _gradLayer = [CAGradientLayer layer];
        _gradLayer.frame = CGRectMake((self.view.width - size.width) / 2 - 5, kLoginViewSpaceToTop - 100, size.width + 10, size.height + 10);
        _gradLayer.colors = @[(__bridge id)[UIColor redColor].CGColor,(__bridge id)[UIColor orangeColor].CGColor,(__bridge id)[UIColor yellowColor].CGColor,(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor cyanColor].CGColor,(__bridge id)[UIColor blueColor].CGColor,(__bridge id)[UIColor purpleColor].CGColor];
        _gradLayer.startPoint = CGPointMake(0.7,0);//(x,y) 左上角（0，0）右下角（1，1）
        _gradLayer.endPoint = CGPointMake(0.3,1);
        
        //Using arc as a mask instead of adding it as a sublayer.
        //[self.view.layer addSublayer:arc];
        _gradLayer.mask = _writingLayer;
    }
    [self.view.layer addSublayer:_gradLayer];
    
    if (_writingStrokeEndAnimation == nil) {
        _writingStrokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _writingStrokeEndAnimation.fromValue = @(0);
        _writingStrokeEndAnimation.toValue = @(1);
        _writingStrokeEndAnimation.duration = _writingLayer.bounds.size.width/10;
    }
    if (_writingStrokeStartAnimation == nil) {
        _writingStrokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        _writingStrokeStartAnimation.fromValue = @(0);
        _writingStrokeStartAnimation.toValue = @(1);
        _writingStrokeStartAnimation.duration = _writingLayer.bounds.size.width/10;
    }
    [self startWritingLogoIsStart:@(NO)];
}

- (void)startWritingLogoIsStart:(NSNumber *)isStart {
    CABasicAnimation * animation = [isStart boolValue]? _writingStrokeStartAnimation : _writingStrokeEndAnimation;
    [self stopWritingLogo];
    [_writingLayer addAnimation:animation forKey:[isStart boolValue]?@"start":@"end"];
    [self performSelector:@selector(startWritingLogoIsStart:) withObject:@(NO) afterDelay:animation.duration + arc4random() % 10];
}

- (void)stopWritingLogo {
    [_writingLayer removeAllAnimations];
}

- (UIBezierPath *)transformToBezierPath:(NSString *)string
{
    CGMutablePathRef paths = CGPathCreateMutable();
    CFStringRef fontNameRef = CFSTR("Zapfino");
    CTFontRef fontRef = CTFontCreateWithName(fontNameRef, 35, nil);
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:@{(__bridge NSString *)kCTFontAttributeName: (__bridge UIFont *)fontRef}];
    CTLineRef lineRef = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArrRef = CTLineGetGlyphRuns(lineRef);
    
    for (int runIndex = 0; runIndex < CFArrayGetCount(runArrRef); runIndex++) {
        const void *run = CFArrayGetValueAtIndex(runArrRef, runIndex);
        CTRunRef runb = (CTRunRef)run;
        
        const void *CTFontName = kCTFontAttributeName;
        
        const void *runFontC = CFDictionaryGetValue(CTRunGetAttributes(runb), CTFontName);
        CTFontRef runFontS = (CTFontRef)runFontC;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        int temp = 0;
        CGFloat offset = .0;
        
        for (int i = 0; i < CTRunGetGlyphCount(runb); i++) {
            CFRange range = CFRangeMake(i, 1);
            CGGlyph glyph = 0;
            CTRunGetGlyphs(runb, range, &glyph);
            CGPoint position = CGPointZero;
            CTRunGetPositions(runb, range, &position);
            
            CGFloat temp3 = position.x;
            int temp2 = (int)temp3/width;
            CGFloat temp1 = 0;
            
            if (temp2 > temp1) {
                temp = temp2;
                offset = position.x - (CGFloat)temp;
            }
            
            CGPathRef path = CTFontCreatePathForGlyph(runFontS, glyph, nil);
            CGFloat x = position.x - (CGFloat)temp*width - offset;
            CGFloat y = position.y - (CGFloat)temp * 80;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
            CGPathAddPath(paths, &transform, path);
            
            CGPathRelease(path);
        }
        CFRelease(runb);
        CFRelease(runFontS);
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:paths]];
    
    CGPathRelease(paths);
    CFRelease(fontNameRef);
    CFRelease(fontRef);
    
    return bezierPath;
}

- (void)initUI {
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setUpNavBar];
    [self initWritingAnimations];
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.versionLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLoggingAction:)];
    tap.numberOfTouchesRequired = 1; //手指数
    tap.numberOfTapsRequired = 5; //tap次数
    [self.view addGestureRecognizer:tap];
}

- (void)showLoggingAction:(UIGestureRecognizer *)gesture {
#if __has_include("STIMLocalLog.h")
    __weak typeof(self) weakSelf = self;
    if (![self.dataSource containsObject:@"isLogging"]) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"确认开始记录App性能数据吗？再次点击屏幕五下关闭！！！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"cancel"] style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf.dataSource addObject:@"isLogging"];
            //发送日志(本地数据库,UserDefault, 本地STIMVerboseLog日志)
            [weakSelf.dataSource addObject:@"Instruments"];
            [[STIMKit sharedInstance] setUserObject:@(STIMLocalLogTypeOpened) forKey:@"recordLogType"];
            [weakSelf.mainTableView reloadData];
        }];
        [alertVc addAction:cancelAction];
        [alertVc addAction:okAction];
        [self presentViewController:alertVc animated:YES completion:nil];
    } else {
        [[STIMKit sharedInstance] setUserObject:@(STIMLocalLogTypeClosed) forKey:@"recordLogType"];
        [[STIMGDPerformanceMonitor sharedInstance] stopMonitoring];
        [[STIMKit sharedInstance] setUserObject:@(NO) forKey:@"isInstruments"];
        [self.mainTableView reloadData];
        STIMVerboseLog(@"关闭成功");
    }
#endif
}

- (void)setUpNavBar {
    
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQTalk) {
        self.title = [NSBundle stimDB_localizedStringForKey:@"About_nav_title_QTalk"];
    } else if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        self.title  =[NSBundle stimDB_localizedStringForKey:@"About_nav_title_QChat"];
    } else {
        self.title = [NSBundle stimDB_localizedStringForKey:@"About_nav_title_Startalk"];
    }
    self.navigationController.navigationBar.translucent = NO;
}

- (void)goBack {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    [self initUI];
}

- (void)dealloc {
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *value = [self.dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"Rate QTalk"]) {
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/qtalk/id1000198342?mt=8"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if ([value isEqualToString:@"Rate QChat"]) {
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/qchat/id994868843?mt=8"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if ([value isEqualToString:@"Feature"]) {

    } else if ([value isEqualToString:@"NavConfig"]) {
        STIMNavConfigManagerVC *navURLsSettingVc = [[STIMNavConfigManagerVC alloc] init];
        STIMNavController *navURLsSettingNav = [[STIMNavController alloc] initWithRootViewController:navURLsSettingVc];
        [self presentViewController:navURLsSettingNav animated:YES completion:nil];

    } else if ([value isEqualToString:@"isLogging"]) {
        
    } else if ([value isEqualToString:@"Instruments"]) {
        
    } else if ([value isEqualToString:@"DataWALFile"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [[STIMKit sharedInstance] stIMDB_dbCheckpoint];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];  //更新 第一个section的第4行
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:lastIndexPath, indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellID";
    NSString *value = [self.dataSource objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([value isEqualToString:@"Rate QTalk"] || [value isEqualToString:@"Rate QChat"]) {
        
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_rate"];
    }  else if ([value isEqualToString:@"Feature"]) {
        
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_features"];
    } else if ([value isEqualToString:@"NavConfig"]) {
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"NavConfig"];
    } else if ([value isEqualToString:@"Function"]) {
        
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_function"];
    } else if ([value isEqualToString:@"Feedback"]) {
        
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_feedback"];
    } else if ([value isEqualToString:@"isLogging"]) {
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_recordLog"];
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
        [switchButton setOn:YES];
        switchButton.enabled = NO;
        cell.userInteractionEnabled = NO;
        [cell setAccessoryView:switchButton];
    } else if ([value isEqualToString:@"Instruments"]) {
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_instruments"];
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
        BOOL isInstrument = [[[STIMKit sharedInstance] userObjectForKey:@"isInstruments"] boolValue];
        [switchButton setOn:isInstrument];
        [switchButton addTarget:self action:@selector(recordInstruments:) forControlEvents:UIControlEventValueChanged];
        [cell setAccessoryView:switchButton];
    } else if ([value isEqualToString:@"DataFile"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_storage_space"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [self dataFileSize];
    } else if ([value isEqualToString:@"DataWALFile"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"About_tab_storage_wal_space"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [self dataWalFileSize];
    } else {
        
    }
    return cell;
}

//查看当前BackTrace
- (void)recordInstruments:(UISwitch *)sender {
    [[STIMKit sharedInstance] setUserObject:@(sender.on) forKey:@"isInstruments"];
    if (sender.on) {
        [[STIMGDPerformanceMonitor sharedInstance] startMonitoring];
    } else {
        [[STIMGDPerformanceMonitor sharedInstance] stopMonitoring];
    }
}

- (NSString *)dataFileSize {
    long long totalSize = [[STIMDataController getInstance] sizeOfDBPath];
    NSString *str = [[STIMDataController getInstance] transfromTotalSize:totalSize];
    return str;
}

- (NSString *)dataWalFileSize {
    long long totalSize = [[STIMDataController getInstance] sizeOfDBWALPath];
    NSString *str = [[STIMDataController getInstance] transfromTotalSize:totalSize];
    return str;
}

    
@end

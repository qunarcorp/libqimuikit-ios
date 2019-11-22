//
//  STIMNavBackBtn.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/16.
//

#import "STIMNavBackBtn.h"
#import "STIMIconInfo.h"

@implementation STIMNavBackBtn

static STIMNavBackBtn *__backBtn = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __backBtn = [[STIMNavBackBtn alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    });
    return __backBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAccessibilityIdentifier:@"STIMNavBackBtn"];
        [self setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:stimDB_backButton_font size:stimDB_backButton_TextSize color:stimDB_backButtonColor]] forState:UIControlStateNormal];
        self.titleLabel.backgroundColor = stimDB_backButtonTextBgColor;
        [self setTitleColor:stimDB_backButtonTextColor forState:UIControlStateNormal];
        self.titleLabel.layer.cornerRadius = 10.5f;
        self.titleLabel.layer.masksToBounds = YES;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat titleW = (self.currentTitle.length > 1) ? (self.currentTitle.length * 12) : (self.currentTitle.length * 21);
    return CGRectMake(contentRect.size.width * 0.3, 11, titleW, 21);
}
 
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat imageW = CGRectGetWidth(contentRect) * 0.3;
    return CGRectMake(0, 11, imageW, 21);
}

- (void)registerNSNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotReadCount:) name:kMsgNotReadCountChange object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateNotReadCount:(NSInteger)appCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (appCount > 0 && appCount <= 99) {
            [self setTitle:[NSString stringWithFormat:@"%ld", (unsigned long)appCount] forState:UIControlStateNormal];
            self.titleLabel.backgroundColor = stimDB_backButtonTextBgColor;
        } else if (appCount > 99) {
            [self setTitle:@"99+" forState:UIControlStateNormal];
            self.titleLabel.backgroundColor = stimDB_backButtonTextBgColor;
        } else {
            [self setTitle:@"" forState:UIControlStateNormal];
            [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        }
    });
}

@end

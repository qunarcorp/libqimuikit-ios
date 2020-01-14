//
//  STIMEmotionManagerView.m
//  STChatIphone
//
//  Created by 李海彬 on 2018/2/7.
//

#import "STIMEmotionManagerView.h"
#import "STIMEmotionView.h"
#import "STIMEmotionManager.h"

@interface STIMEmotionManagerView () <STIMEmotionViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) STIMEmotionView *emotionView;

@property (nonatomic, assign) QTalkEmotionType emotionType;

@end

@implementation STIMEmotionManagerView

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.centerX = self.centerX;
        _pageControl.centerY = CGRectGetMaxY(self.frame) - 10;
        _pageControl.currentPage  = 0;
        _pageControl.pageIndicatorTintColor = [UIColor stimDB_colorWithHex:0xD8D8D8];
        _pageControl.currentPageIndicatorTintColor = [UIColor stimDB_colorWithHex:0x84AEBF];
        [_pageControl addTarget:self action:@selector(pageControlHandle:) forControlEvents:UIControlEventValueChanged];
    }
    _pageControl.numberOfPages = self.emotionView.totalPageIndex;
    return _pageControl;
}

- (STIMEmotionView *)emotionView {
    if (!_emotionView) {
        CGRect rect = self.bounds;
        rect.size.height -= 20;
        _emotionView = [STIMEmotionView qtalkEmotionCollectionViewWithFrame:rect WithPkid:self.packageId];
        _emotionView.emotionViewDelegate = self;
    }
    return _emotionView;
}

- (instancetype)initWithFrame:(CGRect)frame WithPkId:(NSString *)packageId {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerNSNotification];
        self.backgroundColor = [UIColor whiteColor];
        self.packageId = packageId;
        [self addSubview:self.emotionView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNSNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionList:) name:kCollectionEmotionUpdateHandleNotification object:nil];
}

//收藏表情数组改变时，pagecontrol位置改变
- (void)updateCollectionList:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.emotionView reloadCollectionFaceView];
        self.pageControl.numberOfPages = self.emotionView.totalPageIndex;
    });
}

- (void)didSelectShowAllEmotion:(NSString *)faceName andIsSelectDelete:(BOOL)del {
    if (self.delegate && [self.delegate respondsToSelector:@selector(SendTheFaceStr:withPackageId:isDelete:)]) {
        [self.delegate SendTheFaceStr:faceName withPackageId:self.packageId isDelete:del];
    }
}

- (void)didSelectNormalEmotion:(NSString *)faceName {
    if (self.delegate && [self.delegate respondsToSelector:@selector(SendTheFaceStr:withPackageId:)]) {
        [self.delegate SendTheFaceStr:faceName withPackageId:self.packageId];
    }
}

- (void)didSelectCollectionEmotion:(NSString *)fileUrl {
    if (fileUrl.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(SendTheCollectionFaceStr:)]) {
            [self.delegate SendTheCollectionFaceStr:fileUrl];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFaildCollectionFace)]) {
            [self.delegate didSelectFaildCollectionFace];
        }
    }
}

- (void)changePageControlIndex:(NSInteger)pageIndex {
    self.pageControl.currentPage = pageIndex;
}

- (void)pageControlHandle:(UIPageControl *)sender {
    [self.emotionView setContentOffset:CGPointMake(sender.currentPage * CGRectGetWidth(self.emotionView.bounds), self.emotionView.contentOffset.y)  animated:YES];
}

@end

//
//  STIMPreviewMsgVC.m
//  STChatIphone
//
//

#import "STIMPreviewMsgVC.h"
#import "STIMMessageBrowserVC.h"
#import "STIMAttributedLabel.h"
#import "STIMTextContainer.h"
#import "STIMMessageParser.h"

@interface STIMPreviewMsgVC (){
    
    UIScrollView *_scrollView;
    
    STIMAttributedLabel *_msgLabel;
}

@end

@implementation STIMPreviewMsgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    STIMVerboseLog(@"start");//TODO Startalk
    if (self.message.messageDirection == STIMMessageDirection_Received) {
        [self.view setBackgroundColor:[UIColor stimDB_leftBallocColor]];
    }else{
        [self.view setBackgroundColor:[UIColor stimDB_rightBallocColor]];
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:_scrollView];
    
    STIMTextContainer * container = [STIMMessageParser textContainerForMessage:self.message fromCache:NO];
    _msgLabel = [[STIMAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_msgLabel setSize:[container getSuggestedSizeWithFramesetter:nil width:container.textWidth]];
    if (_msgLabel.height <= _scrollView.height) {
        [_msgLabel setCenter:_scrollView.center];
    }
    _msgLabel.backgroundColor = [UIColor clearColor];
    _msgLabel.textContainer = container;
    //    _msgLabel.delegate = self;
    [_scrollView addSubview:_msgLabel];
    [_scrollView setContentSize:CGSizeMake(_msgLabel.width, _msgLabel.height+20)];
    
     STIMVerboseLog(@"viewDidLoad");//TODO Startalk
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose)];
    [self.view addGestureRecognizer:tap];
}

- (void)onClose{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

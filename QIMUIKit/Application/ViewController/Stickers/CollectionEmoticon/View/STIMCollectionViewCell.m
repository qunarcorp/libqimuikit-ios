//
//  STIMCollectionViewCell.m
//  STChatIphone
//
//  Created by qitmac000495 on 16/6/1.
//
//

#import "STIMCollectionViewCell.h"
#import "STIMEmotionTip.h"
#import "STIMCollectionFaceManager.h"
#import "UIImage+STIMUIKit.h"

@interface STIMCollectionViewCell ()

@property (nonatomic, strong) UIImageView *emojiView;

@property (nonatomic, assign) BOOL refresh;

@end

@implementation STIMCollectionViewCell

- (UIImageView *)emojiView {
    
    if (!_emojiView) {
        
        _emojiView = [[UIImageView alloc] initWithFrame:self.bounds];
        _emojiView.userInteractionEnabled = YES;
    }
    return _emojiView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        [self.contentView addSubview:self.emojiView];
    }
    return self;
}

- (void)setRefreshCount:(BOOL)refreshed {
    self.refresh = refreshed;
}

- (void)refreshUIWithFlag:(BOOL)flag {
    
    __weak typeof(self) weakSelf = self;
    if (flag) {
        
        if (self.tag == 0) {
        
            self.emojiView.image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"EmoticonAddButton"];

        } else if (self.tag == -1) {
            self.emojiView.image = [UIImage new];
            self.userInteractionEnabled = NO;
        } else {
            
            self.emojiView.image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"aio_ogactivity_default"];
            NSString *emojiUrl = [[STIMCollectionFaceManager sharedInstance] getCollectionFaceHttpUrlWithIndex:self.tag - 1];
            if (![emojiUrl stimDB_hasPrefixHttpHeader]) {
                emojiUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], emojiUrl];
            }
            [self.emojiView stimDB_setImageWithURL:[NSURL URLWithString:emojiUrl] placeholderImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"aio_ogactivity_default"] options:SDWebImageDecodeFirstFrameOnly progress:nil completed:nil];
            /*
            [[STIMCollectionFaceManager sharedInstance] showSmallImage:^(UIImage *downLoadImage) {

                weakSelf.emojiView.image = downLoadImage;

              } withIndex:self.tag - 1];
            */
        }
    } else {
        self.emojiView.image = [UIImage new];
        self.userInteractionEnabled = NO;
        self.tag = -1;
    }
}

- (void)didMoveIn {
    if (self.tag != 0 && self.tag != -1) {
        [[QTalkGifEmojiTip sharedTip] showTipOnCell:self];
    }
}

- (void)didMoveOut {
    if (self.tag != 0 && self.tag != -1) {
        [[QTalkGifEmojiTip sharedTip] showTipOnCell:nil];
    }
}

@end

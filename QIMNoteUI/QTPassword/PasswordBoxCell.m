//
//  PasswordBoxCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/19.
//
//
#if __has_include("STIMNoteManager.h")
#import "PasswordBoxCell.h"
#import "STIMNoteModel.h"
#import "STIMNoteUICommonFramework.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define NormalImage [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"PasswordBox_favorite_normal"]
#define FavoriteImage [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"PasswordBox_favorite_selected"]

@interface PasswordBoxCell ()
{
    BOOL _selected;
}

@property (nonatomic, strong) UIButton *favoriteView;

@property (nonatomic, strong) STIMNoteModel *model;

@property (nonatomic, strong) UIImageView *selectBtn;


@end

@implementation PasswordBoxCell

- (void)setSTIMNoteModel:(STIMNoteModel *)model {
    if (model != nil) {
        _model = model;
        [self refreshUI];
    }
}

- (UIImageView *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 24, 24)];
        [_selectBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"common_checkbox_no_44px"]];
        _selectBtn.centerY = self.contentView.centerY;
    }
    return _selectBtn;
}

- (UIButton *)favoriteView {
    if (!_favoriteView) {
        _favoriteView = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteView.frame = CGRectMake(SCREEN_WIDTH - 60, 0, 24, 24);
        [_favoriteView addTarget:self action:@selector(favoritePasswordBox:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _favoriteView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selected = NO;
        self.imageView.image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"explore_tab_passwordBox"];
    }
    return self;
}

- (void)favoritePasswordBox:(id)sender {
    STIMVerboseLog(@"%s", __func__);
    if (self.model.q_state == STIMNoteStateFavorite) {
        self.model.q_state = STIMNoteStateNormal;
        [self.favoriteView setImage:NormalImage forState:UIControlStateNormal];
    } else {
        self.model.q_state = STIMNoteStateFavorite;
        [self.favoriteView setImage:FavoriteImage forState:UIControlStateNormal];
    }
    [[STIMNoteManager sharedInstance] updateQTNoteMainItemStateWithModel:self.model];
}

- (void)refreshUI {
    if (self.isSelect) {
        [self.contentView addSubview:self.selectBtn];
    }
    if (self.model.q_state != STIMNoteStateBasket) {
        [self.contentView addSubview:self.favoriteView];
        self.favoriteView.centerY = self.contentView.centerY;
    }
    self.textLabel.text = self.model.q_title;
    if (self.model.q_state == STIMNoteStateFavorite) {
        [self.favoriteView setImage:FavoriteImage forState:UIControlStateNormal];
    } else {
        [self.favoriteView setImage:NormalImage forState:UIControlStateNormal];
    }
}

- (void)setCellSelected:(BOOL)selected {
    _selected = selected;
    [self.selectBtn setImage:selected ? [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"common_checkbox_yes_44px"] : [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"common_checkbox_no_44px"]];
}

- (BOOL)isCellSelected {
    return _selected;
}

@end
#endif

//
//  QIMRNDebugConfigVc.m
//  QIMUIKit
//
//  Created by lilu on 2019/5/27.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMRNDebugConfigVc.h"

@interface QIMRNDebugConfigVc ()

@property (nonatomic, strong) UILabel *opsRNLabel;
@property (nonatomic, strong) UITextView *opsRNTextView;

@property (nonatomic, strong) UILabel *searchRNLabel;
@property (nonatomic, strong) UITextView *searchRNTextView;

@property (nonatomic, strong) UILabel *qtalkRNLabel;
@property (nonatomic, strong) UITextView *qtalkRNTextView;

@end

@implementation QIMRNDebugConfigVc

- (UILabel *)opsRNLabel {
    if (!_opsRNLabel) {
        _opsRNLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_opsRNLabel setText:@"OPS RN调试地址"];
        [_opsRNLabel setBackgroundColor:[UIColor clearColor]];
        [_opsRNLabel setFont:[UIFont systemFontOfSize:14]];
        [_opsRNLabel setTextColor:[UIColor qunarTextGrayColor]];
        [_opsRNLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return _opsRNLabel;
}

- (UITextView *)opsRNTextView {
    if (!_opsRNTextView) {
        _opsRNTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        NSString *opsFoundRNDebugUrl = [[QIMKit sharedInstance] userObjectForKey:@"opsFoundRNDebugUrl"];
        _opsRNTextView.text = (opsFoundRNDebugUrl.length > 0) ? opsFoundRNDebugUrl : @"";
        _opsRNTextView.font = [UIFont systemFontOfSize:16];
        _opsRNTextView.textColor = [UIColor blackColor];
    }
    return _opsRNTextView;
}

- (UILabel *)searchRNLabel {
    if (!_searchRNLabel) {
        _searchRNLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_searchRNLabel setText:@"OPS RN搜索地址"];
        [_searchRNLabel setBackgroundColor:[UIColor clearColor]];
        [_searchRNLabel setFont:[UIFont systemFontOfSize:14]];
        [_searchRNLabel setTextColor:[UIColor qunarTextGrayColor]];
        [_searchRNLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return _searchRNLabel;
}

- (UITextView *)searchRNTextView {
    if (!_searchRNTextView) {
        _searchRNTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        NSString *qtalkSearchRNDebugUrl = [[QIMKit sharedInstance] userObjectForKey:@"qtalkSearchRNDebugUrl"];
        _searchRNTextView.text = (qtalkSearchRNDebugUrl.length > 0) ? qtalkSearchRNDebugUrl : @"";
        _searchRNTextView.font = [UIFont systemFontOfSize:16];
        _searchRNTextView.textColor = [UIColor blackColor];
    }
    return _searchRNTextView;
}

- (UILabel *)qtalkRNLabel {
    if (!_qtalkRNLabel) {
        _qtalkRNLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_qtalkRNLabel setText:@"QIMRN调试地址"];
        [_qtalkRNLabel setBackgroundColor:[UIColor clearColor]];
        [_qtalkRNLabel setFont:[UIFont systemFontOfSize:14]];
        [_qtalkRNLabel setTextColor:[UIColor qunarTextGrayColor]];
        [_qtalkRNLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return _qtalkRNLabel;
}

- (UITextView *)qtalkRNTextView {
    if (!_qtalkRNTextView) {
        _qtalkRNTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        NSString *qtalkFoundRNDebugUrl = [[QIMKit sharedInstance] userObjectForKey:@"qtalkFoundRNDebugUrl"];
        _qtalkRNTextView.text = (qtalkFoundRNDebugUrl.length > 0) ? qtalkFoundRNDebugUrl : @"";
        _qtalkRNTextView.font = [UIFont systemFontOfSize:16];
        _qtalkRNTextView.textColor = [UIColor blackColor];
    }
    return _qtalkRNTextView;
}

- (void)initNav {
    self.title = @"RN调试配置页面";
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Save"] style:UIBarButtonItemStylePlain target:self action:@selector(saverRNDebugConfig)];
    self.navigationItem.rightBarButtonItem = save;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    self.view.backgroundColor = [UIColor qtalkChatBgColor];
    [self.view addSubview:self.opsRNLabel];
    [self.opsRNLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
    }];
    [self.view addSubview:self.opsRNTextView];
    [self.opsRNTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.opsRNLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(80);
    }];
    
    [self.view addSubview:self.searchRNLabel];
    [self.searchRNLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.opsRNTextView.mas_bottom).mas_offset(25);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
    }];
    [self.view addSubview:self.searchRNTextView];
    [self.searchRNTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchRNLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(80);
    }];
    
    [self.view addSubview:self.qtalkRNLabel];
    [self.qtalkRNLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchRNTextView.mas_bottom).mas_offset(25);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
    }];
    [self.view addSubview:self.qtalkRNTextView];
    [self.qtalkRNTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.qtalkRNLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(80);
    }];
}

- (void)saverRNDebugConfig {
    [[QIMKit sharedInstance] setUserObject:self.opsRNTextView.text forKey:@"opsFoundRNDebugUrl"];
    [[QIMKit sharedInstance] setUserObject:self.searchRNTextView.text forKey:@"qtalkSearchRNDebugUrl"];
    [[QIMKit sharedInstance] setUserObject:self.qtalkRNTextView.text forKey:@"qtalkFoundRNDebugUrl"];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

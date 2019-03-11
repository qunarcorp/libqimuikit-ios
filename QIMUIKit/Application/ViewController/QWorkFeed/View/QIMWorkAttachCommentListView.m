//
//  QIMWorkAttachCommentListView.m
//  QIMUIKit
//
//  Created by lilu on 2019/3/11.
//

#import "QIMWorkAttachCommentListView.h"
#import "QIMWorkAttachCommentCell.h"
#import "QIMWorkCommentModel.h"

@interface QIMWorkAttachCommentListView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation QIMWorkAttachCommentListView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.attachCommentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = [self.attachCommentList objectAtIndex:indexPath.row];
    QIMVerboseLog(@"QIMWorkCommentModel *commentModel : %@", commentModel);
    QIMWorkAttachCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[QIMWorkAttachCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    [cell setLeftMargin:self.left];
    [cell setCommentModel:commentModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

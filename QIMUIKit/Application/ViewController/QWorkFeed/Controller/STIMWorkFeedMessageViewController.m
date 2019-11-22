//
//  STIMWorkFeedMessageViewController.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkFeedMessageViewController.h"
#import "STIMWorkMessageCell.h"
#import "STIMWorkNoticeMessageModel.h"
#import "STIMWorkMomentContentModel.h"
#import "STIMWorkFeedDetailViewController.h"
#import <YYModel/YYModel.h>
#import <MJRefresh/MJRefresh.h>

@interface STIMWorkFeedMessageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *messageTableView;

@property (nonatomic, strong) NSMutableArray *noticeMsgs;

@end

@implementation STIMWorkFeedMessageViewController

- (UITableView *)messageTableView {
    if (!_messageTableView) {
        _messageTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _messageTableView.delegate = self;
        _messageTableView.dataSource = self;
        _messageTableView.estimatedRowHeight = 0;
        _messageTableView.estimatedSectionHeaderHeight = 0;
        _messageTableView.estimatedSectionFooterHeight = 0;
        _messageTableView.backgroundColor = [UIColor stimDB_colorWithHex:0xf5f5f5 alpha:1.0];
        _messageTableView.tableFooterView = [UIView new];
        _messageTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _messageTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreNoticeMessages)];
        [_messageTableView.mj_footer setAutomaticallyHidden:YES];
    }
    return _messageTableView;
}

- (NSMutableArray *)noticeMsgs {
    if (!_noticeMsgs) {
        _noticeMsgs = [NSMutableArray arrayWithCapacity:3];
        NSArray *array = [[STIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(STIMWorkFeedNotifyTypeComment), @(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)] readState:0];
        for (NSDictionary *noticeMsgDict in array) {
            STIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
            [_noticeMsgs addObject:model];
        }
    }
    return _noticeMsgs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的消息";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor stimDB_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor stimDB_colorWithHex:0x333333]}];
    [self.view addSubview:self.messageTableView];
    STIMWorkNoticeMessageModel *noticeMsgModel = [self.noticeMsgs firstObject];
    if (noticeMsgModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [[STIMKit sharedInstance] updateLocalWorkNoticeMsgReadStateWithTime:noticeMsgModel.createTime];
            [[STIMKit sharedInstance] updateRemoteWorkNoticeMsgReadStateWithTime:noticeMsgModel.createTime];
            //设置驼圈消息已读
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyWorkNoticeMessage object:nil];
            });
        });
    } else {
        
    }
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMoreNoticeMessages {
    NSArray *moreNoticeMsgs = [[STIMKit sharedInstance] getWorkNoticeMessagesWithLimit:20 WithOffset:0 eventTypes:@[@(STIMWorkFeedNotifyTypeComment), @(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)] readState:0];
    if (moreNoticeMsgs.count > 0) {
        for (NSDictionary *noticeMsgDict in moreNoticeMsgs) {
            STIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
            [self.noticeMsgs addObject:model];
        }
        [self.messageTableView reloadData];
        [self.messageTableView.mj_footer endRefreshing];
    } else {
        [self.messageTableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (STIMWorkNoticeMessageModel *)getNoticeMessageModelWithDict:(NSDictionary *)modelDict {
    STIMWorkNoticeMessageModel *model = [STIMWorkNoticeMessageModel yy_modelWithDictionary:modelDict];
    NSLog(@"STIMWorkNoticeMessageModel *model : %@", model);
    return model;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.noticeMsgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkNoticeMessageModel *model = [self.noticeMsgs objectAtIndex:indexPath.row];
    STIMWorkMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:model.uuid];
    if (!cell) {
        cell = [[STIMWorkMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:model.uuid];
        [cell setNoticeMsgModel:model];
        cell.cellType = STIMWorkMomentCellTypeMyMessage;
        [cell setContentModel:[self getContentModelWithMomentUUId:model.postUUID]];
    }
    return cell;
}

- (STIMWorkMomentContentModel *)getContentModelWithMomentUUId:(NSString *)momentId {
    NSDictionary *momentDic = [[STIMKit sharedInstance] getWorkMomentWithMomentId:momentId];
    
    NSDictionary *contentModelDic = [[STIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    STIMWorkMomentContentModel *contentModel = [STIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    return contentModel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    STIMWorkNoticeMessageModel *model = [self.noticeMsgs objectAtIndex:indexPath.row];
    
    STIMWorkFeedDetailViewController *detailVc = [[STIMWorkFeedDetailViewController alloc] init];
    detailVc.momentId = model.postUUID;
    STIMVerboseLog(@"model.PostUUID : %@", model);
    [self.navigationController pushViewController:detailVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkNoticeMessageModel *model = [self.noticeMsgs objectAtIndex:indexPath.row];
    if (model.rowHeight < 115) {
        return 115;
    } else {
        return model.rowHeight;
    }
}

@end

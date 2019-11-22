//
//  STIMWorkFeedMessageView.m
//  STIMUIKit
//
//  Created by Kamil on 2019/5/15.
//

#import "STIMWorkFeedMessageView.h"
#import "STIMWorkNoticeMessageModel.h"
#import "STIMWorkMomentContentModel.h"
#import "STIMWorkFeedDetailViewController.h"
#import <YYModel/YYModel.h>
#import <MJRefresh/MJRefresh.h>
#import "UIApplication+STIMApplication.h"
#import "STIMWorkOwnerCamalNoDataView.h"

@interface STIMWorkFeedMessageView()
<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) id<STIMWorkFeedMessageViewDataSource> dataSource;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, assign) CGRect iFrame;
@property (nonatomic, assign) NSInteger viewTag;
@property (nonatomic, strong) STIMWorkOwnerCamalNoDataView * noDataView;
@end


@implementation STIMWorkFeedMessageView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(nonnull id<STIMWorkFeedMessageViewDataSource>)dataSource AndViewTag:(NSInteger)viewTag {
    self = [super initWithFrame:frame];
    if (self) {
        self.iFrame = frame;
        self.dataSource = dataSource;
        self.viewTag = viewTag;
        [self addSubview:self.messageTableView];
        [self.messageTableView addSubview:self.noDataView];
    }
    return self;
}

-(STIMWorkOwnerCamalNoDataView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[STIMWorkOwnerCamalNoDataView alloc]initWithFrame:CGRectMake(0, 0, self.iFrame.size.width, self.iFrame.size.height)];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

- (UITableView *)messageTableView {
    if (!_messageTableView) {
        _messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.iFrame.size.width, self.iFrame.size.height) style:UITableViewStylePlain];
        _messageTableView.dataSource = self;
        _messageTableView.delegate = self;
        _messageTableView.estimatedRowHeight = 0;
        _messageTableView.estimatedSectionHeaderHeight = 0;
        _messageTableView.estimatedSectionFooterHeight = 0;
        _messageTableView.backgroundColor = [UIColor stimDB_colorWithHex:0xf5f5f5 alpha:1.0];
        _messageTableView.tableFooterView = [UIView new];
        _messageTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _messageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(updateNewData)];
        _messageTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        [_messageTableView.mj_footer setAutomaticallyHidden:YES];
    }
    return _messageTableView;
}

- (NSMutableArray *)noticeMsgs {
    if (!_noticeMsgs) {
        _noticeMsgs = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray * mArr = [NSMutableArray array];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(qImWorkFeedMessageViewOriginDataSourceWithViewTag:)]) {
            [mArr addObjectsFromArray:[self.dataSource qImWorkFeedMessageViewOriginDataSourceWithViewTag:self.viewTag]];
        }
        for (NSDictionary *noticeMsgDict in mArr) {
            STIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
            [_noticeMsgs addObject:model];
        }
    }
    return _noticeMsgs;
}

- (void)loadMoreNoticeMessages {
    
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
    STIMWorkMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@-%ld", model.uuid, model.eventType]];
    if (!cell) {
        cell = [[STIMWorkMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"%@-%ld", model.uuid, model.eventType]];
    }
    cell.cellType = self.messageCellType;
    [cell setNoticeMsgModel:model];
    [cell setContentModel:[self getContentModelWithMomentUUId:model.postUUID]];
    return cell;
}

- (STIMWorkMomentContentModel *)getContentModelWithMomentUUId:(NSString *)momentId {
    NSMutableDictionary * momentDic = [NSMutableDictionary dictionary];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(qImWorkFeedMessageViewModelWithMomentPostUUID:viewTag:)]) {
        [momentDic setDictionary:[self.dataSource qImWorkFeedMessageViewModelWithMomentPostUUID:momentId viewTag:self.viewTag]];
    }
    
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
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[STIMFastEntrance sharedInstance] getSTIMFastEntranceRootNav];
    }
    [navVC pushViewController:detailVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkNoticeMessageModel *model = [self.noticeMsgs objectAtIndex:indexPath.row];
    if (model.rowHeight < 115) {
        return 115;
    } else {
        return model.rowHeight;
    }
}

- (void)updateNewData{
    __weak typeof(self) weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(qImWorkFeedMessageViewLoadNewDataWithNewTag:finishBlock:)]) {
        [self.delegate qImWorkFeedMessageViewLoadNewDataWithNewTag:self.viewTag finishBlock:^(NSArray * _Nonnull arr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (arr && arr.count > 0) {
                    [weakSelf.noticeMsgs removeAllObjects];
                    for (NSDictionary *noticeMsgDict in arr) {
                        STIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
                        if (model.fromUser) {
                            model.userFrom = model.fromUser;
                        }
                        [weakSelf.noticeMsgs addObject:model];
                    }
                    if (weakSelf.noDataView.hidden == NO) {
                        weakSelf.noDataView.hidden = YES;
                    }
                    [weakSelf.messageTableView reloadData];
                } else {
                    if (weakSelf.noDataView.hidden == YES && weakSelf.noticeMsgs.count == 0) {
                        weakSelf.noDataView.hidden = NO;
                    }
                }
                [weakSelf.messageTableView.mj_header endRefreshing];
            });
        }];
    }
    

}

-(void)loadMoreData{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(qImWorkFeedMessageViewMoreDataSourceWithviewTag:finishBlock:)]) {
        [self.delegate qImWorkFeedMessageViewMoreDataSourceWithviewTag:self.viewTag finishBlock:^(NSArray * _Nonnull arr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (arr.count>0) {
                    for (NSDictionary *noticeMsgDict in arr) {
                        STIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
                        if (model.fromUser) {
                            model.userFrom = model.fromUser;
                        }
                        [self.noticeMsgs addObject:model];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageTableView reloadData];
                        [self.messageTableView.mj_footer endRefreshing];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageTableView.mj_footer endRefreshingWithNoMoreData];
                        if (self.noDataView.hidden == YES && self.noticeMsgs.count == 0) {
                            self.noDataView.hidden = NO;
                        }
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.noDataView.hidden == NO) {
                        self.noDataView.hidden = YES;
                    }
                    [self.messageTableView reloadData];
                });
            });
        }];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

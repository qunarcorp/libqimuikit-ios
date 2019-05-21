//
//  QIMWorkFeedMessageView.m
//  QIMUIKit
//
//  Created by Kamil on 2019/5/15.
//

#import "QIMWorkFeedMessageView.h"
#import "QIMWorkMessageCell.h"
#import "QIMWorkNoticeMessageModel.h"
#import "QIMWorkMomentContentModel.h"
#import "QIMWorkFeedDetailViewController.h"
#import <YYModel/YYModel.h>
#import <MJRefresh/MJRefresh.h>
#import "UIApplication+QIMApplication.h"
#import "QIMWorkOwnerCamalNoDataView.h"

@interface QIMWorkFeedMessageView()
<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) id<QIMWorkFeedMessageViewDataSource> dataSource;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, assign) CGRect iFrame;
@property (nonatomic, assign) NSInteger viewTag;
@property (nonatomic, strong) QIMWorkOwnerCamalNoDataView * noDataView;
@end


@implementation QIMWorkFeedMessageView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(nonnull id<QIMWorkFeedMessageViewDataSource>)dataSource AndViewTag:(NSInteger)viewTag {
    self = [super initWithFrame:frame];
    if (self) {
        self.iFrame = frame;
        self.dataSource = dataSource;
        self.viewTag = viewTag;
        [self addSubview:self.messageTableView];
        QIMWorkNoticeMessageModel *noticeMsgModel = [self.noticeMsgs firstObject];
    }
    return self;
}

-(QIMWorkOwnerCamalNoDataView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[QIMWorkOwnerCamalNoDataView alloc]initWithFrame:self.frame];
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
        _messageTableView.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0];
        _messageTableView.tableFooterView = [UIView new];
        _messageTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
            QIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
            [_noticeMsgs addObject:model];
        }
    }
    return _noticeMsgs;
}

- (void)loadMoreNoticeMessages {
    
}

- (QIMWorkNoticeMessageModel *)getNoticeMessageModelWithDict:(NSDictionary *)modelDict {
    QIMWorkNoticeMessageModel *model = [QIMWorkNoticeMessageModel yy_modelWithDictionary:modelDict];
    NSLog(@"QIMWorkNoticeMessageModel *model : %@", model);
    return model;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.noticeMsgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkNoticeMessageModel *model = [self.noticeMsgs objectAtIndex:indexPath.row];
    QIMWorkMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:model.uuid];
    if (!cell) {
        cell = [[QIMWorkMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:model.uuid];
        [cell setNoticeMsgModel:model];
        [cell setContentModel:[self getContentModelWithMomentUUId:model.postUUID]];
    }
    return cell;
}

- (QIMWorkMomentContentModel *)getContentModelWithMomentUUId:(NSString *)momentId {
    NSMutableDictionary * momentDic = [NSMutableDictionary dictionary];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(qImWorkFeedMessageViewModelWithMomentPostUUID:viewTag:)]) {
        [momentDic setDictionary:[self.dataSource qImWorkFeedMessageViewModelWithMomentPostUUID:momentId viewTag:self.viewTag]];
    }
    
    NSDictionary *contentModelDic = [[QIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    QIMWorkMomentContentModel *contentModel = [QIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    return contentModel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QIMWorkNoticeMessageModel *model = [self.noticeMsgs objectAtIndex:indexPath.row];
    
    QIMWorkFeedDetailViewController *detailVc = [[QIMWorkFeedDetailViewController alloc] init];
    detailVc.momentId = model.postUUID;
    QIMVerboseLog(@"model.PostUUID : %@", model);
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
    }
    [navVC pushViewController:detailVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkNoticeMessageModel *model = [self.noticeMsgs objectAtIndex:indexPath.row];
    return 115;
}

-(void)loadMoreData{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(qImWorkFeedMessageViewMoreDataSourceWithviewTag:finishBlock:)]) {
        [self.delegate qImWorkFeedMessageViewMoreDataSourceWithviewTag:self.viewTag finishBlock:^(NSArray * _Nonnull arr) {
            if (arr.count>0) {
                for (NSDictionary *noticeMsgDict in arr) {
                    QIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
                    [self.noticeMsgs addObject:model];
                }
                [self.messageTableView reloadData];
                [self.messageTableView.mj_footer endRefreshing];
            }
            else {
                [self.messageTableView.mj_footer endRefreshingWithNoMoreData];
                if (self.noticeMsgs.count == 0) {
                    [self addSubview:self.noDataView];
                }
            }
            [self.messageTableView reloadData];
        }];
    }

}

-(void)updateDataWith:(NSArray *)dataArr{
    if (dataArr && dataArr.count > 0) {
        [self.noticeMsgs removeAllObjects];
        for (NSDictionary *noticeMsgDict in dataArr) {
            QIMWorkNoticeMessageModel *model = [self getNoticeMessageModelWithDict:noticeMsgDict];
            [self.noticeMsgs addObject:model];
        }
        [self.messageTableView reloadData];
        [self.messageTableView.mj_footer endRefreshing];
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

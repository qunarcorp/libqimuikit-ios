//
//  QIMWorkMomentHotTopicViewController.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/12/23.
//

#import "QIMWorkMomentHotTopicViewController.h"
#import "QIMImageUtil.h"
#import "UIImage+QIMIconFont.h"
#import <YYModel/YYModel.h>
#import <MJRefresh/MJRefresh.h>
#import "QIMWorkMomentHotTopicTableViewCell.h"
#import "QIMWorkMomentHotTopicModel.h"
#import "QIMWorkFeedDetailViewController.h"
#import "QIMWorkOwnerCamalNoDataView.h"
#import "QIMAutoTracker.h"


@interface QIMWorkMomentHotTopicViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView * tableView;
@property (nonatomic ,strong) NSMutableArray * dataArr;
@property (nonatomic , assign) NSInteger  page;
@property (nonatomic , strong) UIButton * moreHotPageBtn;
@property (nonatomic , strong) QIMWorkOwnerCamalNoDataView * noDataView;


@end

@implementation QIMWorkMomentHotTopicViewController

- (void)viewDidLoad {
    self.dataArr = [NSMutableArray array];
    [super viewDidLoad];
    self.page = 1;
    [self setUpTableView];
    [self requestNetWorkWithpageSize:@(5)];
    [self addLoadMorehotFooterPageView];
    // Do any additional setup after loading the view.
}

- (void)requestNetWorkWithpageSize:(NSNumber *)pageSize{
    
    __weak typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] getMomentTopicTagHeaderWithCurPage:@(self.page) pageSize:pageSize beginTime:nil endTime:nil withCallBack:^(NSArray *moments) {
        if (self.page == 1) {
            [self.dataArr removeAllObjects];
        }
        
        for (NSDictionary * dic in moments) {
            QIMWorkMomentHotTopicModel * model = [QIMWorkMomentHotTopicModel yy_modelWithDictionary:dic];
            [self.dataArr addObject:model];
        }
        
        if (moments.count == 0 || moments == nil) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else{
            [self.tableView.mj_footer endRefreshing];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

-(void)addLoadMorehotFooterPageView{
    
    UIView * footerBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
    footerBGView.backgroundColor = [UIColor whiteColor];
    self.moreHotPageBtn = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH -113)/2, 12, 113, 24)];
    [self.moreHotPageBtn setImage:[UIImage qim_imageNamedFromQIMUIKitBundle:@"showLoadMore"] forState:UIControlStateNormal];
//    self.moreHotPageBtn.backgroundColor = [UIColor redColor];
    [self.moreHotPageBtn addTarget:self action:@selector(showMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerBGView addSubview:self.moreHotPageBtn];
    self.tableView.tableFooterView = footerBGView;
}

- (void)showMoreBtnClick:(UIButton *)btn{
    [[QIMAutoTrackerManager sharedInstance] addACTTrackerDataWithEventId:@"04010101" withDescription:@"查看更多热帖"];
    
    self.page = 1;
    [self requestNetWorkWithpageSize:@(20)];
    _tableView.tableFooterView = nil;
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreHotTopic)];
    [_tableView reloadData];
//    _tableView.mj_footer.automaticallyHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor qim_colorWithHex:0xF7F7F7];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"热帖榜";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor qim_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
}


- (void)setUpTableView{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
   _tableView.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];//f8f8f8
   _tableView.delegate = self;
   _tableView.dataSource = self;
   _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;//0_tableView
   CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
   _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
   _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
   _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
   _tableView.separatorColor = [UIColor qim_colorWithHex:0xdddddd];
    [self.view addSubview:self.tableView];
}

- (void)backBtnClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMoreHotTopic{
    self.page ++;
    [self requestNetWorkWithpageSize:@(20)];
}

#pragma mark -TableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMWorkMomentHotTopicModel * model = self.dataArr[indexPath.row];
    if (model.height > 0) {
        return model.height;
    }
    else{
        return 100;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMWorkMomentHotTopicModel * model = self.dataArr[indexPath.row];
    QIMWorkMomentHotTopicTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"hottopic"];
    if (!cell) {
        cell = [[QIMWorkMomentHotTopicTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hottopic"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    }
    model.headerNub = @(indexPath.row + 1);
    if (indexPath.row <5) {
        model.showNumber = YES;
    }
    else
    {
        model.showNumber = NO;
    }
    if (model.headImg && model.headImg.length > 0) {
        model.showImg = YES;
    }
    else{
        model.showImg = NO;
    }
    [cell setHotTopicModel:model];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMWorkMomentHotTopicModel * model = self.dataArr[indexPath.row];
    QIMWorkFeedDetailViewController * vc = [[QIMWorkFeedDetailViewController alloc]init];
    vc.momentId = model.postUid;
    [self.navigationController pushViewController:vc animated:YES];
}

//-(QIMWorkOwnerCamalNoDataView *)noDataView{
//    if (!_noDataView) {
//        _noDataView = [[QIMWorkOwnerCamalNoDataView alloc]initWithFrame:CGRectMake(0, 0, self.iFrame.size.width, self.iFrame.size.height)];
//        _noDataView.hidden = YES;
//    }
//    return _noDataView;
//}


@end

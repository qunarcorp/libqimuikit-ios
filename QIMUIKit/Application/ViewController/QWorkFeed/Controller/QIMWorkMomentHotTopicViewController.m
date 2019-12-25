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

@interface QIMWorkMomentHotTopicViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView * tableView;
@property (nonatomic ,strong) NSMutableArray * dataArr;
@property (nonatomic , assign) NSInteger  page;

@end

@implementation QIMWorkMomentHotTopicViewController

- (void)viewDidLoad {
    self.dataArr = [NSMutableArray array];
    [super viewDidLoad];
    self.page = 1;
    [self setUpTableView];
    [self requestNetWork];

    // Do any additional setup after loading the view.
}

- (void)requestNetWork{
    
    __weak typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] getMomentTopicTagHeaderWithCurPage:@(self.page) pageSize:@(20) beginTime:nil endTime:nil withCallBack:^(NSArray *moments) {
        if (self.page == 1) {
            [self.dataArr removeAllObjects];
        }
        for (NSDictionary * dic in moments) {
            QIMWorkMomentHotTopicModel * model = [QIMWorkMomentHotTopicModel yy_modelWithDictionary:dic];
            [self.dataArr addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
        });
    }];
    
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
   _tableView.backgroundColor = [UIColor qim_colorWithHex:0xf8f8f8];
   _tableView.delegate = self;
   _tableView.dataSource = self;
   _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;//0_tableView
   CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
   _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
   _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
   _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
   _tableView.separatorColor = [UIColor qim_colorWithHex:0xdddddd];
   
   _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHotTopic)];
   _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreHotTopic)];
   _tableView.mj_footer.automaticallyHidden = YES;
    [self.view addSubview:self.tableView];
}

- (void)backBtnClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMoreHotTopic{
    self.page ++;
    [self requestNetWork];
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)refreshHotTopic{
    self.page = 1;
    [self requestNetWork];
    [self.tableView.mj_header endRefreshing];
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
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell = [[QIMWorkMomentHotTopicTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hottopic"];
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

@end

//
//  QIMWorkMomentTagViewController.m
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/18.
//

#import "QIMWorkMomentTagViewController.h"
#import "QIMWorkMomentTagListTableViewCell.h"
#import "QIMWorkMomentTopicListModel.h"
#import <YYModel/YYModel.h>
#import "QIMWorkMomentTagModel.h"
#import "QIMWorkFeedTagCirrleViewController.h"
#import "QTalkTipsView.h"
#import "QIMUserCacheManager.h"

@interface QIMWorkMomentTagViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) NSMutableArray * dataArr;
@property (nonatomic , strong) NSMutableArray * wulalalla;

@property (nonatomic , strong) NSMutableArray * mySelectArr;
@property (nonatomic , strong) UITableView * tableView;
@property (nonatomic , strong) UIButton * pushBtn;
@end

@implementation QIMWorkMomentTagViewController


-(instancetype)initWithSelectArr:(NSMutableArray *)arr{
    if (self=[super init]) {
        self.mySelectArr = [NSMutableArray array];
        [self.mySelectArr addObjectsFromArray:[arr mutableCopy]];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.wulalalla =  [NSMutableArray array];
    self.dataArr = [NSMutableArray array];
    
    [self setUpNav];
    [self initUI];
    [self beginRequest];
}

- (UIButton *)pushBtn {
    if (!_pushBtn) {
        _pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pushBtn setFrame:CGRectMake(0, 0, 36, 18)];
        [_pushBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_pushBtn setTitleColor:[UIColor qim_colorWithHex:0xBFBFBF] forState:UIControlStateDisabled];
        [_pushBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_pushBtn addTarget:self action:@selector(finishSelectTagClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushBtn;
}

- (void)finishSelectTagClicked:(UIButton *)btn{
//    NSMutableArray * selectedArr = [NSMutableArray array];
//    for (QIMWorkMomentTopicListModel * listModel in self.dataArr) {
//        [selectedArr addObjectsFromArray:listModel.selectArr];
//    }
    if (self.block) {
        self.block(self.mySelectArr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpNav{
    if (self.headerTitle && self.headerTitle.length>0) {
        self.navigationItem.title = self.headerTitle;
    }
    else{
        self.navigationItem.title = @"选择标签";
        UIBarButtonItem *newMomentBtn = [[UIBarButtonItem alloc] initWithCustomView:self.pushBtn];
           [[self navigationItem] setRightBarButtonItem:newMomentBtn];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x333333]}];
}

- (void)initUI{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMWorkMomentTopicListModel * model = [self.dataArr objectAtIndex:indexPath.row];
    [model.selectArr removeAllObjects];

    for (QIMWorkMomentTagModel * tagModel in model.tagList) {
        for (QIMWorkMomentTagModel * selectModel in self.mySelectArr) {
            if (tagModel.tagId.integerValue == selectModel.tagId.integerValue) {
                QIMWorkMomentTagModel * sModel = [[QIMWorkMomentTagModel alloc]init];
                sModel.tagId = selectModel.tagId;
                sModel.tagTitle = selectModel.tagTitle;
                sModel.tagColor = selectModel.tagColor;
                sModel.selected = YES;
                [model.selectArr addObject:sModel];
            }
            else{
                selectModel.selected = NO;
            }
        }
    }
    QIMWorkMomentTagListTableViewCell * cell =  [[QIMWorkMomentTagListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lalalal"];
//    }
    [cell setSelectBlock:^(QIMWorkMomentTagModel *model) {
        if (self.canMutiSelected == YES) {
            
            if (self.mySelectArr.count >=5) {
                model.selected = NO;
                [self showSelectedMessage];
                [self.tableView reloadData];
            }
            else{
                model.selected = YES;
                [self.mySelectArr addObject:model];
            }
        }
        else{
            QIMWorkFeedTagCirrleViewController * vc = [[QIMWorkFeedTagCirrleViewController alloc]init];
            vc.tagId = model.tagId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    [cell setRemoveBlock:^(QIMWorkMomentTagModel *model) {
        for (QIMWorkMomentTagModel * tmodel in self.mySelectArr) {
            if (tmodel.tagId.intValue == model.tagId.intValue) {
                [self.mySelectArr removeObject:tmodel];
                break;
            }
        }
    }];
    cell.canMutiSelected = self.canMutiSelected;
    [cell setModel:model];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMWorkMomentTopicListModel * model = [self.dataArr objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (void)beginRequest{
    
    if ([[QIMUserCacheManager sharedInstance] containsObjectForKey:@"workMomentTag"]) {
        NSArray * arr = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"workMomentTag"];
        for (NSDictionary * dic in arr) {
             QIMWorkMomentTopicListModel * model = [QIMWorkMomentTopicListModel yy_modelWithDictionary:dic];
            [self.dataArr addObject:model];
        }
    }
    else{
        [[QIMKit sharedInstance] getMomentTagListWithCompleteCallBack:^(NSArray *moments) {
            for (NSDictionary * dic in moments) {
                 QIMWorkMomentTopicListModel * model = [QIMWorkMomentTopicListModel yy_modelWithDictionary:dic];
                [self.dataArr addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

- (void)setSelectArrFromPushView:(NSMutableArray *)arr{
    [self.mySelectArr addObjectsFromArray:arr];
}

- (void)showSelectedMessage{

    [QTalkTipsView showTips:[NSString stringWithFormat:@"一个帖子最多可选5个话题"] InView:self.view];
}
/*
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

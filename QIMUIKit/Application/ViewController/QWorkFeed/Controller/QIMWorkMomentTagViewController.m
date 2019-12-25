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

@interface QIMWorkMomentTagViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) NSMutableArray * dataArr;
@property (nonatomic , strong) NSMutableArray * wulalalla;
@property (nonatomic , strong) UITableView * tableView;
@property (nonatomic , strong) UIButton * pushBtn;
@end

@implementation QIMWorkMomentTagViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.wulalalla =  [NSMutableArray array];
//    [self.wulalalla addObjectsFromArray:arr];
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
    NSMutableArray * selectedArr = [NSMutableArray array];
    for (QIMWorkMomentTopicListModel * listModel in self.dataArr) {
        [selectedArr addObjectsFromArray:listModel.selectArr];
    }
    if (self.block) {
        self.block(selectedArr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpNav{
    if (self.title && self.title.length>0) {
        self.navigationItem.title = self.title;
    }
    else{
        self.navigationItem.title = @"选择标签";
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x333333]}];
    
    UIBarButtonItem *newMomentBtn = [[UIBarButtonItem alloc] initWithCustomView:self.pushBtn];
    [[self navigationItem] setRightBarButtonItem:newMomentBtn];
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
    for (QIMWorkMomentTagModel * tagModel in model.selectArr) {
        for (QIMWorkMomentTagModel * selectModel in self.wulalalla) {
            if (tagModel.tagId.integerValue == selectModel.tagId.integerValue) {
                tagModel.selected = YES;
            }
            else{
                tagModel.selected = NO;
            }
        }
    }
    QIMWorkMomentTagListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"lalalal"];
#pragma mark- 跳到带颜色的vc
    
    if (cell == nil) {
        cell = [[QIMWorkMomentTagListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lalalal"];
    }
    [cell setSelectBlock:^(QIMWorkMomentTagModel *model) {
        QIMWorkFeedTagCirrleViewController * vc = [[QIMWorkFeedTagCirrleViewController alloc]init];
        vc.tagId = model.tagId;
        [self.navigationController pushViewController:vc animated:YES];
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

- (void)setSelectArrFromPushView:(NSMutableArray *)arr{
    [self.wulalalla addObjectsFromArray:arr];
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

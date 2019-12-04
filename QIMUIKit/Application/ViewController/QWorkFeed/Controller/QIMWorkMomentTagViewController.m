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
@interface QIMWorkMomentTagViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) NSMutableArray * dataArr;
@property (nonatomic , strong) UITableView * tableView;
@property (nonatomic , strong) NSMutableArray * selectArr;
@end

@implementation QIMWorkMomentTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr =  [NSMutableArray array];
    [self initUI];
    [self beginRequest];
    
    NSDictionary * data = @{
                            @"topicId":@"我是ID",
                            @"topicTitle":@"我是标题",
                            @"tagList":@[@{@"tagId":@"我是ID",
                                           @"tagTitle":@"我是tag",
                                           @"tagColor":@"0xfffff"
                                           },
                                         @{@"tagId":@"我是ID",
                                           @"tagTitle":@"我是tag",
                                           @"tagColor":@"0xfffff"
                                           },
                                         @{@"tagId":@"我是ID",
                                           @"tagTitle":@"我是tag",
                                           @"tagColor":@"0xfffff"
                                           },
                                         @{@"tagId":@"我是ID",
                                           @"tagTitle":@"我是tag",
                                           @"tagColor":@"0xfffff"
                                           },
                                         @{@"tagId":@"我是ID",
                                           @"tagTitle":@"我是tag",
                                           @"tagColor":@"0xfffff"
                                           }
                                         ]
                            };
    QIMWorkMomentTopicListModel * model = [QIMWorkMomentTopicListModel yy_modelWithDictionary:data];
    
    QIMWorkMomentTopicListModel * model1 = [QIMWorkMomentTopicListModel yy_modelWithDictionary:data];
    [self.dataArr addObject:model];
    [self.dataArr addObject:model1];
    
    // Do any additional setup after loading the view.
}

- (void)initUI{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    QIMWorkMomentTagListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"lalalal"];
    if (cell == nil) {
        cell = [[QIMWorkMomentTagListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lalalal"];
    }
    [cell setModel:model];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMWorkMomentTopicListModel * model = [self.dataArr objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (void)beginRequest{

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

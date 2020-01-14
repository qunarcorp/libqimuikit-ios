//
//  STIMDefaultChatBGImageSelectController.m
//  STChatIphone
//
//  Created by haibin.li on 15/7/17.
//
//

#import "STIMDefaultChatBGImageSelectController.h"
#import "STIMChatBGImageDisplayCell.h"

@interface STIMDefaultChatBGImageSelectController ()<UITableViewDataSource,UITableViewDelegate,STIMChatBGImageDisplayCellDelegate>
{
    UITableView         * _mainTableView;
    NSMutableDictionary * _chatBgDic;
}

@end

@implementation STIMDefaultChatBGImageSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"系统自带背景图";
    _chatBgDic = [NSMutableDictionary dictionary];
    [self initMainTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initMainTableView
{
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.width, self.view.height) style:UITableViewStylePlain];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.backgroundColor = [UIColor whiteColor];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    [self.view addSubview:_mainTableView];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"cell";
    STIMChatBGImageDisplayCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[STIMChatBGImageDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    NSMutableArray * images = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < 3; i ++) {
        NSString *imageName =
        [NSString stringWithFormat:@"chatBGImage_%@.jpg",@(indexPath.row * 3 + i)];
        UIImage * image = [_chatBgDic objectForKey:imageName];
        if (image == nil) {
            image = [UIImage stimDB_imageNamedFromSTIMUIKitBundle:imageName];
            if (image) {
                UIGraphicsBeginImageContextWithOptions([STIMChatBGImageDisplayCell getImageSize], NO, [UIScreen mainScreen].scale);
                [image drawInRect:CGRectMake(0, 0, [STIMChatBGImageDisplayCell getImageSize].width, [STIMChatBGImageDisplayCell getImageSize].height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [_chatBgDic setObject:image forKey:imageName];
            }
        }
        if (image) {
            [images addObject:image];
        }else{
            [images addObject:@"noImage"];
        }
    }
    [cell setImages:images];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((tableView.width - (3 + 1) * 10) / 3) / [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.height + 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - STIMChatBGImageDisplayCellDelegate

-(void)imageDisplayCell:(STIMChatBGImageDisplayCell *)cell didSelectedImageAtIndex:(NSInteger )index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(defaultSTIMChatBGImageSelectController:willPopWithImage:)]) {
        [self.delegate defaultSTIMChatBGImageSelectController:self willPopWithImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:[NSString stringWithFormat:@"chatBGImage_%@.jpg",@([_mainTableView indexPathForCell:cell].row * 3 + index)]]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end

//
//  STIMGroupChangeNameVC.m
//  STChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "STIMGroupChangeNameVC.h"
#import "NSBundle+STIMLibrary.h"
#import "STIMViewHelper.h"

@interface STIMGroupChangeNameVC ()<UITextFieldDelegate>{
    UITextField *_textField;
}

@end

@implementation STIMGroupChangeNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    [self.navigationItem setTitle:[NSBundle stimDB_localizedStringForKey:@"group_update_name"]];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"common_save"] style:UIBarButtonItemStylePlain target:self action:@selector(onSaveGroupName)];
    [self.navigationItem setRightBarButtonItem:rightBarItem];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0,20, self.view.width, 30)];
    [_textField setClearButtonMode:UITextFieldViewModeAlways];
    [_textField setBackgroundColor:[UIColor whiteColor]];
    [_textField setKeyboardType:UIKeyboardTypeDefault];
    [_textField setTextColor:[UIColor blackColor]];
    [_textField setText:self.groupName];
    [_textField setReturnKeyType:UIReturnKeyDone];
    [_textField setFont:[UIFont fontWithName:FONT_NAME size:14]];
    [_textField setDelegate:self];
    [STIMViewHelper setTextFieldLeftView:_textField];
    [_textField setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:_textField];

    [_textField becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)onSaveGroupName{
    if (_textField.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"请输入要修改的群名称" delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (![self.groupName isEqualToString:_textField.text]) {
        [[STIMKit sharedInstance] setMucVcardForGroupId:self.groupId WithNickName:_textField.text WithTitle:nil WithDesc:nil WithHeaderSrc:nil withCallBack:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end

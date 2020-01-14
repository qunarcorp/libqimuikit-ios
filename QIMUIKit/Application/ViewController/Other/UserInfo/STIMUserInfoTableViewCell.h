//
//  STIMUserInfoTableViewCell.h
//  STChatIphone
//
//  Created by qitmac000301 on 15/3/24.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@protocol STIMUserInfoTableViewCellDelegate <NSObject>
@optional
- (void)onUserHeaderClick;
@end

@interface STIMUserInfoTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic, weak)   id<STIMUserInfoTableViewCellDelegate> delegate;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *nameTitle;
@property (nonatomic, retain) UITextField *nameLabel;
@property (nonatomic, retain) UILabel *IDLabelTitle;
@property (nonatomic, retain) UILabel *IDLabel;
@property (nonatomic, retain) UILabel *departmentLabel;
@property (nonatomic, retain) UILabel *departmentTitle;
@end
